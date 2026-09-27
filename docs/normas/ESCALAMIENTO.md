# Loki — Escalamiento (hallazgos sensibles en vivo)

Cuando una fase detecte algo que excede lo rutinario, **detener la explotación activa** y escalar al usuario. No continuar por tu cuenta.

## RCE activo / acceso shell ya logrado
1. Detener la explotación inmediatamente (no persistir, no moverte lateralmente, no "explotar más").
2. Preservar la evidencia mínima del PoC (request/comando + resultado) con hash y timestamp.
3. Informar al usuario: alcance alcanzado, riesgo real, y recomendación de parche urgente.
4. Ofrecer continuar solo si el usuario re-confirma Gate D y el alcance lo permite.

## Datos personales o secretos de terceros expuestos en vivo
1. No descargar el volumen completo; capturar solo la evidencia mínima de impacto (placeholder).
2. Nunca incluir el contenido real en el informe ni en logs (`EVIDENCIAS.md`).
3. Escalar al usuario con recomendación de notificación/rotación según aplique (RGPD/LOPD u homólogas).

## Sospecha de compromiso previo (no nuestro) del target
1. Detener; el target puede ya estar comprometido por un tercero.
2. Documentar indicadores observados (IOCs) sin realizar acciones ofensivas adicionales.
3. Escalar al usuario para decisión.

## Petición del usuario fuera de política
Si el usuario pide: borrar logs, atacar producción, apuntar a terceros, fuerza bruta real → **rechazar**, citar `CODIGO-ETICO.md` y `GATES.md`, ofrecer alternativas dentro de política (solo estático, cambio de target, etc.).

## Fallo de infraestructura de la corrida
Presupuesto agotado, timeout, 3 fallos consecutivos de subagentes → declarar el early-exit en el informe como **"cobertura no completada"** (nunca silencioso) y terminar.
