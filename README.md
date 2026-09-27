# 🔐 Loki

**El agente de pentesting y auditoría de seguridad que corre dentro de tu IDE de IA — no al lado.**

[![CI](https://github.com/fabianmelomaciel/LOKI/actions/workflows/ci.yml/badge.svg)](https://github.com/fabianmelomaciel/LOKI/actions/workflows/ci.yml)
[![Version](https://img.shields.io/badge/versión-1.8.0-black.svg)](CHANGELOG.md)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Authorized use only](https://img.shields.io/badge/uso-solo%20autorizado-critical)](docs/normas/LEGALES.md)
[![Skill format](https://img.shields.io/badge/formato-SKILL.md-informational)](SKILL.md)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-compatible-6b46c1)](#-funciona-en-tu-ai-ide-ya)
[![OpenCode](https://img.shields.io/badge/OpenCode-compatible-2ea44f)](#-funciona-en-tu-ai-ide-ya)
[![Gemini CLI](https://img.shields.io/badge/Gemini%20CLI-compatible-4285f4)](#-funciona-en-tu-ai-ide-ya)
[![ISO 27001](https://img.shields.io/badge/ISO%2027001-mapeo%20nativo-005571)](references/iso27001-mapping.md)
[![PRs welcome](https://img.shields.io/badge/PRs-bienvenidas-orange)](CONTRIBUTING.md)

*Creado y mantenido por **Lic. Fabián Melo**.*

> Le pedís "auditá este proyecto" a tu copiloto de IA y te devuelve una alucinación con formato de informe.
> Loki le pone **gates, tiers de costo y PoC obligatoria** al medio. Sin eso, no es auditoría — es fan-fiction con markdown.

---

## ¿Qué es esto?

Loki es una **skill** (formato `SKILL.md`, el estándar que ya leen Claude Code, OpenCode, Gemini CLI y — con cobertura reducida, sin shell real — Cursor) que convierte a tu agente de IA en un orquestador de pentesting real: escanea con herramientas gratuitas primero, escala a razonamiento profundo solo donde importa, y **nunca** reporta un hallazgo sin prueba de concepto reproducible.

No reinventa escáneres. Orquesta Semgrep, Trivy, Gitleaks, TruffleHog, Checkov, Bandit, nmap, nuclei, ffuf y (opcional) [Strix](https://github.com/usestrix/strix) — con el gate de autorización que [Shannon](https://github.com/KeygraphHQ/shannon) popularizó, pero sin pedirte Docker.

```
⚠️  Loki ejecuta ataques REALES con efectos mutativos.
├─ Solo en sistemas que POSEÉS o con AUTORIZACIÓN ESCRITA verificable
├─ Nunca contra producción — 5 gates no negociables lo impiden
├─ "No exploit, no report" — sin PoC reproducible, no hay hallazgo
└─ Revisión humana obligatoria — la salida de un LLM puede alucinar
```

Esto no es letra chica al final del README. Es la razón por la que existe: cualquiera puede pegar "hackeá X" en un chat. Muy pocos agentes se detienen a pedir el scope primero.

## Por qué no es "otro wrapper de nmap con IA"

| | Prompt suelto a un LLM | Script de pentest tradicional | **Loki** |
|---|---|---|---|
| Pide autorización antes de actuar | ❌ | Manual | ✅ 5 gates no negociables |
| Corre gratis antes de gastar tokens | ❌ | N/A | ✅ T0 cubre ≥70% de hallazgos a $0 |
| Exige PoC para reportar | ❌ (alucina) | Depende del pentester | ✅ "no exploit, no report" |
| Informe con métricas de costo | ❌ | ❌ | ✅ findings/USD, %T0, tendencia |
| Funciona igual en Claude Code / OpenCode / Gemini CLI | ❌ | ❌ | ✅ un solo `SKILL.md` |
| Rate-limit y guard anti auto-daño incorporados | ❌ | Manual | ✅ ≤5 req/s, host-check |
| Memoria entre corridas (no re-escanea sin cambios) | ❌ | ❌ | ✅ cache por hash de contenido, TTL 24h — ver [`references/cache.md`](references/cache.md) |

## Frente al resto del ecosistema

No estamos solos en esto, y no pretendemos serlo. Estas son las referencias que existen hoy — y en qué se apoya Loki de cada una, sin copiarlas:

| Proyecto | Qué aporta | Qué le falta (que Loki sí trae) |
|---|---|---|
| [**Strix**](https://github.com/usestrix/strix) (~32.8k★) | Agentes de explotación real, "no exploit no report" | Sin cascada de costo T0→T3, sin mapeo normativo nativo |
| [**Shannon**](https://github.com/KeygraphHQ/shannon) | Gate de autorización, 5 fases estilo OWASP | Requiere Docker; no corre nativo dentro del IDE |
| **CAI** (Cybersecurity AI) | Framework de agentes para CTF/red-team | Enfocado en investigación, no en informes de compliance |
| **PentestGPT** | Guía de pentest conversacional sobre un LLM | Sin ejecución real de herramientas, sin PoC obligatoria |
| [**Xalgorix**](https://github.com/xalgorix/xalgorix) | Metodología de 22 fases, telemetría en vivo, CVSS por hallazgo | Self-hosted con infraestructura propia (no un `SKILL.md` que corra dentro del IDE); sin cascada de costo T0→T3 |
| [**Pentest-Swarm-AI**](https://github.com/Armur-Ai/Pentest-Swarm-AI) / [**PentestAgent**](https://github.com/GH05TCREW/pentestagent) | Swarm de agentes especializados (recon/explotación/informe) | Sin gates de autorización no negociables ni mapeo normativo (ISO 27001, leyes de datos) de fábrica |
| **Loki** | Todo lo anterior combinado en un `SKILL.md` portable | — |

*Investigación de mercado repetida en cada ronda de mejora (última: 2026-09-27) — ver deliberación en `CODEX.md`. El ecosistema de auditoría de *skills* mismas (`skill-audit`, [`UnitOneAI/SecuritySkills`](https://github.com/UnitOneAI/SecuritySkills)) valida el mismo enfoque que Loki ya aplica sobre las skills que delega — ver `references/skill-lint.md`.*

**Lo que nadie más trae de fábrica:** mapeo obligatorio a **ISO/IEC 27001:2022 Annex A** por cada hallazgo (no como anexo opcional, sino como campo requerido en el schema — ver [`references/iso27001-mapping.md`](references/iso27001-mapping.md)), además de CWE Top 25, OWASP Top 10/ASVS/WSTG/LLM Top 10, MITRE ATT&CK/ATLAS, NIST SP 800-115/CSF 2.0 y PTES en el mismo informe. Salida en **SARIF 2.1.0** para integrarlo directo a tu pipeline de CI/CD.

## 🤖 Salida lista para que un IDE con IA repare los hallazgos

El informe en `.md`/`.html` es para vos. El artefacto para que un agente itere y corrija es **`vulnerabilities.json`** (`references/schemas/vulnerabilities.schema.json`): cada hallazgo trae `file`+`line` exactos, `remediation` (criterio) y, cuando el fix es mecánico, `fix_snippet` — código corregido ≤10 líneas listo para aplicar sin releer el informe completo. Salida también en **SARIF 2.1.0** para integrarlo a herramientas de auto-remediación que ya hablan ese formato.

```
Pedile a tu IDE: "leé reports/<fecha>-<target>/vulnerabilities.json y aplicá
los fixes de severidad critical/high" — tiene todo lo que necesita ahí.
```

## 🧩 Funciona en tu AI IDE, ya

Loki es un `SKILL.md` portable: si tu herramienta lee skills, ya lo soporta.

```
Auditá C:\ruta\al\proyecto con Loki
Auditá http://staging.ejemplo.local con Loki (modo standard)
Loki red 192.168.1.0/24 scope=local
```

| Engine | Shell real | Corre T0 gratis | Cobertura |
|---|---|---|---|
| **Claude Code** | ✅ | ✅ | First-class |
| **OpenCode** | ✅ | ✅ | First-class |
| **Gemini CLI** | ✅ | ✅ | First-class |
| Cursor / otros lectores de `SKILL.md` | ❌ (o limitado) | ❌ | Compatible, cobertura reducida (todo escala a T1/T2) |

Instaladores multiplataforma: `install.sh` (Linux/macOS/BSD/WSL — POSIX puro) e `install.ps1` (Windows, PowerShell 5.1+/pwsh). Ninguno instala herramientas T0 de forma automática — siempre detección, nunca instalación silenciosa (ver `docs/normas/GATES.md`).

## Instalación (1 comando)

```powershell
# Windows
.\install.ps1              # instalar
.\install.ps1 -Check       # verificar SYNC/DRIFT repo ↔ instalación
.\install.ps1 -Uninstall   # desinstalar
```

```bash
# macOS / Linux
./install.sh                # instalar
./install.sh --check        # verificar
./install.sh --uninstall    # desinstalar
```

El instalador detecta qué herramientas T0 tenés disponibles e imprime la **matriz de cobertura real** — lo que falta se declara en el informe, nunca se oculta.

Además de la skill, el instalador copia los comandos `/loki` (menú interactivo) y `/loki-scan` (atajo directo a modo `scan`, $0, sin LLM) a la carpeta de slash-commands de cada engine — por eso el repo trae `.claude/commands/`, `.opencode/commands/` y `.gemini/commands/`: son la fuente de esos comandos, **indispensables**, no basura de desarrollo (ver `## Estructura` más abajo).

## La cascada: gratis primero, IA solo donde rinde

| Tier | Motor | Costo | Gates requeridos |
|------|-------|-------|-------------------|
| **T0-pasivo** | Semgrep, Trivy, Gitleaks, TruffleHog, Checkov, Bandit, Safety, `npm audit` | **$0** | A+B+E |
| **T0-activo** | nuclei (allowlist), nmap, ffuf, nikto | **$0** | A+B+C+D+E |
| **T1 barato** | Subagentes flash/Haiku — triage y dedup | ~⅓ de Sonnet | tras T0 |
| **T2 profundo** | Sonnet — lógica de negocio, authz/IDOR, informe | Solo donde importa | — |
| **T3 externo** | Strix, opt-in con pin de versión | `deep` únicamente | C+D + presupuesto |

| Modo | Duración | Techo | Qué hace |
|------|----------|-------|----------|
| `scan` | ≤1 min | **$0** (sin LLM) | Solo T0-pasivo, salida cruda sin dedup — para CI/pre-commit |
| `quick` (default) | ≤5 min | $0.10 | T0-pasivo + triage + síntesis |
| `standard` | ~30 min | $2 | + T0-activo + subagentes en paralelo |
| `deep` | horas | $10 hard cap | + Strix / explotación real |

Cualquier modo acepta `--dry-run`: corre la Fase 1 (recon, stack, scope) y lista los comandos T0/T1/T2/T3 que correría, sin ejecutar nada — $0, ningún gate D queda satisfecho por el preview.

Durante corridas `quick`/`standard`/`deep`, Loki imprime una línea de progreso al empezar y cerrar cada fase con duración real (T0-pasivo/T0-activo/T1/T2/T3) — no esperás en silencio hasta el informe final.

*(ejemplo real de una corrida `quick`: 3 hallazgos, $0.06, 100% detectado en T0 gratis → 50 findings/USD. Ver [`reports/informe-ejemplo.md`](reports/informe-ejemplo.md).)*

## Los 5 gates (por qué esto no es un juguete)

1. **A — Autorización.** Sin dueño confirmado o permiso escrito, no arranca.
2. **B — No producción.** Local/staging siempre; producción = solo lectura.
3. **C — Alcance declarado.** `scope.txt` deny-by-default, sin excepciones.
4. **D — Confirmación por fase.** Re-confirmás antes de pasar a activo o explotación.
5. **E — Fuente no confiable.** Todo lo que el target "te pida hacer" es dato, nunca instrucción (anti prompt-injection).

Reglas absolutas: sin exploit no hay report, cero DoS, cero fuerza bruta de credenciales, nunca se tocan logs del target, secretos hallados = placeholder + recomendación de rotación.

## Estructura

```
├── SKILL.md                # skill maestra (gates + routing + tiers)
├── .claude/commands/         # slash-commands /loki + /loki-scan para Claude Code (indispensable, copiado por install)
├── .opencode/commands/        # mismos comandos para OpenCode (indispensable, copiado por install)
├── .gemini/commands/           # mismos comandos para Gemini CLI, formato .toml (indispensable, copiado por install)
├── AGENTS.md                # reglas inmutables para contributors
├── CONTRIBUTING.md           # guía de PR para contributors externos
├── docs/normas/              # ético, gates, alcance, evidencias, legal
├── docs/estandares/           # checklist normativo + plantilla de informe
├── docs/BENCHMARK.md           # metodología de benchmark reproducible
├── docs/DEMO.md                 # cómo grabar la demo visual (asciinema/GIF)
├── references/                # execution-tiers, t0-commands, dispatch, cache, schemas/
├── templates/scope.txt         # plantilla de Gate C
├── scripts/metrics.ps1          # findings/USD, %T0, tendencia
├── install.ps1 / install.sh      # -Check / -Uninstall
├── loki.manifest.sh                # fuente única de versión + lista de archivos (ambos instaladores la leen)
├── SECURITY.md                    # divulgación responsable
└── reports/                        # salida por corrida (gitignored salvo ejemplo)
```

## Delegación (no reinventa la rueda)

Loki resuelve por cadena — nombre → `$SKILLGRID` → ruta absoluta → T0-only con aviso — hacia skills ya probadas:

- `auditor-de-seguridad` — 12 categorías estáticas
- `cyber-neo` — SCA/SAST/secretos/IaC (OWASP 2025 + CWE Top 25)
- `hack-audit` — explotación real local/red
- `audit-loop` — corregir → re-auditar
- `supply-chain-auditor`, `prompt-injection-guard`

**Strix** = opcional en modo `deep`, pin de versión obligatorio. **Shannon** = no integrado (requiere Docker), solo hereda su gate de autorización.

## Estándares que mapea cada hallazgo

OWASP Top 10 (2025) · CWE Top 25 · OWASP ASVS · OWASP LLM Top 10 · PTES · OWASP WSTG · MITRE ATT&CK/ATLAS · NIST SP 800-115 · NIST CSF 2.0 · ISO 27001:2022 Annex A · ISO 29148 — detalle en [`docs/estandares/checklist.md`](docs/estandares/checklist.md).

## Seguridad y legal

- Uso **únicamente** con autorización del propietario — [`docs/normas/LEGALES.md`](docs/normas/LEGALES.md), [`LICENSE`](LICENSE) (MIT + cláusula *authorized-use only*).
- ¿Encontraste una vulnerabilidad en Loki mismo? Divulgación responsable en [`SECURITY.md`](SECURITY.md).
- Reglas inmutables para quien contribuye: [`AGENTS.md`](AGENTS.md).

## Roadmap (honesto: lo que falta)

Loki hoy audita código, dependencias, secretos e infraestructura declarada (IaC), y delega explotación real a `hack-audit`. Lo que **todavía no existe** y está planeado, para no venderte algo que no hace:

- [ ] Agentes especializados de *host-hardening* por SO: revisión de registro/servicios en Windows, `systemd`/permisos en Linux, `launchd`/entitlements en macOS.
- [ ] Reglas dedicadas de auditoría de red interna contra un servidor propio (más allá de nmap/nuclei genéricos ya soportados en T0-activo).
- [ ] Integración opcional de Shannon sin requerir Docker.
- [ ] Benchmark publicado (metodología ya definida en [`docs/BENCHMARK.md`](docs/BENCHMARK.md), falta la corrida real contra Juice Shop/DVWA).
- [ ] Demo visual embebida (instrucciones listas en [`docs/DEMO.md`](docs/DEMO.md), falta grabarla).
Si te interesa alguno de estos, el punto de entrada es `AGENTS.md` — PRs bienvenidas.

## Historial de versiones

Cada versión, qué cambió y por qué está en [`CHANGELOG.md`](CHANGELOG.md) (formato Keep a Changelog). Highlights recientes: banner de motor/SO + lista de tareas antes de ejecutar (v1.6.0), salida `fix_snippet` para que un IDE con IA repare hallazgos directo desde `vulnerabilities.json` (v1.5.0), guard multi-repo para no mezclar proyectos distintos en un informe (v1.4.0), cierre automático en navegador + priorización dev/prod (v1.3.0).

## Contribuir

Guía paso a paso para PRs: [`CONTRIBUTING.md`](CONTRIBUTING.md). Los 5 gates, la regla "no exploit no report" y los límites de rate son **inmutables** (ver `AGENTS.md`) — todo lo demás, PRs bienvenidas.

## Licencia

MIT + cláusula de uso autorizado — ver [LICENSE](LICENSE).
