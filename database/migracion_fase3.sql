-- ============================================================
--  SOLDYMEG — Migración Fase 3: Facturación + Libro de Ventas
--  Ejecutar DESPUÉS de migracion_pre_fase3.sql
--  Seguro con datos existentes (IF NOT EXISTS)
-- ============================================================

-- ── 0. Agregar estado 'facturada' al ENUM de cotizaciones ─────
--    (si ya ejecutaste migracion_pre_fase3.sql antes de este fix)
ALTER TABLE `cotizaciones`
  MODIFY `estado` ENUM('pendiente','enviada','aprobada','rechazada','facturada')
  NOT NULL DEFAULT 'pendiente';

-- ── 1. Tabla facturas ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS `facturas` (
  `id_factura`       INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `numero_factura`   VARCHAR(25)  NOT NULL COMMENT 'Ej: 001-001-01-00000001',
  `cai_id`           INT(10) UNSIGNED NOT NULL,
  `cliente_id`       INT(10) UNSIGNED NOT NULL,
  `cotizacion_id`    INT(10) UNSIGNED DEFAULT NULL,
  `orden_id`         INT(10) UNSIGNED DEFAULT NULL,
  `usuario_id`       INT(10) UNSIGNED NOT NULL,
  `fecha`            DATE         NOT NULL,
  -- Desglose financiero
  `subtotal`         DECIMAL(14,2) NOT NULL DEFAULT 0.00 COMMENT 'Sin ISV',
  `isv`              DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  `total`            DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  -- Pago
  `metodo_pago`      ENUM('efectivo','tarjeta','transferencia','credito') NOT NULL DEFAULT 'efectivo',
  `referencia_pago`  VARCHAR(100) DEFAULT NULL,
  `estado`           ENUM('emitida','pagada','pendiente','anulada') NOT NULL DEFAULT 'emitida',
  `observaciones`    TEXT DEFAULT NULL,
  `fecha_creacion`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_factura`),
  UNIQUE KEY `uk_factura_numero` (`numero_factura`),
  KEY `idx_fac_cliente`     (`cliente_id`),
  KEY `idx_fac_cotizacion`  (`cotizacion_id`),
  KEY `idx_fac_orden`       (`orden_id`),
  KEY `idx_fac_fecha`       (`fecha`),
  KEY `idx_fac_estado`      (`estado`),
  CONSTRAINT `fk_fac_cai`        FOREIGN KEY (`cai_id`)        REFERENCES `cai_facturacion` (`id_cai`),
  CONSTRAINT `fk_fac_cliente`    FOREIGN KEY (`cliente_id`)    REFERENCES `clientes` (`id_cliente`),
  CONSTRAINT `fk_fac_cotizacion` FOREIGN KEY (`cotizacion_id`) REFERENCES `cotizaciones` (`id_cotizacion`) ON DELETE SET NULL,
  CONSTRAINT `fk_fac_orden`      FOREIGN KEY (`orden_id`)      REFERENCES `ordenes_trabajo` (`id_orden`) ON DELETE SET NULL,
  CONSTRAINT `fk_fac_usuario`    FOREIGN KEY (`usuario_id`)    REFERENCES `usuarios` (`id_usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── 2. Tabla detalle_factura ──────────────────────────────────
CREATE TABLE IF NOT EXISTS `detalle_factura` (
  `id_detalle_fac`  INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `factura_id`      INT(10) UNSIGNED NOT NULL,
  `tipo`            ENUM('material','mano_obra','otro') NOT NULL DEFAULT 'material',
  `descripcion`     VARCHAR(255) NOT NULL,
  `cantidad`        DECIMAL(12,2) NOT NULL DEFAULT 1.00,
  `precio_unitario` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `subtotal_base`   DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `subtotal_final`  DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (`id_detalle_fac`),
  KEY `idx_dfac_factura` (`factura_id`),
  CONSTRAINT `fk_dfac_factura` FOREIGN KEY (`factura_id`)
    REFERENCES `facturas` (`id_factura`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── 3. Tabla pagos_clientes ───────────────────────────────────
CREATE TABLE IF NOT EXISTS `pagos_clientes` (
  `id_pago`        INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `factura_id`     INT(10) UNSIGNED NOT NULL,
  `cliente_id`     INT(10) UNSIGNED NOT NULL,
  `usuario_id`     INT(10) UNSIGNED NOT NULL,
  `fecha`          DATE         NOT NULL,
  `monto`          DECIMAL(14,2) NOT NULL,
  `metodo_pago`    ENUM('efectivo','tarjeta','transferencia','credito') NOT NULL DEFAULT 'efectivo',
  `referencia`     VARCHAR(100) DEFAULT NULL,
  `concepto`       VARCHAR(255) DEFAULT NULL,
  `estado`         ENUM('aplicado','anulado') NOT NULL DEFAULT 'aplicado',
  `fecha_creacion` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_pago`),
  KEY `idx_pago_factura` (`factura_id`),
  KEY `idx_pago_cliente` (`cliente_id`),
  KEY `idx_pago_fecha`   (`fecha`),
  CONSTRAINT `fk_pago_factura` FOREIGN KEY (`factura_id`) REFERENCES `facturas` (`id_factura`),
  CONSTRAINT `fk_pago_cliente` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id_cliente`),
  CONSTRAINT `fk_pago_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id_usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── 4. Permisos Fase 3 para todos los roles ───────────────────
INSERT IGNORE INTO `permisos` (rol_id, modulo, puede_ver, puede_crear, puede_editar, puede_eliminar) VALUES
-- Administrador
(1, 'facturacion', 1, 1, 1, 1),
(1, 'pagos',       1, 1, 1, 1),
-- Ventas
(2, 'facturacion', 1, 1, 1, 0),
(2, 'pagos',       1, 1, 0, 0),
-- Contabilidad
(3, 'facturacion', 1, 0, 0, 0),
(3, 'pagos',       1, 1, 0, 0);

-- Fin migración Fase 3
-- ============================================================
