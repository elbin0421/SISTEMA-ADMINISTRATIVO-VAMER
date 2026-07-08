-- ============================================================
--  SOLDYMEG — Migración Fase 5: Planilla + Reportes
--  Ejecutar en orden. Seguro con IF NOT EXISTS.
-- ============================================================

-- ============================================================
--  SOLDYMEG — Migración Fase 5: Planilla + Reportes
--  Ejecutar en orden. Seguro con IF NOT EXISTS.
-- ============================================================

-- ── 1. Ampliar tabla empleados ────────────────────────────────
ALTER TABLE `empleados` ADD COLUMN IF NOT EXISTS `correo`        VARCHAR(100) DEFAULT NULL          AFTER `rap_numero`;
ALTER TABLE `empleados` ADD COLUMN IF NOT EXISTS `telefono`      VARCHAR(20)  DEFAULT NULL          AFTER `correo`;
ALTER TABLE `empleados` ADD COLUMN IF NOT EXISTS `direccion`     VARCHAR(255) DEFAULT NULL          AFTER `telefono`;
ALTER TABLE `empleados` ADD COLUMN IF NOT EXISTS `cuenta_banco`  VARCHAR(30)  DEFAULT NULL          AFTER `direccion`;
ALTER TABLE `empleados` ADD COLUMN IF NOT EXISTS `banco`         VARCHAR(60)  DEFAULT NULL          AFTER `cuenta_banco`;
ALTER TABLE `empleados` ADD COLUMN IF NOT EXISTS `aplica_ihss`   TINYINT(1)   NOT NULL DEFAULT 1    AFTER `banco`;
ALTER TABLE `empleados` ADD COLUMN IF NOT EXISTS `aplica_rap`    TINYINT(1)   NOT NULL DEFAULT 1    AFTER `aplica_ihss`;
ALTER TABLE `empleados` ADD COLUMN IF NOT EXISTS `aplica_isr`    TINYINT(1)   NOT NULL DEFAULT 0    AFTER `aplica_rap`;
ALTER TABLE `empleados` ADD COLUMN IF NOT EXISTS `seguro_privado` DECIMAL(10,2) NOT NULL DEFAULT 0.00 AFTER `aplica_isr`;

-- ── 2. Tabla planillas (cabecera mensual) ─────────────────────
CREATE TABLE IF NOT EXISTS `planillas` (
  `id_planilla`     INT(10) UNSIGNED  NOT NULL AUTO_INCREMENT,
  `periodo_mes`     TINYINT(2)        NOT NULL COMMENT '1-12',
  `periodo_anio`    YEAR(4)           NOT NULL,
  `fecha_pago`      DATE              NOT NULL,
  `total_salarios`  DECIMAL(14,2)     NOT NULL DEFAULT 0.00,
  `total_ihss_emp`  DECIMAL(14,2)     NOT NULL DEFAULT 0.00 COMMENT 'Deducción empleados',
  `total_ihss_pat`  DECIMAL(14,2)     NOT NULL DEFAULT 0.00 COMMENT 'Aporte patronal',
  `total_rap`       DECIMAL(14,2)     NOT NULL DEFAULT 0.00,
  `total_isr`       DECIMAL(14,2)     NOT NULL DEFAULT 0.00,
  `total_seguro`    DECIMAL(14,2)     NOT NULL DEFAULT 0.00,
  `total_deducciones` DECIMAL(14,2)   NOT NULL DEFAULT 0.00,
  `total_neto`      DECIMAL(14,2)     NOT NULL DEFAULT 0.00,
  `observaciones`   TEXT              DEFAULT NULL,
  `estado`          ENUM('borrador','cerrada') NOT NULL DEFAULT 'borrador',
  `usuario_id`      INT(10) UNSIGNED  NOT NULL,
  `fecha_creacion`  DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_planilla`),
  UNIQUE KEY `uk_planilla_periodo` (`periodo_mes`, `periodo_anio`),
  KEY `idx_planilla_estado` (`estado`),
  CONSTRAINT `fk_planilla_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id_usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── 3. Tabla detalle_planilla (una fila por empleado por mes) ─
CREATE TABLE IF NOT EXISTS `detalle_planilla` (
  `id_detalle`      INT(10) UNSIGNED  NOT NULL AUTO_INCREMENT,
  `planilla_id`     INT(10) UNSIGNED  NOT NULL,
  `empleado_id`     INT(10) UNSIGNED  NOT NULL,
  `salario_base`    DECIMAL(12,2)     NOT NULL DEFAULT 0.00,
  `ihss_empleado`   DECIMAL(10,2)     NOT NULL DEFAULT 0.00 COMMENT '2.5% salario',
  `ihss_patronal`   DECIMAL(10,2)     NOT NULL DEFAULT 0.00 COMMENT '5% salario',
  `rap_empleado`    DECIMAL(10,2)     NOT NULL DEFAULT 0.00 COMMENT '1.5% salario',
  `isr_mensual`     DECIMAL(10,2)     NOT NULL DEFAULT 0.00,
  `seguro_privado`  DECIMAL(10,2)     NOT NULL DEFAULT 0.00,
  `otras_deducciones` DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
  `total_deducciones` DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
  `salario_neto`    DECIMAL(12,2)     NOT NULL DEFAULT 0.00,
  `vacaciones_acum` DECIMAL(10,2)     NOT NULL DEFAULT 0.00 COMMENT 'Vacaciones proporcionales mes',
  `decimo_acum`     DECIMAL(10,2)     NOT NULL DEFAULT 0.00 COMMENT 'Décimo tercer mes proporcional',
  `observaciones`   VARCHAR(255)      DEFAULT NULL,
  PRIMARY KEY (`id_detalle`),
  UNIQUE KEY `uk_detalle_planilla_emp` (`planilla_id`, `empleado_id`),
  KEY `idx_detalle_empleado` (`empleado_id`),
  CONSTRAINT `fk_detalle_planilla` FOREIGN KEY (`planilla_id`) REFERENCES `planillas` (`id_planilla`) ON DELETE CASCADE,
  CONSTRAINT `fk_detalle_empleado` FOREIGN KEY (`empleado_id`) REFERENCES `empleados` (`id_empleado`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── 4. Permisos Fase 5 ────────────────────────────────────────
INSERT IGNORE INTO `permisos` (rol_id, modulo, puede_ver, puede_crear, puede_editar, puede_eliminar) VALUES
-- Administrador
(1, 'planillas', 1, 1, 1, 1),
(1, 'reportes',  1, 1, 1, 1),
-- Contabilidad
(3, 'planillas', 1, 1, 1, 0),
(3, 'reportes',  1, 0, 0, 0),
-- Ventas
(2, 'reportes',  1, 0, 0, 0),
-- Técnico
(4, 'planillas', 0, 0, 0, 0),
(4, 'reportes',  0, 0, 0, 0);

-- ── VERIFICACIÓN ──────────────────────────────────────────────
SELECT 'planillas' AS tabla, COUNT(*) AS registros FROM planillas
UNION ALL
SELECT 'detalle_planilla', COUNT(*) FROM detalle_planilla;

SELECT COLUMN_NAME, COLUMN_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'empleados'
  AND COLUMN_NAME IN ('aplica_ihss','aplica_rap','aplica_isr','seguro_privado','correo','banco')
  AND TABLE_SCHEMA = DATABASE();
-- ============================================================
