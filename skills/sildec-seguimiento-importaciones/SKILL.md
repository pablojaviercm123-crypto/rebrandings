---
name: sildec-seguimiento-importaciones
description: Controla las importaciones de SILDEC desde la orden al proveedor hasta el ingreso a DeltaWin - etapas, fechas, pagos 30/70, alertas de atraso, caja en USD y llegadas que alimentan la rotación. Usar para armar o actualizar el tablero de importaciones o el gestor de importaciones.
---

# Seguimiento de importaciones · SILDEC SRL

Objetivo: que en una sola vista se sepa **qué está en camino, cuánto falta pagar, cuándo llega y qué está atrasado**. Explicar en español simple.

## Contexto SILDEC (el usuario siempre prevalece)
- Pagos al proveedor: **30 % anticipo** al confirmar y **70 % antes de la llegada** (normalmente antes del embarque o de liberar documentos). Sin crédito.
- Conversión USD → Bs con **TC oficial BCB** del día, anotando fecha.
- Stock en **DeltaWin**; el saldo sale del almacén de Cochabamba. Llave = ITEM.
- Las llegadas CRONEX alimentan **cronex-rotacion-90d** (FECHA = llegada al almacén). Existe un gestor de importaciones propio (Supabase/n8n): si se trabaja en él, respetar su estructura.

## 1. Una fila por importación (hoja IMPORTACIONES)
Columnas: N° IMPORTACIÓN · PROVEEDOR · MARCA · INCOTERM · FECHA ORDEN · MONTO U$ · ANTICIPO 30 % (fecha, monto, TC) · SALDO 70 % (fecha prevista, fecha pagada, TC) · FECHA LISTA EN FÁBRICA · FECHA EMBARQUE (ETD) · FECHA LLEGADA PUERTO/FRONTERA (ETA) · N° DIM/DUI · FECHA DESPACHO · FECHA LLEGADA ALMACÉN · FECHA INGRESO DELTAWIN · ETAPA · RESPONSABLE · PRÓXIMA ACCIÓN · OBSERVACIONES.
Detalle por ITEM en otra hoja (IMPORTACION_ITEMS): N° IMPORTACIÓN · ITEM · MODELO · DESCRIPCIÓN · CLASE · CANT. PEDIDA · CANT. RECIBIDA · DIFERENCIA.

## 2. Etapas fijas
1 ORDEN → 2 ANTICIPO PAGADO → 3 EN PRODUCCIÓN → 4 SALDO PAGADO → 5 EMBARCADO → 6 EN PUERTO/FRONTERA → 7 EN ADUANA → 8 EN ALMACÉN → 9 INGRESADO A DELTAWIN → 10 COSTEADO.
La etapa se calcula con fórmula desde las fechas llenas (la última fecha registrada manda), no se escribe a mano.

## 3. Alertas (OK / REVISAR / ATRASADO)
- Saldo 70 % sin pagar a menos de N días del embarque (N en PARAMETROS).
- ETA pasada sin fecha de llegada al almacén.
- Más de N días en aduana o en almacén sin ingreso a DeltaWin.
- Cant. recibida ≠ pedida → reclamar al proveedor y costear con lo recibido.
- Importación llegada pero sin costeo cerrado (ver **sildec-costeo-importacion**).
Mostrar días de atraso, no solo el color.

## 4. Caja de importaciones
- Calendario semanal de pagos en U$ y en Bs (TC BCB de la fecha o TC de proyección marcado como supuesto): anticipos, saldos, flete, tributos, despachante.
- Separar **pagado / comprometido / estimado**. Total a pagar en las próximas 4 y 13 semanas.
- Capital inmovilizado en tránsito = Σ pagado de importaciones aún no ingresadas a DeltaWin.
- Días desde el anticipo hasta el ingreso a almacén (ciclo de importación) por proveedor: sirve para planificar la próxima orden. Para la caja general seguir **sildec-asesor-financiero**.

## 5. Indicadores
- Lead time promedio por proveedor y por etapa (orden → almacén).
- % de importaciones a tiempo (llegada ≤ ETA original).
- Diferencias de cantidad por proveedor.
- Monto en tránsito por marca (Jadever concentra la mayor parte del capital).

## 6. Actualización semanal
1. Llenar fechas nuevas y pagos realizados (con TC BCB).
2. Revisar alertas y escribir PRÓXIMA ACCIÓN con responsable.
3. Lo que llegó: pasar al costeo y, si es CRONEX, a IMPORTACIONES de la rotación 90D.
4. Confirmar con DeltaWin que lo ingresado cuadra con lo recibido.

## Entrega
Excel con **sildec-formato-excel** y fórmulas de **sildec-formulas-importacion**. Arriba, 3 frases: qué llega pronto, qué pago viene y qué está atrasado. No contactar proveedores ni hacer pagos: solo preparar borradores si se piden.
