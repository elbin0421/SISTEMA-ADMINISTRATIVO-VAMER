-- ============================================================
--  SOLDYMEG — Migración: días de crédito por cliente
-- ============================================================
ALTER TABLE `clientes`
  ADD COLUMN IF NOT EXISTS `dias_credito` SMALLINT(5) UNSIGNED NOT NULL DEFAULT 0
  AFTER `contacto`
  COMMENT '0 = contado, N = días de crédito otorgados';

-- Verificación
SELECT COLUMN_NAME, COLUMN_TYPE, COLUMN_DEFAULT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'clientes'
  AND COLUMN_NAME = 'dias_credito'
  AND TABLE_SCHEMA = DATABASE();
