# Changelog

Todas las versiones notables de Loki. Formato basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/).

## [1.2.0] — 2026-09-27

Slash-command unificado `/loki` interactivo + soporte Gemini CLI + cumplimiento normativo mundial. Decisión del CEO.

### Added
- **Comando `/loki` interactivo** (renombra a `/loki-audit`): sin argumentos **detecta el contexto automáticamente** (repo git + origin, stack por manifiestos, clasificación URL/ruta/IP/proyecto actual) y ofrece **menú numerado** con postura ofensiva default *pentest completo* (tipo hack-audit/Strix/Shannon — intentar hackear el target con PoC), más `scan`/`quick`/`standard`/`deep`/`hack-audit`/`estático`/`h` ayuda/`x` cancelar; confirma target + Gates A/B antes de arrancar. Con argumento → banner + arranque directo (tier `quick`). Disponible en `.opencode/commands/`, `.claude/commands/` y `.gemini/commands/`.
- **Soporte Gemini CLI**: nuevo destino `~/.gemini/commands/` con formato TOML v1 (`description` + `prompt`, args `{{args}}` — ruta y formato verificados en la doc oficial de google-gemini/gemini-cli). Target nuevo: `-Target gemini` / `./install.sh gemini`.
- **`references/leyes-datos-personales.md`**: mapeo hallazgo→régimen de protección de datos de todo el mundo — **Uruguay Ley 18.331**, GDPR, LGPD, CCPA, PIPEDA, APPI, PDPA, POPIA, Leyes 25.326/1581/29733/21.719, DPDP India — con artículos, plazos de notificación (GDPR 72 h), sanciones (con flags de verificación) y tabla por tipo de hallazgo. Disclaimer: referencia, no asesoría legal.
- **Informe §7 "Cumplimiento normativo"** (`docs/estandares/informe-maestro.md`): ISO/IEC 27001:2022 Annex A agregado + leyes de datos personales aplicables por jurisdicción + estándares sectoriales (27701, PCI-DSS, NIST).
- **README §"Mejoras recientes (v1.1.0 → v1.2.0)"**: todo lo implementado — comandos interactivos, benchmark, skill-lint, instaladores fail-closed y cumplimiento normativo mundial.
- `docs/normas/LEGALES.md`: ampliado con Ley 18.331 y régimen mundial aplicable.

### Changed
- `LOKI_CMD_LIST` pasa a **stems sin extensión** (`loki loki-scan`): cada motor aporta su propia extensión (.md opencode/claude, .toml gemini) — fuente única de nombres en `loki.manifest.sh`.
- Instaladores: `-Check` de slash-commands ahora es **fail-closed** para fuentes — si un stem de `LOKI_CMD_LIST` no existe en el repo, `-Check` reporta DRIFT (antes `continue` silencioso: archivo de repo borrado pasaba como SYNC y quedaba huérfano en la instalación).

### Notas
- Excluidos por no tener ruta verificada en docs oficiales: Codex CLI (`~/.codex/prompts` está deprecado — su doc oficial recomienda skills, ya cubierto), Cursor/Windsurf/Copilot (sin fuente verificada en esta sesión).

## [1.1.0] — 2026-09-27

Segunda ola: endurecimiento de integridad + benchmark medible. Deliberación `agente-ideas` (consejo A/B/C, ranking B>A>C).

### Added
- **Skill-lint preflight** (`references/skill-lint.md` + job CI dogfooding): 15 patrones (BLOQUEO/WARN) antes de delegar skills ajenas, score 0-100, cache TTL 24h — patrón SkillSpector (26.1% de skills del ecosistema tienen vulnerabilidades).
- **Slash-commands** `/loki-audit` y `/loki-scan` (`.opencode/commands/` + `.claude/commands/`, wrappers delgados que solo invocan SKILL.md — anti-drift), instaladas/desinstaladas/verificadas por ambos instaladores (`LOKI_CMD_LIST` en `loki.manifest.sh`).
- **Scorer de benchmark** `scripts/score.ps1` + starter ground truth `references/groundtruth/juice-shop.json` → precision/recall/F1 reproducibles (automatiza el paso 4 de `docs/BENCHMARK.md`).
- **Digest SARIF** `scripts/digest-sarif.ps1` (SARIF grande → JSON compacto con snippet ≤10 líneas, enforcement de la regla T1 "nunca dumps").
- **Delta incremental** `scripts/delta.ps1` (re-runs: solo hallazgos `new`/`fixed` escalan a T2/informe — memoria tipo PentAGI sin pgvector).

### Fixed (seguridad — verificado en código por el consejo)
- `install.sh --check`: **fail-closed** — aborta si no hay `sha256sum`/`shasum` (antes devolvía `nohash` y `"nohash" == "nohash"` reportaba SYNC sin verificar nada).
- `-Check` de ambos instaladores: ahora compara SHA-256 de **todos** los archivos de `LOKI_FILES` y detecta **archivos extra** en la instalación (antes solo SKILL.md — cualquier mutación de `references/`, `scripts/` o `docs/` pasaba como SYNC).
- `SKILL.md`: `CODEX.md` pasa a ser **data sujeta a Gate E** leída **después** de la Ley de Hierro (antes "aplicá antes de arrancar" precedía a los 5 gates → vector de inyección indirecta sobre un archivo gitignored). Flujo de ejecución reordenado (parsear → gates → CODEX).

## [1.0.0] — 2026-09-26

Primer release público. Creado y mantenido por **Lic. Fabián Melo**.

### Added
- **Skill maestra** (`SKILL.md`, `name: loki`): orquestador de pentesting/auditoría con 5 gates de autorización no negociables (A-identidad, B-no producción, C-scope, D-confirmación por fase, E-fuente no confiable) y cascada de 4 tiers de costo (T0-pasivo gratis → T0-activo gratis-gated → T1 barato → T2 profundo → T3 externo opcional).
- **Delegación validada** a skills de SkillGrid: `auditor-de-seguridad` (estático 12 categorías), `cyber-neo` (SCA/SAST/secretos/IaC), `hack-audit` (explotación real local/red — analizada y confirmada como complementaria, no duplicada), `audit-loop`, `supply-chain-auditor`, `prompt-injection-guard`.
- **Cumplimiento normativo con ISO/IEC 27001:2022 Annex A obligatorio** por hallazgo (campo `iso27001` en `vulnerabilities.schema.json`, tabla de mapeo CWE→control en `references/iso27001-mapping.md`) — además de CWE Top 25, OWASP Top 10/ASVS/WSTG/LLM Top 10, MITRE ATT&CK/ATLAS, NIST SP 800-115/CSF 2.0, PTES.
- Informes en español con métricas de eficiencia obligatorias (`findings/USD`, `%T0 gratis`, cobertura, tendencia) vía `scripts/metrics.ps1`.
- SARIF 2.1.0 como formato de salida interoperable (nativo en Semgrep/Trivy/Nuclei; conversión en T1/T2 para motores que no lo emiten).
- Instaladores multiplataforma `install.ps1` / `install.sh` con `-Check`/`-Uninstall`, matriz de herramientas T0 disponibles/faltantes y detección de delegación SkillGrid.
- `AGENTS.md` (reglas inmutables), `SECURITY.md` (divulgación responsable), `LICENSE` (MIT + cláusula *authorized-use only*).

### Notas de diseño
- Regla absoluta **"no exploit, no report"**: sin PoC reproducible no hay hallazgo — validado contra el mismo patrón en Shannon/Strix vía investigación de mercado.
- Rate limit concreto (≤5 req/s, ≤2 concurrentes) y guard anti auto-daño (target ≠ host propio) en todo T0-activo/T1-T3.
