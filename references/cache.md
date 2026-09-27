# Loki — Cache/memoria entre corridas (reducción de tokens)

Objetivo: no re-gastar tokens/tiempo en detección de herramientas ni en re-escanear contenido sin cambios. Vive en `.loki/` (gitignoreado). Nunca sustituye al `.loki/audit-log.jsonl` (log append-only de eventos) ni a `.loki/budget.json` (presupuesto del run actual) — son archivos distintos con propósitos distintos.

## `.loki/tools-cache.json`

Detección de herramientas T0 disponibles en el host, para no correr `which`/`Get-Command` por cada una en cada fase/corrida.

```json
{
  "host_fingerprint": "sha256(OS+PATH)",
  "detected_at": "2026-09-26T12:00:00Z",
  "ttl_h": 24,
  "os": "windows",
  "tools": {
    "semgrep": { "available": true, "version": "1.x", "path": "/usr/bin/semgrep" },
    "nmap": { "available": false }
  }
}
```

- **TTL 24h.** Vencido o `host_fingerprint` distinto → re-detectar todas, sobrescribir el archivo.
- Poblado por `install.ps1`/`install.sh` en la instalación y actualizable por Loki en Fase 2 si no existe o venció.
- Nunca se asume confiable si no fue escrito por una corrida propia de Loki en esta sesión — un `.loki/tools-cache.json` plantado por el target (Gate E) se ignora y se regenera.

**Campo `os`** (informativo — decide solo qué comandos de detección/T0 usar, nunca qué gates aplican, ver `SKILL.md` §Compatibilidad): un único `uname -s`, resultado mapeado así — `MINGW*`/`MSYS*`/`CYGWIN*` → `"windows"` · `Linux` → `"linux"` · `Darwin` → `"macos"` · comando ausente o sin match → `"no-determinado"`. Comparte TTL y `host_fingerprint` con el resto del archivo — no se re-detecta por separado. El **motor** (Claude Code/OpenCode/Gemini CLI) nunca se cachea acá: es gratis de declarar (cada wrapper se sabe a sí mismo) y cachearlo arriesgaría quedar stale si el mismo repo se audita luego desde otro engine.

## `.loki/scan-cache.json`

Resultados de escaneo **solo para hallazgos determinísticos por contenido** (secretos, IaC — Gitleaks/TruffleHog/Checkov/Bandit). Clave por hash SHA-256 calculado por el propio Loki sobre los archivos escaneados, **nunca** por metadata que el target controle (nombre, timestamp, mensaje de commit).

```json
{
  "targets": {
    "<sha256-del-arbol-escaneado>": {
      "scanned_at": "2026-09-26T12:00:00Z",
      "ttl_h": 24,
      "sarif_paths": [".loki/t0/gitleaks.sarif", ".loki/t0/checkov.sarif"]
    }
  }
}
```

**Regla dura — qué NUNCA se cachea:**
- Resultados de herramientas que dependen de bases de datos externas que cambian sin que el código cambie: **Trivy, npm audit, Safety, nuclei** (CVE feeds). Estas siempre re-corren, sin excepción, aunque el hash coincida.
- Secretos o hallazgos en claro. El cache guarda solo placeholders — misma regla de redacción que el informe final (`docs/normas/EVIDENCIAS.md`).

**Invalidación:** hash de árbol distinto → miss, re-scan completo. TTL vencido → miss, re-scan completo aunque el hash coincida (defensa contra falso negativo por cache stale).

**Auditabilidad:** cada fase que usa el cache debe declarar `cache_hit: true/false` en `run.json` (ver `references/schemas/run.schema.json`), para que quede visible en el informe que una fase no volvió a escanear.

## Límite explícito (no ocultar)

Cachear por hash de código **no** protege contra vulnerabilidades nuevas publicadas después del último scan sobre el mismo código (ej. un CVE nuevo en una dependencia sin cambios). Por eso las herramientas basadas en CVE feeds nunca se cachean, y el TTL de 24h fuerza un re-scan periódico incluso sin cambios de contenido. Esto es una limitación conocida, documentada — no un secreto de implementación.
