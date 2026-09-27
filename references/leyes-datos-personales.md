# Loki — Mapeo de leyes de datos personales (referencia para informes)

> **Disclaimer:** referencia informativa para estructurar la sección de cumplimiento del informe
> (`docs/estandares/informe-maestro.md` §7). **No es asesoría legal** — ver `docs/normas/LEGALES.md`.
> Verificar vigencia, artículos y montos con asesor legal antes de citarlos en un informe formal.
> Revisión: 2026-09.

## Cuándo aplica un régimen

Un hallazgo toca protección de datos cuando expone, permite leer o altera **PII** (nombres, documentos,
emails, teléfonos, direcciones, IP+identidad, credenciales de personas, salud, biometría…). El régimen
aplica por la **jurisdicción de las personas afectadas**, no por donde esté la infraestructura
(extraterritorialidad: GDPR art. 3, LGPD art. 3 — oferta a residentes alcanza igual).

## Matriz principal (todo el mundo)

| Jurisdicción | Régimen | Alcance / disparador | Notificación de brecha | Sanciones (verificar vigencia) |
|---|---|---|---|---|
| **Uruguay** | **Ley 18.331** (2008) + decreto 003/2009 | Cualquier tratamiento de datos personales; registro de bases de datos ante la autoridad de control; derechos ARCO | Informar a la persona afectada; a la autoridad si el daño es significativo (verificar artículo/plazo) | Sanciones administrativas (art. 59 — verificar montos en UI vigentes) + acciones civiles |
| UE / EEEE | **GDPR** (Rgto UE 2016/679) | Oferta de bienes/servicios o monitoreo de residentes UE (art. 3) | **72 h** a la autoridad (art. 33); a las personas si riesgo alto (art. 34) | Hasta **20 M€ o 4%** de la facturación anual global |
| Brasil | **LGPD** (Ley 13.709/2018) | Tratamiento en Brasil o oferta a residentes (art. 3) | A la ANPD sin dilación indebida (art. 48) | Hasta 2% facturación BR, tope 50 M BRL por infracción (art. 52) |
| Argentina | Ley 25.326 + procedencia de la AAIP | Datos de personas en Argentina | Según gravedad (verificar) | Multas + acciones civiles |
| EE.UU. — California | **CCPA/CPRA** | Consumidores de California | Aviso bajo Civ. Code §1798.82 | Daños estatutarios $100–$750 por consumidor/incidente (§1798.150) |
| Canadá | **PIPEDA** | Actividades comerciales + PII de canadienses | A la OPC + afectados "tan pronto como sea posible" (art. 10.1) | Multas administrativas por incumplimiento |
| Japón | **APPI** | Cualquier PII de personas en Japón | A la PPC + individuos según riesgo | Multas + órdenes de cesación |
| Singapur | **PDPA 2012** | Datos personales en Singapur | A la PDPC sin dilación | Hasta 10% facturación anual SG o S$1M (verificar) |
| Sudáfrica | **POPIA** | PII de sujetos en Sudáfrica | Al Information Regulator + datos subject "tan pronto como sea razonable" | Multas + imprisonments civiles |
| México | **LGPDPPSO (2017)** | PII tratada en México | Al INAI y titulares (art. 20) | Multas hasta 32 M MXN (?) — verificar |
| Chile | Ley 19.628 → **Ley 21.719** (2025, verificar entrada en vigor) | Datos personales en Chile | A la autoridad (verificar plazo) | Multas (verificar) |
| Colombia | **Ley 1581 de 2012** + Decreto 1377 | PII de sujetos en Colombia | A la SIC | Multas hasta 200 SMMLV (verificar) |
| India | **DPDP Act 2023** (reglamentación en curso) | Datos de sujetos en India | Al Data Protection Board | Multas hasta ₹250 crore (verificar) |
| Perú | **Ley 29733** + reglamento | PII en Perú | A la Autoridad Nacional | Multas (verificar) |

Estándares sectoriales **no-legales** pero citables junto con ISO 27001: **ISO/IEC 27701** (privacidad),
**NIST Privacy Framework**, **PCI-DSS** si hay datos de tarjetas (ver `references/iso27001-mapping.md`
para el mapeo CWE→Annex A ya obligatorio por hallazgo).

## Cómo usarlo en el informe

1. ¿El hallazgo expone/altera PII? Si no → no citar leyes (solo ISO 27001/CWE/OWASP como siempre).
2. Si sí → ¿de qué jurisdicciones son las personas afectadas / dónde opera el target? Listar **solo esos** regímenes.
3. Por régimen citar: nombre + artículo de seguridad/notificación + plazo + remediación vinculada
   (p. ej. PII en logs → cifrado en reposo/tránsito + minimización + notificación si ya hubo brecha).
4. Declarar en el pie: "referencia normativa — no asesoría legal; verificar vigencia con asesor".

## Mapeo rápido por tipo de hallazgo

| Hallazgo | Régimen típico a citar |
|---|---|
| PII expuesta en logs/errores/respuestas | GDPR art. 32/33 (si UE) · Ley 18.331 (si Uruguay) · LGPD art. 46/48 (si BR) |
| Falta de cifrado de PII en reposo/tránsito | GDPR art. 32 · Ley 18.331 (medidas de seguridad) · PDPA/POPIA según jurisdicción |
| Acceso sin autorización a base con PII | Todos los anteriores + deber de notificación de brecha (plazos arriba) |
| PII en backups/snapshots sin control | Mismos regímenes — énfasis en minimización y retención |
| Credenciales de personas expuestas | Regímenes de datos personales + rotación obligatoria (EVIDENCIAS.md) |
