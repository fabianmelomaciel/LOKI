# Loki — Execution Tiers (referencia de eficiencia)

Cascada obligatoria: cada tier solo corre si el anterior no cubrió o el usuario pidió subir de modo.

## T0-pasivo — GRATIS (siempre primero, Gates A+B+E)
Ver `references/t0-commands.md`:
- **SCA/SAST:** Semgrep (owasp-top-ten), Bandit, Safety, npm audit, Trivy
- **Secretos:** Gitleaks, TruffleHog
- **IaC:** Checkov
- Salidas a `.loki/t0/` (SARIF/JSON). Detectar con `which`; ausentes → informe.

## T0-activo — GRATIS pero gated (solo Gates A+B+C+D+E)
- Nuclei allowlist: `-tags cve,misconfig,exposure -exclude-tags dos,destructive,fuzz -rate 5`
- nmap `-T3 --max-rate 500`, ffuf `-rate 5`, nikto `-maxtime 120s`, `curl` de recon
- **Rate:** ≤5 req/s, ≤2 concurrentes, ≥200 ms; backoff 1s→30s (máx 3) ante 429/5xx

## T1 — BARATO (triage)
Subagentes flash/Haiku (~1/3 de Sonnet):
- Dedup (clave: CWE+file+line), supresión de falsos positivos (Chesterton's fence)
- Normalización a `references/schemas/vulnerabilities.schema.json`
- **Prompts-cervecía:** `references/dispatch.md` (con 5 gates + Gate E verbatim)
- Nunca dumps de archivos al contexto (snippet ≤10 líneas)

## T2 — PROFUNDO (solo donde importa)
Sonnet/Pro: lógica de negocio, authz/IDOR, crypto, síntesis del informe.
- **Obligatorio:** todo `critical`/`high` pasa por T2 (prompt T2-verify de `references/dispatch.md`) antes del informe.
- Merge/dedup central en el orquestador.

## T3 — EXTERNO (solo `deep`, opt-in, pin obligatorio)
- **Strix:** `npx skills add usestrix/strix@b0866244 --skill strix-pentest` → verificar `sha256sum` contra `references/strix-pin.sha256` **antes** de ejecutar (mismatch o archivo vacío → STOP + confirmación humana, ver SKILL.md T3) → registrar `ref`+`sha256` en `run.json.externals[]` → `strix -n -t <target> --scan-mode deep --max-budget 10`.
- Importar hallazgos Strix → dedup CWE+file+line → sumar `cost_usd` al total.
- **Shannon:** NO integrado (Docker); solo hereda Gate A.

## Modos, techos y budget
| Modo | Duración | Alcance | Techo (`budget.json.cap_usd`) |
|------|----------|---------|-------------------------------|
| `scan` | ≤1 min | **Solo T0-pasivo**, salida cruda sin dedup ni LLM | **$0** (sin LLM) |
| `quick` (default) | ≤5 min | T0-pasivo + T1 + T2 top findings | $0.10 |
| `standard` | ~30 min | + T0-activo (gate) + subagentes ≤5 + T2 dirigido | $2 |
| `deep` | horas | + T3/explotación (gates C+D) | **$10 hard cap** |

`scan` es el único modo sin T1/T2: no hay dedup ni supresión de falsos positivos, los hallazgos de cada scanner se reportan tal cual salen. Útil para CI/pre-commit gratis; no reemplaza `quick` para un informe curado.

- `.loki/budget.json`: `{mode, cap_usd, spent_usd: 0, max_turns: 20}` — incrementar `spent_usd` tras cada fase; si `spent_usd > cap*0.8` → solo T0+informe.
- Defaults: `max_turns: 20`; timeout global 15 min (quick) / 60 min (standard).

## Paralelismo
- **Paralelo:** T0-pasivo CLI (no multiplican tokens); subagentes por categoría (≤5); agentes de fase.
- **Secuencial/gates:** recon → T0-pasivo → [Gate D] → T0-activo → triage → T2 → informe.
- **Audit-loop:** `SKILLGRID_LOOP_MAX_ITER=3`, `SKILLGRID_LOOP_TIMEOUT=300` antes de delegar.

## Paradas
Presupuesto · max-turns · 3 fallos consecutivos · plateau (`findings_by_phase` sin critical/high en 2 fases) → early-exit **declarado** "cobertura no completada".

## Métricas FinOps (obligatorias — `scripts/metrics.ps1`)
`wall_clock_s`, tokens por tier, `cost_usd`, findings/USD, findings/1K tokens, **% hallazgos T0 gratis (≥70%)**, tasa de FP descartados, cobertura, matriz de tools, tendencia vía `reports/index.jsonl`.
