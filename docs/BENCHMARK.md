# Benchmark reproducible de Loki

**Estado actual: metodología definida, sin corrida publicada todavía.** Esta página documenta cómo correr el benchmark y cómo reportar resultados, para que cualquiera (nosotros u otro tercero) pueda reproducirlo y verificar los números — no reemplaza una corrida real.

## Por qué no hay números todavía

Un benchmark de pentest agent solo vale si corre contra un target real y reproducible. Publicar números inventados sería peor que no publicar nada. Esta guía es el paso previo: define el método para que la primera corrida real (hecha por el mantenedor o por cualquier contributor) sea comparable con las siguientes.

## Targets recomendados (vulnerable-by-design, autorización implícita del proyecto)

| Target | Por qué | Vulnerabilidades conocidas |
|---|---|---|
| [OWASP Juice Shop](https://github.com/juice-shop/juice-shop) | Estándar de facto, checklist de "retos" documentado | ~100 retos catalogados, mapeados a OWASP Top 10 |
| [DVWA](https://github.com/digininja/DVWA) | Simple, rápido de levantar, niveles de dificultad | SQLi, XSS, CSRF, command injection catalogados por nivel |
| Un repo propio con `npm audit`/`safety` conocidos | Mide SCA real, no solo SAST | CVEs reales en dependencias fijadas |

Correr siempre en **local** (Docker), nunca contra una instancia pública compartida — Gate B (no-producción) aplica también acá.

## Método

1. Levantar el target local: `docker run -p 3000:3000 bkimminich/juice-shop` (u otro).
2. Correr Loki en modo `standard` contra `http://localhost:3000` con Gates A-E cumplidos (target propio = autorización trivial, documentarlo igual en `scope.txt`).
3. Registrar la salida de `scripts/metrics.ps1` tal cual (no editar a mano): `wall_clock_s`, `cost_usd`, `findings_by_phase`, `% hallazgos T0 gratis`, findings/USD.
4. **Precisión (automatizada):** `powershell -File scripts/score.ps1 -Findings <ruta>/vulnerabilities.json -GroundTruth references/groundtruth/juice-shop.json` → `precision`, `recall`, `f1` (+ `uncovered_known`/`unmatched_findings` para revisión manual). El ground truth es un **starter subset** — ampliarlo con el scoreboard del target fijo (misma versión Docker) antes de publicar números; un match por CWE sin hint puede ser otro hallazgo.
5. Repetir 3 corridas (varianza de LLM) y reportar mediana, no una sola corrida.

## Qué reportar

```markdown
| Corrida | Target | Modo | $ | Tiempo | Findings | % T0 gratis | Recall | Precisión |
|---|---|---|---|---|---|---|---|---|
| 2026-XX-XX | Juice Shop vX.X | standard | $X.XX | Xm | N | X% | X% | X% |
```

Guardar el `run.json` y `vulnerabilities.json` de cada corrida benchmark en `reports/benchmark-<fecha>/` (queda gitignored por defecto — si se quiere publicar como evidencia, agregar excepción puntual en `.gitignore`, igual que `informe-ejemplo.md`).

## Comparación contra el ecosistema

Otras herramientas de pentesting con IA no publican metodología de benchmark reproducible contra targets fijos con este nivel de detalle (recall/precisión, no solo "encontró N vulnerabilidades"). Si alguien corre este método contra el mismo target con otra herramienta, el resultado es comparable — esa es la intención.
