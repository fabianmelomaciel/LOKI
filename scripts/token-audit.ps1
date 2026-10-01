# Loki - token_estimate audit (CI + local)
# Fails if real tokens in SKILL.md (chars/4) drift more than the tolerance
# from the frontmatter token_estimate.input value. PS 5.1 compatible, ASCII only.
param([int]$TolerancePercent = 10)

$ErrorActionPreference = 'Stop'
$skillPath = Join-Path $PSScriptRoot '..\SKILL.md'
$text = Get-Content -Raw -LiteralPath $skillPath

if ($text -notmatch 'token_estimate:\s*\{\s*input:\s*(\d+)') {
    Write-Host 'FAIL: token_estimate input no encontrado en el frontmatter de SKILL.md'
    exit 1
}
$declared = [int]$Matches[1]
$actual = [int][math]::Ceiling($text.Length / 4)
$drift = [math]::Abs($actual - $declared) / $declared * 100

Write-Host ("declarado={0} real~={1} drift={2:N1}% (tolerancia {3}%)" -f $declared, $actual, $drift, $TolerancePercent)

if ($drift -gt $TolerancePercent) {
    Write-Host 'FAIL: recalcular token_estimate.input en el frontmatter de SKILL.md'
    exit 1
}
Write-Host 'OK'
exit 0
