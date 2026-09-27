# Changelog

Todas las versiones notables de Loki. Formato basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/).

## [1.0.0] — 2026-09-26

Primer release público. Creado y mantenido por **Lic. Fabián Melo**.

### Added
- **Skill maestra** (`SKILL.md`, `name: loki`): orquestador de pentesting/auditoría con 5 gates de autorización no negociables (A-identidad, B-no producción, C-scope, D-confirmación por fase, E-fuente no confiable) y cascada de 4 tiers de costo (T0-pasivo gratis → T0-activo gratis-gated → T1 barato → T2 profundo → T3 externo opcional).
- **Delegación validada** a skills de SkillGrid: `auditor-de-seguridad` (estático 12 categorías), `cyber-neo` (SCA/SAST/secretos/IaC), `hack-audit` (explotación real local/red — analizada y confirmada como complementaria, no duplicada), `audit-loop`, `supply-chain-auditor`, `prompt-injection-guard`.
- **Cumplimiento normativo con ISO/IEC 27001:2022 Annex A obligatorio** por hallazgo (campo `iso27001` en `vulnerabilities.schema.json`, tabla de mapeo CWE→control en `references/iso27001-mapping.md`) — además de CWE Top 25, OWASP Top 10/ASVS/WSTG/LLM Top 10, MITRE ATT&CK/ATLAS, NIST SP 800-115/CSF 2.0, PTES.
- Informes en español con métricas de eficiencia obligatorias (`findings/USD`, `%T0 gratis`, cobertura, tendencia) vía `scripts/metrics.ps1`.
- SARIF 2.1.0 como formato de salida interoperable (nativo en Semgrep/Trivy/Nuclei; conversión en T1/T2 para motores que no lo emiten).
- Instaladores multiplataforma `install.ps1` / `install.sh` con `-Check`/`-Uninstall`, matriz de herramientas T0 disponibles/faltantes y detección de delegación SkillGrid.
- `AGENTS.md` (reglas inmutables), `SECURITY.md` (divulgación responsable), `LICENSE` (MIT + cláusula *authorized-use only*).

### Notas de diseño
- Regla absoluta **"no exploit, no report"**: sin PoC reproducible no hay hallazgo — validado contra el mismo patrón en Shannon/Strix vía investigación de mercado.
- Rate limit concreto (≤5 req/s, ≤2 concurrentes) y guard anti auto-daño (target ≠ host propio) en todo T0-activo/T1-T3.
