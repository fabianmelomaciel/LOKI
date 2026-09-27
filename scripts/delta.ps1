# Loki - delta.ps1: re-run incremental - que cambio respecto de la corrida previa?
# Clave de match: CWE+file+line (mismo criterio de dedup T1, ver execution-tiers.md).
# Solo los hallazgos "new"/"fixed" escalan a T2/informe; unchanged no re-gasta tokens.
# Uso: powershell -File scripts\delta.ps1 -Prev reports\prev\vulnerabilities.json -Curr reports\new\vulnerabilities.json
param(
    [Parameter(Mandatory = $true)][string]$Prev,
    [Parameter(Mandatory = $true)][string]$Curr
)

$ErrorActionPreference = "Stop"
if (-not (Test-Path $Prev)) { throw "No existe: $Prev" }
if (-not (Test-Path $Curr)) { throw "No existe: $Curr" }

function Get-Key($f) {
    $ln = ""
    if ($f.PSObject.Properties.Name -contains "line" -and $null -ne $f.line) { $ln = [string]$f.line }
    return ("{0}|{1}|{2}" -f $f.cwe, $f.file, $ln).ToLower()
}

$prevMap = @{}
foreach ($f in @(Get-Content $Prev -Raw | ConvertFrom-Json).findings) { $prevMap[(Get-Key $f)] = $f }
$currMap = @{}
foreach ($f in @(Get-Content $Curr -Raw | ConvertFrom-Json).findings) { $currMap[(Get-Key $f)] = $f }

$new = @($currMap.Keys | Where-Object { -not $prevMap.ContainsKey($_) } | ForEach-Object { $currMap[$_] })
$fixed = @($prevMap.Keys | Where-Object { -not $currMap.ContainsKey($_) } | ForEach-Object { $prevMap[$_] })
$unchanged = $currMap.Keys.Count - $new.Count

$result = [ordered]@{
    prev_total  = $prevMap.Count
    curr_total  = $currMap.Count
    new         = @($new | ForEach-Object { $_.id })
    fixed       = @($fixed | ForEach-Object { $_.id })
    new_items   = $new
    fixed_items = $fixed
    unchanged   = $unchanged
    note        = "new/fixed escalan; unchanged no re-procesa"
}

$result | ConvertTo-Json -Depth 6
