# Loki — Guard multi-repo (Fase 1)

> Por qué existe: si TARGET termina siendo una carpeta padre que contiene varios repos
> independientes (ej. `C:\laragon\www`, padre de ~20 proyectos no relacionados), Loki podía
> escanearlos todos juntos y emitir **un solo informe** que mezcla hallazgos, secretos y PII
> de proyectos/clientes distintos bajo un único `{target}`. Este guard corre **antes** de
> cualquier tool T0 y antes del conteo de archivos de Fase 1 (`SKILL.md` paso 5).

## 1. Detección

1. Si TARGET es una ruta local: `git rev-parse --show-toplevel` desde esa ruta.
   - Si **coincide** con TARGET (o TARGET no es repo pero el toplevel resuelto es un único
     ancestro directo) → TARGET es la raíz de un repo. Seguir normal, sin STOP.
2. Si el comando anterior **falla** (TARGET no es un repo git) → enumerar carpetas `.git` de
   primer/segundo nivel bajo TARGET, excluyendo `node_modules`:
   ```bash
   find TARGET -maxdepth 3 -type d -name ".git" -not -path '*/node_modules/*'
   ```
3. **0 resultados** → TARGET no contiene ningún repo (código suelto o non-git). Seguir normal,
   advertir en el informe "sin control de versiones detectado".
4. **1 resultado** → tratar esa carpeta como raíz efectiva del repo. Seguir normal.
5. **≥2 resultados** → **STOP**. No auto-elegir, no escanear la carpeta padre completa.

## 2. Mensaje de STOP (multi-repo detectado)

```
🛑 Loki detectó N repos independientes bajo {TARGET}:
├─ {repo_1} (origin: {url|sin remoto})
├─ {repo_2} (origin: {url|sin remoto})
└─ ...

No se puede auditar una carpeta que mezcla varios proyectos en una sola corrida —
cada repo necesita su propio Gate A (autorización) y Gate C (scope.txt).

Elegí una opción:
 1. Auditar solo uno → indicá cuál (ruta exacta)
 2. Multi-repo intencional (modo `equipo`) → confirmá Gate A/C repo por repo (ver abajo)
 x. Cancelar
```

## 3. Multi-repo intencional (modo `equipo`)

Si el usuario confirma que quiere auditar varios repos a la vez (modo `equipo`, ya soportado
en `SKILL.md` §"Modo por tipo de objetivo"):

- **Gate A y Gate C se re-confirman por cada repo**, nunca una vez para la carpeta padre.
  `scope.txt` lista cada repo en `REPOS=` de forma explícita (uno por línea o coma-separado,
  pero cada uno debe tener autorización verificable — ver `docs/normas/ALCANCE.md`).
- Patrón de referencia ya validado en SkillGrid: `hack-audit` mapea proceso→repo y suma cada
  repo al alcance **uno por uno** (nunca "la máquina entera" de un solo golpe) cuando el target
  es "esta máquina".
- El informe final **segmenta por repo** — ver `docs/estandares/informe-maestro.md` §"Target
  multi-repo": una tabla con un bloque de hallazgos y hash de evidencia por repo, nunca
  hallazgos de distintos repos mezclados bajo un solo `Target`.
- `run.json` registra `repo_count` (int) e `is_multi_repo` (bool) — ver
  `references/schemas/run.schema.json` — para poder filtrar corridas multi-repo en
  `reports/index.jsonl` al calcular tendencias (`scripts/metrics.ps1`).

## 4. Conteo de archivos con exclusiones (patrón cyber-neo)

Una vez resuelto el repo (único), el conteo de Fase 1 que decide el tier
(`<1k full / 1k–10k targeted / >10k critical-path`) **ya debe excluir ruido** en el mismo
comando — patrón validado en `SkillGrid/skills/cyber-neo/SKILL.md` (Step 1.2):

```bash
find REPO_ROOT -type f \
  -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/vendor/*' \
  -not -path '*/__pycache__/*' -not -path '*/dist/*' -not -path '*/build/*' \
  -not -path '*/.next/*' -not -path '*/target/*' | wc -l
```

Sin esto, un repo con `node_modules`/`vendor`/backups pesados infla el conteo, fuerza el tier
`critical-path` de forma artificial y degrada la métrica "% hallazgos de T0 gratis" al mezclar
ruido no auditable con señal real.
