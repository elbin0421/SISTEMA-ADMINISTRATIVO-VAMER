-- ============================================================
--  SOLDYMEG — Migración Fase 5 — Correcciones
--  Agrega: ubicacion en empleados, quincena + extras en planilla
-- ============================================================

-- ── 1. Ubicación del empleado ─────────────────────────────────
ALTER TABLE `empleados`
  ADD COLUMN IF NOT EXISTS `ubicacion` ENUM('SOLDYMEG','VESTA') NOT NULL DEFAULT 'SOLDYMEG'
  AFTER `nombre`;

-- ── 2. Quincena en planillas ──────────────────────────────────
ALTER TABLE `planillas`
  ADD COLUMN IF NOT EXISTS `quincena` ENUM('1ra','2da') NOT NULL DEFAULT '1ra'
  AFTER `periodo_anio`;

-- ── 3. Campos extras en detalle_planilla ─────────────────────
ALTER TABLE `detalle_planilla` ADD COLUMN IF NOT EXISTS `horas_extra`          DECIMAL(6,2)  NOT NULL DEFAULT 0.00 AFTER `salario_base`;
ALTER TABLE `detalle_planilla` ADD COLUMN IF NOT EXISTS `monto_horas_extra`    DECIMAL(10,2) NOT NULL DEFAULT 0.00 AFTER `horas_extra`;
ALTER TABLE `detalle_planilla` ADD COLUMN IF NOT EXISTS `dias_faltados`        DECIMAL(5,2)  NOT NULL DEFAULT 0.00 AFTER `monto_horas_extra`;
ALTER TABLE `detalle_planilla` ADD COLUMN IF NOT EXISTS `monto_dias_faltados`  DECIMAL(10,2) NOT NULL DEFAULT 0.00 AFTER `dias_faltados`;
ALTER TABLE `detalle_planilla` ADD COLUMN IF NOT EXISTS `abono_prestamo`       DECIMAL(10,2) NOT NULL DEFAULT 0.00 AFTER `monto_dias_faltados`;
ALTER TABLE `detalle_planilla` ADD COLUMN IF NOT EXISTS `abono_vale`           DECIMAL(10,2) NOT NULL DEFAULT 0.00 AFTER `abono_prestamo`;

-- ── 4. Cambiar unique key planillas para incluir quincena ─────
ALTER TABLE `planillas` DROP INDEX IF EXISTS `uk_planilla_periodo`;
ALTER TABLE `planillas`
  ADD UNIQUE KEY IF NOT EXISTS `uk_planilla_periodo_quincena` (`periodo_mes`, `periodo_anio`, `quincena`);

-- ── VERIFICACIÓN ──────────────────────────────────────────────
SELECT COLUMN_NAME, COLUMN_TYPE FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'empleados' AND COLUMN_NAME = 'ubicacion' AND TABLE_SCHEMA = DATABASE();

SELECT COLUMN_NAME, COLUMN_TYPE FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'planillas' AND COLUMN_NAME = 'quincena' AND TABLE_SCHEMA = DATABASE();
-- ============================================================
