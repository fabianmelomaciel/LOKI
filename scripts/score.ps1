# Loki - score.ps1: precision / recall / F1 vs ground truth
# Uso: powershell -File scripts\score.ps1 -Findings reports\X\vulnerabilities.json -GroundTruth references\groundtruth\juice-shop.json
# Documentado en docs/BENCHMARK.md paso 4. Salida: JSON en stdout.
param(
    [Parameter(Mandatory = $true)][string]$Findings,
    [Parameter(Mandatory = $true)][string]$GroundTruth
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $Findings)) { throw "No existe: $Findings" }
if (-not (Test-Path $GroundTruth)) { throw "No existe: $GroundTruth" }

$f = Get-Content $Findings -Raw | ConvertFrom-Json
$g = Get-Content $GroundTruth -Raw | ConvertFrom-Json
if (-not $f.findings) { throw "vulnerabilities.json sin campo findings" }
if (-not $g.known) { throw "ground truth sin campo known" }

$known = @($g.known)
$matchedKnown = @{}
$tp = 0
$unmatchedFindings = @()

foreach ($fi in $f.findings) {
    $hit = $null
    foreach ($k in $known) {
        if ($matchedKnown.ContainsKey($k.id)) { continue }
        if ($fi.cwe -ne $k.cwe) { continue }
        $ok = $true
        if ($k.PSObject.Properties.Name -contains "endpoint_hint") {
            $ep = ""
            if ($fi.PSObject.Properties.Name -contains "endpoint" -and $fi.endpoint) { $ep = $fi.endpoint }
            if ($ep.ToLower().IndexOf($k.endpoint_hint.ToLower()) -lt 0) { $ok = $false }
        }
        if ($k.PSObject.Properties.Name -contains "file_hint") {
            $fl = ""
            if ($fi.PSObject.Properties.Name -contains "file" -and $fi.file) { $fl = $fi.file }
            if ($fl.ToLower().IndexOf($k.file_hint.ToLower()) -lt 0) { $ok = $false }
        }
        if ($ok) { $hit = $k.id; break }
    }
    if ($hit) { $tp++; $matchedKnown[$hit] = $true }
    else { $unmatchedFindings += $fi.id }
}

$fn = @($known | Where-Object { -not $matchedKnown.ContainsKey($_.id) }).Count
$fp = $unmatchedFindings.Count
$precision = if (($tp + $fp) -gt 0) { [math]::Round($tp / ($tp + $fp), 4) } else { 0 }
$recall = if (($tp + $fn) -gt 0) { [math]::Round($tp / ($tp + $fn), 4) } else { 0 }
$f1 = if (($precision + $recall) -gt 0) { [math]::Round(2 * $precision * $recall / ($precision + $recall), 4) } else { 0 }

$result = [ordered]@{
    target              = $g.target
    findings_total      = @($f.findings).Count
    known_total         = $known.Count
    tp                  = $tp
    fp                  = $fp
    fn                  = $fn
    precision           = $precision
    recall              = $recall
    f1                  = $f1
    matched_known       = @($matchedKnown.Keys)
    uncovered_known     = @($known | Where-Object { -not $matchedKnown.ContainsKey($_.id) } | ForEach-Object { $_.id })
    unmatched_findings  = $unmatchedFindings
    note                = "revisar uncovered_known y unmatched_findings a mano antes de publicar (matching cwe+hint, ver groundtruth)"
}

$result | ConvertTo-Json -Depth 5
