# Grabar la demo visual de Loki

**Estado actual: instrucciones listas, sin demo grabada todavía.** Grabar terminal en vivo no es algo que un agente de código pueda hacer por sí solo (no hay pantalla ni terminal interactiva real en este entorno) — esto es para que el mantenedor (o cualquier contributor) la genere en minutos.

## Opción recomendada: asciinema (liviano, texto, sin binario pesado en el repo)

1. Instalar: `brew install asciinema` / `apt install asciinema` / `winget install asciinema` (o WSL).
2. Levantar un target de prueba local (ver [`docs/BENCHMARK.md`](BENCHMARK.md) — Juice Shop o DVWA con Docker).
3. Grabar una corrida `quick` real y corta (apuntar a ≤2 minutos de cast):
   ```
   asciinema rec loki-demo.cast
   # dentro de la sesión: "Auditá http://localhost:3000 con Loki (modo quick)"
   # dejar que corra hasta el informe final, luego Ctrl+D
   ```
4. Subir el cast: `asciinema upload loki-demo.cast` (devuelve una URL pública tipo `asciinema.org/a/XXXXX`).
5. Embeber en el README:
   ```markdown
   [![asciicast](https://asciinema.org/a/XXXXX.svg)](https://asciinema.org/a/XXXXX)
   ```

## Alternativa: GIF corto

Si se prefiere un GIF (más pesado, pero se ve directo en GitHub sin click):
1. Grabar con `asciinema rec` como arriba.
2. Convertir con [`agg`](https://github.com/asciinema/agg): `agg loki-demo.cast loki-demo.gif --speed 1.5`.
3. Guardar en `docs/assets/loki-demo.gif` (crear la carpeta) y embeber con `![demo](docs/assets/loki-demo.gif)`.

## Qué mostrar (guion sugerido, ≤2 min)

1. Prompt de una línea pidiendo la auditoría (mostrar que no hace falta configuración previa).
2. Los 5 gates pidiendo confirmación (autorización, scope) — es el diferencial ético, no ocultarlo.
3. T0-pasivo corriendo en paralelo (Semgrep/Gitleaks/etc.) — mostrar que es gratis y rápido.
4. El informe final con el mapeo ISO 27001 de al menos un hallazgo.

No graba el mantenedor apurado ni con secretos reales en pantalla — usar siempre el target de prueba local, nunca un repo/cliente real.
