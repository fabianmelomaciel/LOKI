---
description: Loki — menú interactivo de pentest con detección automática de target; con argumento arranca directo
---
Entrada: $ARGUMENTS

## CASO A — "Entrada:" vacía → INTERACTIVO (no asumas nada, esperá al usuario)

### 1. Detección de contexto (solo lectura local, $0, ningún request activo)
- Directorio actual y ¿hay repo git? → `git rev-parse --show-toplevel` + `git remote get-url origin` (silenciá errores si no hay repo). **Si falla** (no es repo git): NO asumas el directorio actual como target candidato — buscá carpetas `.git` de primer/segundo nivel bajo el cwd (excluyendo `node_modules`); si hay ≥2 repos independientes, el candidato del banner es "ninguno (N repos detectados)" y el paso 3 exige elegir uno o confirmar multi-repo intencional — nunca se autocompleta con la carpeta padre entera (`references/multi-repo-guard.md`).
- Stack → manifiesto en la raíz detectada (`package.json`, `composer.json`, `requirements.txt`, `pyproject.toml`, `go.mod`, `pom.xml`, `Cargo.toml`, `*.csproj`): solo nombre/versión/deps top-level, vía Glob/Read.
- Clasificá lo detectado: **URL** (http/https) · **ruta existente** en disco · **IP/red** · **"esta máquina"** · **nada**.
- SO → leé `.loki/tools-cache.json.os` si existe y no venció (TTL 24h); si no, corré `uname -s` una vez (mapeo completo en `references/cache.md`). Motor: este wrapper siempre corre bajo **OpenCode** (dato fijo, sin detección).

### 2. Banner + menú — mostrá y ESPERÁ la respuesta
```
🔐 Loki — detección automática
├─ Motor: OpenCode · SO: {Windows | Linux | macOS | no determinado}
├─ Target candidato: {ruta | URL | IP | ninguno}
├─ Contexto: {repo → origin | stack detectado | no detectado}
├─ Tipo sugerido: {codigo | red | equipo | completo}
└─ Regla: target del usuario o con autorización escrita (Gate A), entorno no productivo (Gate B)

 1. pentest completo (recomendado) — postura ofensiva total tipo hack-audit: intentar
    hackear el target elegido, validar con PoC → informe completo listo para reparar + ISO 27001
    + leyes de datos personales (Uruguay 18.331 y mundo)
 2. scan      — solo T0-pasivo, gratis $0, ≤1 min, crudo sin dedup
 3. quick     — default: T0 + triage T1 + síntesis T2, ≤5 min ~$0.10
 4. standard  — subagentes en paralelo, ~30 min ~$2
 5. deep      — T3 explotación dirigida nativa, cap $10, sin dependencias externas
 6. hack-audit — delegación directa a skill hack-audit (explotación real local/red)
 7. estático  — solo código sin red: auditor-de-seguridad / cyber-neo
 h. ayuda      — qué hace Loki
 x. cancelar   — no hacer nada

 (agregá "--dry-run" a tu respuesta para previsualizar qué comandos correría, sin ejecutar nada)
```

### 3. Al responder → confirmá en ese mismo intercambio
- **Target exacto** (ruta/URL/IP) — si la detección sugirió uno, preguntá "¿el candidato detectado o el tuyo?".
- **Gate A**: ¿autorizado / dueño? y **Gate B**: ¿entorno no productivo? — si la respuesta es no → STOP.
- Opción `1`: pedí presupuesto (`standard` $2 / `deep` $10) — la explotación real va con rate ≤5 req/s, sin DoS, `no exploit no report`.
- Opción `h`: mostrá la ayuda — **Loki**: skill de pentesting con 5 gates (A autorización · B no-productivo · C alcance · D fase · E anti-injection), cascada T0 gratis → T1 barato → T2 → T3 (explotación dirigida nativa), informe en español con métricas findings/USD, comandos `/loki` y `/loki-scan` — y volvé al menú.
- Opción `x` o gate en "no" → terminá sin acciones. Selección inválida → re-mostrá el menú.

### 4. Con selección → invocá la skill `loki` (SKILL.md) con modo/tier elegido
Seguí su FLUJO DE EJECUCIÓN completo. Este comando es un wrapper delgado: el menú **no reemplaza ningún gate** — 5 gates inmutables, `no exploit, no report`, rate ≤5 req/s siguen aplicando verbatim. Opción `1` con explotación → delegá `hack-audit` (con rate-limit inyectado y T2-verify de sus hallazgos) o T3 `deep` según lo confirmado.

## CASO B — "Entrada:" con contenido → arranque directo
Clasificá la entrada (URL / ruta existente / IP-red / "esta máquina"), mostrá el mismo banner con lo detectado, e invocá la skill `loki` (SKILL.md) directamente con tier por defecto `quick` (salvo que la entrada indique otro modo). Gates y flujo completos igual que siempre.
