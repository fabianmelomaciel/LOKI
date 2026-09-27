# Changelog

## [1.2.0] — 2026-09-26

### Changed
- **Rebrand: EticHack → Loki.** Renombre completo del proyecto de cara al repo público (`github.com/fabianmelomaciel/LOKI`): frontmatter `name: loki` en `SKILL.md`, `$SkillName`/`SKILL_NAME` en instaladores, directorio de budget `.loki/`, rutas de instalación `~/.claude/skills/loki` y `~/.config/opencode/skills/loki`. Sin cambios funcionales — gates, tiers y delegación quedan idénticos.
- README reescrito para lanzamiento público (hook, tabla comparativa, badges).
- `.gitignore` ampliado con más patrones de secretos y artefactos de editor.

## [1.1.0] — 2026-09-22

### Fixed (CRITICAL)
- `allowed-tools`: eliminados `Bash(pwsh *)`, `Bash(npx *)`, `Bash(npm *)`; añadido `Bash(npm audit *)` y `Bash(sha256sum *)`. Capacidades activas (curl/nmap/nuclei/ffuf/nikto) documentadas como solo Gate D.
- T0 dividido en **T0-pasivo** (A+B+E) y **T0-activo** (A+B+C+D+E) — ya no hay escaneos activos en el tier "siempre primero".
- Orden de flujo corregido: Gates A+B+E antes de todo; Gate C se completa al levantar `scope.txt` en Fase 1; Gate D escalonado por transición (antes: flujo literal imposible).

### Added
- `references/t0-commands.md` — driver T0 canónico (fallback sin cyber-neo).
- `references/schemas/run.schema.json` + `vulnerabilities.schema.json` — schemas tipados.
- `references/dispatch.md` — prompts-cervecía T1/T2/categorías con gates verbatim.
- `templates/scope.txt` — plantilla real de Gate C.
- `scripts/metrics.ps1` — calcula findings/USD, %T0, tendencia (`reports/index.jsonl`).
- `.loki/budget.json` + audit-log como pasos explícitos del flujo.
- Rate limit concreto (≤5 req/s) en SKILL.md, GATES.md, execution-tiers, t0-commands.
- Guard anti auto-daño (target = host propio) + tabla anti-racionalización.
- `AGENTS.md` — gates inmutables para contributors.
- `CHANGELOG.md`, `reports/informe-ejemplo.md`.
- Instaladores: flags `-Check`/`--check` (hash SYNC/DRIFT), `-Uninstall`/`--uninstall`, detección de delegación SkillGrid, copia de `LICENSE`, dejan de copiar `CODEX.md`.

### Changed
- `version: 1.1.0` en frontmatter; Strix con pin `@b0866244`.
- Cadena de resolución de delegación portable (nombre → `$SKILLGRID` → `../SkillGrid` → absoluta → T0-only).
- Importación de hallazgos Strix (dedup + cost_usd) y audit-loop con env vars.
- `.gitignore`: excepciones `!reports/.gitkeep`, `!reports/informe-ejemplo.md`, `!templates/scope.txt`; artefactos hack-audit (`evidencia/`, `recon.md`, `*.har`, `*.pcap`).
- Plantilla de informe: checklist de redacción secretos/PII.

## [1.0.0] — 2026-09-22

### Added
- Fundación Loki: SKILL.md maestro, 5 gates, execution tiers T0–T3, 6 normas, checklist estándares, plantilla de informe, instaladores ps1/sh.
- Consejo agente-ideas (B 8/10 > C 7/10 > A 6/10), aprobación CEO.
