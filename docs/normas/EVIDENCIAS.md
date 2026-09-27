# Loki — Manejo de Evidencias y Secretos

## Secretos y credenciales hallados
- **Nunca** copiar el valor literal al informe ni a ningún artefacto commiteable.
- Formato permitido: placeholder + prefijo/sufijo parcial (ej. `AKIA****XYZ1`) + recomendación de **rotación/revocación inmediata**.
- **No usar** el hallazgo para autenticarse ni probarlo como llave de acceso.
- No persistir en claro en `reports/` ni en logs locales.

## Datos de usuarios / PII
- Siempre placeholders (`[email_usuario]`, `[nombre]`).
- Minimización: capturar solo lo necesario para demostrar el impacto.
- Retención limitada: borrar evidencias crudas tras el cierre del informe (o cifrarlas).

## Cadena de custodia
Cada evidencia registrada con:
- SHA-256 del artefacto
- Timestamp (UTC)
- Host/target, comando o request ejecutado
- Fase y gate bajo los que se ejecutó

## Almacenamiento
- `reports/` va en `.gitignore` — nunca commitear evidencias.
- Evidencias crudas: carpeta local excluida de git; cifrada cuando contenga secretos o PII.
- Bitácora de auditoría: `.loki/audit-log.jsonl` — append-only: `{ts, user, gate, scope, mode, active_commands, target}`. La bitácora del pentester es evidencia de conducta, no se edita ni se borra.

## Informes
- SARIF 2.1.0 + JSON + Markdown en español.
- Nunca secretos vivos ni PII en claro dentro del informe (ver plantilla `docs/estandares/informe-maestro.md`).
