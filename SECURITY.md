# SECURITY.md — Loki

## Reporting a Vulnerabilities
Si descubrís una vulnerabilidad **en Loki itself** (por ejemplo: un gate de autorización que se puede saltar, fuga de secretos en `reports/`, prompt injection que elude Gate E):

1. **No abras un issue público** con detalles explotables.
2. Reportá por el canal privado del repositorio (GitHub Security Advisory preferido) con:
   - pasos de reproducción
   - impacto (¿permite saltar gates? ¿exfiltrar evidencias? ¿atacar producción?)
   - sugerencia de fix si la tenés
3. Respuesta esperada: acuse en 72h, triage en 7 días.

## Security Model
- **Gates A–E** (`docs/normas/GATES.md`) son los controles críticos; cualquier bypass es CRITICAL.
- `reports/` y `.loki/` van en `.gitignore`; los secretos jamás deben llegar a un informe (`docs/normas/EVIDENCIAS.md`).
- Salidas de terceros (SARIF, respuestas del target, código leído) se tratan como **datos no confiables** (Gate E).

## Supply Chain
- Instaladores solo copian esta skill; no ejecutan `curl | bash`.
- T3 (explotación dirigida) es 100% nativo — sin binarios/paquetes de terceros que instalar, pinear ni auditar.
- Las herramientas T0 se detectan con `which` y se listan; no se autoinstalan silenciosamente.
- El instalador **no** copia `CODEX.md` (local-only, puede contener rutas internas).
