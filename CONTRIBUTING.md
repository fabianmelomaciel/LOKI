# Contribuir a Loki

Gracias por el interés. Antes de un PR:

1. **Leé `docs/normas/LEGALES.md` y aceptá la cláusula *authorized-use only* de `LICENSE`.** Loki ejecuta técnicas ofensivas — cualquier cambio que facilite usarlo sin autorización del dueño del sistema no se acepta.
2. **Los 5 gates de `SKILL.md` (A-Autorización, B-No-producción, C-Alcance, D-Confirmación por fase, E-Anti-injection) y la regla "no exploit, no report" son inmutables** — ver `AGENTS.md`. No mandes PRs que los debiliten, los hagan opcionales o los muevan a config editable por el usuario.
3. **Tras tocar `install.ps1` o `install.sh`: corré la verificación y confirmá `SYNC`:**
   ```
   .\install.ps1 -Check     # Windows
   ./install.sh --check     # Linux/macOS/WSL
   ```
   Si tocás versión o lista de archivos, editá solo `loki.manifest.sh` (fuente única) — nunca los instaladores directamente.
4. **No commitees:** `reports/` (salvo `informe-ejemplo.md`), `.loki/`, `scope.txt`, secretos, evidencias crudas, ni `CODEX.md` (es local-only).
5. **JSON de `references/schemas/` debe seguir siendo válido** — el CI lo valida (`node -e "JSON.parse(...)"`).
6. Abrí el PR contra `main` con una descripción de qué cambia y por qué. El CI (gitleaks + schemas + install-check en Windows/Linux/macOS) tiene que pasar en verde.

Dudas o vulnerabilidades encontradas en el propio Loki: ver [`SECURITY.md`](SECURITY.md).
