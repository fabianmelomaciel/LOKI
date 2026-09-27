# Loki — Instalador Windows (PowerShell 5.1 safe, BOM UTF-8)
# Cobertura de SO: Windows (PowerShell 5.1+ y pwsh 7+ cross-platform).
# Linux/macOS/BSD/WSL → usar install.sh (POSIX puro).
# Instala la skill en opencode y Claude Code. Detecta herramientas T0 y delegación.
# Uso:
#   .\install.ps1                    # instalar (default all)
#   .\install.ps1 -Target opencode   # solo opencode
#   .\install.ps1 -Target gemini     # solo slash-commands de Gemini CLI (sin skill)
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

# Fuente única de versión + lista de archivos (sync con install.sh) — ver loki.manifest.sh
$ManifestPath = Join-Path $Src "loki.manifest.sh"
$ManifestContent = Get-Content $ManifestPath -Raw
if ($ManifestContent -notmatch 'LOKI_VERSION="([^"]+)"') {
    throw "loki.manifest.sh: no se pudo leer LOKI_VERSION"
}
$SkillVersion = $Matches[1]
if ($ManifestContent -notmatch 'LOKI_FILES="([^"]+)"') {
    throw "loki.manifest.sh: no se pudo leer LOKI_FILES"
}
$FileList = $Matches[1] -split '\s+' | Where-Object { $_ -ne "" }
if ($ManifestContent -notmatch 'LOKI_CMD_LIST="([^"]+)"') {
    throw "loki.manifest.sh: no se pudo leer LOKI_CMD_LIST"
}
$CmdList = $Matches[1] -split '\s+' | Where-Object { $_ -ne "" }

$DestRoots = @()
if ($Target -eq "all" -or $Target -eq "opencode") {
    $DestRoots += (Join-Path $env:USERPROFILE ".config\opencode\skills")
}
if ($Target -eq "all" -or $Target -eq "claude") {
    $DestRoots += (Join-Path $env:USERPROFILE ".claude\skills")
}

# Destinos de slash-commands (fuente: .opencode/commands/, .claude/commands/ y
# .gemini/commands/ del repo). Cada motor aporta su extensión: .md / .md / .toml
$CmdTargets = @()
if ($Target -eq "all" -or $Target -eq "opencode") {
    $CmdTargets += @{ Src = Join-Path $Src ".opencode\commands"; Dst = Join-Path $env:USERPROFILE ".config\opencode\commands"; Ext = ".md" }
}
if ($Target -eq "all" -or $Target -eq "claude") {
    $CmdTargets += @{ Src = Join-Path $Src ".claude\commands"; Dst = Join-Path $env:USERPROFILE ".claude\commands"; Ext = ".md" }
}
if ($Target -eq "all" -or $Target -eq "gemini") {
    $CmdTargets += @{ Src = Join-Path $Src ".gemini\commands"; Dst = Join-Path $env:USERPROFILE ".gemini\commands"; Ext = ".toml" }
}

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
    $drift = @()
    foreach ($f in $FileList) {
        $srcPath = Join-Path $Src $f
        if (-not (Test-Path $srcPath)) { continue }
        if (Test-Path $srcPath -PathType Container) {
            $dstTree = Join-Path $Dest $f
            foreach ($sf in (Get-ChildItem -Path $srcPath -Recurse -File)) {
                $rel = $sf.FullName.Substring((Get-Item $srcPath).FullName.Length).TrimStart('\', '/')
                $df = Join-Path $dstTree $rel
                if (-not (Test-Path $df)) { $drift += "falta: $f/$rel" }
                elseif ((Get-FileHash256 $sf.FullName) -ne (Get-FileHash256 $df)) { $drift += "difiere: $f/$rel" }
            }
            if (Test-Path $dstTree) {
                $dstBase = (Get-Item $dstTree).FullName
                foreach ($dfx in (Get-ChildItem -Path $dstTree -Recurse -File)) {
                    $rel = $dfx.FullName.Substring($dstBase.Length).TrimStart('\', '/')
                    if (-not (Test-Path (Join-Path $srcPath $rel))) { $drift += "extra (posible inyeccion): $f/$rel" }
                }
            }
        } else {
            $df = Join-Path $Dest $f
            if (-not (Test-Path $df)) { $drift += "falta: $f" }
            elseif ((Get-FileHash256 $srcPath) -ne (Get-FileHash256 $df)) { $drift += "difiere: $f" }
        }
    }
    if ($drift.Count -eq 0) {
        Write-Host ("  [SYNC]  " + $Dest)
        return $true
    }
    $drift | Select-Object -First 8 | ForEach-Object { Write-Host ("  [DRIFT] " + $_) }
    $installed = ""
    $first = Get-Content (Join-Path $Dest "SKILL.md") -TotalCount 5 | Out-String
    if ($first -match "version:\s*(\S+)") { $installed = $Matches[1] }
    Write-Host ("  [DRIFT] " + $Dest + " — " + $drift.Count + " archivo(s) alterado(s)/faltante(s), instalada v" + $installed + " vs repo v" + $SkillVersion + " → re-ejecutá install.ps1")
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

function Install-Cmds {
    foreach ($t in $CmdTargets) {
        if (-not (Test-Path $t.Dst)) { New-Item -ItemType Directory -Path $t.Dst -Force | Out-Null }
        foreach ($s in $CmdList) {
            $name = $s + $t.Ext
            $srcFile = Join-Path $t.Src $name
            if (-not (Test-Path $srcFile)) {
                Write-Output ("  [WARN] comando fuente no existe en repo: " + $srcFile)
                continue
            }
            Copy-Item $srcFile (Join-Path $t.Dst $name) -Force
        }
        Write-Output ("  OK -> " + $t.Dst + "  (slash-commands)")
    }
}

function Test-CmdSync {
    $drift = @()
    foreach ($t in $CmdTargets) {
        foreach ($s in $CmdList) {
            $name = $s + $t.Ext
            $srcFile = Join-Path $t.Src $name
            $dstFile = Join-Path $t.Dst $name
            if (-not (Test-Path $srcFile)) { $drift += "comando fuente no existe en repo: $srcFile"; continue }
            if (-not (Test-Path $dstFile)) { $drift += "comando falta: $dstFile" }
            elseif ((Get-FileHash256 $srcFile) -ne (Get-FileHash256 $dstFile)) { $drift += "comando difiere: $dstFile" }
        }
    }
    foreach ($d in $drift) { Write-Host ("  [DRIFT] " + $d) }
    return ($drift.Count -eq 0)
}

function Uninstall-Cmds {
    foreach ($t in $CmdTargets) {
        foreach ($s in $CmdList) {
            $dstFile = Join-Path $t.Dst ($s + $t.Ext)
            if (Test-Path $dstFile) { Remove-Item -Force $dstFile; Write-Output ("  [DEL]   " + $dstFile) }
        }
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
    Uninstall-Cmds
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
    if (-not (Test-CmdSync)) { $allOk = $false }
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
Install-Cmds

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
