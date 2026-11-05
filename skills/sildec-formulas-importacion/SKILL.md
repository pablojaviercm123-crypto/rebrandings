---
name: sildec-formulas-importacion
description: Recetario de fórmulas Excel compatibles con el Excel de SILDEC (sin XLOOKUP, MAXIFS, FILTER ni LET) para importaciones - CIF, GA, IVA 14,94 %, prorrateo por peso/volumen/valor, TC BCB por fecha, pagos 30/70, etapas, alertas, caja semanal y precios A/B/C.
---

# Fórmulas de importación · SILDEC

Fórmulas listas para copiar en los Excel de importaciones. Formato y colores: **sildec-formato-excel**. Lógica del cálculo: **sildec-costeo-importacion** y **sildec-seguimiento-importaciones**.

## Reglas
- Agregar **solo las columnas y métricas que se piden**; las ideas extra se sugieren aparte. Nunca cambiar el formato de las plantillas de SILDEC (plancha de pedido, rotaciones).
- `TC` = TC oficial BCB del día (~11,68 en oct 2026). Nunca 6,96 ni el paralelo, tampoco en costos y márgenes.
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

## Datos de DeltaWin (limpiar antes de cruzar)
- Código sin espacios al final: `=ESPACIOS(A2)` (también quita dobles espacios; si el código se lee como número, `=ESPACIOS(TEXTO(A2;"0"))`). Cruzar siempre con la columna limpia.
- Traer el Código Jadever desde el Código interno: `=SI.ERROR(INDICE(MAESTRO!$B$2:$B$3000;COINCIDIR(ESPACIOS(A2);MAESTRO!$A$2:$A$3000;0));"SIN CÓDIGO")`
- Saldo negativo: `=SI(SALDO2<0;"Dato a revisar";"")` (es una devolución).
- Ventas sin devoluciones (ventas negativas no cuentan): `=SUMAR.SI.CONJUNTO(VENTAS!$F$2:$F$9000;VENTAS!$A$2:$A$9000;A2;VENTAS!$F$2:$F$9000;">0")`
- Excluir material POP y repuestos (según la columna que los marque, p. ej. CLASE): agregar `;VENTAS!$D$2:$D$9000;"<>POP";VENTAS!$D$2:$D$9000;"<>REPUESTOS"` al SUMAR.SI.CONJUNTO.

## Capital de trabajo, días de inventario y plata parada
Cada término, en simple: **CT** = plata que hace falta tener metida en mercadería y cuentas por cobrar; **DIO** = cuántos días dura el stock al ritmo actual; **plata parada** = lo invertido en productos que no se venden.
- CT (año): `=COSTO_ANUAL*(DIAS_IMPORT+DIAS_ROTACION)/365+VENTAS_ANUALES*DIAS_COBRO/365`
- CT (análisis de 4 meses): mismo cálculo con `120` en vez de `365` y costo/ventas del período.
- DIO: `=SI.ERROR(STOCK_AL_COSTO/COSTO_VENTAS_PERIODO*DIAS_PERIODO;"N/A")` (Jadever ronda 168 días)
- Plata parada de un ITEM (no rota = sin ventas en el período, o el criterio que se pida): `=SI(VENTAS_PERIODO2=0;SALDO2*COSTO2;0)`; total por marca con SUMAR.SI.CONJUNTO. Ordenar de mayor a menor para priorizar promociones.

## Precios y margen
Costos y márgenes solo en archivos del admin; en los de vendedores, solo precio de venta.
- Margen bruto: `=SI.ERROR((PRECIO-COSTO)/PRECIO;"N/A")` con COSTO en Bs al TC oficial.
- Precio para margen: `=REDONDEAR(COSTO/(1-MARGEN);2)`
- Jadever C Regular: `=REDONDEAR(LISTA*(1-35%);2)`
- Jadever B Preferente: `=REDONDEAR(LISTA*(1-35%)*(1-35%);2)`
- Jadever A VIP: `=REDONDEAR(LISTA*(1-35%)*(1-40%);2)` (descuentos sucesivos: se multiplican, nunca se suman)
- Promo del mes: precio fijo en su celda, sin aplicarle los descuentos A/B/C.
- Piso de precio: `=SI(PRECIO_PROMO<COSTO_BS;"BAJO COSTO";SI((PRECIO_PROMO-COSTO_BS)/PRECIO_PROMO<MARGEN_MIN;"BAJO MARGEN";"OK"))`
- Margen efectivo de un 3x2: `=SI.ERROR((2*PRECIO-3*COSTO)/(2*PRECIO);"N/A")`; de un 2x1: `=(PRECIO-2*COSTO)/PRECIO` (con 28–32 % sale negativo, por eso casi nunca conviene). Ojo: un 3x2 solo deja ganancia si el margen normal del ítem supera 33,3 %, y un 2x1 si supera 50 %; calcularlo siempre por ítem antes de proponerlo.
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
