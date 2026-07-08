-- ============================================================
--  SOLDYMEG — Migración: OT Cliente + Orden de Compra
--  Agrega los campos a la tabla cotizaciones
--  Seguro de ejecutar múltiples veces (IF NOT EXISTS)
-- ============================================================

ALTER TABLE `cotizaciones`
  ADD COLUMN IF NOT EXISTS `ot_cliente`   VARCHAR(50) DEFAULT NULL
    COMMENT 'Número de OT del cliente (ej: 4007731855)'
    AFTER `observaciones`;

ALTER TABLE `cotizaciones`
  ADD COLUMN IF NOT EXISTS `orden_compra` VARCHAR(50) DEFAULT NULL
    COMMENT 'Número de Orden de Compra del cliente (ej: 5503905114)'
    AFTER `ot_cliente`;

-- Verificación
SELECT COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_COMMENT
FROM   INFORMATION_SCHEMA.COLUMNS
WHERE  TABLE_NAME  = 'cotizaciones'
  AND  COLUMN_NAME IN ('ot_cliente', 'orden_compra')
  AND  TABLE_SCHEMA = DATABASE();
-- ============================================================
