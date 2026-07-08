-- ============================================================
--  SOLDYMEG — Migración Pre-Fase 3
--  Ejecutar en phpMyAdmin o MySQL sobre la BD soldymeg_admin
--  Seguro para ejecutar con datos existentes (usa IF NOT EXISTS)
-- ============================================================

-- ── 1. Agregar estado 'cotizado' al ENUM de ordenes_trabajo ──
ALTER TABLE `ordenes_trabajo`
  MODIFY `estado` ENUM('borrador','en_proceso','finalizada','cotizado','facturada','anulada')
  NOT NULL DEFAULT 'borrador';

-- ── 2. Agregar 'cotizacion' al ENUM de movimientos_inventario ─
ALTER TABLE `movimientos_inventario`
  MODIFY `tipo_referencia`
  ENUM('compra','orden_trabajo','cotizacion','ajuste_manual')
  NOT NULL DEFAULT 'ajuste_manual';

-- ── 3. Tabla cotizaciones ─────────────────────────────────────
CREATE TABLE IF NOT EXISTS `cotizaciones` (
  `id_cotizacion`        INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `numero_cotizacion`    VARCHAR(20)  NOT NULL COMMENT 'Ej: COT-2026-001',
  `cliente_id`           INT(10) UNSIGNED NOT NULL,
  `orden_id`             INT(10) UNSIGNED DEFAULT NULL COMMENT 'NULL si es DIRECTA',
  `usuario_id`           INT(10) UNSIGNED NOT NULL,
  `fecha`                DATE         NOT NULL,
  `vigencia_dias`        TINYINT      NOT NULL DEFAULT 15,
  `modo`                 ENUM('POST_TRABAJO','DIRECTA') NOT NULL DEFAULT 'POST_TRABAJO',
  `estado`               ENUM('pendiente','enviada','aprobada','rechazada','facturada') NOT NULL DEFAULT 'pendiente',
  -- Desglose de cálculo (guardado para auditoría)
  `subtotal_materiales`  DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  `subtotal_mano_obra`   DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  `costo_base`           DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  `subtotal_con_soldymeg` DECIMAL(14,2) NOT NULL DEFAULT 0.00 COMMENT '+35% margen SOLDYMEG',
  `subtotal_comercial`   DECIMAL(14,2) NOT NULL DEFAULT 0.00 COMMENT '+15% margen comercial',
  `isv`                  DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  `total`                DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  `observaciones`        TEXT DEFAULT NULL,
  `fecha_creacion`       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_cotizacion`),
  UNIQUE KEY `uk_cotizacion_numero` (`numero_cotizacion`),
  KEY `idx_cot_cliente`  (`cliente_id`),
  KEY `idx_cot_orden`    (`orden_id`),
  KEY `idx_cot_estado`   (`estado`),
  KEY `idx_cot_fecha`    (`fecha`),
  CONSTRAINT `fk_cot_cliente`  FOREIGN KEY (`cliente_id`)  REFERENCES `clientes` (`id_cliente`),
  CONSTRAINT `fk_cot_orden`    FOREIGN KEY (`orden_id`)    REFERENCES `ordenes_trabajo` (`id_orden`) ON DELETE SET NULL,
  CONSTRAINT `fk_cot_usuario`  FOREIGN KEY (`usuario_id`)  REFERENCES `usuarios` (`id_usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── 4. Tabla detalle_cotizacion ───────────────────────────────
CREATE TABLE IF NOT EXISTS `detalle_cotizacion` (
  `id_detalle_cot`   INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `cotizacion_id`    INT(10) UNSIGNED NOT NULL,
  `tipo`             ENUM('material','mano_obra','otro') NOT NULL DEFAULT 'material',
  `descripcion`      VARCHAR(255) NOT NULL,
  `cantidad`         DECIMAL(12,2) NOT NULL DEFAULT 1.00,
  `precio_unitario`  DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `subtotal_base`    DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Sin márgenes',
  `subtotal_final`   DECIMAL(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Con márgenes + ISV',
  PRIMARY KEY (`id_detalle_cot`),
  KEY `idx_dcot_cotizacion` (`cotizacion_id`),
  CONSTRAINT `fk_dcot_cotizacion` FOREIGN KEY (`cotizacion_id`)
    REFERENCES `cotizaciones` (`id_cotizacion`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── 5. Tabla cai_facturacion ──────────────────────────────────
CREATE TABLE IF NOT EXISTS `cai_facturacion` (
  `id_cai`             INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `cai`                VARCHAR(50) NOT NULL COMMENT 'Código CAI emitido por SAR',
  `rango_inicio`       VARCHAR(20) NOT NULL COMMENT 'Ej: 001-001-01-00000001',
  `rango_fin`          VARCHAR(20) NOT NULL COMMENT 'Ej: 001-001-01-00099999',
  `correlativo_actual` VARCHAR(20) NOT NULL,
  `fecha_limite_emision` DATE NOT NULL,
  `establecimiento`    VARCHAR(10) NOT NULL DEFAULT '001',
  `punto_emision`      VARCHAR(10) NOT NULL DEFAULT '001',
  `tipo_documento`     VARCHAR(10) NOT NULL DEFAULT '01' COMMENT '01=Factura',
  `estado`             ENUM('activo','agotado','vencido') NOT NULL DEFAULT 'activo',
  `fecha_registro`     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `usuario_id`         INT(10) UNSIGNED NOT NULL,
  PRIMARY KEY (`id_cai`),
  UNIQUE KEY `uk_cai_codigo` (`cai`),
  KEY `fk_cai_usuario` (`usuario_id`),
  CONSTRAINT `fk_cai_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id_usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── 6. Agregar permisos para módulos nuevos (Fase 3) ─────────
-- Administrador (rol_id=1): acceso total a cotizaciones y facturación
INSERT IGNORE INTO `permisos` (rol_id, modulo, puede_ver, puede_crear, puede_editar, puede_eliminar) VALUES
(1, 'cotizaciones', 1, 1, 1, 1),
(1, 'facturacion',  1, 1, 1, 1);

-- Ventas (rol_id=2): puede ver y crear cotizaciones, no eliminar
INSERT IGNORE INTO `permisos` (rol_id, modulo, puede_ver, puede_crear, puede_editar, puede_eliminar) VALUES
(2, 'cotizaciones', 1, 1, 1, 0);

-- ── 7. Columna cotizacion_id en ordenes_trabajo (si no existe) ─
-- (La columna cotizacion_origen_id ya existe, agregamos la inversa)
ALTER TABLE `ordenes_trabajo`
  ADD COLUMN IF NOT EXISTS `cotizacion_id` INT(10) UNSIGNED DEFAULT NULL
  COMMENT 'Cotización generada desde esta OT',
  ADD KEY IF NOT EXISTS `idx_ot_cotizacion` (`cotizacion_id`);

-- Fin de migración pre-Fase 3
-- ============================================================
