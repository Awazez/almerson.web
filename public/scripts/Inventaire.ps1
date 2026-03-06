# ==============================================================
#  Script   : Inventaire Poste Client - Almerson
#  Auteur   : Martin AUBEUT - Almerson (www.almerson.com)
#  Version  : 2.1
#  Usage    : iex (irm https://www.almerson.com/Inventaire.ps1)
#  Desc     : Collecte complète pour fiche GLPI / rapport client
# ==============================================================
#Requires -Version 5.1

Set-StrictMode -Version Latest
$ErrorActionPreference = 'SilentlyContinue'

# ── Palette couleurs ────────────────────────────────────────────
$C = @{
    Title  = 'Cyan'
    Key    = 'White'
    Val    = 'Green'
    Warn   = 'Yellow'
    Err    = 'Red'
    Sep    = 'DarkGray'
    Brand  = 'Cyan'
}

function Write-Sep  { Write-Host ('─' * 60) -ForegroundColor $C.Sep }
function Write-Sep2 { Write-Host ('═' * 60) -ForegroundColor $C.Title }
function Write-KV([string]$k, $v, [string]$color = $C.Val) {
    if ($null -ne $v -and $v -ne '' -and $v -ne 'N/A') {
        Write-Host ("  {0,-22}: " -f $k) -NoNewline -ForegroundColor $C.Key
        Write-Host $v -ForegroundColor $color
    }
}

# ── Bannière ────────────────────────────────────────────────────
Clear-Host
Write-Host ""
Write-Host "  ###############################################################################" -ForegroundColor Cyan
Write-Host "  #                                                                             #" -ForegroundColor Cyan
Write-Host "  #    ░█████╗░██╗░░░░░███╗░░░███╗███████╗██████╗░░██████╗░░█████╗░███╗░░██╗    #" -ForegroundColor Cyan
Write-Host "  #    ██╔══██╗██║░░░░░████╗░████║██╔════╝██╔══██╗██╔════╝░██╔══██╗████╗░██║    #" -ForegroundColor Cyan
Write-Host "  #    ███████║██║░░░░░██╔████╔██║█████╗░░██████╔╝╚█████╗░░██║░░██║██╔██╗██║    #" -ForegroundColor Cyan
Write-Host "  #    ██╔══██║██║░░░░░██║╚██╔╝██║██╔══╝░░██╔══██╗░╚═══██╗░██║░░██║██║╚████║    #" -ForegroundColor Cyan
Write-Host "  #    ██║░░██║███████╗██║░╚═╝░██║███████╗██║░░██║██████╔╝░╚█████╔╝██║░╚███║    #" -ForegroundColor Cyan
Write-Host "  #    ╚═╝░░╚═╝╚══════╝╚═╝░░░░╚═╝╚══════╝╚═╝░░╚═╝╚═════╝░░░╚════╝░╚═╝░░╚══╝     #" -ForegroundColor Cyan
Write-Host "  #                                                                             #" -ForegroundColor Cyan
Write-Host "  #                   S E C U R E   I N F R A S T R U C T U R E                 #" -ForegroundColor Cyan
Write-Host "  #                                                                             #" -ForegroundColor Cyan
Write-Host "  ###############################################################################" -ForegroundColor Cyan
Write-Host "  #  Script   : Inventaire Poste Client - Almerson                              #" -ForegroundColor Cyan
Write-Host "  #  Auteur   : Martin AUBEUT - Almerson (www.almerson.com)                     #" -ForegroundColor Cyan
Write-Host "  #  Version  : 2.1                                                             #" -ForegroundColor Cyan
Write-Host "  #  Usage    : iex (irm https://www.almerson.com/Inventaire.ps1)               #" -ForegroundColor Cyan
Write-Host "  #  Desc     : Collecte complète pour fiche GLPI / rapport client              #" -ForegroundColor Cyan
Write-Host "  ###############################################################################" -ForegroundColor Cyan
Write-Host ""

# ==============================================================
#  BLOC 1 — COLLECTE WMI
# ==============================================================

Write-Sep2
Write-Host "`n  [ COLLECTE INVENTAIRE ]" -ForegroundColor $C.Title
Write-Sep

Write-Host "  Collecte en cours..." -ForegroundColor $C.Warn

# Système
$cs    = Get-WmiObject Win32_ComputerSystem
$bios  = Get-WmiObject Win32_BIOS
$os    = Get-WmiObject Win32_OperatingSystem
$prods = Get-WmiObject Win32_ComputerSystemProduct

# Processeur (premier uniquement)
$cpu   = Get-WmiObject Win32_Processor | Select-Object -First 1

# RAM — slots physiques
$ramSlots = Get-WmiObject Win32_PhysicalMemory

# Disques physiques
$disks = Get-WmiObject Win32_DiskDrive

# Interfaces réseau actives (avec IP assignée)
$nics = Get-WmiObject Win32_NetworkAdapterConfiguration |
        Where-Object { $_.IPEnabled -eq $true -and $null -ne $_.IPAddress }

# Carte(s) graphique(s)
$gpus = Get-WmiObject Win32_VideoController

# Logiciels installés (registre 64-bit + 32-bit)
$swPaths = @(
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
)
$rawSw = foreach ($path in $swPaths) {
    Get-ItemProperty $path -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -and $_.DisplayName.Trim() -ne '' } |
        Select-Object @{ Name='name';      Expression={ $_.DisplayName    } },
                      @{ Name='version';   Expression={ $_.DisplayVersion } },
                      @{ Name='publisher'; Expression={ $_.Publisher      } }
}
$softwares = @($rawSw | Sort-Object name -Unique)

# Licence Windows
$licProduct  = Get-WmiObject -Query "SELECT * FROM SoftwareLicensingProduct WHERE ApplicationId='55c92734-d682-4d71-983e-d6ec3f16059f' AND PartialProductKey IS NOT NULL" |
               Select-Object -First 1
$winEdition  = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').EditionID
$licStatus   = switch ($licProduct.LicenseStatus) {
    1 { 'Activé' } 2 { 'Grace OOB' } 3 { 'Grace OOT' }
    4 { 'Non authentique' } 5 { 'Notification' } default { 'Non activé' }
}
$partialKey  = if ($licProduct.PartialProductKey) { "xxxxx-xxxxx-xxxxx-xxxxx-$($licProduct.PartialProductKey)" } else { 'N/A' }
$licType     = switch -Wildcard ($licProduct.ProductKeyChannel) {
    'OEM*'    { 'OEM' } 'Retail*' { 'Retail' } 'Volume*' { 'Volume' } default { 'Inconnu' }
}

# ── Affichage collecte ───────────────────────────────────────────
Write-Sep
Write-Host "`n  [ SYSTÈME ]" -ForegroundColor $C.Title
Write-KV 'Nom'              $cs.Name
Write-KV 'Fabricant'        $cs.Manufacturer
Write-KV 'Modèle'           $cs.Model
Write-KV 'N° de série'      $bios.SerialNumber
Write-KV 'Version BIOS'     $bios.SMBIOSBIOSVersion
Write-KV 'Date BIOS'        ([Management.ManagementDateTimeConverter]::ToDateTime($bios.ReleaseDate)).ToString('dd/MM/yyyy')
Write-KV 'UUID'             $prods.UUID
Write-KV 'Type'             $cs.PCSystemType

Write-Sep
Write-Host "`n  [ SYSTÈME D''EXPLOITATION ]" -ForegroundColor $C.Title
Write-KV 'OS'               $os.Caption
Write-KV 'Édition'          $winEdition
Write-KV 'Version'          "$($os.Version) (Build $($os.BuildNumber))"
Write-KV 'Architecture'     $os.OSArchitecture
Write-KV 'Clé partielle'    $partialKey
Write-KV 'Type licence'     $licType
Write-KV 'Statut licence'   $licStatus

Write-Sep
Write-Host "`n  [ PROCESSEUR ]" -ForegroundColor $C.Title
Write-KV 'CPU'              $cpu.Name.Trim()
Write-KV 'Fabricant'        $cpu.Manufacturer
Write-KV 'Fréquence max'    "$($cpu.MaxClockSpeed) MHz"
Write-KV 'Cœurs physiques'  $cpu.NumberOfCores
Write-KV 'Threads'          $cpu.NumberOfLogicalProcessors

Write-Sep
Write-Host "`n  [ MÉMOIRE RAM ]" -ForegroundColor $C.Title
$totalRamGb = [math]::Round(($ramSlots | Measure-Object -Property Capacity -Sum).Sum / 1GB, 1)
Write-KV 'Total RAM'        "$totalRamGb GB"
$slotNum = 0
foreach ($slot in $ramSlots) {
    $slotNum++
    $slotGb = [math]::Round($slot.Capacity / 1GB, 0)
    Write-KV "Slot $slotNum"  "$slotGb GB @ $($slot.Speed) MHz — $($slot.Manufacturer)"
}

Write-Sep
Write-Host "`n  [ STOCKAGE ]" -ForegroundColor $C.Title
foreach ($disk in $disks) {
    $sizeGb = [math]::Round($disk.Size / 1GB, 0)
    if ($sizeGb -gt 0) {
        Write-KV $disk.Model.Trim()  "$sizeGb GB — $($disk.MediaType)"
    }
}

Write-Sep
Write-Host "`n  [ RÉSEAU ]" -ForegroundColor $C.Title
foreach ($nic in $nics) {
    Write-KV $nic.Description  "$($nic.IPAddress[0]) — $($nic.MACAddress)"
}

Write-Sep
Write-Host "`n  [ LOGICIELS ]" -ForegroundColor $C.Title
Write-Host "  Logiciels détectés    : $($softwares.Count) applications" -ForegroundColor $C.Val

Write-Sep
Write-Host "`n  [ CARTE GRAPHIQUE ]" -ForegroundColor $C.Title
foreach ($gpu in $gpus) {
    $vramMb = [math]::Round($gpu.AdapterRAM / 1MB, 0)
    Write-KV $gpu.Name.Trim()  "$vramMb MB — Driver $($gpu.DriverVersion)"
}

Write-Sep2

# ==============================================================
#  BLOC 2 — PUSH VERS ALMERSON API (proxy GLPI sécurisé)
# ==============================================================

Write-Sep2
Write-Host "`n  [ ENVOI INVENTAIRE → ALMERSON ]" -ForegroundColor $C.Title
Write-Sep
Write-Host "  Préparation du payload..." -ForegroundColor $C.Warn

$payload = @{
    computer = @{
        name         = $cs.Name
        manufacturer = $cs.Manufacturer
        model        = $cs.Model
        serial       = $bios.SerialNumber.Trim()
        biosVersion  = $bios.SMBIOSBIOSVersion
        biosDate     = ([Management.ManagementDateTimeConverter]::ToDateTime($bios.ReleaseDate)).ToString('yyyy-MM-dd')
        uuid         = $prods.UUID
        pcSystemType = [int]$cs.PCSystemType
    }
    os = @{
        name         = ($os.Caption -replace 'Microsoft ','')
        edition      = $winEdition
        version      = $os.Version
        buildNumber  = $os.BuildNumber
        architecture = $os.OSArchitecture
        partialKey    = $partialKey
        licenseType   = $licType
        licenseStatus = $licStatus
    }
    cpu = @{
        name                      = $cpu.Name.Trim()
        manufacturer              = $cpu.Manufacturer.Trim()
        maxClockSpeed             = [int]$cpu.MaxClockSpeed
        numberOfCores             = [int]$cpu.NumberOfCores
        numberOfLogicalProcessors = [int]$cpu.NumberOfLogicalProcessors
    }
    ram = @(
        $ramSlots | ForEach-Object {
            @{
                capacityBytes    = [long]$_.Capacity
                speed            = [int]$_.Speed
                manufacturer     = if ($_.Manufacturer) { $_.Manufacturer.Trim() } else { 'Unknown' }
                serialNumber     = if ($_.SerialNumber)  { $_.SerialNumber.Trim()  } else { '' }
                smbiosMemoryType = [int]$_.SMBIOSMemoryType
                memoryType       = [int]$_.MemoryType
            }
        }
    )
    disks = @(
        $disks | Where-Object { [math]::Round($_.Size / 1GB, 0) -gt 0 } | ForEach-Object {
            @{
                model        = $_.Model.Trim()
                manufacturer = if ($_.Manufacturer) { $_.Manufacturer.Trim() } else { 'Unknown' }
                sizeBytes    = [long]$_.Size
                serialNumber = if ($_.SerialNumber) { $_.SerialNumber.Trim() } else { '' }
                mediaType    = $_.MediaType
            }
        }
    )
    nics = @(
        $nics | ForEach-Object {
            @{
                description = $_.Description
                ipAddress   = $_.IPAddress[0]
                macAddress  = $_.MACAddress
            }
        }
    )
    gpus = @(
        $gpus | ForEach-Object {
            @{
                name          = $_.Name.Trim()
                adapterRAM    = [long]$_.AdapterRAM
                driverVersion = $_.DriverVersion
            }
        }
    )
}

Write-Host "  Envoi hardware vers https://www.almerson.com/api/inventory..." -ForegroundColor $C.Warn

$computerId = $null
try {
    $body     = $payload | ConvertTo-Json -Depth 10 -Compress
    $response = Invoke-RestMethod `
        -Uri         'https://www.almerson.com/api/inventory' `
        -Method      Post `
        -Body        $body `
        -ContentType 'application/json' `
        -ErrorAction Stop

    if ($response.success) {
        $computerId = $response.computerId
        Write-Sep
        Write-Host "  OK Hardware — Computer ID : $computerId" -ForegroundColor $C.Val
        Write-Host "  $($response.glpiUrl)" -ForegroundColor $C.Brand
    } else {
        Write-Host "  [ERREUR] $($response.error)" -ForegroundColor $C.Err
    }
} catch {
    Write-Host "  [ERREUR] $($_.Exception.Message)" -ForegroundColor $C.Err
}

if ($computerId) {
    Write-Sep
    Write-Host "  Envoi logiciels vers https://www.almerson.com/api/software..." -ForegroundColor $C.Warn
    $swList = [System.Collections.ArrayList]::new()
    foreach ($sw in $softwares) {
        if ($sw.name) {
            [void]$swList.Add(@{
                name      = [string]$sw.name
                version   = if ($sw.version)    { [string]$sw.version    } else { '' }
                publisher = if ($sw.publisher)  { [string]$sw.publisher  } else { '' }
            })
        }
    }
    Write-Host "  $($swList.Count) logiciels préparés pour l'envoi" -ForegroundColor $C.Warn
    try {
        $swBody     = (@{ computerId = $computerId; softwares = $swList }) | ConvertTo-Json -Depth 5 -Compress
        $swResponse = Invoke-RestMethod `
            -Uri         'https://www.almerson.com/api/software' `
            -Method      Post `
            -Body        $swBody `
            -ContentType 'application/json' `
            -ErrorAction Stop

        if ($swResponse.success) {
            Write-Host "  OK Logiciels — $($swResponse.softwares) importés" -ForegroundColor $C.Val
        } else {
            Write-Host "  [ERREUR logiciels] $($swResponse.error)" -ForegroundColor $C.Err
        }
    } catch {
        Write-Host "  [ERREUR logiciels] $($_.Exception.Message)" -ForegroundColor $C.Err
    }
}

Write-Sep2
