// ==============================================================
//  Endpoint  : POST /api/software
//  Auteur    : Martin AUBEUT - Almerson (www.almerson.com)
//  Desc      : Pousse la liste des logiciels installés dans GLPI
//              pour un Computer déjà créé par /api/inventory.
// ==============================================================

import https from 'node:https'
import http  from 'node:http'

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

async function resolveSoftwareVersion(name: string, version: string, publisher: string, mfgCache: Record<string, number>, tok: string) {
  const swFound = await glpiGet('Software', tok, { 'searchText[name]': name, range: '0-1' })
  const swItems = normalizeItems(swFound)
  let swId: number
  if (swItems.length > 0) {
    swId = parseInt(swItems[0].id)
  } else {
    const mfgId   = mfgCache[publisher] || 0
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
  const match = normalizeItems(svFound).find((sv: any) => parseInt(sv.softwares_id) === swId)
  return match ? parseInt(match.id) : 0
}

// ── Handler principal ────────────────────────────────────────────
export default defineEventHandler(async (event) => {
  const { computerId, softwares = [] } = await readBody(event)

  if (!computerId) {
    throw createError({ statusCode: 400, message: 'Payload invalide — champ "computerId" manquant' })
  }

  const { GLPI_URL, GLPI_APP_TOKEN, GLPI_USER_TOKEN } = process.env
  if (!GLPI_URL || !GLPI_APP_TOKEN || !GLPI_USER_TOKEN) {
    throw createError({ statusCode: 500, message: 'Variables GLPI non configurées sur Vercel' })
  }

  const session = await request('GET', `${GLPI_URL}/initSession`, {
    'App-Token'     : GLPI_APP_TOKEN,
    'Authorization' : `user_token ${GLPI_USER_TOKEN}`
  }, null).catch(() => null)

  if (!session?.session_token) {
    throw createError({ statusCode: 502, message: 'Authentification GLPI échouée' })
  }

  const tok = session.session_token

  try {
    // ── 1. Pré-charger tous les fabricants en parallèle ───────
    const uniquePublishers = [...new Set<string>(softwares.map((s: any) => s.publisher).filter(Boolean))]
    const mfgCache: Record<string, number> = {}
    await Promise.all(uniquePublishers.map(async (pub: string) => {
      mfgCache[pub] = await resolveDropdown('Manufacturer', pub, tok)
    }))

    // ── 2. Supprimer les anciens liens ────────────────────────
    const existingLinks = await glpiGet('Item_SoftwareVersion', tok, {
      'searchText[items_id]' : String(computerId),
      'searchText[itemtype]' : 'Computer',
      range                  : '0-500'
    })
    await Promise.all(normalizeItems(existingLinks).map((item: any) => {
      const id = item.id || item['2']
      return id ? glpiDelete(`Item_SoftwareVersion/${id}`, tok) : null
    }))

    // ── 3. Pousser les logiciels par batches de 10 ────────────
    let swOk = 0
    const BATCH = 10
    for (let i = 0; i < softwares.length; i += BATCH) {
      await Promise.all(softwares.slice(i, i + BATCH).map(async (sw: any) => {
        try {
          if (!sw.name) return
          const svId = await resolveSoftwareVersion(sw.name, sw.version, sw.publisher, mfgCache, tok)
          if (svId > 0) {
            await glpiPost('Item_SoftwareVersion', tok, {
              input: {
                items_id            : computerId,
                itemtype            : 'Computer',
                softwareversions_id : svId,
                is_dynamic          : 1
              }
            })
            swOk++
          }
        } catch (_) { /* item ignoré */ }
      }))
    }

    return { success: true, softwares: `${swOk}/${softwares.length}` }

  } catch (err: any) {
    throw createError({ statusCode: 500, message: err.message })
  } finally {
    await glpiGet('killSession', tok).catch(() => {})
  }
})
