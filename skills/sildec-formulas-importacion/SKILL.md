---
name: sildec-formulas-importacion
description: Recetario de fórmulas Excel compatibles con el Excel de SILDEC (sin XLOOKUP, MAXIFS, FILTER ni LET) para importaciones - CIF, GA, IVA 14,94 %, prorrateo por peso/volumen/valor, TC BCB por fecha, pagos 30/70, etapas, alertas, caja semanal y precios A/B/C.
---

# Fórmulas de importación · SILDEC

Fórmulas listas para copiar en los Excel de importaciones. Formato y colores: **sildec-formato-excel**. Lógica del cálculo: **sildec-costeo-importacion** y **sildec-seguimiento-importaciones**.

## Reglas
- El Excel de SILDEC **no tiene** XLOOKUP/BUSCARX, MAXIFS, MINIFS, FILTER, UNIQUE, LET ni matrices dinámicas. Usar SUMAR.SI.CONJUNTO, CONTAR.SI.CONJUNTO, SUMAPRODUCTO, INDICE/COINCIDIR, BUSCARV, SI.ERROR.
- Excel en español: separador **;**. Si se genera el archivo con Python (openpyxl), escribir la fórmula en inglés con **,** (SUMIFS, SUMPRODUCT, INDEX, MATCH, VLOOKUP, IFERROR, IF, AND, ROUND); Excel la muestra en español solo.
- Rangos acotados (`$A$2:$A$2000`), no columnas enteras, dentro de SUMAPRODUCTO.
- Parámetros con **nombre definido** en PARAMETROS (celdas amarillas): `TC` , `IVA_IMP` (=13/87), `ANTICIPO` (0,3), `CORTE` (fecha de corte), `DIAS_ALERTA`. Usar `CORTE` en vez de HOY() para que el reporte se pueda repetir.

## Costeo (hoja COSTEO, fila 2 = primer ITEM)
Columnas ejemplo: A ITEM · E CANTIDAD · G PRECIO U$ · H PESO KG · I VOLUMEN M3 · J % GA.
| Cálculo | Fórmula |
|---|---|
| FOB línea U$ | `=E2*G2` → K2 |
| Peso volumétrico (aéreo, si el transportista usa 6000) | `=largo_cm*ancho_cm*alto_cm/6000` |
| Flete prorrateado por peso | `=TOTAL_FLETE*H2/SUMA($H$2:$H$500)` |
| Almacenaje por volumen | `=TOTAL_ALMACENAJE*I2/SUMA($I$2:$I$500)` |
| Seguro por valor | `=TOTAL_SEGURO*K2/SUMA($K$2:$K$500)` |
| CIF línea | `=K2+L2+M2` (FOB + flete + seguro) → N2 |
| GA por línea (cada ITEM con su tasa) | `=N2*J2` → O2 |
| IVA importación (crédito fiscal, no costo) | `=(N2+O2+P2)*IVA_IMP` (P = otros cargos aduaneros de la DIM) |
| Costo puesto línea U$ | `=N2+O2+P2+Q2` (Q = despachante, transporte interno y otros prorrateados) → R2 |
| Costo unitario U$ | `=SI.ERROR(R2/CANT_RECIBIDA;"N/D")` |
| Costo unitario Bs | `=S2*TC` |
| Factor de importación | `=SUMA(R2:R500)/SUMA(K2:K500)` |
| Total de un gasto por tipo de reparto | `=SUMAR.SI.CONJUNTO(GASTOS!$C$2:$C$100;GASTOS!$E$2:$E$100;"PESO")` |
| Control de cuadre | `=SI(ABS(SUMA(L2:L500)-TOTAL_FLETE)<0,01;"OK";"REVISAR")` |

## Tipo de cambio BCB por fecha
Hoja TC: A FECHA (orden ascendente) · B TC oficial BCB.
- TC de una fecha (o el último publicado antes): `=BUSCARV(fecha;TC!$A$2:$B$2000;2;VERDADERO)`
- Bs de un pago: `=monto_U$*BUSCARV(fecha_pago;TC!$A$2:$B$2000;2;VERDADERO)`
- TC promedio ponderado de los pagos de una importación: `=SUMAPRODUCTO((PAGOS!$A$2:$A$500=A2)*PAGOS!$D$2:$D$500*PAGOS!$F$2:$F$500)/SUMAR.SI.CONJUNTO(PAGOS!$D$2:$D$500;PAGOS!$A$2:$A$500;A2)` (D monto U$, F TC)

## Pagos 30/70
- Anticipo: `=REDONDEAR(MONTO*ANTICIPO;2)`
- Saldo: `=MONTO-ANTICIPO_CELDA` (restar, no multiplicar por 0,7, para que sume exacto)
- Pendiente de pago: `=MONTO-SUMAR.SI.CONJUNTO(PAGOS!$D$2:$D$500;PAGOS!$A$2:$A$500;A2)`

## Seguimiento (hoja IMPORTACIONES)
- Etapa (fechas F:O llenadas en orden; lista de etapas en PARAMETROS!A10:A19): `=SI(CONTAR(F2:O2)=0;"SIN INICIAR";INDICE(PARAMETROS!$A$10:$A$19;CONTAR(F2:O2)))`
- Control de orden de fechas: `=SI(CONTAR(F2:O2)=CONTAR(F2:INDICE(F2:O2;CONTAR(F2:O2)));"OK";"REVISAR")`
- Atraso de llegada: `=SI(Y(ETA2<CORTE;LLEGADA2="");"ATRASADO "&CORTE-ETA2&" días";"OK")`
- Saldo 70 % por vencer: `=SI(Y(PAGO70_2="";EMBARQUE2-CORTE<=DIAS_ALERTA);"PAGAR SALDO";"OK")`
- Días en aduana: `=SI(FECHA_DESPACHO2="";CORTE-FECHA_PUERTO2;FECHA_DESPACHO2-FECHA_PUERTO2)`
- Lead time orden → almacén: `=SI(LLEGADA2="";"";LLEGADA2-ORDEN2)`
- Promedio por proveedor: `=SI.ERROR(SUMAR.SI.CONJUNTO($T$2:$T$300;$B$2:$B$300;X2)/CONTAR.SI.CONJUNTO($B$2:$B$300;X2;$T$2:$T$300;"<>");"N/A")`
- Última llegada de un ITEM (en vez de MAX.SI.CONJUNTO): `=SUMAPRODUCTO(MAX((ITEMS!$B$2:$B$5000=A2)*ITEMS!$C$2:$C$5000))`
- Diferencia recibido vs pedido: `=CANT_RECIBIDA-CANT_PEDIDA` con formato rojo si < 0.

## Caja semanal de importaciones
A2 = lunes de la semana. Estado en PAGOS!G (PAGADO / COMPROMETIDO / ESTIMADO).
`=SUMAR.SI.CONJUNTO(PAGOS!$D$2:$D$500;PAGOS!$B$2:$B$500;">="&A2;PAGOS!$B$2:$B$500;"<"&A2+7;PAGOS!$G$2:$G$500;"COMPROMETIDO")`
- Capital en tránsito: `=SUMAPRODUCTO((IMPORTACIONES!$Q$2:$Q$300="")*IMPORTACIONES!$Z$2:$Z$300)` (Q ingreso DeltaWin vacío, Z total pagado)

## Precios y margen
- Precio para margen: `=REDONDEAR(COSTO/(1-MARGEN);2)` (Jadever 30 % → `/0,7`)
- Margen resultante: `=SI.ERROR((PRECIO-COSTO)/PRECIO;"N/A")`
- Alerta Jadever: `=SI(MARGEN_CELDA<0,28;"BAJO 28%";"OK")`
- Costo anterior desde DeltaWin: `=SI.ERROR(INDICE(DELTAWIN!$D$2:$D$3000;COINCIDIR(A2;DELTAWIN!$A$2:$A$3000;0));"NUEVO")`
- Variación de costo: `=SI(ESNUMERO(ANT);NUEVO/ANT-1;"NUEVO")`
- Promedio ponderado con el stock (si DeltaWin valora así): `=(STOCK*COSTO_ANT+RECIBIDO*COSTO_NUEVO)/(STOCK+RECIBIDO)`

## Nivel moderno (pulir sin perder compatibilidad)
Estas mejoras funcionan en el Excel actual de SILDEC y hacen los archivos más rápidos de actualizar y más difíciles de romper:
- **Tablas de Excel (Ctrl+T)** en todas las hojas base, con nombre (`tblPROFORMA`, `tblPAGOS`, `tblTC`). Las fórmulas usan referencias estructuradas y crecen solas: `=SUMAR.SI.CONJUNTO(tblPAGOS[MONTO U$];tblPAGOS[N° IMPORTACIÓN];[@[N° IMPORTACIÓN]])`. Se acaban los rangos `$A$2:$A$500` que se quedan cortos.
- **Power Query** (Datos → Obtener datos) para importar los reportes de DeltaWin, la proforma del proveedor y la tabla de TC BCB: se limpia una vez (columnas, tipos, ITEM como texto) y luego solo se pulsa "Actualizar todo". Nada de copiar y pegar a mano.
- **Validación de datos** con listas desplegables para ETAPA, MARCA, INCOTERM, estado de pago y tipo de reparto: evita "Jadever" / "JADEVER" / "jadever".
- **Nombres definidos** para todos los parámetros (TC, IVA_IMP, ANTICIPO, CORTE): fórmulas que se leen como frases.
- **Formato condicional** para alertas (ATRASADO en rojo, PAGAR SALDO en ámbar) en vez de colorear a mano.
- **Controles de cuadre en una hoja CONTROLES** que resuma todos los OK / REVISAR del libro en una sola celda: `=SI(CONTAR.SI(rango_controles;"REVISAR")=0;"LIBRO OK";"REVISAR "&CONTAR.SI(rango_controles;"REVISAR"))`.
- **Puente a las herramientas digitales**: las hojas base con encabezados limpios (fila 1, sin celdas combinadas) son las mismas que se pueden subir a Supabase o leer con n8n para el gestor de importaciones y los tableros. Diseñar el Excel pensando en que algún día lo lea una app.
- **Claude como auditor**: pedir que revise el libro (errores, rangos cortos, controles en REVISAR, costos que subieron más de X %) antes de pasarlo a gerencia o Contabilidad.
- Si algún día SILDEC pasa a Microsoft 365, existen BUSCARX, MAX.SI.CONJUNTO, FILTRAR y LET; hasta entonces **no usarlas**, porque en los equipos actuales salen como #¿NOMBRE?.

## Antes de entregar
Recalcular, buscar #¿NOMBRE?, #DIV/0!, #N/A y #REF!, y comprobar que todos los controles digan OK.
