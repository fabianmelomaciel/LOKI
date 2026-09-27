# Loki — Plantilla de Informe Maestro (español)

> Copiar esta plantilla a `reports/<fecha>-<target>/informe.md` y rellenar. Estructura fija — no reordenar secciones. Todo hallazgo necesita PoC reproducible o se descarta.
> **Cierre obligatorio (SKILL.md paso 12):** generar `informe.html` desde `templates/informe.html` (contenido HTML-escapado) y abrirlo en el navegador default del SO — imprimir siempre el link `file:///`.
> **Priorización (ver `references/dev-vs-prod.md`):** §3 ordena **producción primero** — `alcance: prod/ambos` antes que `dev`, duda → prod.
> **Target multi-repo (ver `references/multi-repo-guard.md`):** si `scope.txt` declaró más de un `REPOS=` (modo `equipo` intencional), **nunca** un solo `{target}` mezclando hallazgos de repos distintos. Generar un `informe-<repo>.md` completo (cabecera + §1-§7, hash de evidencia propio) por cada repo dentro de `reports/<fecha>-<target-padre>/`, y un `informe.md` raíz que solo resume qué repos se auditaron con link a cada uno.
> **Para IDEs con IA que van a reparar hallazgos:** este `.md` (y su espejo `.html`) son para lectura humana. El artefacto para reparar en loop es `vulnerabilities.json` — cada hallazgo trae `file`+`line`, `remediation` (criterio) y, cuando el fix es mecánico, `fix_snippet` (código corregido ≤10 líneas listo para aplicar). Iterar ese JSON, no parsear prosa.

```markdown
# 🔐 Informe de Auditoría — Loki
**Target:** {target} (single-repo; si multi-repo ver nota arriba — un `{target}` = un repo, siempre) │ **Fecha:** {fecha} │ **Modo:** {quick|standard|deep} │ **Tipo:** {codigo|red|equipo}
**Scope:** {scope.txt resumido} │ **Gates:** A✓ B✓ C✓ D✓ E✓
**Estado:** 🟢 Completado / 🟡 Cobertura no completada / 🔴 Detenido por gate
**Redacción:** Secretos → {n} placeholders │ PII → {n} minimizada (checklist EVIDENCIAS.md)

## 1. Resumen ejecutivo
{3–6 párrafos: postura de seguridad, riesgo de negocio, top findings, recomendación prioritaria. Sin jerga innecesaria.}

## 2. Métricas de eficiencia (obligatorio)
| Métrica | Valor |
|---------|-------|
| wall_clock_s (+ por fase) | |
| tokens in/out por tier | |
| cost_usd total / por tier | |
| findings/USD | |
| findings/1K tokens | |
| % hallazgos de T0 gratis (objetivo ≥70%) | |
| Falsos positivos descartados en triage | |
| Cobertura (archivos escaneados/total, fases) | |
| Herramientas T0 disponibles / faltantes | |
| Tendencia vs corridas previas (index.jsonl) | |
| Secretos redactados / PII placeholder (check sí) | |

## 3. Hallazgos por severidad
{Orden: **prod/ambos primero**, dev al final (severidad intacta — solo cambia el orden). Para cada hallazgo:}
### [{SEVERIDAD}] {Título} — {CWE-XX / OWASP A0X / ISO27001 {control}}
- **Ubicación:** {file:line o endpoint}
- **Alcance:** {prod | dev | ambos} — {"afecta producción" si prod/ambos; si es solo-dev y de severidad alta/crítica, declararlo explícito en §1}
- **Norma:** CWE-XX · OWASP A0X · **ISO/IEC 27001:2022 {control Annex A}** (obligatorio — ver `references/iso27001-mapping.md`) · MITRE si aplica
- **Descripción:** {qué está mal y por qué importa}
- **PoC (reproducible):** {request/comando/pasos exactos}
- **Impacto:** {qué puede lograr un atacante}
- **Remediación:** {fix concreto, no genérico}
- **Fix rápido:** {fix_snippet si existe en vulnerabilities.json — código corregido ≤10 líneas; omitir esta línea si no aplica}
- **Evidencia:** {hash SHA-256 + timestamp}

#### Conteo
🔴 Crítico: {n} │ 🟠 Alto: {n} │ 🟡 Medio: {n} │ 🔵 Bajo: {n} │ ⚪ Info: {n}

## 4. Cobertura y limitaciones
{Qué se escaneó, qué no, por qué (herramienta faltante, scope, early-exit declarado).}

## 5. Artefactos
- `vulnerabilities.json` — hallazgos estructurados
- `findings.sarif` — SARIF 2.1.0 (si aplica)
- `run.json` — metadata de corrida y llm_usage

## 6. Recomendaciones priorizadas
1. {Acción inmediata (si crítico)}
2. {Plan corto plazo}
3. {Mejoras estructurales}

## 7. Cumplimiento normativo
- **ISO/IEC 27001:2022 Annex A:** resumen agregado de los controles afectados (el detalle por hallazgo ya va en §3, obligatorio — `references/iso27001-mapping.md`). {n} hallazgos → controles {A.xx,…} afectados.
- **Leyes de datos personales aplicables** (solo si el hallazgo toca PII y el target opera/esas personas; ver `references/leyes-datos-personales.md`): {jurisdicción → régimen: Uruguay Ley 18.331 · GDPR UE · LGPD Brasil · CCPA California · …} con artículo de seguridad/notificación y plazo (GDPR 72 h).
- **Estándares sectoriales si aplica:** ISO/IEC 27701 (privacidad), PCI-DSS (datos de tarjetas), NIST SP 800-53/CSF 2.0.
- Pie obligatorio: *referencia normativa — no asesoría legal; verificar vigencia con asesor (LEGALES.md).*

---
*Revisión humana requerida antes de cerrar. Salida LLM puede contener alucinaciones.*
*Generado por Loki — no exploit, no report.*
```
