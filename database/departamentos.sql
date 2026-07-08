-- ============================================================
--  SOLDYMEG — Tabla departamentos + ALTER empleados
--  Ejecutar en BD de producción.
-- ============================================================
CREATE TABLE IF NOT EXISTS `departamentos` (
  `id_departamento` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `nombre`          varchar(100) NOT NULL,
  `descripcion`     varchar(255) DEFAULT NULL,
  `estado`          enum('activo','inactivo') NOT NULL DEFAULT 'activo',
  `fecha_creacion`  datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_departamento`),
  UNIQUE KEY `uk_nombre` (`nombre`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `departamentos` (`nombre`) VALUES
  ('Soldadura'),('Mecánica'),('Eléctrico'),('Pintura'),
  ('Almacén'),('Administración'),('Mantenimiento'),('Servicios Generales');

ALTER TABLE `empleados`
  ADD COLUMN IF NOT EXISTS `departamento_id` int(10) UNSIGNED DEFAULT NULL AFTER `ubicacion`;

-- Migración nombres/apellidos si no se ha ejecutado:
ALTER TABLE `empleados`
  ADD COLUMN IF NOT EXISTS `nombres`   VARCHAR(100) NOT NULL DEFAULT '' AFTER `id_empleado`,
  ADD COLUMN IF NOT EXISTS `apellidos` VARCHAR(100) NOT NULL DEFAULT '' AFTER `nombres`;

UPDATE `empleados` SET
  `nombres` = TRIM(CASE
    WHEN LENGTH(TRIM(`nombre`)) - LENGTH(REPLACE(TRIM(`nombre`),' ','')) >= 2
      THEN CONCAT(SUBSTRING_INDEX(TRIM(`nombre`),' ',1),' ',SUBSTRING_INDEX(SUBSTRING_INDEX(TRIM(`nombre`),' ',2),' ',-1))
    ELSE SUBSTRING_INDEX(TRIM(`nombre`),' ',1)
  END),
  `apellidos` = TRIM(CASE
    WHEN LENGTH(TRIM(`nombre`)) - LENGTH(REPLACE(TRIM(`nombre`),' ','')) >= 3
      THEN CONCAT(SUBSTRING_INDEX(SUBSTRING_INDEX(TRIM(`nombre`),' ',3),' ',-1),' ',SUBSTRING_INDEX(TRIM(`nombre`),' ',-1))
    WHEN LOCATE(' ',TRIM(`nombre`)) > 0 THEN SUBSTRING_INDEX(TRIM(`nombre`),' ',-1)
    ELSE TRIM(`nombre`)
  END)
WHERE (`nombres` = '' OR `apellidos` = '') AND `nombre` IS NOT NULL AND `nombre` != '';
