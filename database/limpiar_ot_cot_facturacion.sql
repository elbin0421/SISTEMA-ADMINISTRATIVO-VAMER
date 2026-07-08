-- ============================================================
--  SOLDYMEG — Limpieza completa: OT + Cotizaciones +
--             Facturación + Compras + Materiales
--  Usa DELETE (no TRUNCATE) para respetar FK en phpMyAdmin
-- ============================================================

SET FOREIGN_KEY_CHECKS = 0;

-- ══════════════════════════════════════════════════════════════
--  BLOQUE 1: FACTURACIÓN
-- ══════════════════════════════════════════════════════════════

DELETE FROM `pagos_clientes`;
ALTER TABLE `pagos_clientes` AUTO_INCREMENT = 1;

DELETE FROM `detalle_factura`;
ALTER TABLE `detalle_factura` AUTO_INCREMENT = 1;

DELETE FROM `facturas`;
ALTER TABLE `facturas` AUTO_INCREMENT = 1;

-- ══════════════════════════════════════════════════════════════
--  BLOQUE 2: COTIZACIONES
-- ══════════════════════════════════════════════════════════════

DELETE FROM `detalle_cotizacion`;
ALTER TABLE `detalle_cotizacion` AUTO_INCREMENT = 1;

DELETE FROM `cotizaciones`;
ALTER TABLE `cotizaciones` AUTO_INCREMENT = 1;

-- ══════════════════════════════════════════════════════════════
--  BLOQUE 3: ÓRDENES DE TRABAJO
-- ══════════════════════════════════════════════════════════════

DELETE FROM `detalle_orden_materiales`;
ALTER TABLE `detalle_orden_materiales` AUTO_INCREMENT = 1;

DELETE FROM `detalle_orden_mano_obra`;
ALTER TABLE `detalle_orden_mano_obra` AUTO_INCREMENT = 1;

DELETE FROM `orden_tecnicos`;
ALTER TABLE `orden_tecnicos` AUTO_INCREMENT = 1;

DELETE FROM `ordenes_trabajo`;
ALTER TABLE `ordenes_trabajo` AUTO_INCREMENT = 1;

-- ══════════════════════════════════════════════════════════════
--  BLOQUE 4: COMPRAS
-- ══════════════════════════════════════════════════════════════

DELETE FROM `detalle_compras`;
ALTER TABLE `detalle_compras` AUTO_INCREMENT = 1;

DELETE FROM `compras`;
ALTER TABLE `compras` AUTO_INCREMENT = 1;

-- ══════════════════════════════════════════════════════════════
--  BLOQUE 5: INVENTARIO Y MATERIALES
-- ══════════════════════════════════════════════════════════════

DELETE FROM `movimientos_inventario`;
ALTER TABLE `movimientos_inventario` AUTO_INCREMENT = 1;

DELETE FROM `materiales`;
ALTER TABLE `materiales` AUTO_INCREMENT = 1;

-- ══════════════════════════════════════════════════════════════
--  BLOQUE 6: REINICIAR CORRELATIVO CAI
-- ══════════════════════════════════════════════════════════════

UPDATE `cai_facturacion`
SET `correlativo_actual` = `rango_inicio`
WHERE `estado` = 'activo';

SET FOREIGN_KEY_CHECKS = 1;

-- ══════════════════════════════════════════════════════════════
--  VERIFICACIÓN FINAL
-- ══════════════════════════════════════════════════════════════
SELECT 'ordenes_trabajo'       AS tabla, COUNT(*) AS registros FROM ordenes_trabajo
UNION ALL
SELECT 'cotizaciones',                   COUNT(*)               FROM cotizaciones
UNION ALL
SELECT 'facturas',                       COUNT(*)               FROM facturas
UNION ALL
SELECT 'compras',                        COUNT(*)               FROM compras
UNION ALL
SELECT 'materiales',                     COUNT(*)               FROM materiales
UNION ALL
SELECT 'movimientos_inventario',         COUNT(*)               FROM movimientos_inventario;

SELECT 'CAI activo' AS info, cai, rango_inicio, correlativo_actual, fecha_limite_emision
FROM cai_facturacion WHERE estado = 'activo';
-- ============================================================
