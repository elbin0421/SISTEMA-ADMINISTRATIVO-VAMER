-- ============================================================
--  SOLDYMEG — Migración: Retenciones en pagos_clientes
--  Agrega campos de retención 1% (ISR) y 12.5% (ISV)
--  Seguro de ejecutar múltiples veces (IF NOT EXISTS)
-- ============================================================

-- Retención ISR 1% sobre subtotal (sin ISV)
ALTER TABLE `pagos_clientes`
  ADD COLUMN IF NOT EXISTS `retencion_isr`  DECIMAL(14,2) NOT NULL DEFAULT 0.00
    COMMENT 'Retención ISR 1% sobre subtotal (sin ISV)'
    AFTER `monto`;

-- Retención ISV 12.5% sobre subtotal (sin ISV)
ALTER TABLE `pagos_clientes`
  ADD COLUMN IF NOT EXISTS `retencion_isv`  DECIMAL(14,2) NOT NULL DEFAULT 0.00
    COMMENT 'Retención ISV 12.5% sobre subtotal (sin ISV)'
    AFTER `retencion_isr`;

-- Monto neto efectivamente recibido (monto - retencion_isr - retencion_isv)
ALTER TABLE `pagos_clientes`
  ADD COLUMN IF NOT EXISTS `monto_neto`     DECIMAL(14,2) NOT NULL DEFAULT 0.00
    COMMENT 'Monto neto recibido = monto - retenciones'
    AFTER `retencion_isv`;

-- Verificación
SELECT COLUMN_NAME, COLUMN_TYPE, COLUMN_DEFAULT, COLUMN_COMMENT
FROM   INFORMATION_SCHEMA.COLUMNS
WHERE  TABLE_NAME  = 'pagos_clientes'
  AND  COLUMN_NAME IN ('monto','retencion_isr','retencion_isv','monto_neto')
  AND  TABLE_SCHEMA = DATABASE()
ORDER  BY ORDINAL_POSITION;
-- ============================================================
