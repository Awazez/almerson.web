// ==============================================================
//  Endpoint  : POST /api/inventory
//  Auteur    : Martin AUBEUT - Almerson (www.almerson.com)
//  Desc      : Reçoit l'inventaire WMI du script PowerShell et
//              pousse les données dans GLPI via l'API REST.
//              Les credentials GLPI restent côté serveur (Vercel).
// ==============================================================

import https from 'node:https'
import http  from 'node:http'

// ── HTTP bas niveau ─────────────────────────────────────────────
function request(method: string, urlStr: string, headers: Record<string, string>, body: unknown) {
  return new Promise<any>((resolve, reject) => {
    const u       = new URL(urlStr)
    const bodyStr = body ? JSON.stringify(body) : null
    const lib     = u.protocol === 'https:' ? https : http
    const opts    = {
      hostname : u.hostname,
      port     : u.port || (u.protocol === 'https:' ? 443 : 80),
      path     : u.pathname + u.search,
      method,
      headers  : {
        ...headers,
        ...(bodyStr ? { 'Content-Length': String(Buffer.byteLength(bodyStr)) } : {})
      }
    }
    const req = lib.request(opts, res => {
      let data = ''
      res.on('data', (c: string) => data += c)
      res.on('end', () => {
        try   { resolve(JSON.parse(data)) }
        catch { resolve(data) }
      })
    })
    req.on('error', reject)
    if (bodyStr) req.write(bodyStr)
    req.end()
  })
}

// ── Helpers GLPI ────────────────────────────────────────────────
function glpiEndpoint(endpoint: string, query: Record<string, string> = {}) {
  const u = new URL(`${process.env.GLPI_URL}/${endpoint}`)
  for (const [k, v] of Object.entries(query)) u.searchParams.set(k, v)
  return u.toString()
}

function glpiHeaders(tok?: string) {
  const h: Record<string, string> = {
    'App-Token'    : process.env.GLPI_APP_TOKEN ?? '',
    'Content-Type' : 'application/json'
  }
  if (tok) h['Session-Token'] = tok
  return h
}

const glpiGet    = (ep: string, tok: string, q: Record<string, string> = {}) => request('GET',    glpiEndpoint(ep, q), glpiHeaders(tok), null)
const glpiPost   = (ep: string, tok: string, b: unknown)                      => request('POST',   glpiEndpoint(ep),    glpiHeaders(tok), b)
const glpiPut    = (ep: string, tok: string, b: unknown)                      => request('PUT',    glpiEndpoint(ep),    glpiHeaders(tok), b)
const glpiDelete = (ep: string, tok: string)                                  => request('DELETE', glpiEndpoint(ep),    glpiHeaders(tok), null)

function normalizeItems(data: any) {
  if (Array.isArray(data))  return data
  if (data?.data)           return ([] as any[]).concat(data.data)
  if (data?.id)             return [data]
  return []
}

async function resolveDropdown(itemType: string, name: string, tok: string) {
  if (!name) return 0
  const found = await glpiGet(itemType, tok, { 'searchText[name]': name, range: '0-1' })
  const items = normalizeItems(found)
  if (items.length > 0) return parseInt(items[0].id)
  const created = await glpiPost(itemType, tok, { input: { name } })
  return parseInt(created?.id) || 0
}

async function resolveDevice(deviceType: string, designation: string, extra: Record<string, unknown>, tok: string) {
  if (!designation) return 0
  const found = await glpiGet(deviceType, tok, { 'searchText[designation]': designation, range: '0-1' })
  const items = normalizeItems(found)
  if (items.length > 0) return parseInt(items[0].id)
  const created = await glpiPost(deviceType, tok, { input: { designation, ...extra } })
  return parseInt(created?.id) || 0
}

async function clearLinks(linkType: string, computerId: number, tok: string) {
  const existing = await glpiGet(linkType, tok, {
    'searchText[items_id]' : String(computerId),
    'searchText[itemtype]' : 'Computer',
    range                  : '0-50'
  })
  const items = normalizeItems(existing)
  await Promise.all(items.map((item: any) => {
    const id = item.id || item['2']
    return id ? glpiDelete(`${linkType}/${id}`, tok) : null
  }))
}

function getDdrLabel(smbiosType: number, memType: number, capacityBytes: number, speed: number) {
  const smbiosMap: Record<number, string> = { 20: 'DDR', 21: 'DDR2', 24: 'DDR3', 26: 'DDR4', 34: 'DDR5' }
  const memMap: Record<number, string>    = { 20: 'DDR', 21: 'DDR2', 22: 'DDR3' }
  const gen       = smbiosMap[smbiosType] || memMap[memType] || ''
  const gb        = Math.round(capacityBytes / 1073741824)
  let label       = `${gb}GB`
  if (speed) label += ` @${speed}MHz`
  if (gen)   label += ` ${gen}`
  return label
}

const mfgCache: Record<string, number> = {}
async function resolveManufacturerCached(publisher: string, tok: string) {
  if (!publisher) return 0
  if (mfgCache[publisher] !== undefined) return mfgCache[publisher]
  const id = await resolveDropdown('Manufacturer', publisher, tok)
  mfgCache[publisher] = id
  return id
}

async function resolveSoftwareVersion(name: string, version: string, publisher: string, tok: string) {
  const swFound = await glpiGet('Software', tok, { 'searchText[name]': name, range: '0-1' })
  const swItems = normalizeItems(swFound)
  let swId: number
  if (swItems.length > 0) {
    swId = parseInt(swItems[0].id)
  } else {
    const mfgId   = await resolveManufacturerCached(publisher, tok)
    const created = await glpiPost('Software', tok, {
      input: { name, manufacturers_id: mfgId, is_dynamic: 1 }
    })
    swId = parseInt(created?.id) || 0
  }
  if (!swId) return 0

  const versionName = version || 'N/A'
  const svCreated = await glpiPost('SoftwareVersion', tok, {
    input: { name: versionName, softwares_id: swId, is_dynamic: 1 }
  })
  if (svCreated?.id) return parseInt(svCreated.id)

  const svFound = await glpiGet('SoftwareVersion', tok, {
    'searchText[name]' : versionName,
    range              : '0-50'
  })
  const match = normalizeItems(svFound).find((sv: any) =>
    parseInt(sv.softwares_id) === swId || parseInt(sv['9']) === swId
  )
  return match ? parseInt(match.id) : 0
}

// ── Handler principal ────────────────────────────────────────────
export default defineEventHandler(async (event) => {
  const d = await readBody(event)

  if (!d?.computer) {
    throw createError({ statusCode: 400, message: 'Payload invalide — champ "computer" manquant' })
  }

  const { GLPI_URL, GLPI_APP_TOKEN, GLPI_USER_TOKEN } = process.env
  if (!GLPI_URL || !GLPI_APP_TOKEN || !GLPI_USER_TOKEN) {
    throw createError({ statusCode: 500, message: 'Variables GLPI non configurées sur Vercel' })
  }

  // ── 1. Authentification ──────────────────────────────────────
  const session = await request('GET', `${GLPI_URL}/initSession`, {
    'App-Token'     : GLPI_APP_TOKEN,
    'Authorization' : `user_token ${GLPI_USER_TOKEN}`
  }, null).catch(() => null)

  if (!session?.session_token) {
    throw createError({ statusCode: 502, message: 'Authentification GLPI échouée' })
  }

  const tok = session.session_token

  try {
    const { computer, os, cpu, ram, disks, nics, gpus = [] } = d

    // ── 2. Résolution des dropdowns (en parallèle) ───────────
    const [manufacturerId, modelId, osId, osVersionId, osArchId] = await Promise.all([
      resolveDropdown('Manufacturer',                computer.manufacturer, tok),
      resolveDropdown('ComputerModel',               computer.model,        tok),
      resolveDropdown('OperatingSystem',             os.name,               tok),
      resolveDropdown('OperatingSystemVersion',      `${os.version} (Build ${os.buildNumber})`, tok),
      resolveDropdown('OperatingSystemArchitecture', os.architecture,       tok)
    ])

    // ── 3. Recherche du Computer par numéro de série ─────────
    const searchResult = await glpiGet('Computer', tok, {
      'searchText[serial]' : computer.serial,
      range                : '0-1',
      'forcedisplay[0]'    : '2'
    })
    const searchItems = normalizeItems(searchResult)
    let computerId    = searchItems.length > 0 ? parseInt(searchItems[0].id) : null

    // ── 4. Création ou mise à jour du Computer ───────────────
    const computerPayload = {
      name                            : computer.name,
      serial                          : computer.serial,
      uuid                            : computer.uuid,
      manufacturers_id                : manufacturerId,
      computermodels_id               : modelId,
      operatingsystems_id             : osId,
      operatingsystemversions_id      : osVersionId,
      operatingsystemarchitectures_id : osArchId,
      comment                         : `Inventaire Almerson v2 — ${new Date().toLocaleString('fr-FR')}`,
      is_dynamic                      : 1
    }

    if (computerId) {
      await glpiPut(`Computer/${computerId}`, tok, { input: computerPayload })
    } else {
      const created = await glpiPost('Computer', tok, { input: computerPayload })
      if (!created?.id) throw new Error('Impossible de créer le poste GLPI')
      computerId = parseInt(created.id)
    }

    // ── 4b. Item_OperatingSystem (GLPI 10+) ─────────────────
    const existingOsLinks = await glpiGet('Item_OperatingSystem', tok, {
      'searchText[items_id]' : String(computerId),
      'searchText[itemtype]' : 'Computer',
      range                  : '0-1'
    })
    const osLinks       = normalizeItems(existingOsLinks)
    const osLinkPayload = {
      items_id                        : computerId,
      itemtype                        : 'Computer',
      operatingsystems_id             : osId,
      operatingsystemversions_id      : osVersionId,
      operatingsystemarchitectures_id : osArchId,
      is_dynamic                      : 1
    }
    if (osLinks.length > 0) {
      await glpiPut(`Item_OperatingSystem/${osLinks[0].id}`, tok, { input: osLinkPayload })
    } else {
      await glpiPost('Item_OperatingSystem', tok, { input: osLinkPayload })
    }

    // ── 5. CPU ───────────────────────────────────────────────
    const cpuMfgId = await resolveDropdown('Manufacturer', cpu.manufacturer, tok)
    const cpuDevId = await resolveDevice('DeviceProcessor', cpu.name, {
      manufacturers_id : cpuMfgId,
      frequence        : cpu.maxClockSpeed,
      frequence_max    : cpu.maxClockSpeed,
      nbcores          : cpu.numberOfCores,
      nbthreads        : cpu.numberOfLogicalProcessors
    }, tok)

    if (cpuDevId > 0) {
      await clearLinks('Item_DeviceProcessor', computerId, tok)
      await glpiPost('Item_DeviceProcessor', tok, {
        input: {
          items_id            : computerId,
          itemtype            : 'Computer',
          deviceprocessors_id : cpuDevId,
          nbcores             : cpu.numberOfCores,
          nbthreads           : cpu.numberOfLogicalProcessors,
          frequency           : cpu.maxClockSpeed,
          is_dynamic          : 1
        }
      })
    }

    // ── 6. RAM ───────────────────────────────────────────────
    await clearLinks('Item_DeviceMemory', computerId, tok)
    for (let i = 0; i < ram.length; i++) {
      const slot       = ram[i]
      const label      = getDdrLabel(slot.smbiosMemoryType, slot.memoryType, slot.capacityBytes, slot.speed)
      const capacityMb = Math.round(slot.capacityBytes / 1048576)
      const ramMfgId   = await resolveDropdown('Manufacturer', slot.manufacturer || 'Unknown', tok)
      const ramDevId   = await resolveDevice('DeviceMemory', label, {
        manufacturers_id : ramMfgId,
        frequence        : slot.speed,
        size_default     : capacityMb
      }, tok)
      if (ramDevId > 0) {
        await glpiPost('Item_DeviceMemory', tok, {
          input: {
            items_id          : computerId,
            itemtype          : 'Computer',
            devicememories_id : ramDevId,
            size              : capacityMb,
            serial            : slot.serialNumber || '',
            busID             : `Slot ${i + 1}`,
            is_dynamic        : 1
          }
        })
      }
    }

    // ── 7. Disques ───────────────────────────────────────────
    await clearLinks('Item_DeviceHardDrive', computerId, tok)
    for (const disk of disks) {
      const sizeGb    = Math.round(disk.sizeBytes / 1073741824)
      if (sizeGb === 0) continue
      const diskMfgId = await resolveDropdown('Manufacturer', disk.manufacturer || 'Unknown', tok)
      const isSsd     = /SSD|Solid|NVMe/i.test((disk.mediaType || '') + disk.model)
      const diskDevId = await resolveDevice('DeviceHardDrive', disk.model, {
        manufacturers_id : diskMfgId,
        capacity         : sizeGb * 1024,
        rpm              : isSsd ? 0 : 7200
      }, tok)
      if (diskDevId > 0) {
        await glpiPost('Item_DeviceHardDrive', tok, {
          input: {
            items_id            : computerId,
            itemtype            : 'Computer',
            deviceharddrives_id : diskDevId,
            capacity            : sizeGb * 1024,
            serial              : disk.serialNumber || '',
            is_dynamic          : 1
          }
        })
      }
    }

    // ── 8. Interfaces réseau ─────────────────────────────────
    const existingPorts = await glpiGet('NetworkPort', tok, {
      'searchText[items_id]' : String(computerId),
      'searchText[itemtype]' : 'Computer',
      range                  : '0-50'
    })
    await Promise.all(normalizeItems(existingPorts).map((p: any) => {
      const id = p.id || p['2']
      return id ? glpiDelete(`NetworkPort/${id}`, tok) : null
    }))

    for (let i = 0; i < nics.length; i++) {
      const nic        = nics[i]
      const portResult = await glpiPost('NetworkPort', tok, {
        input: {
          items_id           : computerId,
          itemtype           : 'Computer',
          instantiation_type : 'NetworkPortEthernet',
          name               : nic.description,
          mac                : nic.macAddress,
          logical_number     : i + 1,
          is_dynamic         : 1
        }
      })
      if (portResult?.id) {
        const nameResult = await glpiPost('NetworkName', tok, {
          input: {
            items_id   : parseInt(portResult.id),
            itemtype   : 'NetworkPort',
            name       : computer.name.toLowerCase(),
            is_dynamic : 1
          }
        })
        if (nameResult?.id) {
          await glpiPost('IPAddress', tok, {
            input: {
              items_id   : parseInt(nameResult.id),
              itemtype   : 'NetworkName',
              name       : nic.ipAddress,
              is_dynamic : 1
            }
          })
        }
      }
    }

    // ── 9. Cartes graphiques ─────────────────────────────────
    await clearLinks('Item_DeviceGraphicCard', computerId, tok)
    for (const gpu of gpus) {
      const vramMb   = gpu.adapterRAM ? Math.round(gpu.adapterRAM / 1048576) : 0
      const gpuDevId = await resolveDevice('DeviceGraphicCard', gpu.name, {
        memory : vramMb
      }, tok)
      if (gpuDevId > 0) {
        await glpiPost('Item_DeviceGraphicCard', tok, {
          input: {
            items_id              : computerId,
            itemtype              : 'Computer',
            devicegraphiccards_id : gpuDevId,
            memory                : vramMb,
            is_dynamic            : 1
          }
        })
      }
    }

    // ── 10. Réponse ──────────────────────────────────────────
    const glpiBase = GLPI_URL.replace(/\/api\.php\/v1$/, '').replace(/\/apirest\.php$/, '')
    return {
      success    : true,
      computerId,
      glpiUrl    : `${glpiBase}/front/computer.form.php?id=${computerId}`
    }

  } catch (err: any) {
    throw createError({ statusCode: 500, message: err.message })
  } finally {
    await glpiGet('killSession', tok).catch(() => {})
  }
})
