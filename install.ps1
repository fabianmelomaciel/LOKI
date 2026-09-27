# Loki — Instalador Windows (PowerShell 5.1 safe, BOM UTF-8)
# Cobertura de SO: Windows (PowerShell 5.1+ y pwsh 7+ cross-platform).
# Linux/macOS/BSD/WSL → usar install.sh (POSIX puro).
# Instala la skill en opencode y Claude Code. Detecta herramientas T0 y delegación.
# Uso:
#   .\install.ps1                    # instalar (default all)
#   .\install.ps1 -Target opencode   # solo opencode
#   .\install.ps1 -Check             # verificar sincronía repo ↔ instalación
#   .\install.ps1 -Uninstall         # desinstalar de todos los destinos

param(
    [string]$Target = "all",
    [switch]$Check,
    [switch]$Uninstall
)

$ErrorActionPreference = "Stop"
$Src = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillName = "loki"
$SkillVersion = "1.0.0"

$DestRoots = @()
if ($Target -eq "all" -or $Target -eq "opencode") {
    $DestRoots += (Join-Path $env:USERPROFILE ".config\opencode\skills")
}
if ($Target -eq "all" -or $Target -eq "claude") {
    $DestRoots += (Join-Path $env:USERPROFILE ".claude\skills")
}

# Lista canónica de archivos (fuente única — mantener en sync con install.sh)
$FileList = @(
    "SKILL.md", "README.md", "LICENSE", "SECURITY.md",
    "docs", "references", "templates", "scripts"
)

function Get-FileHash256($path) {
    (Get-FileHash -Path $path -Algorithm SHA256).Hash.ToLower()
}

function Install-Skill($DestRoot) {
    if (-not (Test-Path $DestRoot)) {
        New-Item -ItemType Directory -Path $DestRoot -Force | Out-Null
    }
    $Dest = Join-Path $DestRoot $SkillName
    if (Test-Path $Dest) {
        Remove-Item -Recurse -Force $Dest
    }
    New-Item -ItemType Directory -Path $Dest -Force | Out-Null

    foreach ($f in $FileList) {
        $srcPath = Join-Path $Src $f
        if (Test-Path $srcPath) {
            Copy-Item $srcPath (Join-Path $Dest $f) -Recurse -Force
        }
    }
    # CODEX.md NO se copia (local-only / puede contener rutas internas)
    Write-Output ("  OK -> " + $Dest + "  (v" + $SkillVersion + ")")
}

function Test-Sync($DestRoot) {
    $Dest = Join-Path $DestRoot $SkillName
    if (-not (Test-Path (Join-Path $Dest "SKILL.md"))) {
        Write-Host ("  [MISS]  " + $Dest + " — no instalada")
        return $false
    }
    $srcSkill = Join-Path $Src "SKILL.md"
    $dstSkill = Join-Path $Dest "SKILL.md"
    $h1 = Get-FileHash256 $srcSkill
    $h2 = Get-FileHash256 $dstSkill
    if ($h1 -eq $h2) {
        Write-Host ("  [SYNC]  " + $Dest)
        return $true
    }
    # Detectar versión instalada
    $installed = ""
    $first = Get-Content $dstSkill -TotalCount 5 | Out-String
    if ($first -match "version:\s*(\S+)") { $installed = $Matches[1] }
    Write-Host ("  [DRIFT] " + $Dest + " — instalada v" + $installed + " vs repo v" + $SkillVersion + " → re-ejecutá install.ps1")
    return $false
}

function Uninstall-Skill($DestRoot) {
    $Dest = Join-Path $DestRoot $SkillName
    if (Test-Path $Dest) {
        Remove-Item -Recurse -Force $Dest
        Write-Output ("  [DEL]   " + $Dest)
    } else {
        Write-Output ("  [SKIP]  " + $Dest + " no existe")
    }
}

Write-Output ""
Write-Output ("🔐 Loki Installer v" + $SkillVersion)

if ($Uninstall) {
    Write-Output "=== UNINSTALL ==="
    $i = 1
    foreach ($dr in $DestRoots) {
        Write-Output ("[" + $i + "/" + $DestRoots.Count + "] " + $dr)
        Uninstall-Skill $dr
        $i++
    }
    Write-Output ""
    exit 0
}

if ($Check) {
    Write-Output "=== CHECK (repo vs instalación) ==="
    $i = 1
    $allOk = $true
    foreach ($dr in $DestRoots) {
        Write-Output ("[" + $i + "/" + $DestRoots.Count + "] " + $dr)
        if (-not (Test-Sync $dr)) { $allOk = $false }
        $i++
    }
    # Delegación SkillGrid
    Write-Output ""
    Write-Output "[delegacion] SkillGrid skills:"
    $sgSkills = @("auditor-de-seguridad","cyber-neo","hack-audit","audit-loop","supply-chain-auditor","prompt-injection-guard")
    $sgRoots = @("$env:SKILLGRID", "C:\laragon\www\SkillGrid\skills")
    foreach ($s in $sgSkills) {
        $found = $false
        foreach ($r in $sgRoots) {
            if ($r -and (Test-Path (Join-Path $r "$s\SKILL.md"))) { $found = $true; break }
        }
        if ($found) { Write-Output ("  [OK]    " + $s) } else { Write-Output ("  [MISS]  " + $s) }
    }
    Write-Output ""
    if ($allOk) { Write-Output "RESULTADO: SYNC"; exit 0 } else { Write-Output "RESULTADO: DRIFT — re-instalar"; exit 1 }
}

# === INSTALL ===
$i = 1
foreach ($dr in $DestRoots) {
    Write-Output ("[" + $i + "/" + $DestRoots.Count + "] " + $dr)
    Install-Skill $dr
    $i++
}

# Matriz de herramientas T0
Write-Output ""
Write-Output "[tools] Matriz de herramientas T0 (deteccion):"
$tools = @("semgrep","trivy","gitleaks","trufflehog","checkov","bandit","safety","nuclei","nmap","ffuf","nikto","node","npm","git")
$avail = @()
$missing = @()
foreach ($t in $tools) {
    $cmd = Get-Command $t -ErrorAction SilentlyContinue
    if ($cmd) { $avail += $t; Write-Output ("  [OK]    " + $t) }
    else { $missing += $t; Write-Output ("  [MISS]  " + $t) }
}
Write-Output ("Disponibles: " + $avail.Count + "/" + $tools.Count)
if ($missing.Count -gt 0) {
    Write-Output ("Faltantes (se declaran en el informe): " + ($missing -join ", "))
    $setup = "C:\laragon\www\SkillGrid\scripts\setup-security-tools.ps1"
    if (Test-Path $setup) { Write-Output ("Instalar opcionales: pwsh -File `"" + $setup + "`"") }
}

# Delegación SkillGrid
Write-Output ""
Write-Output "[delegacion] SkillGrid skills:"
$sgSkills = @("auditor-de-seguridad","cyber-neo","hack-audit","audit-loop","supply-chain-auditor","prompt-injection-guard")
$sgRoots = @("$env:SKILLGRID", "C:\laragon\www\SkillGrid\skills")
foreach ($s in $sgSkills) {
    $found = $false
    foreach ($r in $sgRoots) {
        if ($r -and (Test-Path (Join-Path $r "$s\SKILL.md"))) { $found = $true; break }
    }
    if ($found) { Write-Output ("  [OK]    " + $s) } else { Write-Output ("  [MISS]  " + $s + " — fallback T0-only") }
}

Write-Output ""
Write-Output ("✅ Instalado v" + $SkillVersion + ". Uso: 'Audita <target> con Loki'.")
Write-Output "⚠️  5 gates de autorizacion requeridos antes de cualquier accion activa."
Write-Output ""
