# 🔐 Informe de Auditoría — Loki (EJEMPLO)

**Target:** http://staging.app.local │ **Fecha:** 2026-09-22 │ **Modo:** quick │ **Tipo:** codigo
**Scope:** repo `./mi-app`, host staging, puertos 3000 │ **Gates:** A✓ B✓ C✓ D✓ (N/A — solo T0-pasivo) E✓
**Estado:** 🟢 Completado
**Redacción:** Secretos → 1 placeholder │ PII → 0 (sin PII en evidencias)

## 1. Resumen ejecutivo

La aplicación presenta un hallazgo crítico de inyección SQL en el endpoint de búsqueda y dos hallazgos medios de configuración (headers faltantes). No se detectaron secretos filtrados ni dependencias con CVE activo. Recomendación prioritaria: parametrizar la query en `src/search.js` antes de cualquier despliegue a producción.

## 2. Métricas de eficiencia (obligatorio)

| Métrica | Valor |
|---------|-------|
| wall_clock_s (+ por fase) | 142s (recon 12 / T0 95 / T1 20 / T2 15) |
| tokens in/out por tier | T1: 12K/3K · T2: 8K/2K |
| cost_usd total / por tier | $0.06 (T1 $0.02 + T2 $0.04) |
| findings/USD | 50.0 |
| findings/1K tokens | 0.23 |
| % hallazgos de T0 gratis (objetivo ≥70%) | 100% OK |
| Falsos positivos descartados en triage | 3 (33%) |
| Cobertura (archivos escaneados/total) | 142/142 (100%) |
| Herramientas T0 disponibles / faltantes | semgrep,trivy,gitleaks,bandit / nuclei,nmap (T0-activo no requerido) |
| Tendencia vs corridas previas | 1ª corrida de este target |
| Secretos redactados / PII placeholder | 1 / 0 |

## 3. Hallazgos por severidad

### [critical] SQL Injection en búsqueda — CWE-89 / OWASP A03
- **Ubicación:** `src/search.js:42`
- **Norma:** CWE-89, OWASP A03:2021
- **Descripción:** Concatenación de input de usuario en query SQL sin parametrizar.
- **PoC (reproducible):**
  ```
  curl "http://staging.app.local/api/search?q=x'%20OR%201=1--"
  → devuelve todos los registros (bypass de filtro)
  ```
- **Impacto:** Lectura/posible borrado de la BD completa.
- **Remediación:** Usar prepared statements del ORM en `src/search.js:42` (parámetro `q`).
- **Evidencia:** sha256 `a3f2…c81` + 2026-09-22T10:15:00Z

#### Conteo
🔴 Crítico: 1 │ 🟠 Alto: 0 │ 🟡 Medio: 2 │ 🔵 Bajo: 0 │ ⚪ Info: 1

## 4. Cobertura y limitaciones

Se corrió T0-pasivo completo (Semgrep, Trivy, Gitleaks, Bandit). T0-activo (nmap/nuclei) no requerido por alcance (solo repo). Herramientas faltantes en host: nikto — declarada, no bloquea.

## 5. Artefactos

- `vulnerabilities.json` — 4 hallazgos (schema v1.1.0)
- `run.json` — status=completed, llm_usage.cost_usd=0.06, evidence_hashes=1

## 6. Recomendaciones priorizadas

1. **Inmediato:** parametrizar `src/search.js:42`.
2. **Corto plazo:** añadir headers HSTS/CSP (hallazgos medios).
3. **Estructural:** gate de CI con Semgrep owasp-top-ten en cada PR.

---
*Revisión humana requerida antes de cerrar. Salida LLM puede contener alucinaciones.*
*Generado por Loki — no exploit, no report.*
