# Loki — Gate de validación y confianza (T1/T2)

> Método adaptado y reescrito de `anthropics/claude-code-security-review` (MIT), `elementalsouls/Claude-BugHunter` (MIT + CC BY 4.0) y `SnailSploit/Claude-Red` (MIT). Ver `NOTICE`. No se copiaron archivos ni código.

Se aplica antes de escribir `vulnerabilities.json` y antes de dar un hallazgo por confirmado.

## 1. Escala de confianza (obligatoria)

| Confianza | Estado | Acción |
|---|---|---|
| 9–10 | `confirmed` | PoC reproducible + impacto demostrado. Entra al informe. |
| 8 | `confirmed` | Camino completo verificado y PoC mínimo reproducible. Entra. |
| 5–7 | `needs-validation` | Hay camino pero falta PoC o contexto. No se reporta como confirmado. |
| 1–4 | `discarded` | Patrón sin impacto, código muerto o protección existente. Sale con motivo. |

Regla dura: **confianza <8 nunca se presenta como `confirmed`**. El score se justifica en una línea.

## 2. Pre-Severity Gate (solo `critical`/`high`)

Antes de asignar `critical` o `high`, responder:

1. ¿El impacto es demostrado o solo "podría"?
2. ¿El atacante controla el input y alcanza el sink en este contexto?
3. ¿La protección existente (middleware, escape, permiso) ya lo cubre?
4. ¿El alcance real está dentro de `scope.txt` y del entorno autorizado?

Si alguna respuesta deja duda → bajar a `medium` o `needs-validation`. Nunca inflar severidad para "que se vea".

## 3. Estado y retest

Cada hallazgo confirmado lleva:

- `estado`: `abierto` | `corregido` | `riesgo_aceptado`
- `retest`: fecha + comando/pasos usados para re-verificar (o `pendiente`)

## 4. Retracción

Si un hallazgo confirmado se cae al re-verificar, se marca `retractado` con motivo y se descuenta del conteo. No se borra la traza: el informe declara el cambio.

## 5. Qué no entra

- DoS o agotamiento sin impacto demostrado (en modo completo sí se audita como categoría, con evidencia).
- Rate limiting genérico sin bypass reproducible.
- Secretos en disco sin exposición real (se reportan como higiene, no como crítico).
- Open redirect sin cadena a robo de token/sesión.
- Hallazgos preexistentes mezclados con el diff (van aparte, `pre-existing`).

> Fuente: filtros de alto ruido de Anthropic + Q6 de BugHunter ("impacto demostrado, no técnicamente posible") + anclaje CVSS de Claude-Red. Reescrito y acotado a Loki.
