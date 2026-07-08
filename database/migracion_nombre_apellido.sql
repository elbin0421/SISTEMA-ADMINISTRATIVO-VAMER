-- ============================================================
--  SOLDYMEG — Migración empleados: nombre → nombres + apellidos
--  EJECUTAR UNA SOLA VEZ en la BD de producción.
--  Es seguro correr varias veces (usa IF NOT EXISTS / IGNORE).
-- ============================================================

-- 1. Agregar columnas si no existen
ALTER TABLE `empleados`
  ADD COLUMN IF NOT EXISTS `nombres`   VARCHAR(100) NOT NULL DEFAULT '' AFTER `id_empleado`,
  ADD COLUMN IF NOT EXISTS `apellidos` VARCHAR(100) NOT NULL DEFAULT '' AFTER `nombres`;

-- 2. Poblar desde columna nombre existente (solo si están vacías)
--    Lógica hondureña:
--      4+ palabras: "Melvin Danilson Gomez Aguilar" → nombres="Melvin Danilson" | apellidos="Gomez Aguilar"
--      3 palabras:  "Elbin Mauricio Arita"          → nombres="Elbin Mauricio"  | apellidos="Arita"
--      2 palabras:  "Juan Perez"                    → nombres="Juan"            | apellidos="Perez"
--      1 palabra:   "Juan"                          → nombres="Juan"            | apellidos="Juan"

UPDATE `empleados`
SET
  `nombres` = TRIM(CASE
    WHEN LENGTH(TRIM(`nombre`)) - LENGTH(REPLACE(TRIM(`nombre`), ' ', '')) >= 3
      THEN CONCAT(SUBSTRING_INDEX(TRIM(`nombre`),' ',1),' ',SUBSTRING_INDEX(SUBSTRING_INDEX(TRIM(`nombre`),' ',2),' ',-1))
    WHEN LENGTH(TRIM(`nombre`)) - LENGTH(REPLACE(TRIM(`nombre`), ' ', '')) = 2
      THEN CONCAT(SUBSTRING_INDEX(TRIM(`nombre`),' ',1),' ',SUBSTRING_INDEX(SUBSTRING_INDEX(TRIM(`nombre`),' ',2),' ',-1))
    ELSE SUBSTRING_INDEX(TRIM(`nombre`),' ',1)
  END),
  `apellidos` = TRIM(CASE
    WHEN LENGTH(TRIM(`nombre`)) - LENGTH(REPLACE(TRIM(`nombre`), ' ', '')) >= 3
      THEN CONCAT(SUBSTRING_INDEX(SUBSTRING_INDEX(TRIM(`nombre`),' ',3),' ',-1),' ',SUBSTRING_INDEX(TRIM(`nombre`),' ',-1))
    WHEN LENGTH(TRIM(`nombre`)) - LENGTH(REPLACE(TRIM(`nombre`), ' ', '')) = 2
      THEN SUBSTRING_INDEX(TRIM(`nombre`),' ',-1)
    WHEN LOCATE(' ', TRIM(`nombre`)) > 0
      THEN SUBSTRING_INDEX(TRIM(`nombre`),' ',-1)
    ELSE TRIM(`nombre`)
  END)
WHERE `nombres` = '' OR `apellidos` = '';

-- 3. Verificar resultado:
-- SELECT id_empleado, nombre, nombres, apellidos FROM empleados;

-- 4. Corregir manualmente si algún registro no quedó bien:
-- UPDATE empleados SET nombres='Elbin Mauricio', apellidos='Arita Bueso' WHERE id_empleado=1;

-- 5. Eliminar columna antigua (SOLO después de verificar paso 3):
-- ALTER TABLE `empleados` DROP COLUMN `nombre`;

-- ============================================================
