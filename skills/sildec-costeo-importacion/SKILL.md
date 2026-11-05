---
name: sildec-costeo-importacion
description: Calcula el costo puesto en almacén (landed cost) por ITEM de cada importación de SILDEC (Jadever, CRONEX, ASUS, Delux) en Bolivia, con tributos aduaneros, prorrateo, tipo de cambio BCB y precios A/B/C. Usar al costear un embarque, una proforma o al fijar precios de una llegada.
---

# Costeo de importación · SILDEC SRL

Objetivo: saber **cuánto cuesta de verdad cada ITEM puesto en el almacén de Cochabamba**, y con eso fijar precios que respeten el margen. Explicar en español simple.

## Contexto SILDEC (el usuario siempre prevalece)
- Importadora boliviana (Cochabamba; sucursales Santa Cruz y La Paz). Jadever (herramientas, ~1.200 ítems, la mayor parte del capital), CRONEX (accesorios de computación), ASUS (preventa) y Delux.
- El proveedor **no da crédito**: 30% de anticipo y 70% antes de que llegue la mercadería.
- Toda conversión USD → Bs, incluidos costos y márgenes, usa el **TC oficial del BCB del día** (~11,68 en oct 2026), anotando la fecha. **Nunca 6,96 ni el paralelo.**
- Llave de producto = **ITEM** (un modelo tiene varios ítems por color). Stock y contabilidad en **DeltaWin**. Mostrar los dos códigos, **"Código interno"** (SILDEC/Delta) y **"Código Jadever"** (proveedor, ej. JDAC1314), y limpiar espacios al final para que crucen.
- Material POP y repuestos no se venden (van a servicio): se excluyen del costeo de venta y de precios.
- Jadever: margen bruto de 28 a 32 % al TC oficial, precios por tipo de cliente **A VIP, B Preferente, C Regular**.
- **Solo las columnas y métricas que se piden.** Las ideas extra se sugieren aparte. Nunca cambiar el formato de las plantillas de SILDEC.
- Explicar cada término financiero en palabras simples (ej. "landed cost = lo que de verdad nos cuesta el producto ya en nuestro almacén").

## 1. Datos de entrada (pedir solo lo que falte)
Por embarque: proforma/factura comercial (ITEM, cantidad, precio unitario USD), Incoterm, flete internacional, seguro, gastos de frontera y puerto (Arica/Iquique u otro), transporte interno, almacenaje, despachante, DIM/DUI cuando exista, peso y volumen por ITEM o por caja, fechas y TC de los pagos 30/70.
Si un gasto todavía no llegó, va como **estimado** (marcado) y se reemplaza por el real cuando llegue la factura. Faltante ≠ cero.

## 2. Incoterm: qué ya viene pagado
| Incoterm | Lo que SILDEC todavía paga |
|---|---|
| EXW | Carga en fábrica, trámites de exportación, flete, seguro, todo lo de destino |
| FCA / FOB | Flete principal, seguro y todo lo de destino |
| CFR | Seguro y destino (el flete ya está en el precio) |
| CIF / CIP | Solo destino (flete y seguro ya incluidos; revisar cobertura mínima) |
| DAP / DPU | Descarga (DAP), tributos y despacho en Bolivia |
| DDP | Casi nada: verificar que el proveedor de verdad pague tributos bolivianos |
Regla: **no duplicar** flete ni seguro que ya están dentro del precio del proveedor.

## 3. Cálculo (orden fijo)
1. **FOB** = Σ cantidad × precio unitario USD (ajustar al Incoterm).
2. **CIF frontera/aduana** = FOB + flete hasta frontera + seguro.
3. **GA** (gravamen arancelario) = CIF × tasa de la partida arancelaria del ITEM. Las tasas van de 0 a 35 % según partida: tomarlas de la DIM o del despachante, nunca suponer una tasa general.
4. **Otros cargos de despacho** que entran a la base del IVA (verificación, etc.) según la DIM.
5. **IVA importación** = (CIF + GA + otros cargos aduaneros) × 14,94 % (13 % nominal "por dentro" = 13/87). Si hay ICE, seguir la DIM.
6. **Costo puesto** = CIF + GA + cargos aduaneros no recuperables + despachante + almacenaje + transporte interno + otros gastos atribuibles.
   - **El IVA de importación NO es costo**: es crédito fiscal (va aparte). Mismo criterio para el IVA de facturas de despachante y transporte.
   - Diferencias de cambio entre pagos y registro: confirmar el criterio con Contabilidad (Lilian). En contabilidad suelen ir a resultados, no al inventario; en el análisis de gerencia se puede mostrar también el costo "de caja".
7. **Prorrateo a cada ITEM**: los gastos comunes se reparten con un factor causal y se declara cuál:
   - Flete y almacenaje → por peso o volumen (el mayor entre peso real y peso volumétrico si así cobra el transportista).
   - Seguro, GA (si es una misma tasa), despachante → por valor FOB.
   - Si hay tasas de GA distintas, calcular el GA por línea, no prorratearlo.
   - Control: la suma prorrateada **debe cuadrar** con el total del gasto (OK / REVISAR).
8. **Costo unitario** = costo puesto del ITEM / cantidad recibida (no la pedida, si hubo faltantes).

## 4. Precio y margen
- Margen % = (P − C) / P. Recargo % = (P − C) / C. **No confundirlos.**
- Precio para un margen m: **P = C / (1 − m)**. Ejemplo Jadever: margen 30 % → P = C / 0,70.
- **Precios Jadever por tipo de cliente** (descuentos sucesivos sobre el precio de lista; se multiplican, no se suman):
  - C Regular: 35 % → lista × 0,65
  - B Preferente: 35 % + 35 % → lista × 0,65 × 0,65
  - A VIP: 35 % + 40 % → lista × 0,65 × 0,60
  Calcular el margen de cada tipo contra el **costo al TC oficial** y avisar si alguno baja de 28 %. El descuento VIP solo lo ajusta el admin o Cobranzas.
- **Promo del mes**: precio fijo, sin sumar descuentos por tipo de cliente.
- **Piso de precio** = costo al TC oficial (o costo / (1 − margen mínimo) si se pide un margen mínimo). Ninguna promo por debajo sin decisión expresa. Con 28–32 % de margen el 2x1 casi nunca alcanza: preferir 3x2, yapa, precio por volumen o kits.
- CRONEX: precios por escalón de volumen con margen y ROI por escalón (ver **sildec-promo-mayorista**).
- Comparar con el costo anterior del mismo ITEM (DeltaWin): mostrar variación % y si hay que actualizar precios.
- **Quién ve qué**: costos y márgenes solo en archivos del admin. Los archivos de vendedores llevan **solo precios de venta**, sin costo ni margen.
- No cambiar precios: solo proponer. Precios, descuentos y plazos en la plancha los cambia solo Cobranzas (Leslie).

## 5. Excel
Seguir **sildec-formato-excel** (línea CRONEX o JADEVER según la marca). Si ya existe un archivo o plantilla, trabajar sobre él sin cambiar su formato ni agregar columnas no pedidas. Solo al armar un costeo desde cero, estructura sugerida (confirmar antes con JAVIER): PARAMETROS (TC BCB y fecha, tasas, método de prorrateo, celdas amarillas), PROFORMA (ITEM · MODELO · DESCRIPCIÓN · CLASE · CANTIDAD · FECHA · PRECIO U$ · PESO · VOLUMEN · PARTIDA · % GA), GASTOS (concepto, monto, moneda, real/estimado, factor de prorrateo), COSTEO (por ITEM con fórmulas), PRECIOS A/B/C y RESUMEN GERENCIAL. Fórmulas en **sildec-formulas-importacion**.

## 6. Entrega
1. Costo total del embarque en U$ y Bs, y cuánto subió sobre el FOB (factor de importación = costo puesto / FOB).
2. Tabla por ITEM: costo unitario, costo anterior, variación, precios A/B/C sugeridos y margen.
3. Gastos estimados aún pendientes y cómo podrían mover el costo.
4. Tasas e impuestos: indicar que se verifican con la DIM y el despachante; las normas cambian, citar fuente y fecha si se buscan.
