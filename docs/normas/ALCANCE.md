# Loki — Plantilla de Alcance (scope) y Denylist

## `scope.txt` (deny-by-default)

Plantilla oficial: `templates/scope.txt` — copiar a la carpeta de la corrida antes de cualquier fase activa (Gate C). Formato:

```
# INCLUSIONES (lo único que se puede tocar)
TARGET_URL=https://staging.ejemplo.local
HOSTS=127.0.0.1,192.168.1.0/24
PORTS=3000,8080,22
PATHS=/api/,/auth/
REPOS=/ruta/al/repo

# EXCLUSIONES (prioridad sobre inclusiones)
EXCLUDE_PATHS=/logout,/admin/delete,/api/payments/refund
EXCLUDE_HOSTS=

# METADATANO
ENVIRONMENT=staging          # staging|sandbox|local — NUNCA production
AUTHORIZATION=escrita|owner  # Gate A: cómo se acredita
DATE=YYYY-MM-DD
```

## Denylist de producción (bloquea fases activas)

Detección heurística — si coincide CUALQUIERA → **solo análisis estático**:
- `ENVIRONMENT=production` o `env=production` en configs.
- IPs públicas sin confirmación explícita de dueño (ej. no-RFC1918 en targets remotos).
- Dominios comerciales reales (`*.com`, `*.io` públicos) no declarados en inclusiones.
- Endpoints cloud de gestión (`console.cloud.google.com`, `*.amazonaws.com` de gestión, etc.).
- Cualquier host fuera de `scope.txt`.

**Override:** flag explícito `--i-own-production` + re-confirmación Gate B. Aun así, la explotación mutativa queda prohibida en producción; solo recon pasivo y estático.

## Reglas de alcance
- Toda superficie nueva descubierta durante el recon se añade a `scope.txt` y re-gatea (Gate C) antes de tocarse.
- Modo `equipo`: el alcance son repos e inventario de accesos; **nunca** incluye atacar personas, phishing ni fuerza bruta contra cuentas reales de usuarios.
- Modo `red`: solo hosts/segmentos listados; respetar **rate ≤5 req/s, ≤2 concurrentes** y ventanas horarias si el acuerdo de alcance las define.

## Multi-repo (`REPOS=` con varios proyectos)

`REPOS=` acepta más de una ruta **solo** en modo `equipo` intencional (nunca por default —
ver `references/multi-repo-guard.md` de la skill para el guard de Fase 1 que lo detecta y
detiene la corrida si el usuario no lo confirmó explícitamente):

- Cada repo listado necesita su **propio Gate A** (autorización verificable) — no alcanza con
  que uno de los repos esté autorizado para asumir los demás.
- El informe final **nunca mezcla hallazgos de repos distintos bajo un solo `Target`** —
  `docs/estandares/informe-maestro.md` segmenta por repo cuando `REPOS=` tiene más de una
  entrada.
- Una carpeta padre que contiene varios repos (ej. la raíz de todos los proyectos de un
  operador) **no es un target válido por sí sola** — es una lista de candidatos, y cada uno
  entra a `REPOS=` de forma explícita o no entra.
