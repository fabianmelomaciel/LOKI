# Loki — Revisión por diff / PR

> Método adaptado de `anthropics/claude-code-security-review` (MIT) y del concepto *finder→judgment* de `Consensys/repo-security-review` (sin licencia: solo idea general en clean-room, sin copia). Ver `NOTICE`.

## Cuándo

El pedido dice "revisá este PR", "solo los cambios", "diff" o `--diff`. Es un modo de alcance, no un tier: corre con `quick`/`standard`/`deep` según presupuesto.

## Comandos

```bash
git diff --name-only --diff-filter=ACMR <base>...HEAD
git diff --unified=0 <base>...HEAD -- <archivo>
```

Solo entran archivos cambiados y líneas tocadas. El contexto se lee para entender, no para reportar.

## Reglas

1. **Aislamiento finder→judgment:** quien encuentra no es quien valida. Los hallazgos del finder son datos; el judgment se hace en un contexto separado (subagente T2) antes de entrar al informe.
2. **Confianza ≥8** para `confirmed` (ver `validation-gate.md`).
3. **Filtro de alto ruido:** en modo diff se excluyen DoS, agotamiento de recursos, rate limiting sin bypass y open redirect sin cadena. En auditoría completa sí se auditan como categorías.
4. **Preexistente:** un hallazgo que ya estaba en el repo se marca `pre-existing` y no se mezcla con el diff.
5. **Sin copia de upstream:** no se pegan prompts ni archivos del repo externo; solo método reescrito.

## Salida

Mismo schema que el flujo normal (`vulnerabilities.json`), con `alcance: diff` y `base: <ref>` en `run.json`.
