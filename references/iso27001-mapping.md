# Loki — Mapeo CWE → ISO/IEC 27001:2022 Annex A (referencia rápida T1/T2)

> Ninguna herramienta de pentesting con IA relevada (CAI, PentestGPT, entre otras) mapea
> hallazgos a un control Annex A de forma nativa en su capa open source — es el diferenciador
> de Loki. Tabla de consulta rápida; si el CWE no aparece, usar el control más cercano por
> categoría y dejarlo explícito en el campo `finding` ("iso27001 aproximado por categoría X").

| Categoría de hallazgo | CWE típicos | Control Annex A | Nombre del control |
|---|---|---|---|
| Inyección (SQL/NoSQL/OS/LDAP) | CWE-89, CWE-78, CWE-90 | **A.8.28** | Codificación segura |
| XSS / validación de input | CWE-79, CWE-20 | **A.8.28** | Codificación segura |
| SSRF | CWE-918 | **A.8.20** | Seguridad de redes |
| Autenticación rota | CWE-287, CWE-306 | **A.8.5** | Autenticación segura |
| Autorización / IDOR | CWE-639, CWE-862, CWE-863 | **A.8.3** | Restricción de acceso a la información |
| Gestión de sesión | CWE-384, CWE-613 | **A.8.5** | Autenticación segura |
| Secretos / credenciales expuestas | CWE-798, CWE-312, CWE-522 | **A.8.24** | Uso de criptografía |
| Criptografía débil/obsoleta | CWE-327, CWE-326 | **A.8.24** | Uso de criptografía |
| Dependencias con CVE (SCA) | CWE-1104, CWE-937 | **A.8.8** | Gestión de vulnerabilidades técnicas |
| Misconfiguración (headers, CORS, permisos) | CWE-16, CWE-732, CWE-284 | **A.8.9** | Gestión de la configuración |
| Exposición de datos sensibles / PII | CWE-200, CWE-359 | **A.8.12** | Prevención de fuga de datos |
| Logging/monitoreo insuficiente | CWE-778, CWE-223 | **A.8.15** | Registro (logging) |
| Superficie de red expuesta (puertos/servicios) | CWE-668, CWE-1021 | **A.8.20** | Seguridad de redes |
| IaC / cloud misconfig | CWE-1188 | **A.8.9** | Gestión de la configuración |
| Prompt injection / LLM (OWASP LLM Top 10) | — | **A.8.28** + **A.5.23** | Codificación segura + seguridad en servicios cloud/IA |
| Deserialización insegura | CWE-502 | **A.8.28** | Codificación segura |
| SSH/hardening de host | CWE-16, CWE-284 | **A.8.9** | Gestión de la configuración |

## Cómo se usa

1. **T1 (triage):** busca el CWE del hallazgo en la tabla → copia el control a `iso27001` en `vulnerabilities.json`. Si no matchea ningún CWE listado, usa la fila de categoría más cercana.
2. **T2 (verificación):** si el hallazgo es de negocio/lógica sin CWE claro, asigná el control manualmente razonando desde el Annex A completo (`docs/normas/GATES.md` no aplica acá — ver ISO 27001:2022 texto completo si hace falta más precisión).
3. **Informe:** el control aparece en la línea `**Norma:**` de cada hallazgo junto a CWE/OWASP (ver `docs/estandares/informe-maestro.md`).

Fuente: ISO/IEC 27001:2022 Annex A — 4 temas (A.5 organizacionales, A.6 personas, A.7 físicos, A.8 tecnológicos). Detalle de implementación en ISO 27002.
