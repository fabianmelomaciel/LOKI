# Loki — Calculadora de métricas FinOps
# Uso: .\scripts\metrics.ps1 -RunDir reports/<fecha>-<target>
# Lee run.json + vulnerabilities.json (y reports/index.jsonl para tendencia).
# PS 5.1 safe — guardar con BOM UTF-8.

param(
    [Parameter(Mandatory = $true)]
    [string]$RunDir
)

$ErrorActionPreference = "Stop"
$runPath = Join-Path $RunDir "run.json"
$vulnPath = Join-Path $RunDir "vulnerabilities.json"

if (-not (Test-Path $runPath)) { Write-Error "No existe $runPath"; exit 1 }
if (-not (Test-Path $vulnPath)) { Write-Error "No existe $vulnPath"; exit 1 }

$run = Get-Content -Raw $runPath | ConvertFrom-Json
$vuln = Get-Content -Raw $vulnPath | ConvertFrom-Json

$findings = @($vuln.findings)
$total = $findings.Count
$cost = [double]$run.llm_usage.cost_usd
$inTok = [int]$run.llm_usage.input_tokens
$outTok = [int]$run.llm_usage.output_tokens
$tok = [double]($inTok + $outTok)

# % hallazgos de T0 (tier t0-*)
$t0 = @($findings | Where-Object { $_.tier -like "t0*" }).Count
$pctT0 = if ($total -gt 0) { [math]::Round(100 * $t0 / $total, 1) } else { 0 }

# findings/USD y findings/1K tokens
$fPerUsd = if ($cost -gt 0) { [math]::Round($total / $cost, 2) } else { "inf (T0 gratis)" }
$fPer1k = if ($tok -gt 0) { [math]::Round($total / ($tok / 1000), 3) } else { 0 }

# FP rechazados
$fp = @($findings | Where-Object { $_.status -eq "rejected_fp" }).Count
$fpRate = if (($total + $fp) -gt 0) { [math]::Round(100 * $fp / ($total + $fp), 1) } else { 0 }

# conteos por severidad
$sev = @{}
foreach ($s in @("critical", "high", "medium", "low", "info")) {
    $sev[$s] = @($findings | Where-Object { $_.severity -eq $s }).Count
}

Write-Output ""
Write-Output "📊 Métricas Loki — $RunDir"
Write-Output "--------------------------------------------------"
Write-Output ("status             : " + $run.status + " | mode: " + $run.mode)
Write-Output ("wall_clock_s       : " + $run.wall_clock_s)
Write-Output ("cost_usd           : " + $cost + " (cap: " + $run.budget.cap_usd + ")")
Write-Output ("tokens in/out      : " + $inTok + " / " + $outTok)
Write-Output ("findings total     : " + $total)
Write-Output ("  critical/high    : " + $sev["critical"] + "/" + $sev["high"])
Write-Output ("  medium/low/info  : " + $sev["medium"] + "/" + $sev["low"] + "/" + $sev["info"])
Write-Output ("findings/USD       : " + $fPerUsd)
Write-Output ("findings/1K tokens : " + $fPer1k)
Write-Output ("% T0 gratis        : " + $pctT0 + "% (objetivo >=70%) " + $(if ($pctT0 -ge 70) { "OK" } else { "BAJO" }))
Write-Output ("FP descartados     : " + $fp + " (" + $fpRate + "%)")
Write-Output ("evidence hashes    : " + @($run.evidence_hashes).Count)
Write-Output ""

# Append a reports/index.jsonl para tendencia
$idx = Join-Path (Split-Path -Parent $RunDir) "index.jsonl"
$line = (@{
    date          = $(if ($run.started_at) { $run.started_at } else { (Get-Date).ToString("o") })
    target        = ($run.targets -join ",")
    mode          = $run.mode
    cost_usd      = $cost
    findings_total= $total
    pct_t0        = $pctT0
    critical      = $sev["critical"]
    high          = $sev["high"]
} | ConvertTo-Json -Compress)
Add-Content -Path $idx -Value $line
Write-Output ("index.jsonl  <--  " + $line)
Write-Output ""

# Tendencia: últimas 5 corridas del mismo target
if (Test-Path $idx) {
    $prev = @(Get-Content $idx | ForEach-Object { $_ | ConvertFrom-Json } |
        Where-Object { $_.target -eq ($run.targets -join ",") })
    if ($prev.Count -gt 1) {
        Write-Output ("Tendencia (" + $prev.Count + " corridas de este target):")
        $prev | Select-Object -Last 5 | ForEach-Object {
            Write-Output ("  " + $_.date + "  $" + $_.cost_usd + "  findings=" + $_.findings_total + "  %T0=" + $_.pct_t0)
        }
        Write-Output ""
    }
}
