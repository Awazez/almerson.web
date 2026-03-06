# ==============================================================
#  Script   : Audit.ps1
#  Auteur   : Martin AUBEUT - Almerson (www.almerson.com)
#  Version  : 1.4
#  Usage    : iex (irm https://www.almerson.com/Audit.ps1)
#             Ou en local : .\Audit.ps1 [-NomCabinet "Cabinet Dupont"]
#  Desc     : Audit securite complet - rapport HTML brande Almerson
#             Combine inventaire hardware + controles securite
#             + scan reseau avec scoring de risques
#  Prereqs  : PS 5.1+, nmap dans PATH (reseau)
#             Droits administrateur recommandes
# --------------------------------------------------------------
#  Changelog :
#  1.0 - Version initiale (HTML uniquement, chemin courant)
#  1.1 - Corrections securite : verification droits admin,
#        echappement HTML (XSS), coherence seuils de risque
#  1.2 - Rapport HTML depose sur le Bureau, chemin normalise
#  1.3 - Ajout scan reseau nmap, scoring de risques etendu
#  1.4 - Param -NomCabinet, suppression ErrorActionPreference global,
#        nouveaux controles : AutoRun, PS logging, sessions actives,
#        CTA footer rapport HTML
# ==============================================================
#Requires -Version 5.1
param(
    [string]$NomCabinet = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

# ── Palette console ─────────────────────────────────────────────
$C = @{ Title='Cyan'; Key='White'; Val='Green'; Warn='Yellow'; Err='Red'; Sep='DarkGray'; Ok='Green' }

function Write-Sep  { Write-Host ('─' * 70) -ForegroundColor $C.Sep }
function Write-Sep2 { Write-Host ('═' * 70) -ForegroundColor $C.Title }
function Write-KV([string]$k, $v, [string]$color = $C.Val) {
    if ($null -ne $v -and "$v".Trim() -ne '' -and "$v".Trim() -ne 'N/A') {
        Write-Host ("  {0,-28}: " -f $k) -NoNewline -ForegroundColor $C.Key
        Write-Host $v -ForegroundColor $color
    }
}
function Write-Step([string]$msg) { Write-Host "  >> $msg" -ForegroundColor $C.Warn }
function Write-OK([string]$msg)   { Write-Host "  [OK]  $msg" -ForegroundColor $C.Ok }
function Write-WARN([string]$msg) { Write-Host "  [!!]  $msg" -ForegroundColor $C.Warn }
function Write-CRIT([string]$msg) { Write-Host "  [XX]  $msg" -ForegroundColor $C.Err }

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
Write-Host "  #  Script   : Audit.ps1                                                       #" -ForegroundColor Cyan
Write-Host "  #  Auteur   : Martin AUBEUT - Almerson (www.almerson.com)                     #" -ForegroundColor Cyan
Write-Host "  #  Version  : 1.4                                                             #" -ForegroundColor Cyan
Write-Host "  #  Usage    : iex (irm https://www.almerson.com/Audit.ps1)                    #" -ForegroundColor Cyan
Write-Host "  #             .\Audit.ps1 [-NomCabinet 'Cabinet Dupont']                      #" -ForegroundColor Cyan
Write-Host "  #  Desc     : Audit securite complet — livrable HTML sur le Bureau            #" -ForegroundColor Cyan
Write-Host "  ###############################################################################" -ForegroundColor Cyan
Write-Host ""

# Verification droits administrateur
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-WARN "Ce script s'execute SANS droits administrateur — certains controles seront incomplets (BitLocker, secedit, etc.)"
    Write-Host ""
}

# Nom du cabinet (via param ou saisie interactive)
if (-not $NomCabinet) {
    $NomCabinet = Read-Host "  Nom du cabinet / client (laisser vide pour ignorer)"
}
if (-not $NomCabinet) { $NomCabinet = 'Client' }

$timestamp        = Get-Date -Format 'yyyy-MM-dd_HHmm'
$dateDisplay      = Get-Date -Format 'dd/MM/yyyy a HH:mm'
$desktop          = [Environment]::GetFolderPath('Desktop')
$rapportHtml      = Join-Path $desktop "Audit-Almerson_${NomCabinet}_$timestamp.html"

# ──────────────────────────────────────────────────────────────
#  BLOC 1 — COLLECTE INVENTAIRE HARDWARE
# ──────────────────────────────────────────────────────────────
Write-Sep2
Write-Host "`n  [ BLOC 1 — INVENTAIRE HARDWARE ]" -ForegroundColor $C.Title
Write-Sep

Write-Step "Collecte WMI en cours..."

$cs       = Get-WmiObject Win32_ComputerSystem -ErrorAction SilentlyContinue
$bios     = Get-WmiObject Win32_BIOS -ErrorAction SilentlyContinue
$os       = Get-WmiObject Win32_OperatingSystem -ErrorAction SilentlyContinue
$prods    = Get-WmiObject Win32_ComputerSystemProduct -ErrorAction SilentlyContinue
$cpu      = Get-WmiObject Win32_Processor -ErrorAction SilentlyContinue | Select-Object -First 1
$ramSlots = Get-WmiObject Win32_PhysicalMemory -ErrorAction SilentlyContinue
$disks    = Get-WmiObject Win32_DiskDrive -ErrorAction SilentlyContinue
$nics     = Get-WmiObject Win32_NetworkAdapterConfiguration -ErrorAction SilentlyContinue |
            Where-Object { $_.IPEnabled -eq $true -and $null -ne $_.IPAddress }
$gpus     = Get-WmiObject Win32_VideoController -ErrorAction SilentlyContinue

# Licence Windows
$licProduct = Get-WmiObject -Query "SELECT * FROM SoftwareLicensingProduct WHERE ApplicationId='55c92734-d682-4d71-983e-d6ec3f16059f' AND PartialProductKey IS NOT NULL" -ErrorAction SilentlyContinue |
              Select-Object -First 1
$winEdition = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').EditionID
$licStatus  = switch ($licProduct.LicenseStatus) {
    1 {'Actif'} 2 {'Grace OOB'} 3 {'Grace OOT'} 4 {'Non authentique'} 5 {'Notification'} default {'Non active'}
}
$licType = switch -Wildcard ($licProduct.ProductKeyChannel) {
    'OEM*' {'OEM'} 'Retail*' {'Retail'} 'Volume*' {'Volume'} default {'Inconnu'}
}
$partialKey = if ($licProduct.PartialProductKey) { "xxxxx-xxxxx-xxxxx-xxxxx-$($licProduct.PartialProductKey)" } else { 'N/A' }

# Logiciels
$swPaths = @(
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
)
$rawSw = foreach ($path in $swPaths) {
    Get-ItemProperty $path -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName -and $_.DisplayName.Trim() -ne '' } |
        Select-Object @{N='name';E={$_.DisplayName}},
                      @{N='version';E={$_.DisplayVersion}},
                      @{N='publisher';E={$_.Publisher}},
                      @{N='installDate';E={$_.InstallDate}}
}
$softwares = @($rawSw | Sort-Object name -Unique)

$totalRamGb = [math]::Round(($ramSlots | Measure-Object -Property Capacity -Sum).Sum / 1GB, 1)

Write-OK "Hardware collecte — $($cs.Model)"
Write-OK "OS : $($os.Caption) — Build $($os.BuildNumber)"
Write-OK "$($softwares.Count) logiciels detectes"

# ──────────────────────────────────────────────────────────────
#  BLOC 2 — CONTROLES SECURITE
# ──────────────────────────────────────────────────────────────
Write-Sep2
Write-Host "`n  [ BLOC 2 — CONTROLES SECURITE ]" -ForegroundColor $C.Title
Write-Sep

$riskScore = 0
$findings  = [System.Collections.ArrayList]::new()

function Add-Finding([string]$categorie, [string]$titre, [string]$detail, [string]$niveau, [string]$recommandation) {
    [void]$findings.Add([PSCustomObject]@{
        Categorie      = $categorie
        Titre          = $titre
        Detail         = $detail
        Niveau         = $niveau
        Recommandation = $recommandation
    })
}

# ── 2.1 Windows Update ──────────────────────────────────────────
Write-Step "Windows Update..."
try {
    $updateSession  = New-Object -ComObject Microsoft.Update.Session
    $updateSearcher = $updateSession.CreateUpdateSearcher()
    $histCount      = $updateSearcher.GetTotalHistoryCount()
    $history        = if ($histCount -gt 0) { $updateSearcher.QueryHistory(0, [math]::Min($histCount,50)) } else { $null }
    $lastUpdate     = if ($history) {
        ($history | Where-Object { $_.ResultCode -eq 2 } | Sort-Object Date -Descending | Select-Object -First 1).Date
    } else { $null }
    $pendingSearch = $updateSearcher.Search("IsInstalled=0 and Type='Software' and IsHidden=0")
    $pendingCount  = $pendingSearch.Updates.Count

    if ($lastUpdate) {
        $daysSince     = (New-TimeSpan -Start $lastUpdate -End (Get-Date)).Days
        $lastUpdateStr = $lastUpdate.ToString('dd/MM/yyyy')
        if ($daysSince -gt 90) {
            $riskScore += 20
            Add-Finding 'Windows Update' "Dernier patch : $lastUpdateStr" "Aucune mise a jour depuis $daysSince jours" 'CRIT' "Appliquer immediatement les mises a jour Windows. Activer les MAJ automatiques."
            Write-CRIT "Dernier patch : $lastUpdateStr ($daysSince jours)"
        } elseif ($daysSince -gt 30) {
            $riskScore += 8
            Add-Finding 'Windows Update' "Dernier patch : $lastUpdateStr" "Aucune mise a jour depuis $daysSince jours" 'WARN' "Verifier la politique de mise a jour automatique."
            Write-WARN "Dernier patch : $lastUpdateStr ($daysSince jours)"
        } else {
            Add-Finding 'Windows Update' "Dernier patch : $lastUpdateStr" "Systeme a jour ($daysSince jours)" 'OK' ""
            Write-OK "Dernier patch : $lastUpdateStr"
        }
    } else {
        $riskScore += 15
        Add-Finding 'Windows Update' 'Historique indisponible' "Impossible de determiner la date du dernier patch" 'WARN' "Verifier manuellement l'historique Windows Update."
        Write-WARN "Historique MAJ indisponible"
    }
    if ($pendingCount -gt 0) {
        $riskScore += [math]::Min($pendingCount * 3, 20)
        Add-Finding 'Windows Update' "$pendingCount mise(s) a jour en attente" "Updates non installees detectees" 'WARN' "Planifier l'installation des $pendingCount mise(s) a jour en attente."
        Write-WARN "$pendingCount mise(s) a jour en attente"
    }
} catch {
    $riskScore += 10
    Add-Finding 'Windows Update' 'Service inaccessible' "Impossible d'interroger Windows Update" 'WARN' "Verifier que le service Windows Update est actif."
    Write-WARN "Impossible d'interroger Windows Update"
}

# ── 2.2 Antivirus ───────────────────────────────────────────────
Write-Step "Antivirus..."
$avProducts = Get-WmiObject -Namespace 'root\SecurityCenter2' -Class AntiVirusProduct -ErrorAction SilentlyContinue
if ($avProducts) {
    foreach ($av in $avProducts) {
        $productState = [Convert]::ToString($av.productState, 16).PadLeft(6,'0')
        $rtProtect    = $productState.Substring(2,2)
        $defState     = $productState.Substring(4,2)
        $rtEnabled    = ($rtProtect -eq '10')
        $defUpToDate  = ($defState  -eq '00')
        $avName = $av.displayName
        if (-not $rtEnabled) {
            $riskScore += 30
            Add-Finding 'Antivirus' "$avName — Protection temps reel INACTIVE" "L'antivirus est detecte mais desactive" 'CRIT' "Reactiver immediatement la protection temps reel de $avName."
            Write-CRIT "$avName — Protection temps reel DESACTIVEE"
        } elseif (-not $defUpToDate) {
            $riskScore += 15
            Add-Finding 'Antivirus' "$avName — Definitions obsoletes" "Signatures antivirus non a jour" 'WARN' "Mettre a jour les signatures de $avName."
            Write-WARN "$avName — Definitions obsoletes"
        } else {
            Add-Finding 'Antivirus' "$avName — Actif et a jour" "Protection temps reel active, definitions recentes" 'OK' ""
            Write-OK "$avName — OK"
        }
    }
} else {
    $riskScore += 35
    Add-Finding 'Antivirus' 'Aucun antivirus detecte' "Aucune solution de protection endpoint trouvee" 'CRIT' "Deployer une solution antivirus managee (ex : Bitdefender GravityZone)."
    Write-CRIT "Aucun antivirus detecte !"
}

# ── 2.3 Pare-feu Windows ────────────────────────────────────────
Write-Step "Pare-feu Windows..."
try {
    $fwProfiles = Get-NetFirewallProfile -ErrorAction Stop
    foreach ($profile in $fwProfiles) {
        if (-not $profile.Enabled) {
            $riskScore += 15
            Add-Finding 'Pare-feu' "Profil $($profile.Name) DESACTIVE" "Le pare-feu Windows est inactif sur ce profil" 'CRIT' "Activer le pare-feu Windows sur le profil $($profile.Name)."
            Write-CRIT "Pare-feu $($profile.Name) : DESACTIVE"
        } else {
            Add-Finding 'Pare-feu' "Profil $($profile.Name) actif" "" 'OK' ""
            Write-OK "Pare-feu $($profile.Name) : actif"
        }
    }
} catch {
    $riskScore += 10
    Add-Finding 'Pare-feu' 'Etat indisponible' "Impossible de lire l'etat du pare-feu" 'WARN' "Verifier manuellement l'etat du pare-feu Windows."
    Write-WARN "Pare-feu : etat indisponible"
}

# ── 2.4 BitLocker ───────────────────────────────────────────────
Write-Step "BitLocker..."
try {
    $blVolumes = Get-BitLockerVolume -ErrorAction Stop
    foreach ($vol in $blVolumes) {
        if ($vol.VolumeType -eq 'OperatingSystem') {
            if ($vol.ProtectionStatus -eq 'On') {
                Add-Finding 'BitLocker' "Volume $($vol.MountPoint) chiffre" "BitLocker actif — protection des donnees au repos assuree" 'OK' ""
                Write-OK "BitLocker $($vol.MountPoint) : ON"
            } else {
                $riskScore += 25
                Add-Finding 'BitLocker' "Volume $($vol.MountPoint) NON chiffre" "Donnees accessibles sans authentification en cas de vol du poste" 'CRIT' "Activer BitLocker sur le volume systeme. Indispensable pour un cabinet traitant des donnees confidentielles."
                Write-CRIT "BitLocker $($vol.MountPoint) : NON chiffre"
            }
        }
    }
} catch {
    $riskScore += 10
    Add-Finding 'BitLocker' 'Etat indisponible' "Impossible de lire l'etat BitLocker (peut necessiter droits admin)" 'WARN' "Verifier l'etat du chiffrement disque manuellement."
    Write-WARN "BitLocker : etat indisponible"
}

# ── 2.5 Secure Boot ─────────────────────────────────────────────
Write-Step "Secure Boot..."
try {
    $secureBoot = Confirm-SecureBootUEFI -ErrorAction Stop
    if ($secureBoot) {
        Add-Finding 'Secure Boot' 'Active' "Demarrage securise UEFI active" 'OK' ""
        Write-OK "Secure Boot : actif"
    } else {
        $riskScore += 10
        Add-Finding 'Secure Boot' 'INACTIF' "Le demarrage securise n'est pas active dans le BIOS/UEFI" 'WARN' "Activer Secure Boot dans les parametres UEFI du poste."
        Write-WARN "Secure Boot : inactif"
    }
} catch {
    Add-Finding 'Secure Boot' 'Inconnu (BIOS legacy ?)' "Secure Boot non disponible ou non applicable" 'WARN' "Verifier si le poste supporte UEFI et Secure Boot."
    Write-WARN "Secure Boot : indetermine"
}

# ── 2.6 Comptes administrateurs locaux ──────────────────────────
Write-Step "Comptes administrateurs locaux..."
try {
    $adminGroup   = [ADSI]"WinNT://./Administrators,group"
    $adminMembers = @($adminGroup.Invoke("Members") | ForEach-Object { $_.GetType().InvokeMember('Name','GetProperty',$null,$_,$null) })
    $adminCount   = $adminMembers.Count
    $adminList    = $adminMembers -join ', '
    if ($adminCount -gt 3) {
        $riskScore += 15
        Add-Finding 'Comptes admin' "$adminCount administrateurs locaux" "Comptes : $adminList" 'CRIT' "Reduire le nombre d'administrateurs locaux au strict minimum."
        Write-CRIT "$adminCount admins locaux : $adminList"
    } elseif ($adminCount -gt 2) {
        $riskScore += 5
        Add-Finding 'Comptes admin' "$adminCount administrateurs locaux" "Comptes : $adminList" 'WARN' "Verifier que tous les comptes admin sont legitimes et necessaires."
        Write-WARN "$adminCount admins locaux : $adminList"
    } else {
        Add-Finding 'Comptes admin' "$adminCount administrateur(s)" "Comptes : $adminList" 'OK' ""
        Write-OK "$adminCount admin(s) : $adminList"
    }
} catch {
    Add-Finding 'Comptes admin' 'Indisponible' "Impossible de lire le groupe Administrators" 'WARN' "Verifier manuellement les membres du groupe Administrators."
    Write-WARN "Comptes admin : inaccessibles"
}

# ── 2.7 Dossiers partages ───────────────────────────────────────
Write-Step "Dossiers partages..."
$shares = Get-WmiObject Win32_Share |
          Where-Object { $_.Type -eq 0 -and $_.Name -notmatch '^\w\$' -and $_.Name -notlike 'ADMIN$' -and $_.Name -notlike 'IPC$' }
if ($shares -and $shares.Count -gt 0) {
    $shareNames = ($shares | ForEach-Object { $_.Name }) -join ', '
    $riskScore += $shares.Count * 5
    Add-Finding 'Partages reseau' "$($shares.Count) partage(s) expose(s)" "Partages : $shareNames" 'WARN' "Verifier que chaque partage est necessaire et correctement protege."
    Write-WARN "$($shares.Count) partage(s) : $shareNames"
} else {
    Add-Finding 'Partages reseau' 'Aucun partage non-systeme detecte' "" 'OK' ""
    Write-OK "Aucun partage expose"
}

# ── 2.8 RDP ─────────────────────────────────────────────────────
Write-Step "Remote Desktop (RDP)..."
$rdpEnabled = (Get-ItemProperty 'HKLM:\System\CurrentControlSet\Control\Terminal Server').fDenyTSConnections -eq 0
$nlaEnabled = (Get-ItemProperty 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp').UserAuthentication -eq 1
if ($rdpEnabled) {
    if (-not $nlaEnabled) {
        $riskScore += 25
        Add-Finding 'RDP' 'RDP actif SANS NLA' "Bureau a distance expose sans NLA" 'CRIT' "Activer NLA pour RDP, ou desactiver RDP si non utilise."
        Write-CRIT "RDP actif sans NLA — risque eleve !"
    } else {
        $riskScore += 5
        Add-Finding 'RDP' 'RDP actif avec NLA' "Bureau a distance actif, NLA active" 'WARN' "S'assurer que RDP est necessaire. Envisager un VPN."
        Write-WARN "RDP actif (NLA OK — surveiller l'exposition)"
    }
} else {
    Add-Finding 'RDP' 'RDP desactive' "" 'OK' ""
    Write-OK "RDP : desactive"
}

# ── 2.9 SMBv1 ───────────────────────────────────────────────────
Write-Step "SMBv1 (WannaCry / NotPetya)..."
try {
    $smb1 = Get-WindowsOptionalFeature -Online -FeatureName 'SMB1Protocol' -ErrorAction Stop
    if ($smb1.State -eq 'Enabled') {
        $riskScore += 30
        Add-Finding 'SMBv1' 'SMBv1 ACTIVE' "Protocole obsolete exploite par WannaCry, NotPetya, EternalBlue" 'CRIT' "Desactiver immediatement SMBv1 : Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol"
        Write-CRIT "SMBv1 ACTIVE — vecteur ransomware connu !"
    } else {
        Add-Finding 'SMBv1' 'SMBv1 desactive' "" 'OK' ""
        Write-OK "SMBv1 : desactive"
    }
} catch {
    $smb1Reg = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters').SMB1
    if ($smb1Reg -ne 0) {
        $riskScore += 25
        Add-Finding 'SMBv1' 'SMBv1 potentiellement actif' "Impossible de confirmer via DISM, registre ambigu" 'WARN' "Verifier et desactiver SMBv1 manuellement."
        Write-WARN "SMBv1 : statut ambigu"
    } else {
        Add-Finding 'SMBv1' 'SMBv1 desactive (registre)' "" 'OK' ""
        Write-OK "SMBv1 : desactive"
    }
}

# ── 2.10 Politique de mots de passe ─────────────────────────────
Write-Step "Politique de mots de passe..."
$secpolOutput = & secedit /export /cfg "$env:TEMP\secpol_tmp.cfg" /quiet 2>$null
$secpol = if (Test-Path "$env:TEMP\secpol_tmp.cfg") { Get-Content "$env:TEMP\secpol_tmp.cfg" -ErrorAction SilentlyContinue } else { $null }
if ($secpol) {
    $minLength  = ($secpol | Where-Object { $_ -match 'MinimumPasswordLength' }) -replace '.*=\s*',''
    $maxAge     = ($secpol | Where-Object { $_ -match 'MaximumPasswordAge' })    -replace '.*=\s*',''
    $complexity = ($secpol | Where-Object { $_ -match 'PasswordComplexity' })    -replace '.*=\s*',''
    $lockout    = ($secpol | Where-Object { $_ -match 'LockoutBadCount' })       -replace '.*=\s*',''
    $minLengthInt  = [int]("$minLength".Trim())
    $complexityInt = [int]("$complexity".Trim())
    $lockoutInt    = [int]("$lockout".Trim())
    if ($minLengthInt -lt 8) {
        $riskScore += 15
        Add-Finding 'Mots de passe' "Longueur minimale : $minLengthInt caracteres" "Longueur insuffisante (min recommande : 12)" 'CRIT' "Configurer la longueur minimale de mot de passe a 12 caracteres."
        Write-CRIT "Longueur minimale mdp : $minLengthInt (trop court)"
    } elseif ($minLengthInt -lt 12) {
        $riskScore += 5
        Add-Finding 'Mots de passe' "Longueur minimale : $minLengthInt caracteres" "Acceptable mais inferieure au standard recommande (12)" 'WARN' "Augmenter la longueur minimale a 12 caracteres."
        Write-WARN "Longueur minimale mdp : $minLengthInt"
    } else {
        Add-Finding 'Mots de passe' "Longueur minimale : $minLengthInt caracteres" "" 'OK' ""
        Write-OK "Longueur minimale mdp : $minLengthInt"
    }
    if ($complexityInt -ne 1) {
        $riskScore += 10
        Add-Finding 'Mots de passe' 'Complexite DESACTIVEE' "Les mots de passe simples sont autorises" 'WARN' "Activer les exigences de complexite des mots de passe."
        Write-WARN "Complexite mdp : desactivee"
    } else {
        Add-Finding 'Mots de passe' 'Complexite activee' "" 'OK' ""
        Write-OK "Complexite mdp : activee"
    }
    if ($lockoutInt -eq 0) {
        $riskScore += 10
        Add-Finding 'Mots de passe' 'Verrouillage DESACTIVE' "Aucune limite de tentatives — bruteforce possible" 'WARN' "Configurer le verrouillage apres 5 tentatives echouees."
        Write-WARN "Verrouillage compte : desactive"
    } else {
        Add-Finding 'Mots de passe' "Verrouillage apres $lockoutInt tentatives" "" 'OK' ""
        Write-OK "Verrouillage compte : apres $lockoutInt tentatives"
    }
    Remove-Item "$env:TEMP\secpol_tmp.cfg" -Force -ErrorAction SilentlyContinue
} else {
    Add-Finding 'Mots de passe' 'Politique indisponible' "Impossible de lire la politique de securite locale" 'WARN' "Verifier la politique de mots de passe dans gpedit.msc."
    Write-WARN "Politique mdp : indisponible"
}

# ── 2.11 Windows Defender ───────────────────────────────────────
Write-Step "Windows Defender..."
try {
    $defender = Get-MpComputerStatus -ErrorAction Stop
    if ($defender.RealTimeProtectionEnabled) {
        if ($defender.AntivirusSignatureAge -gt 7) {
            $riskScore += 10
            Add-Finding 'Windows Defender' "Signatures : $($defender.AntivirusSignatureAge) jours" "Signatures Defender obsoletes" 'WARN' "Forcer la mise a jour : Update-MpSignature"
            Write-WARN "Defender : signatures vieilles de $($defender.AntivirusSignatureAge) jours"
        } else {
            Add-Finding 'Windows Defender' "Defender actif, signatures a jour ($($defender.AntivirusSignatureAge) j)" "" 'OK' ""
            Write-OK "Defender : actif, signatures OK"
        }
    } else {
        Add-Finding 'Windows Defender' 'Defender desactive' "Probablement remplace par un AV tiers" 'OK' ""
        Write-OK "Defender : desactive (AV tiers en place)"
    }
} catch {
    Add-Finding 'Windows Defender' 'Statut indisponible' "" 'WARN' ""
}

# ── 2.12 AutoRun / AutoPlay ──────────────────────────────────────
Write-Step "AutoRun / AutoPlay..."
try {
    $autoRunReg  = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' -ErrorAction SilentlyContinue
    $noDriveTypeAutoRun = $autoRunReg.NoDriveTypeAutoRun
    if ($null -eq $noDriveTypeAutoRun -or $noDriveTypeAutoRun -lt 255) {
        $riskScore += 15
        Add-Finding 'AutoRun' 'AutoRun potentiellement actif' "Vecteur USB/CD non bloque par strategie — risque infection physique" 'CRIT' "Configurer NoDriveTypeAutoRun=0xFF via GPO ou registre pour bloquer AutoRun sur tous les supports."
        Write-CRIT "AutoRun : non bloque (vecteur cle USB)"
    } else {
        Add-Finding 'AutoRun' 'AutoRun desactive (tous supports)' "NoDriveTypeAutoRun=0xFF — protection USB/CD active" 'OK' ""
        Write-OK "AutoRun : desactive"
    }
} catch {
    Add-Finding 'AutoRun' 'Statut indisponible' "Impossible de lire la cle registre AutoRun" 'WARN' "Verifier NoDriveTypeAutoRun dans HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer."
    Write-WARN "AutoRun : statut indisponible"
}

# ── 2.13 PowerShell — Script Block Logging ──────────────────────
Write-Step "PowerShell Script Block Logging..."
try {
    $psLogReg  = Get-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' -ErrorAction SilentlyContinue
    $psEnabled = $psLogReg.EnableScriptBlockLogging
    if ($psEnabled -eq 1) {
        Add-Finding 'PS Logging' 'Script Block Logging actif' "Journalisation PowerShell activee — tracabilite des scripts" 'OK' ""
        Write-OK "PS Script Block Logging : actif"
    } else {
        $riskScore += 10
        Add-Finding 'PS Logging' 'Script Block Logging INACTIF' "Les scripts PowerShell ne sont pas journalises — forensic compromis" 'WARN' "Activer via GPO : Computer > Admin Templates > PowerShell > Turn on Script Block Logging."
        Write-WARN "PS Script Block Logging : inactif"
    }
} catch {
    $riskScore += 5
    Add-Finding 'PS Logging' 'Statut indisponible' "Cle registre PowerShell\ScriptBlockLogging introuvable" 'WARN' "Verifier la strategie PowerShell Script Block Logging."
    Write-WARN "PS Script Block Logging : indisponible"
}

# ── 2.14 Sessions utilisateurs actives ──────────────────────────
Write-Step "Sessions utilisateurs actives..."
try {
    $sessions = @(query session 2>$null | Select-Object -Skip 1 |
        Where-Object { $_ -match 'Active|Actif' })
    $sessionCount = $sessions.Count
    if ($sessionCount -gt 2) {
        $riskScore += 10
        Add-Finding 'Sessions actives' "$sessionCount sessions actives detectees" "Plusieurs sessions ouvertes simultanement — surface d'attaque elargie" 'WARN' "Verifier que les sessions sont legitimes. Activer la deconnexion automatique apres inactivite (GPO)."
        Write-WARN "$sessionCount sessions actives"
    } elseif ($sessionCount -gt 0) {
        Add-Finding 'Sessions actives' "$sessionCount session(s) active(s)" "" 'OK' ""
        Write-OK "$sessionCount session(s) active(s)"
    } else {
        Add-Finding 'Sessions actives' 'Aucune session active detectee' "" 'OK' ""
        Write-OK "Sessions : aucune session active en dehors de la session courante"
    }
} catch {
    Add-Finding 'Sessions actives' 'Indisponible' "Impossible d'interroger les sessions (query session)" 'WARN' ""
    Write-WARN "Sessions : statut indisponible"
}

# ── Calcul score final ───────────────────────────────────────────
$scoreNiveau        = if ($riskScore -le 20) { 'FAIBLE' } elseif ($riskScore -le 50) { 'MOYEN' } else { 'ELEVE' }
$scoreCouleurConsole = if ($riskScore -le 20) { 'Green' } elseif ($riskScore -le 50) { 'Yellow' } else { 'Red' }
$critFindings = @($findings | Where-Object { $_.Niveau -eq 'CRIT' }).Count
$warnFindings = @($findings | Where-Object { $_.Niveau -eq 'WARN' }).Count

Write-Sep2
Write-Host "`n  SCORE DE RISQUE : $riskScore pts — Niveau $scoreNiveau" -ForegroundColor $scoreCouleurConsole
Write-Host "  $critFindings point(s) critique(s) | $warnFindings avertissement(s)" -ForegroundColor $C.Warn
Write-Sep2

# ──────────────────────────────────────────────────────────────
#  BLOC 3 — SCAN RÉSEAU
# ──────────────────────────────────────────────────────────────
Write-Sep2
Write-Host "`n  [ BLOC 3 — SCAN RESEAU ]" -ForegroundColor $C.Title
Write-Sep

$nmapAvailable = $null -ne (Get-Command nmap -ErrorAction SilentlyContinue)
$networkHosts  = @()
$networkData   = [System.Collections.ArrayList]::new()

$riskyPorts = @{
    21   = @{ name='FTP';      level='CRIT'; reason='Protocole non chiffre, transfert en clair' }
    22   = @{ name='SSH';      level='INFO'; reason='Acces distant — verifier si necessaire' }
    23   = @{ name='Telnet';   level='CRIT'; reason='Protocole non chiffre, identifiants en clair' }
    25   = @{ name='SMTP';     level='WARN'; reason='Serveur mail expose — risque relay' }
    80   = @{ name='HTTP';     level='WARN'; reason='Service web non chiffre' }
    135  = @{ name='RPC';      level='WARN'; reason='RPC expose — vecteur lateral movement' }
    139  = @{ name='NetBIOS';  level='WARN'; reason='NetBIOS expose — information disclosure' }
    443  = @{ name='HTTPS';    level='INFO'; reason='Service web chiffre' }
    445  = @{ name='SMB';      level='CRIT'; reason='SMB expose — vecteur ransomware (EternalBlue/WannaCry)' }
    1433 = @{ name='MSSQL';    level='WARN'; reason='Base de donnees exposee sur le reseau' }
    3306 = @{ name='MySQL';    level='WARN'; reason='Base de donnees exposee sur le reseau' }
    3389 = @{ name='RDP';      level='CRIT'; reason='Bureau a distance expose — brute-force, BlueKeep' }
    5900 = @{ name='VNC';      level='CRIT'; reason='Acces distant VNC — souvent sans auth forte' }
    8080 = @{ name='HTTP-alt'; level='WARN'; reason='Service web alternatif' }
    8443 = @{ name='HTTPS-alt';level='INFO'; reason='Service web alternatif chiffre' }
}

if ($nmapAvailable) {
    Write-Step "nmap detecte — scan du reseau local en cours..."
    $networkConfig = Get-NetIPConfiguration |
        Where-Object { $_.IPv4DefaultGateway -ne $null -and $_.NetAdapter.Status -eq 'Up' } |
        Select-Object -First 1

    if ($networkConfig) {
        $ipLocal = $networkConfig.IPv4Address.IPAddress
        $octets  = $ipLocal -split '\.'
        $reseau  = "$($octets[0]).$($octets[1]).$($octets[2]).0/24"
        Write-Step "Detection des hotes actifs sur $reseau ..."
        $networkHosts = nmap -sn $reseau -oG - 2>$null |
            Where-Object { $_ -match 'Up' } |
            ForEach-Object { ($_ -split '\s+')[1] } |
            Sort-Object
        Write-OK "$($networkHosts.Count) hote(s) detecte(s)"

        foreach ($ip in $networkHosts) {
            Write-Step "Scan $ip ..."
            $dnsResult = Resolve-DnsName -Name $ip -Type PTR -ErrorAction SilentlyContinue
            $hostname  = if ($dnsResult) { ($dnsResult | Select-Object -First 1).NameHost -replace '\.','' } else { '(non resolu)' }
            $pingResult = Test-Connection -ComputerName $ip -Count 1 -ErrorAction SilentlyContinue
            $latency = 'N/A'
            if ($pingResult) {
                $props  = $pingResult.PSObject.Properties.Name
                $latVal = if ($props -contains 'Latency') { $pingResult.Latency } elseif ($props -contains 'ResponseTime') { $pingResult.ResponseTime } else { $null }
                if ($null -ne $latVal) { $latency = "$latVal ms" }
            }
            $portsLine = nmap -sV -T4 $ip -oG - 2>$null |
                Where-Object { $_ -match 'Ports:' } | Select-Object -First 1
            $hostRisk  = 'OK'
            $portsList = [System.Collections.ArrayList]::new()
            if ($portsLine) {
                $portsStr = $portsLine -replace '.*Ports:\s*',''
                foreach ($entry in ($portsStr -split ',\s*')) {
                    $parts   = $entry.Trim() -split '/'
                    if ($parts.Count -lt 2) { continue }
                    $port    = [int]($parts[0].Trim())
                    $state   = $parts[1].Trim()
                    $proto   = if ($parts.Count -ge 3) { $parts[2].Trim() } else { '' }
                    $service = if ($parts.Count -ge 5) { $parts[4].Trim() } else { '' }
                    $detail  = if ($parts.Count -ge 7) { ($parts[6..($parts.Count-1)] -join '/').Trim() } else { '' }
                    $portRisk   = 'INFO'
                    $portReason = ''
                    if ($state -eq 'open' -and $riskyPorts.ContainsKey($port)) {
                        $portRisk   = $riskyPorts[$port].level
                        $portReason = $riskyPorts[$port].reason
                        if ($portRisk -eq 'CRIT') { $hostRisk = 'CRIT'; $riskScore += 10 }
                        elseif ($portRisk -eq 'WARN' -and $hostRisk -ne 'CRIT') { $hostRisk = 'WARN'; $riskScore += 3 }
                    }
                    [void]$portsList.Add([PSCustomObject]@{
                        Port=($port); State=$state; Proto=$proto
                        Service=$service; Detail=$detail; Risk=$portRisk; Reason=$portReason
                    })
                }
            }
            [void]$networkData.Add([PSCustomObject]@{
                IP=$ip; Hostname=$hostname; Latency=$latency; Risk=$hostRisk; Ports=$portsList
            })
        }
        Write-OK "Scan reseau termine"
    }
} else {
    Write-WARN "nmap non trouve dans PATH — scan reseau ignore"
    Write-Host "  Installez nmap (https://nmap.org) pour activer le scan reseau." -ForegroundColor $C.Sep
}

# ──────────────────────────────────────────────────────────────
#  BLOC 4 — GÉNÉRATION RAPPORT HTML
# ──────────────────────────────────────────────────────────────
Write-Sep2
Write-Host "`n  [ BLOC 4 — GENERATION RAPPORT HTML ]" -ForegroundColor $C.Title
Write-Sep
Write-Step "Construction du rapport HTML Almerson..."

# Recalcul post-réseau
$scoreNiveau  = if ($riskScore -le 20) { 'FAIBLE' } elseif ($riskScore -le 50) { 'MOYEN' } else { 'ELEVE' }
$scoreColor   = if ($riskScore -le 20) { '#16a34a' } elseif ($riskScore -le 50) { '#d97706' } else { '#dc2626' }
$scoreBg      = if ($riskScore -le 20) { '#f0fdf4' } elseif ($riskScore -le 50) { '#fffbeb' } else { '#fff5f5' }
$critCount    = @($findings | Where-Object { $_.Niveau -eq 'CRIT' }).Count
$warnCount    = @($findings | Where-Object { $_.Niveau -eq 'WARN' }).Count
$okCount      = @($findings | Where-Object { $_.Niveau -eq 'OK'   }).Count
$topReco = @($findings | Where-Object { $_.Niveau -eq 'CRIT' -and $_.Recommandation -ne '' } | Select-Object -First 3)
if ($topReco.Count -lt 3) {
    $topReco += @($findings | Where-Object { $_.Niveau -eq 'WARN' -and $_.Recommandation -ne '' } | Select-Object -First (3 - $topReco.Count))
}

function hx([string]$s) {
    if (-not $s) { return '' }
    $s = $s -replace '[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]', ''
    $s -replace '&','&amp;' -replace '<','&lt;' -replace '>','&gt;' -replace '"','&quot;'
}

function niveauBadge([string]$n) {
    switch ($n) {
        'CRIT' { '<span class="badge crit">CRITIQUE</span>' }
        'WARN' { '<span class="badge warn">ATTENTION</span>' }
        'OK'   { '<span class="badge ok">OK</span>' }
        default { "<span class=`"badge`">$n</span>" }
    }
}

$cpuName    = if ($cpu)  { $cpu.Name.Trim() }              else { 'N/A' }
$cpuDetail  = if ($cpu)  { "$($cpu.NumberOfCores)c/$($cpu.NumberOfLogicalProcessors)t — $($cpu.MaxClockSpeed) MHz" } else { '' }
$biosSerial = if ($bios) { $bios.SerialNumber.Trim() }     else { 'N/A' }
$biosVer    = if ($bios) { $bios.SMBIOSBIOSVersion }       else { 'N/A' }

$html = [System.Text.StringBuilder]::new(200000)

[void]$html.Append(@"
<!DOCTYPE html>
<html lang="fr">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Audit Almerson — $(hx $NomCabinet)</title>
<style>
  *{box-sizing:border-box;margin:0;padding:0}
  body{font-family:Arial,sans-serif;font-size:13px;background:#f1f5f9;color:#1e293b}
  .page{max-width:1100px;margin:0 auto;padding:24px}
  .cover{background:#0f172a;color:#e2e8f0;padding:48px 40px 36px;border-radius:8px;margin-bottom:24px;text-align:center}
  .cover .brand{font-size:36px;font-weight:900;color:#00e8c8;letter-spacing:4px}
  .cover .sub{font-size:13px;color:#94a3b8;margin-top:4px;letter-spacing:2px}
  .cover hr{border:none;border-top:2px solid #00e8c8;margin:24px auto;width:200px}
  .cover .title{font-size:22px;font-weight:700;color:#f8fafc;margin-bottom:8px}
  .cover .client{font-size:16px;color:#00e8c8;font-weight:600;margin-bottom:6px}
  .cover .date{font-size:12px;color:#64748b}
  .cover .conf{font-size:11px;color:#475569;margin-top:16px}
  .section{background:#fff;border-radius:8px;padding:24px;margin-bottom:20px;box-shadow:0 1px 3px rgba(0,0,0,.08)}
  .section-title{font-size:15px;font-weight:700;color:#0f172a;padding-left:12px;border-left:4px solid #00e8c8;margin-bottom:16px}
  .kpi-grid{display:grid;grid-template-columns:repeat(5,1fr);gap:12px;margin-bottom:8px}
  .kpi{border-radius:6px;padding:14px;text-align:center}
  .kpi .label{font-size:10px;color:#94a3b8;text-transform:uppercase;letter-spacing:1px;margin-bottom:6px}
  .kpi .value{font-size:24px;font-weight:800}
  table{width:100%;border-collapse:collapse;font-size:12px}
  th{background:#0f172a;color:#00e8c8;text-align:left;padding:8px 10px;font-size:11px;text-transform:uppercase;letter-spacing:.5px}
  td{padding:7px 10px;border-bottom:1px solid #e2e8f0;color:#334155}
  tr:last-child td{border-bottom:none}
  tr:nth-child(even) td{background:#f8fafc}
  .badge{display:inline-block;padding:2px 8px;border-radius:4px;font-size:10px;font-weight:700;letter-spacing:.5px}
  .badge.crit{background:#fff5f5;color:#dc2626}
  .badge.warn{background:#fffbeb;color:#d97706}
  .badge.ok  {background:#f0fdf4;color:#16a34a}
  .reco-card{display:grid;grid-template-columns:40px 1fr;gap:0;margin-bottom:10px;border-radius:6px;overflow:hidden;border:1px solid #e2e8f0}
  .reco-num{background:#0f172a;color:#00e8c8;font-weight:800;font-size:18px;display:flex;align-items:center;justify-content:center}
  .reco-body{padding:10px 14px}
  .reco-body .reco-titre{font-weight:700;font-size:12px;margin-bottom:4px}
  .reco-body .reco-detail{font-size:11px;color:#64748b}
  .infra-label{background:#f1f5f9;color:#475569;font-weight:600;width:35%}
  .footer{background:#0f172a;color:#94a3b8;text-align:center;padding:18px;border-radius:8px;font-size:11px;margin-top:8px}
  .footer strong{color:#00e8c8}
  @media print{body{background:#fff}.section{box-shadow:none;border:1px solid #e2e8f0}}
</style>
</head>
<body>
<div class="page">

<div class="cover">
  <div class="brand">ALMERSON</div>
  <div class="sub">SECURE INFRASTRUCTURE</div>
  <hr>
  <div class="title">Rapport d'Audit Sécurité et Infrastructure</div>
  <div class="client">$(hx $NomCabinet)</div>
  <div class="date">Généré le $dateDisplay</div>
  <div class="conf">Document confidentiel — destiné exclusivement au responsable informatique du cabinet.</div>
</div>

<div class="section">
  <div class="section-title">Résumé Exécutif</div>
  <div class="kpi-grid">
    <div class="kpi" style="background:$scoreBg">
      <div class="label">Score de risque</div>
      <div class="value" style="color:$scoreColor">$riskScore pts</div>
      <div style="font-size:11px;color:$scoreColor;font-weight:700;margin-top:4px">$scoreNiveau</div>
    </div>
    <div class="kpi" style="background:#f8fafc">
      <div class="label">Contrôles</div>
      <div class="value" style="color:#0f172a">$($findings.Count)</div>
    </div>
    <div class="kpi" style="background:#fff5f5">
      <div class="label">Critiques</div>
      <div class="value" style="color:#dc2626">$critCount</div>
    </div>
    <div class="kpi" style="background:#fffbeb">
      <div class="label">Attentions</div>
      <div class="value" style="color:#d97706">$warnCount</div>
    </div>
    <div class="kpi" style="background:#f0fdf4">
      <div class="label">OK</div>
      <div class="value" style="color:#16a34a">$okCount</div>
    </div>
  </div>
</div>

"@)

[void]$html.Append('<div class="section"><div class="section-title">Recommandations Prioritaires</div>')
if ($topReco.Count -eq 0) {
    [void]$html.Append('<p style="color:#16a34a;font-weight:600">Aucun point critique identifié — bon niveau de sécurité.</p>')
} else {
    $ri = 1
    foreach ($r in $topReco) {
        $rc = if ($r.Niveau -eq 'CRIT') { '#dc2626' } else { '#d97706' }
        $rb = if ($r.Niveau -eq 'CRIT') { '#fff5f5' } else { '#fffbeb' }
        [void]$html.Append("<div class=`"reco-card`"><div class=`"reco-num`">$ri</div><div class=`"reco-body`" style=`"background:$rb`"><div class=`"reco-titre`" style=`"color:$rc`">$(hx $r.Titre)</div><div class=`"reco-detail`">$(hx $r.Recommandation)</div></div></div>")
        $ri++
    }
}
[void]$html.Append('</div>')

[void]$html.Append('<div class="section"><div class="section-title">Contrôles de Sécurité</div><table><thead><tr><th>Catégorie</th><th>Niveau</th><th>Détail / Recommandation</th></tr></thead><tbody>')
foreach ($f in $findings) {
    $detail = hx $f.Titre
    if ($f.Recommandation) { $detail += " — " + (hx $f.Recommandation) }
    [void]$html.Append("<tr><td>$(hx $f.Categorie)</td><td>$(niveauBadge $f.Niveau)</td><td>$detail</td></tr>")
}
[void]$html.Append('</tbody></table></div>')

[void]$html.Append('<div class="section"><div class="section-title">Infrastructure du Poste Audité</div><table><tbody>')
$infraRows = @(
    @('Nom du poste',         "$($cs.Name)"),
    @('Fabricant / Modèle',   "$(hx $cs.Manufacturer) $(hx $cs.Model)"),
    @('Système exploitation', "$(hx $os.Caption) — Build $($os.BuildNumber)"),
    @('Edition / Licence',    "$(hx $winEdition) — $licStatus ($licType)"),
    @('Clé partielle',        "$(hx $partialKey)"),
    @('Processeur',           "$(hx $cpuName) — $cpuDetail"),
    @('RAM',                  "$totalRamGb GB ($($ramSlots.Count) slot(s))"),
    @('Numéro de série',      "$(hx $biosSerial)"),
    @('Version BIOS',         "$(hx $biosVer)"),
    @('Logiciels installés',  "$($softwares.Count) applications détectées")
)
foreach ($row in $infraRows) {
    [void]$html.Append("<tr><td class=`"infra-label`">$($row[0])</td><td>$($row[1])</td></tr>")
}
[void]$html.Append('</tbody></table>')

[void]$html.Append('<br><strong style="color:#0f172a;font-size:12px">Stockage</strong><br><br><table><thead><tr><th>Disque</th><th>Capacité</th><th>Type</th></tr></thead><tbody>')
foreach ($d in $disks) {
    $gb = [math]::Round($d.Size/1GB,0)
    if ($gb -gt 0) {
        [void]$html.Append("<tr><td>$(hx $d.Model.Trim())</td><td style=`"text-align:center`">$gb GB</td><td>$(hx $d.MediaType)</td></tr>")
    }
}
[void]$html.Append('</tbody></table>')

[void]$html.Append('<br><strong style="color:#0f172a;font-size:12px">Mémoire RAM</strong><br><br><table><thead><tr><th>Slot RAM</th><th>Fréquence</th><th>Fabricant</th></tr></thead><tbody>')
foreach ($slot in $ramSlots) {
    $gb = [math]::Round($slot.Capacity/1GB,0)
    [void]$html.Append("<tr><td>$gb GB</td><td style=`"text-align:center`">$($slot.Speed) MHz</td><td>$(hx $slot.Manufacturer)</td></tr>")
}
[void]$html.Append('</tbody></table>')

[void]$html.Append('<br><strong style="color:#0f172a;font-size:12px">Interfaces Réseau</strong><br><br><table><thead><tr><th>Interface</th><th>Adresse IP</th><th>Adresse MAC</th></tr></thead><tbody>')
foreach ($nic in $nics) {
    [void]$html.Append("<tr><td>$(hx $nic.Description)</td><td style=`"text-align:center`">$(hx $nic.IPAddress[0])</td><td style=`"text-align:center`">$(hx $nic.MACAddress)</td></tr>")
}
[void]$html.Append('</tbody></table></div>')

[void]$html.Append('<div class="section"><div class="section-title">Scan Réseau Local</div>')
if ($networkData.Count -eq 0) {
    [void]$html.Append('<p style="color:#94a3b8;font-style:italic">Scan réseau non disponible — nmap requis dans PATH.</p>')
} else {
    foreach ($h in $networkData) {
        $hc = if ($h.Risk -eq 'CRIT') { '#dc2626' } elseif ($h.Risk -eq 'WARN') { '#d97706' } else { '#1e293b' }
        [void]$html.Append("<p style=`"font-weight:700;color:$hc;margin-bottom:8px`">$(hx $h.IP) &nbsp; $(hx $h.Hostname) &nbsp; <span style=`"font-weight:400;color:#64748b;font-size:11px`">(latence : $(hx $h.Latency))</span></p>")
        [void]$html.Append('<table><thead><tr><th>Port</th><th>État</th><th>Service</th><th>Risque</th><th>Détail</th></tr></thead><tbody>')
        if ($h.Ports.Count -gt 0) {
            foreach ($p in $h.Ports) {
                $pDetail = hx $p.Detail
                if ($p.Reason) { $pDetail += " — " + (hx $p.Reason) }
                $pBadge = if ($p.Risk -ne 'INFO') { niveauBadge $p.Risk } else { '' }
                [void]$html.Append("<tr><td><strong>$(hx "$($p.Port)/$($p.Proto)")</strong></td><td>$(hx $p.State)</td><td>$(hx $p.Service)</td><td>$pBadge</td><td style=`"font-size:11px`">$pDetail</td></tr>")
            }
        } else {
            [void]$html.Append('<tr><td colspan="5" style="color:#94a3b8;font-style:italic">Aucun port détecté.</td></tr>')
        }
        [void]$html.Append('</tbody></table><br>')
    }
}
[void]$html.Append('</div>')

$swLimit = [math]::Min($softwares.Count, 150)
[void]$html.Append("<div class=`"section`"><div class=`"section-title`">Logiciels Installés ($($softwares.Count) applications)</div><table><thead><tr><th>Application</th><th>Version</th><th>Éditeur</th></tr></thead><tbody>")
for ($i = 0; $i -lt $swLimit; $i++) {
    $sw = $softwares[$i]
    [void]$html.Append("<tr><td>$(hx $sw.name)</td><td style=`"text-align:center`">$(hx $sw.version)</td><td>$(hx $sw.publisher)</td></tr>")
}
if ($softwares.Count -gt 150) {
    [void]$html.Append("<tr><td colspan=`"3`" style=`"color:#94a3b8;font-style:italic`">... et $($softwares.Count - 150) autres (liste tronquée à 150).</td></tr>")
}
[void]$html.Append('</tbody></table></div>')

[void]$html.Append(@"
<div class="footer">
  <strong>ALMERSON</strong> — Cybersécurité et IT pour les professionnels du droit et du chiffre<br>
  <span>www.almerson.com — Document confidentiel — $(hx $NomCabinet) — $dateDisplay</span><br><br>
  <span style="color:#00e8c8;font-weight:700">Un point critique détecté ? Contactez-nous pour un accompagnement personnalisé.</span><br>
  <span>
    <a href="https://www.almerson.com" style="color:#00e8c8;text-decoration:none">&#127760; www.almerson.com</a>
    &nbsp;|&nbsp;
    <a href="https://www.almerson.com#contact" style="color:#00e8c8;text-decoration:none">&#128197; Prendre rendez-vous</a>
  </span>
</div>

</div></body></html>
"@)

$rapportFinal = $null
try {
    $htmlContent = $html.ToString()
    [System.IO.File]::WriteAllText($rapportHtml, $htmlContent, [System.Text.UTF8Encoding]::new($false))
    $rapportFinal = $rapportHtml
    Write-OK "Rapport HTML genere : $rapportHtml"
} catch {
    Write-WARN "Erreur generation HTML : $($_.Exception.Message)"
    $rapportFinal = $null
}

# ──────────────────────────────────────────────────────────────
#  FIN — RÉSUMÉ CONSOLE
# ──────────────────────────────────────────────────────────────
Write-Sep2
Write-Host ""
Write-Host "  AUDIT TERMINE" -ForegroundColor $C.Title
Write-Sep
Write-Host "  Score de risque  : $riskScore pts - Niveau $scoreNiveau" -ForegroundColor $scoreCouleurConsole
Write-Host "  Points critiques : $critCount" -ForegroundColor $(if ($critCount -gt 0) { 'Red' } else { 'Green' })
Write-Host "  Avertissements   : $warnCount" -ForegroundColor $(if ($warnCount -gt 0) { 'Yellow' } else { 'Green' })
Write-Host "  Controles OK     : $okCount"   -ForegroundColor 'Green'
Write-Sep
if ($rapportFinal) {
    Write-Host "  Rapport          : $rapportFinal" -ForegroundColor $C.Val
    Write-Sep2
    Write-Host ""
    Invoke-Item $rapportFinal
} else {
    Write-CRIT "Rapport non genere — voir erreurs ci-dessus."
    Write-Sep2
}
