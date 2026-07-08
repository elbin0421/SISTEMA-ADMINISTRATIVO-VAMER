-- ============================================================
--  SOLDYMEG — Tabla catalogo_precios
-- ============================================================
CREATE TABLE IF NOT EXISTS `catalogo_precios` (
  `id_catalogo`    int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `codigo`         varchar(10)  NOT NULL,
  `descripcion`    varchar(255) NOT NULL,
  `tipo`           enum('material','mano_obra','otro') NOT NULL DEFAULT 'material',
  `categoria`      varchar(100) DEFAULT NULL,
  `precio`         decimal(12,2) NOT NULL DEFAULT 0.00,
  `estado`         enum('activo','inactivo') NOT NULL DEFAULT 'activo',
  `fecha_creacion` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_catalogo`),
  UNIQUE KEY `uk_codigo` (`codigo`),
  KEY `idx_estado` (`estado`),
  KEY `idx_categoria` (`categoria`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
