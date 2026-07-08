-- ============================================================
--  SOLDYMEG — Tabla requisiciones_materiales
--  Ejecutar en BD de producción.
-- ============================================================
CREATE TABLE IF NOT EXISTS `requisiciones_materiales` (
  `id_requisicion`   int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `numero`           varchar(20)  NOT NULL COMMENT 'REQ-2026-001',
  `fecha_solicitud`  date         NOT NULL,
  `empleado_id`      int(10) UNSIGNED NOT NULL,
  `departamento`     varchar(100) NOT NULL,
  `numero_ot`        varchar(20)  DEFAULT NULL,
  `unidad`           varchar(50)  DEFAULT NULL COMMENT 'Placa / unidad',
  `estado`           enum('pendiente','aprobada','despachada','anulada') NOT NULL DEFAULT 'pendiente',
  `observaciones`    text         DEFAULT NULL,
  `usuario_id`       int(10) UNSIGNED NOT NULL,
  `fecha_creacion`   datetime     NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_requisicion`),
  UNIQUE KEY `uk_numero` (`numero`),
  KEY `fk_req_empleado` (`empleado_id`),
  KEY `fk_req_usuario`  (`usuario_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `requisicion_detalle` (
  `id_detalle`       int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `requisicion_id`   int(10) UNSIGNED NOT NULL,
  `material_id`      int(10) UNSIGNED DEFAULT NULL COMMENT 'NULL si no está en inventario',
  `descripcion`      varchar(255) NOT NULL,
  `unidad_medida`    varchar(30)  NOT NULL DEFAULT 'unidad',
  `cantidad`         decimal(10,2) NOT NULL,
  `observacion`      varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_detalle`),
  KEY `fk_det_req` (`requisicion_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Agregar 'requisicion' al enum tipo_referencia de movimientos_inventario
ALTER TABLE `movimientos_inventario`
  MODIFY COLUMN `tipo_referencia`
    enum('compra','orden_trabajo','cotizacion','ajuste_manual','requisicion')
    NOT NULL DEFAULT 'ajuste_manual';
