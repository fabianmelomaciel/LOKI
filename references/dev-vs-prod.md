# Loki — Análisis dev vs producción (priorización de hallazgos)

> **Regla central:** todo hallazgo lleva `alcance: prod | dev | ambos` y el informe ordena
> **producción primero**. Si un hallazgo afecta producción, manda — aunque otro sea técnicamente
> más severo pero solo exista en dev. Presunción conservadora: duda → `prod` (mejor priorizar de
> más que ocultar). Ver also `docs/estandares/informe-maestro.md` §3.

## 1. Señales de contexto dev (Fase 1 — recon)

- **`.gitignore` presente** → leer sus patrones: definen qué es **exclusivo de dev** y no se
  commitea ni (normalmente) se despliega:
  - Típicos dev-only: `.env*`, `*.local`, `credentials*`, `*.pem`, `.vscode/`, `.idea/`,
    `dump*`, `*.sqlite`, `coverage/`, `*.log`, `.DS_Store`, `node_modules/`.
  - Ambiguos (analizar caso a caso): `dist/`, `build/`, `.next/` — si hay pipeline de deploy,
    **el artifact SÍ llega a producción** aunque esté gitignored.
  - `.env` gitignored **no** significa inofensivo: si el .md de config muestra defaults
    inseguros (secretos hardcodeados fallback), eso SÍ escala a prod → `alcance: prod`.
- **`package.json`**: `devDependencies` (nodemon, concurrently, vite, jest, fixtures) = código
  que **no corre en producción** → hallazgos ahí suelen ser `dev`. `dependencies` → `prod`.
- **Config/debug**: `DEBUG=*`, `NODE_ENV` checks, `listen(0.0.0.0)` solo en dev, CORS `*` en
  dev-config, seeds/demo data, endpoints `/debug`, swagger expuesto.
- **Evidencia de despliegue**: `.github/workflows/`, `Dockerfile`, `docker-compose*`,
  `k8s/`, `ecosystem.config*`, `Procfile`, `fly.toml` → muestrear qué archivos entran a prod
  (build context, CMD/ENTRYPOINT, `COPY`).

## 2. Clasificación por hallazgo

| `alcance` | Criterio | Prioridad en informe |
|---|---|---|
| `prod` | Código/config que se despliega o expone en producción (runtime del server, `dependencies`, endpoints vivos, CI/CD) | **1º — prioridad máxima** |
| `ambos` | Afecta dev y prod (la mayoría de bugs de código runtime) | Tratar como `prod` |
| `dev` | Solo en dev-only: gitignored no-desplegable, `devDependencies`, fixtures, debug-only, tests | Al final — calidad, no producción |

## 3. Checklist de `.gitignore` (obligatorio si existe)

1. Listar patrones y clasificar: dev-only vs "gitignored pero desplegable" (artifacts).
2. ¿El hallazgo está en un archivo **gitignored y no-desplegable**? → `dev`.
3. ¿Está en fuente commiteada / dependencies de producción / config de deploy? → `prod`.
4. ¿No se puede determinar (repo sin pipeline visible)? → declarar en *Cobertura*:
   "sin evidencia de despliegue — asumir `prod` salvo indicación" (fail-closed).

## 4. Salida obligatoria

- Por hallazgo: campo `alcance` en `vulnerabilities.json` (schema) + `**Alcance:** {…}` en
  `informe.md` + tag en `informe.html` (`.tag-prod` / `.tag-dev`).
- §3 del informe: ordenar prod/ambos → dev. En §1 resumen: si hay severidad alta/crítica
  solo-dev, mencionarlo explícito ("crítico solo-dev, no afecta producción") para no
  alarmar ni ocultar.
- **Nunca degradar** un hallazgo prod por ser "de dev tools": la prioridad es por alcance,
  la severidad técnica se mantiene intacta.
