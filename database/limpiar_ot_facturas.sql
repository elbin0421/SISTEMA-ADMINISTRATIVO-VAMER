-- ============================================================
--  SOLDYMEG — Limpieza: OT → Cotizaciones → Facturación
--  Solo borra el flujo operativo para reiniciar pruebas.
--  NO toca: clientes, materiales, inventario, compras,
--            usuarios, roles, CAI (configuración).
--  Ejecutar en phpMyAdmin o cliente MySQL.
-- ============================================================

SET FOREIGN_KEY_CHECKS = 0;

-- ── 1. FACTURACIÓN ───────────────────────────────────────────
--  Orden: pagos → detalle → facturas

DELETE FROM `pagos_clientes`;
ALTER TABLE `pagos_clientes`  AUTO_INCREMENT = 1;

DELETE FROM `detalle_factura`;
ALTER TABLE `detalle_factura` AUTO_INCREMENT = 1;

DELETE FROM `facturas`;
ALTER TABLE `facturas`        AUTO_INCREMENT = 1;

-- ── 2. COTIZACIONES ──────────────────────────────────────────

DELETE FROM `detalle_cotizacion`;
ALTER TABLE `detalle_cotizacion` AUTO_INCREMENT = 1;

DELETE FROM `cotizaciones`;
ALTER TABLE `cotizaciones`       AUTO_INCREMENT = 1;

-- ── 3. ÓRDENES DE TRABAJO ────────────────────────────────────
--  Orden: detalle materiales, mano de obra, técnicos → OT

DELETE FROM `detalle_orden_materiales`;
ALTER TABLE `detalle_orden_materiales` AUTO_INCREMENT = 1;

DELETE FROM `detalle_orden_mano_obra`;
ALTER TABLE `detalle_orden_mano_obra`  AUTO_INCREMENT = 1;

DELETE FROM `orden_tecnicos`;
ALTER TABLE `orden_tecnicos`           AUTO_INCREMENT = 1;

DELETE FROM `ordenes_trabajo`;
ALTER TABLE `ordenes_trabajo`          AUTO_INCREMENT = 1;

DELETE FROM `detalle_compras`;
ALTER TABLE `detalle_compras`  AUTO_INCREMENT = 1;

DELETE FROM `compras`;
ALTER TABLE `compras`  AUTO_INCREMENT = 1;

DELETE FROM `movimientos_inventario`;
ALTER TABLE `movimientos_inventario`  AUTO_INCREMENT = 1;

DELETE FROM `materiales`;
ALTER TABLE `materiales`  AUTO_INCREMENT = 1;

-- ── 4. REINICIAR CORRELATIVO CAI ─────────────────────────────
--  Vuelve al primer número del rango configurado.

UPDATE `cai_facturacion`
SET    `correlativo_actual` = `rango_inicio`
WHERE  `estado` = 'activo';

SET FOREIGN_KEY_CHECKS = 1;

-- ── VERIFICACIÓN FINAL ───────────────────────────────────────
SELECT 'ordenes_trabajo'         AS tabla, COUNT(*) AS registros FROM ordenes_trabajo
UNION ALL
SELECT 'detalle_orden_materiales',          COUNT(*)              FROM detalle_orden_materiales
UNION ALL
SELECT 'detalle_orden_mano_obra',           COUNT(*)              FROM detalle_orden_mano_obra
UNION ALL
SELECT 'orden_tecnicos',                    COUNT(*)              FROM orden_tecnicos
UNION ALL
SELECT 'cotizaciones',                      COUNT(*)              FROM cotizaciones
UNION ALL
SELECT 'detalle_cotizacion',                COUNT(*)              FROM detalle_cotizacion
UNION ALL
SELECT 'facturas',                          COUNT(*)              FROM facturas
UNION ALL
SELECT 'detalle_factura',                   COUNT(*)              FROM detalle_factura
UNION ALL
SELECT 'pagos_clientes',                    COUNT(*)              FROM pagos_clientes;

-- Confirma correlativo CAI reiniciado
SELECT 'CAI' AS info,
       cai,
       rango_inicio,
       correlativo_actual AS correlativo_reiniciado,
       fecha_limite_emision
FROM   cai_facturacion
WHERE  estado = 'activo';

-- ============================================================
--  LO QUE NO SE TOCA:
--    ✔ clientes
--    ✔ materiales / categorias_material
--    ✔ movimientos_inventario
--    ✔ compras / detalle_compras
--    ✔ usuarios / roles / permisos
--    ✔ cai_facturacion (solo reinicia correlativo)
--    ✔ empleados / proveedores
-- ============================================================
