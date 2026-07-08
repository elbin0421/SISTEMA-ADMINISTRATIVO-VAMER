-- ============================================================
--  SOLDYMEG — Migración: días de crédito + multi-cotización
-- ============================================================

-- 1. Agregar días de crédito a clientes (si no existe)
ALTER TABLE `clientes`
  ADD COLUMN IF NOT EXISTS `dias_credito` SMALLINT(3) UNSIGNED NOT NULL DEFAULT 0
  AFTER `contacto`;

-- 2. Tabla para ligar múltiples cotizaciones a una factura
CREATE TABLE IF NOT EXISTS `factura_cotizaciones` (
  `id`          INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `factura_id`  INT(10) UNSIGNED NOT NULL,
  `cotizacion_id` INT(10) UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_fac_cot` (`factura_id`,`cotizacion_id`),
  CONSTRAINT `fk_faccot_factura` FOREIGN KEY (`factura_id`) REFERENCES `facturas`(`id_factura`) ON DELETE CASCADE,
  CONSTRAINT `fk_faccot_cot` FOREIGN KEY (`cotizacion_id`) REFERENCES `cotizaciones`(`id_cotizacion`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Verificación
SELECT COLUMN_NAME, COLUMN_TYPE FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME='clientes' AND COLUMN_NAME='dias_credito' AND TABLE_SCHEMA=DATABASE();
