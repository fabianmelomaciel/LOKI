# Changelog

Todas las versiones notables de Loki. Formato basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/).

## [1.6.0] — 2026-09-27

Conciencia de motor/SO en el menú interactivo: Loki ahora declara qué engine lo ejecuta y qué sistema operativo detectó antes de correr nada, y muestra la lista concreta de tareas que va a hacer. Deliberación `agente-ideas` (consejo A/B/C, veto de seguridad B — sin early-exit, ranking B>C>A), pedido del CEO ("debe entender que ide usa... consciente de esto... menú de preguntas claro e intuitivo... listar las tareas que va a realizar en pantalla").

### Added
- **Detección de motor y SO** (`SKILL.md` §Compatibilidad): motor se declara gratis por wrapper (cada `.claude/.opencode/.gemini` sabe qué engine lo carga, sin comando); SO se detecta con un único `uname -s` cacheado en `.loki/tools-cache.json.os` (mismo TTL 24h/`host_fingerprint` que la detección de herramientas T0) — mapeo `MINGW*/MSYS*/CYGWIN*`→Windows, `Linux`→Linux, `Darwin`→macOS, ausente→"no determinado".
- **Regla dura explícita**: motor/SO deciden únicamente qué comandos T0 correr y cómo se ve el banner — nunca qué gates aplican. Cierra el riesgo bloqueante que levantó la perspectiva de seguridad del consejo (motor/SO no pueden convertirse en una vía para saltear los 5 gates).
- **Banner "▶ Voy a ejecutar..."** en el banner canónico de `SKILL.md` (PARSEO DE INTENCIÓN): lista estática de las fases concretas que van a correr según tier/motor/SO, antes de lanzar nada — un solo lugar (no duplicado en los 3 wrappers, que siguen siendo "delgados").
- **Gemini CLI** agregado a la tabla de compatibilidad de engines (README y `SKILL.md`) — ya tenía wrapper propio (`.gemini/commands/loki.toml`) pero no figuraba como first-class.
- Campo `os` documentado en el schema de `.loki/tools-cache.json` (`references/cache.md`).

### Fixed
- `references/t0-commands.md` instruía detectar herramientas T0 con `which <tool>` sin importar el SO — falla silenciosa en Windows nativo sin Git Bash/WSL. Ahora es OS-aware: `Get-Command` en Windows, `which` en el resto (mismo criterio que ya usaba `install.ps1` vs `install.sh`, pero no estaba propagado a la detección en runtime).

## [1.5.0] — 2026-09-27

Ronda de pulido: salida accionable para IDEs con IA, higiene de README (badge desincronizado, duplicación con CHANGELOG) e investigación de mercado repetida (Xalgorix, Pentest-Swarm-AI/PentestAgent, ecosistema skill-audit). Deliberación `agente-ideas`, pedido explícito del CEO ("mejora el proyecto lo mas que pueda... reduccion de tokens... que los IDE ia puedan repararlo").

### Added
- **Campo `fix_snippet`** (opcional, ≤10 líneas) en `vulnerabilities.schema.json`: código corregido listo para aplicar cuando el fix es mecánico, sin desplazar a `remediation` (que sigue siendo el criterio en prosa para fixes de rediseño). `SKILL.md` (Fase 4) y `docs/estandares/informe-maestro.md` documentan cuándo completarlo.
- **`vulnerabilities.json` declarado explícitamente como artefacto canónico para IDEs con IA** — nueva sección README "🤖 Salida lista para que un IDE con IA repare los hallazgos"; `informe.md`/`.html` quedan como lectura humana, el JSON (+ SARIF) como lo que un agente itera para reparar.
- CI: el badge de versión del README ahora se valida contra `loki.manifest.sh`/`SKILL.md` (antes solo esos dos se comparaban entre sí — el badge quedó en 1.0.0 desde el primer release sin que nada lo detectara).

### Changed
- README: sección "Mejoras recientes" (duplicaba `CHANGELOG.md` casi textual, crecía sin límite en cada versión) reemplazada por un resumen de 3 líneas + link — reduce el tamaño del archivo que más se carga como contexto.
- README: tabla "Frente al resto del ecosistema" ampliada con hallazgos de la investigación de esta ronda (Xalgorix, Pentest-Swarm-AI, PentestAgent) y nota sobre el ecosistema de auditoría de skills (`skill-audit`, `UnitOneAI/SecuritySkills`) que valida el enfoque ya aplicado en `references/skill-lint.md`.
- `AGENTS.md`: el checklist de bump de versión ahora incluye explícitamente el badge del README (antes solo mencionaba `SKILL.md`).

## [1.4.0] — 2026-09-27

Guard multi-repo: evita que Loki mezcle hallazgos de proyectos distintos en un solo informe cuando TARGET es una carpeta padre (ej. `C:\laragon\www`) en vez de la raíz de un repo. Deliberación `agente-ideas` (consejo A/B/C con Stage 2, veto de seguridad, ranking B>C>A) + revisión de auditores SkillGrid (auditor-de-seguridad/cyber-neo/hack-audit — mismo gap, patrón de exclusiones reutilizado de cyber-neo). Decisión del CEO.

### Added
- **`references/multi-repo-guard.md`**: detección de repos `.git` independientes bajo TARGET antes de tocar cualquier tool T0; STOP con listado de candidatos si hay ≥2; flujo de multi-repo intencional (Gate A/C por repo, patrón validado en hack-audit) y patrón de exclusiones de conteo (`node_modules`/`.git`/`vendor`/`__pycache__`/`dist`/`build`/`.next`/`target`) tomado de `SkillGrid/skills/cyber-neo`.
- Campos `repo_count` (int) e `is_multi_repo` (bool) en `references/schemas/run.schema.json`, propagados por `scripts/metrics.ps1` a `reports/index.jsonl` — permiten filtrar retroactivamente corridas multi-repo de la tendencia histórica.
- `docs/normas/ALCANCE.md`: sección "Multi-repo" — `REPOS=` con varias entradas solo en modo `equipo` intencional, Gate A por repo, una carpeta padre nunca es target válido por sí sola.

### Changed
- `SKILL.md` Fase 1 (paso 5): guard multi-repo corre antes del conteo de archivos; el conteo aplica las exclusiones en el mismo comando (antes contaba el árbol completo sin excludes).
- `SKILL.md` paso 12 e `docs/estandares/informe-maestro.md`: si multi-repo intencional, un `informe-<repo>.md` por repo (nunca un `{target}` único mezclando repos).
- `docs/normas/GATES.md` (Gate C): nota de que el gate se satisface por repo, no por carpeta padre.
- `.claude/commands/loki.md`, `.opencode/commands/loki.md`, `.gemini/commands/loki.toml`: si `git rev-parse --show-toplevel` falla, ya no se asume el cwd como target candidato — se enumeran los repos bajo esa ruta y se exige confirmación explícita.
- `references/t0-commands.md`: nota de que `<target>` ya pasó el guard (siempre single-repo).

## [1.3.0] — 2026-09-27

Cierre de informe en navegador + priorización dev/prod de hallazgos. Decisión del CEO (patrón SkillGrid).

### Added
- **`templates/informe.html`**: dashboard HTML del informe (resumen, métricas, hallazgos con severidad/alcance/POC/remediación, cobertura, artefactos, recomendaciones, cumplimiento) — **cierre obligatorio**: se genera junto al `.md` y se abre en el **navegador default del SO** (Windows `start` · Linux `xdg-open` · macOS `open`, patrón `skills/shared/open-report.md` de SkillGrid), fallo silencioso sin GUI y **siempre** se imprime el link `file:///`. Gate E: solo contenido HTML-escapado y solo la ruta propia bajo `reports/` — jamás una ruta/URL sugerida por el target.
- **`references/dev-vs-prod.md`**: análisis dev vs producción por hallazgo — lectura de `.gitignore` (qué es dev-only vs desplegable), `devDependencies`, config/debug, pipeline de deploy; checklist y **regla de priorización: los hallazgos que afectan PRODUCCIÓN van primero** (`alcance: prod/dev/ambos`, duda → prod).
- **Campo `alcance`** (opcional, additivo) en `vulnerabilities.schema.json`.
- allowed-tools: 3 entradas estrechas de cierre (`start/xdg-open/open file:///*`) — sin tocar las prohibiciones inmutables (pwsh/npx/npm).

### Changed
- Flujo de SKILL.md: Fase 1 detecta entorno dev/prod; Fase 4 asigna `alcance` y ordena prod-first; paso 12 genera `informe.html` y lo abre en el navegador.
- `docs/estandares/informe-maestro.md`: campo `**Alcance:**` por hallazgo, orden prod-first en §3 y nota de cierre HTML.

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
