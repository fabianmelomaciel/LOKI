# Loki — Checklist Normativo (índice de mapeo)

> Cada hallazgo del informe debe mapear a ≥1 norma de esta lista. Carga perezosa: leer el archivo de norma solo si hay hallazgos que mapear.

## Clasificación técnica (obligatoria para todo hallazgo)
| Norma | Uso | Referencia |
|-------|-----|------------|
| **CWE Top 25** | Clasificación técnica del defecto (CWE-ID en cada hallazgo) | `https://cwe.mitre.org/top25/` |
| **OWASP Top 10 (2025)** | Categoría de riesgo de aplicación | OWASP A01–A10 |
| **ISO/IEC 27001:2022 Annex A** | **Obligatorio.** Control (ej. `A.8.8`) en el campo `iso27001` del schema — ver `references/iso27001-mapping.md` para la tabla CWE→control | `docs/estandares/checklist.md` + `references/iso27001-mapping.md` |

## Metodología de fases
| Norma | Uso |
|-------|-----|
| **PTES** | Estructura de fases del pentest (pre-engagement, recon, análisis, explotación, post-explotación, reporte) |
| **OWASP WSTG** | Técnicas de testing web por categoría |

## Controles y reporte
| Norma | Uso |
|-------|-----|
| **NIST SP 800-115** | Guía técnica de security testing — coherencia de método |
| **NIST CSF 2.0** | Estructura de hallazgo/remediación para comité (Identify/Protect/Detect/Respond/Recover) |
| **ISO 27002** | Detalle de implementación del control Annex A asignado (ver clasificación técnica arriba) |
| **ISO 29148** | Calidad de redacción de hallazgos/requisitos (claro, verificable, trazable) |
| **OWASP ASVS** | Requisitos verificables para apps (nivel según criticidad) |

## IA / agentes (cuando el target use LLM)
| Norma | Uso |
|-------|-----|
| **OWASP LLM Top 10 (2025)** | Riesgos LLM (LLM01 prompt injection, etc.) |
| **MITRE ATLAS** | Tácticas de ataque a sistemas ML/IA |
| **MITRE ATT&CK** | Mapeo tácticas/techniques del ataque demostrado (para red/equipo) |

## Legal / evidencia
- `docs/normas/CODIGO-ETICO.md` — ética.
- `docs/normas/LEGALES.md` — autorización y responsabilidad.
- `docs/normas/EVIDENCIAS.md` — custodia y redacción.
- RGPD/LOPD u homólogas — cuando haya PII en evidencias.
