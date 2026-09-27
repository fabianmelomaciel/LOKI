# Loki - digest-sarif.ps1: SARIF grande -> JSON compacto para T1
# Enforce de references/execution-tiers.md (T1): nunca dumps al contexto; snippet <= 10 lineas.
# Uso: powershell -File scripts\digest-sarif.ps1 -Sarif .loki\t0\semgrep.sarif [-OutFile .loki\t0\semgrep.digest.json]
param(
    [Parameter(Mandatory = $true)][string]$Sarif,
    [string]$OutFile,
    [int]$MaxSnippetLines = 10,
    [int]$MaxSnippetChars = 800
)

$ErrorActionPreference = "Stop"
if (-not (Test-Path $Sarif)) { throw "No existe: $Sarif" }

$s = Get-Content $Sarif -Raw | ConvertFrom-Json
$out = @()

foreach ($run in @($s.runs)) {
    $ruleMap = @{}
    if ($run.tool.driver.rules) {
        foreach ($r in @($run.tool.driver.rules)) { $ruleMap[$r.id] = $r.shortDescription.text }
    }
    foreach ($res in @($run.results)) {
        $file = $null; $line = $null
        if ($res.locations -and $res.locations[0].physicalLocation) {
            $pl = $res.locations[0].physicalLocation
            if ($pl.artifactLocation) { $file = $pl.artifactLocation.uri }
            if ($pl.region) { $line = $pl.region.startLine }
        }
        $title = $null
        if ($ruleMap.ContainsKey([string]$res.ruleId)) { $title = $ruleMap[[string]$res.ruleId] }
        $snippet = ""
        if ($file -and $line) {
            $path = $file -replace '^file:///', '' -replace '^/', ''
            if (Test-Path $path) {
                $lines = Get-Content $path -Encoding UTF8 -ErrorAction SilentlyContinue
                $start = [math]::Max(0, $line - 1)
                $end = [math]::Min($lines.Count - 1, $start + $MaxSnippetLines - 1)
                if ($end -ge $start) {
                    $snippet = ($lines[$start..$end] -join "`n")
                    if ($snippet.Length -gt $MaxSnippetChars) { $snippet = $snippet.Substring(0, $MaxSnippetChars) }
                }
            }
        }
        $out += [ordered]@{
            rule    = [string]$res.ruleId
            title   = $title
            file    = $file
            line    = $line
            level   = [string]$res.level
            snippet = $snippet
        }
    }
}

$json = $out | ConvertTo-Json -Depth 4
if ($OutFile) { Set-Content -Path $OutFile -Value $json -Encoding UTF8; Write-Output ("digest: " + $out.Count + " resultados -> " + $OutFile) }
else { Write-Output $json }
