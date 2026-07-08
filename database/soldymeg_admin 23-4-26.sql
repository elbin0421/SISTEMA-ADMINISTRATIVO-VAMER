-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 23-04-2026 a las 22:54:28
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `soldymeg_admin`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cai_facturacion`
--

CREATE TABLE `cai_facturacion` (
  `id_cai` int(10) UNSIGNED NOT NULL,
  `cai` varchar(50) NOT NULL COMMENT 'Código CAI emitido por SAR',
  `rango_inicio` varchar(20) NOT NULL COMMENT 'Ej: 001-001-01-00000001',
  `rango_fin` varchar(20) NOT NULL COMMENT 'Ej: 001-001-01-00099999',
  `correlativo_actual` varchar(20) NOT NULL,
  `fecha_limite_emision` date NOT NULL,
  `establecimiento` varchar(10) NOT NULL DEFAULT '001',
  `punto_emision` varchar(10) NOT NULL DEFAULT '001',
  `tipo_documento` varchar(10) NOT NULL DEFAULT '01' COMMENT '01=Factura',
  `estado` enum('activo','agotado','vencido') NOT NULL DEFAULT 'activo',
  `fecha_registro` datetime NOT NULL DEFAULT current_timestamp(),
  `usuario_id` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `cai_facturacion`
--

INSERT INTO `cai_facturacion` (`id_cai`, `cai`, `rango_inicio`, `rango_fin`, `correlativo_actual`, `fecha_limite_emision`, `establecimiento`, `punto_emision`, `tipo_documento`, `estado`, `fecha_registro`, `usuario_id`) VALUES
(1, '4ED242-6E9F76-20DCE0-63BE03-09091A-59', '000-001-01-00000001', '000-001-01-00000050', '000-001-01-00000001', '2027-04-06', '001', '001', '01', 'activo', '2026-04-20 17:46:52', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categorias_material`
--

CREATE TABLE `categorias_material` (
  `id_categoria` int(10) UNSIGNED NOT NULL,
  `nombre` varchar(80) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `categorias_material`
--

INSERT INTO `categorias_material` (`id_categoria`, `nombre`) VALUES
(5, 'Eléctrico y Electrónico'),
(7, 'Filtros'),
(2, 'Grasas y lubricantes'),
(4, 'Herramientas y Consumibles'),
(3, 'Materiales de Soldadura'),
(6, 'Neumáticos y Suspensión'),
(8, 'Otros'),
(1, 'Repuestos');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clientes`
--

CREATE TABLE `clientes` (
  `id_cliente` int(10) UNSIGNED NOT NULL,
  `nombre` varchar(150) NOT NULL,
  `tipo_cliente` enum('natural','empresa') NOT NULL DEFAULT 'empresa',
  `rtn` varchar(20) DEFAULT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `telefono2` varchar(20) DEFAULT NULL,
  `direccion` varchar(255) DEFAULT NULL,
  `correo` varchar(100) DEFAULT NULL,
  `contacto` varchar(100) DEFAULT NULL COMMENT 'Nombre persona de contacto en empresa',
  `dias_credito` smallint(3) UNSIGNED NOT NULL DEFAULT 0,
  `estado` enum('activo','inactivo') NOT NULL DEFAULT 'activo',
  `fecha_creacion` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `clientes`
--

INSERT INTO `clientes` (`id_cliente`, `nombre`, `tipo_cliente`, `rtn`, `telefono`, `telefono2`, `direccion`, `correo`, `contacto`, `dias_credito`, `estado`, `fecha_creacion`) VALUES
(1, 'CARGILL DE HONDURAS S DE R.L', 'empresa', '05019001049230', '9496-0403', '', 'Bufalo, Villanueva, Cortes', 'Fredy_lopez@cargill.com', 'FREDY LOPEZ', 60, 'activo', '2026-04-01 12:15:59'),
(2, 'GRANEL S.A DE C.V', 'empresa', '05019002063180', '9290-0356', '', 'Sector Aldea Río Blanquito, Choloma, Cortés.', 'josue.alvarez@somoscmi.com', 'JOSUE ALVARES', 60, 'activo', '2026-04-01 12:17:38'),
(3, 'VESTA LOGISTIC SERVICE PROVIDER S.A DE C.V', 'empresa', '05019023478612', '3141-1835', '', '', '', 'FERNANDA GALLARDO', 30, 'activo', '2026-04-01 12:19:08'),
(4, 'CONSTRUCCIONES CERRATO Y ASOCIADOS SRL DE CV', 'empresa', '05019000045593', '', '', '', '', '', 15, 'activo', '2026-04-01 12:19:46'),
(5, 'RCJ LOGISTIC S.A DE C.V', 'empresa', '05029021315488', '', '', '', '', 'Luis López', 30, 'activo', '2026-04-01 12:20:29'),
(6, 'TRANICOP', 'empresa', '', '', '', '', '', '', 15, 'activo', '2026-04-01 12:21:31'),
(7, 'TRANSPORTES EMAGRO', 'empresa', '', '', '', '', '', '', 30, 'activo', '2026-04-14 16:30:32'),
(8, 'CEMCOL', 'empresa', '', '9949-7122', '', '', '', 'ORLIN VARDALES', 30, 'activo', '2026-04-18 11:49:12');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `compras`
--

CREATE TABLE `compras` (
  `id_compra` int(10) UNSIGNED NOT NULL,
  `numero_documento` varchar(50) DEFAULT NULL COMMENT 'Número de factura del proveedor',
  `proveedor_id` int(10) UNSIGNED NOT NULL,
  `fecha` date NOT NULL,
  `subtotal` decimal(12,2) NOT NULL DEFAULT 0.00,
  `impuesto` decimal(12,2) NOT NULL DEFAULT 0.00,
  `total` decimal(12,2) NOT NULL DEFAULT 0.00,
  `estado` enum('pendiente','pagada','anulada') NOT NULL DEFAULT 'pendiente',
  `metodo_pago` enum('efectivo','tarjeta','credito') DEFAULT NULL,
  `referencia_pago` varchar(100) DEFAULT NULL,
  `usuario_id` int(10) UNSIGNED NOT NULL,
  `observaciones` varchar(255) DEFAULT NULL,
  `fecha_creacion` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cotizaciones`
--

CREATE TABLE `cotizaciones` (
  `id_cotizacion` int(10) UNSIGNED NOT NULL,
  `numero_cotizacion` varchar(20) NOT NULL COMMENT 'Ej: COT-2026-001',
  `cliente_id` int(10) UNSIGNED NOT NULL,
  `orden_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'NULL si es DIRECTA',
  `usuario_id` int(10) UNSIGNED NOT NULL,
  `fecha` date NOT NULL,
  `vigencia_dias` tinyint(4) NOT NULL DEFAULT 15,
  `modo` enum('POST_TRABAJO','DIRECTA') NOT NULL DEFAULT 'POST_TRABAJO',
  `estado` enum('pendiente','enviada','aprobada','rechazada','facturada') DEFAULT NULL,
  `subtotal_materiales` decimal(14,2) NOT NULL DEFAULT 0.00,
  `subtotal_mano_obra` decimal(14,2) NOT NULL DEFAULT 0.00,
  `costo_base` decimal(14,2) NOT NULL DEFAULT 0.00,
  `subtotal_con_soldymeg` decimal(14,2) NOT NULL DEFAULT 0.00 COMMENT '+35% margen SOLDYMEG',
  `subtotal_comercial` decimal(14,2) NOT NULL DEFAULT 0.00 COMMENT '+15% margen comercial',
  `isv` decimal(14,2) NOT NULL DEFAULT 0.00,
  `total` decimal(14,2) NOT NULL DEFAULT 0.00,
  `observaciones` text DEFAULT NULL,
  `ot_cliente` varchar(50) DEFAULT NULL COMMENT 'Número de OT del cliente (ej: 4007731855)',
  `orden_compra` varchar(50) DEFAULT NULL COMMENT 'Número de Orden de Compra del cliente (ej: 5503905114)',
  `fecha_creacion` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `cotizaciones`
--

INSERT INTO `cotizaciones` (`id_cotizacion`, `numero_cotizacion`, `cliente_id`, `orden_id`, `usuario_id`, `fecha`, `vigencia_dias`, `modo`, `estado`, `subtotal_materiales`, `subtotal_mano_obra`, `costo_base`, `subtotal_con_soldymeg`, `subtotal_comercial`, `isv`, `total`, `observaciones`, `ot_cliente`, `orden_compra`, `fecha_creacion`) VALUES
(1, 'COT-2026-001', 8, NULL, 1, '2026-04-18', 15, 'DIRECTA', 'enviada', 0.00, 7500.00, 7500.00, 7500.00, 7500.00, 1125.00, 8625.00, 'INCLUYA MANO DE OBRA Y MATERIALES', NULL, NULL, '2026-04-18 11:51:16'),
(2, 'COT-2026-002', 8, NULL, 1, '2026-04-18', 15, 'DIRECTA', 'enviada', 0.00, 8181.95, 8181.95, 8181.95, 8181.95, 1227.29, 9409.24, '', NULL, NULL, '2026-04-18 11:53:24'),
(3, 'COT-2026-003', 8, NULL, 1, '2026-04-18', 15, 'DIRECTA', 'enviada', 0.00, 6000.00, 6000.00, 6000.00, 6000.00, 900.00, 6900.00, '', NULL, NULL, '2026-04-18 11:53:58'),
(4, 'COT-2026-004', 8, NULL, 1, '2026-04-18', 15, 'DIRECTA', 'enviada', 0.00, 141552.90, 141552.90, 141552.90, 141552.90, 21232.94, 162785.84, 'INCLUYA MANO DE OBRA Y MATERIALES', NULL, NULL, '2026-04-18 11:54:45');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_compras`
--

CREATE TABLE `detalle_compras` (
  `id_detalle_compra` int(10) UNSIGNED NOT NULL,
  `compra_id` int(10) UNSIGNED NOT NULL,
  `material_id` int(10) UNSIGNED NOT NULL,
  `cantidad` decimal(12,2) NOT NULL,
  `precio_unitario` decimal(12,2) NOT NULL,
  `subtotal` decimal(12,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Disparadores `detalle_compras`
--
DELIMITER $$
CREATE TRIGGER `trg_compra_entrada_inventario` AFTER INSERT ON `detalle_compras` FOR EACH ROW BEGIN
  -- Aumentar stock del material
  UPDATE materiales
     SET stock = stock + NEW.cantidad
   WHERE id_material = NEW.material_id;

  -- Registrar movimiento en kardex
  INSERT INTO movimientos_inventario
    (material_id, tipo, cantidad, costo_unitario, tipo_referencia, referencia_id, usuario_id, observaciones)
  SELECT
    NEW.material_id, 'entrada', NEW.cantidad, NEW.precio_unitario,
    'compra', NEW.compra_id, c.usuario_id, CONCAT('Compra #', NEW.compra_id)
  FROM compras c WHERE c.id_compra = NEW.compra_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_cotizacion`
--

CREATE TABLE `detalle_cotizacion` (
  `id_detalle_cot` int(10) UNSIGNED NOT NULL,
  `cotizacion_id` int(10) UNSIGNED NOT NULL,
  `tipo` enum('material','mano_obra','otro') NOT NULL DEFAULT 'material',
  `descripcion` varchar(255) NOT NULL,
  `cantidad` decimal(12,2) NOT NULL DEFAULT 1.00,
  `precio_unitario` decimal(12,2) NOT NULL DEFAULT 0.00,
  `subtotal_base` decimal(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Sin márgenes',
  `subtotal_final` decimal(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Con márgenes + ISV'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `detalle_cotizacion`
--

INSERT INTO `detalle_cotizacion` (`id_detalle_cot`, `cotizacion_id`, `tipo`, `descripcion`, `cantidad`, `precio_unitario`, `subtotal_base`, `subtotal_final`) VALUES
(1, 1, 'mano_obra', 'REPARACION DE PLATAFORMA ONBOY INCLUYE MANO DE OBRA Y MATERIALES', 1.00, 7500.00, 7500.00, 7500.00),
(2, 2, 'mano_obra', 'FABRIDADO E INSTALADO DE COMPUERTA DE PICKUP', 1.00, 8181.95, 8181.95, 8181.95),
(3, 3, 'mano_obra', 'DESMONTAJE DE CARROCERIA, MANTENIMIENTO E INSTALACION EN OTRO VEHICULO', 1.00, 6000.00, 6000.00, 6000.00),
(4, 4, 'mano_obra', 'REPARACION DE PLATAFORMA LONBOY INCLUYE MANO DE OBRA Y MATERIALES', 1.00, 141552.90, 141552.90, 141552.90);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_factura`
--

CREATE TABLE `detalle_factura` (
  `id_detalle_fac` int(10) UNSIGNED NOT NULL,
  `factura_id` int(10) UNSIGNED NOT NULL,
  `tipo` enum('material','mano_obra','otro') NOT NULL DEFAULT 'material',
  `descripcion` varchar(255) NOT NULL,
  `cantidad` decimal(12,2) NOT NULL DEFAULT 1.00,
  `precio_unitario` decimal(12,2) NOT NULL DEFAULT 0.00,
  `subtotal_base` decimal(12,2) NOT NULL DEFAULT 0.00,
  `subtotal_final` decimal(12,2) NOT NULL DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_orden_mano_obra`
--

CREATE TABLE `detalle_orden_mano_obra` (
  `id_mano_obra` int(10) UNSIGNED NOT NULL,
  `orden_id` int(10) UNSIGNED NOT NULL,
  `descripcion` varchar(255) NOT NULL,
  `dias` decimal(6,2) NOT NULL DEFAULT 1.00,
  `tarifa_dia` decimal(12,2) NOT NULL DEFAULT 0.00,
  `subtotal` decimal(12,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_orden_materiales`
--

CREATE TABLE `detalle_orden_materiales` (
  `id_detalle_om` int(10) UNSIGNED NOT NULL,
  `orden_id` int(10) UNSIGNED NOT NULL,
  `material_id` int(10) UNSIGNED NOT NULL,
  `cantidad` decimal(12,2) NOT NULL,
  `precio_unitario` decimal(12,2) NOT NULL COMMENT 'Precio al momento del uso',
  `subtotal` decimal(12,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Disparadores `detalle_orden_materiales`
--
DELIMITER $$
CREATE TRIGGER `trg_ot_revertir_inventario` AFTER DELETE ON `detalle_orden_materiales` FOR EACH ROW BEGIN
  UPDATE materiales
     SET stock = stock + OLD.cantidad
   WHERE id_material = OLD.material_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_ot_salida_inventario` AFTER INSERT ON `detalle_orden_materiales` FOR EACH ROW BEGIN
  -- Disminuir stock
  UPDATE materiales
     SET stock = stock - NEW.cantidad
   WHERE id_material = NEW.material_id;

  -- Registrar movimiento en kardex
  INSERT INTO movimientos_inventario
    (material_id, tipo, cantidad, costo_unitario, tipo_referencia, referencia_id, usuario_id, observaciones)
  SELECT
    NEW.material_id, 'salida', NEW.cantidad, NEW.precio_unitario,
    'orden_trabajo', NEW.orden_id, ot.usuario_id, CONCAT('OT ', ot.numero_orden)
  FROM ordenes_trabajo ot WHERE ot.id_orden = NEW.orden_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_planilla`
--

CREATE TABLE `detalle_planilla` (
  `id_detalle` int(10) UNSIGNED NOT NULL,
  `planilla_id` int(10) UNSIGNED NOT NULL,
  `empleado_id` int(10) UNSIGNED NOT NULL,
  `salario_base` decimal(12,2) NOT NULL DEFAULT 0.00,
  `horas_extra` decimal(6,2) NOT NULL DEFAULT 0.00,
  `monto_horas_extra` decimal(10,2) NOT NULL DEFAULT 0.00,
  `dias_faltados` decimal(5,2) NOT NULL DEFAULT 0.00,
  `monto_dias_faltados` decimal(10,2) NOT NULL DEFAULT 0.00,
  `abono_prestamo` decimal(10,2) NOT NULL DEFAULT 0.00,
  `abono_vale` decimal(10,2) NOT NULL DEFAULT 0.00,
  `ihss_empleado` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT '2.5% salario',
  `ihss_patronal` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT '5% salario',
  `rap_empleado` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT '1.5% salario',
  `isr_mensual` decimal(10,2) NOT NULL DEFAULT 0.00,
  `seguro_privado` decimal(10,2) NOT NULL DEFAULT 0.00,
  `otras_deducciones` decimal(10,2) NOT NULL DEFAULT 0.00,
  `total_deducciones` decimal(10,2) NOT NULL DEFAULT 0.00,
  `salario_neto` decimal(12,2) NOT NULL DEFAULT 0.00,
  `vacaciones_acum` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Vacaciones proporcionales mes',
  `decimo_acum` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Décimo tercer mes proporcional',
  `observaciones` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `detalle_planilla`
--

INSERT INTO `detalle_planilla` (`id_detalle`, `planilla_id`, `empleado_id`, `salario_base`, `horas_extra`, `monto_horas_extra`, `dias_faltados`, `monto_dias_faltados`, `abono_prestamo`, `abono_vale`, `ihss_empleado`, `ihss_patronal`, `rap_empleado`, `isr_mensual`, `seguro_privado`, `otras_deducciones`, `total_deducciones`, `salario_neto`, `vacaciones_acum`, `decimo_acum`, `observaciones`) VALUES
(173, 9, 1, 14000.00, 3.00, 210.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 14210.00, 0.00, 0.00, NULL),
(174, 9, 2, 11000.00, 3.00, 210.00, 1.00, 733.33, 2000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 2733.33, 8476.67, 0.00, 0.00, NULL),
(175, 9, 3, 9000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 9000.00, 0.00, 0.00, NULL),
(176, 9, 4, 7500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 7500.00, 0.00, 0.00, NULL),
(177, 9, 5, 6000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 6000.00, 0.00, 0.00, NULL),
(178, 9, 6, 11000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 11000.00, 0.00, 0.00, NULL),
(179, 9, 7, 7500.00, 3.00, 210.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 7710.00, 0.00, 0.00, NULL),
(180, 9, 8, 7500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 7500.00, 0.00, 0.00, NULL),
(181, 9, 9, 9000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 9000.00, 0.00, 0.00, NULL),
(182, 9, 10, 5000.00, 3.00, 210.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 5210.00, 0.00, 0.00, NULL),
(183, 9, 11, 9000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 9000.00, 0.00, 0.00, NULL),
(184, 9, 12, 9250.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 9250.00, 0.00, 0.00, NULL),
(185, 9, 13, 9000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 9000.00, 0.00, 0.00, NULL),
(186, 9, 14, 6000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 6000.00, 0.00, 0.00, NULL),
(187, 9, 15, 14000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 14000.00, 0.00, 0.00, NULL),
(188, 9, 16, 13000.00, 3.00, 210.00, 0.00, 0.00, 2000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 2000.00, 11210.00, 0.00, 0.00, NULL),
(189, 9, 17, 10000.00, 3.00, 210.00, 2.00, 1333.33, 1005.15, 1000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 3338.48, 6871.52, 0.00, 0.00, NULL),
(190, 9, 18, 8000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 8000.00, 0.00, 0.00, NULL),
(191, 9, 19, 10500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 10500.00, 0.00, 0.00, NULL),
(192, 9, 20, 5000.00, 3.00, 210.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 5210.00, 0.00, 0.00, NULL),
(193, 9, 21, 6250.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 6250.00, 0.00, 0.00, NULL),
(341, 17, 1, 14000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 2000.00, 0.00, 0.00, 0.00, 0.00, 352.25, 0.00, 2352.25, 11647.75, 0.00, 0.00, NULL),
(342, 17, 2, 11000.00, 0.00, 0.00, 1.00, 733.33, 2000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 352.25, 0.00, 3085.58, 7914.42, 0.00, 0.00, NULL),
(343, 17, 3, 9000.00, 9.00, 765.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 211.35, 0.00, 211.35, 9553.65, 0.00, 0.00, NULL),
(344, 17, 4, 7500.00, 7.00, 595.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 211.35, 0.00, 211.35, 7883.65, 0.00, 0.00, NULL),
(345, 17, 5, 6000.00, 6.00, 510.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 211.35, 0.00, 211.35, 6298.65, 0.00, 0.00, NULL),
(346, 17, 6, 11000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 352.25, 0.00, 352.25, 10647.75, 0.00, 0.00, NULL),
(347, 17, 7, 7500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 352.25, 0.00, 352.25, 7147.75, 0.00, 0.00, NULL),
(348, 17, 8, 7500.00, 9.00, 765.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 211.35, 0.00, 211.35, 8053.65, 0.00, 0.00, NULL),
(349, 17, 9, 9000.00, 6.00, 510.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 211.35, 0.00, 211.35, 9298.65, 0.00, 0.00, NULL),
(350, 17, 10, 5000.00, 0.00, 0.00, 2.00, 666.67, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 666.67, 4333.33, 0.00, 0.00, NULL),
(351, 17, 11, 9000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 211.35, 0.00, 211.35, 8788.65, 0.00, 0.00, NULL),
(352, 17, 12, 9250.00, 6.00, 510.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 9760.00, 0.00, 0.00, NULL),
(353, 17, 13, 9000.00, 6.00, 510.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 211.35, 0.00, 211.35, 9298.65, 0.00, 0.00, NULL),
(354, 17, 14, 6000.00, 6.00, 510.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 211.35, 0.00, 211.35, 6298.65, 0.00, 0.00, NULL),
(355, 17, 15, 14000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 352.25, 0.00, 352.25, 13647.75, 0.00, 0.00, NULL),
(356, 17, 16, 13000.00, 0.00, 0.00, 0.00, 0.00, 2000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 352.25, 0.00, 2352.25, 10647.75, 0.00, 0.00, NULL),
(357, 17, 17, 10000.00, 0.00, 0.00, 1.00, 666.67, 1005.15, 800.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 2471.82, 7528.18, 0.00, 0.00, NULL),
(358, 17, 18, 8000.00, 6.00, 510.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 211.35, 0.00, 211.35, 8298.65, 0.00, 0.00, NULL),
(359, 17, 19, 10500.00, 6.00, 510.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 211.35, 0.00, 211.35, 10798.65, 0.00, 0.00, NULL),
(360, 17, 20, 5000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 5000.00, 0.00, 0.00, NULL),
(361, 17, 21, 6250.00, 6.00, 510.00, 1.00, 416.67, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 211.35, 0.00, 628.02, 6131.98, 0.00, 0.00, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empleados`
--

CREATE TABLE `empleados` (
  `id_empleado` int(10) UNSIGNED NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `ubicacion` enum('SOLDYMEG','VESTA') NOT NULL DEFAULT 'SOLDYMEG',
  `identidad` varchar(20) DEFAULT NULL,
  `puesto` varchar(80) DEFAULT NULL,
  `tipo_contrato` enum('tiempo_completo','medio_tiempo','por_obra') NOT NULL DEFAULT 'tiempo_completo',
  `salario_mensual` decimal(12,2) NOT NULL DEFAULT 0.00,
  `fecha_ingreso` date DEFAULT NULL,
  `ihss_numero` varchar(20) DEFAULT NULL,
  `rap_numero` varchar(20) DEFAULT NULL,
  `correo` varchar(100) DEFAULT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `direccion` varchar(255) DEFAULT NULL,
  `cuenta_banco` varchar(30) DEFAULT NULL,
  `banco` varchar(60) DEFAULT NULL,
  `aplica_ihss` tinyint(1) NOT NULL DEFAULT 1,
  `aplica_rap` tinyint(1) NOT NULL DEFAULT 1,
  `aplica_isr` tinyint(1) NOT NULL DEFAULT 0,
  `seguro_privado` decimal(10,2) NOT NULL DEFAULT 0.00,
  `estado` enum('activo','inactivo') NOT NULL DEFAULT 'activo',
  `fecha_creacion` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `empleados`
--

INSERT INTO `empleados` (`id_empleado`, `nombre`, `ubicacion`, `identidad`, `puesto`, `tipo_contrato`, `salario_mensual`, `fecha_ingreso`, `ihss_numero`, `rap_numero`, `correo`, `telefono`, `direccion`, `cuenta_banco`, `banco`, `aplica_ihss`, `aplica_rap`, `aplica_isr`, `seguro_privado`, `estado`, `fecha_creacion`) VALUES
(1, 'ANGEL DANIEL GUDIEL DIAZ', 'SOLDYMEG', '', 'SOLDADOR', 'tiempo_completo', 28000.00, '2026-12-02', '', '', '', '', '', '', '', 0, 0, 0, 352.25, 'activo', '2026-04-01 12:35:23'),
(2, 'ANGEL DAVID GEORGE ORELLANA', 'SOLDYMEG', '', 'SOLDADOR', 'tiempo_completo', 22000.00, '2026-04-01', '', '', '', '', '', '', 'BAC', 0, 0, 0, 352.25, 'activo', '2026-04-01 12:36:25'),
(3, 'DANI DANIEL MARTINEZ MANZANAREZ', 'VESTA', '', 'SOLDADOR', 'tiempo_completo', 18000.00, '2026-04-01', '', '', '', '', '', '', 'BAC', 0, 0, 0, 211.35, 'activo', '2026-04-01 12:37:10'),
(4, 'DANIEL EDGARDO MEJIA RODRIGUEZ', 'VESTA', '', 'AYUDANTE', 'tiempo_completo', 15000.00, '2026-04-01', '', '', '', '', '', '', 'BAC', 0, 0, 0, 211.35, 'activo', '2026-04-01 14:46:45'),
(5, 'DENIS JOEL LOPEZ MARADIAGA', 'VESTA', '', 'AYUDANTE', 'tiempo_completo', 12000.00, '2026-04-01', '', '', '', '', '', '', 'BAC', 0, 0, 0, 211.35, 'activo', '2026-04-01 14:47:15'),
(6, 'ELBIN MAURICIO ARITA ARITA', 'SOLDYMEG', '', 'ADMINISTRACION', 'tiempo_completo', 22000.00, '2026-04-01', '', '', '', '', '', '', 'BAC', 0, 0, 0, 352.25, 'activo', '2026-04-01 14:48:06'),
(7, 'ELTHON SAMUEL URBINA MELGAR', 'SOLDYMEG', '', 'SOLDADOR', 'tiempo_completo', 15000.00, '2026-04-01', '', '', '', '', '', '', 'BAC', 0, 0, 0, 352.25, 'activo', '2026-04-01 14:48:24'),
(8, 'ERICK ULLOA GUTIERREZ MIRANDA', 'VESTA', '', 'AYUDANTE', 'tiempo_completo', 15000.00, '2026-04-01', '', '', '', '', '', '', 'BAC', 0, 0, 0, 211.35, 'activo', '2026-04-01 14:48:53'),
(9, 'ESDRAS JOEL CALIX MOREIRA', 'VESTA', '', 'SOLDADOR', 'tiempo_completo', 18000.00, '2026-04-01', '', '', '', '', '', '', 'BAC', 0, 0, 0, 211.35, 'activo', '2026-04-01 14:49:47'),
(10, 'GERSON MANUEL LOPEZ URBINA', 'SOLDYMEG', '', 'SOLDADOR', 'tiempo_completo', 10000.00, '2026-04-01', '', '', '', '', '', '', 'BAC', 0, 0, 0, 352.25, 'activo', '2026-04-01 14:50:18'),
(11, 'JOEL ANDRES JIMEZ TORRES', 'VESTA', '', 'MECANICO', 'tiempo_completo', 18000.00, '2026-04-01', '', '', '', '', '', '', 'BAC', 0, 0, 0, 211.35, 'activo', '2026-04-01 14:50:50'),
(12, 'JUAN ANGEL ULLOA GUTIERREZ', 'VESTA', '', 'MECANICO', 'tiempo_completo', 18500.00, '2026-04-01', '', '', '', '', '', '', 'BAC', 0, 0, 0, 211.35, 'activo', '2026-04-01 14:52:22'),
(13, 'JUAN CARLOS ECHEVERRIA MARTINEZ', 'VESTA', '', 'MECANICO', 'tiempo_completo', 18000.00, '2026-04-01', '', '', '', '', '', '', 'BAC', 0, 0, 0, 211.35, 'activo', '2026-04-01 14:52:59'),
(14, 'LUANIS ISRAEL RIVERA', 'VESTA', '', 'AYUDANTE', 'tiempo_completo', 12000.00, '2026-04-01', '', '', '', '', '', '', 'BAC', 0, 0, 0, 211.35, 'activo', '2026-04-01 14:53:33'),
(15, 'MARLENI YOSIBEL CALIX MOREIRA', 'SOLDYMEG', '', 'ADMINISTRACION', 'tiempo_completo', 28000.00, '2026-04-01', '', '', '', '', '', '', 'BAC', 0, 0, 0, 352.25, 'activo', '2026-04-01 14:53:58'),
(16, 'MELVIN DANILSON GOMEZ', 'SOLDYMEG', '', 'SUPERVISOR', 'tiempo_completo', 26000.00, '2026-04-01', '', '', '', '', '', '', 'BAC', 0, 0, 0, 352.25, 'activo', '2026-04-01 14:54:26'),
(17, 'WALTER ISAIAS OVIEDO ESPINAL', 'SOLDYMEG', '', 'SOLDADOR', 'tiempo_completo', 20000.00, '2026-04-01', '', '', '', '', '', '', 'BAC', 0, 0, 0, 352.25, 'activo', '2026-04-01 14:54:49'),
(18, 'WILLIAN DANIEL BAUTISTA', 'VESTA', '', 'AYUDANTE', 'tiempo_completo', 16000.00, '2026-04-01', '', '', '', '', '', '', 'BAC', 0, 0, 0, 211.35, 'activo', '2026-04-01 14:55:11'),
(19, 'WILLIAN NORTIE ARDON', 'VESTA', '', 'MOTORISTA', 'tiempo_completo', 21000.00, '2026-04-01', '', '', '', '', '', '', 'BAC', 0, 0, 0, 211.35, 'activo', '2026-04-01 14:55:34'),
(20, 'WILSON JOSUE FUNEZ FIGUEROA', 'SOLDYMEG', '', 'ASEADOR', 'tiempo_completo', 10000.00, '2026-04-01', '', '', '', '', '', '', 'BAC', 0, 0, 0, 352.25, 'activo', '2026-04-01 14:56:00'),
(21, 'YEFRY YAFETH ESTRADA', 'VESTA', '', 'AYUDANTE', 'tiempo_completo', 12500.00, '2026-04-01', '', '', '', '', '', '', 'BAC', 0, 0, 0, 211.35, 'activo', '2026-04-01 14:56:28');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `facturas`
--

CREATE TABLE `facturas` (
  `id_factura` int(10) UNSIGNED NOT NULL,
  `numero_factura` varchar(25) NOT NULL COMMENT 'Ej: 001-001-01-00000001',
  `cai_id` int(10) UNSIGNED NOT NULL,
  `cliente_id` int(10) UNSIGNED NOT NULL,
  `cotizacion_id` int(10) UNSIGNED DEFAULT NULL,
  `orden_id` int(10) UNSIGNED DEFAULT NULL,
  `usuario_id` int(10) UNSIGNED NOT NULL,
  `fecha` date NOT NULL,
  `subtotal` decimal(14,2) NOT NULL DEFAULT 0.00 COMMENT 'Sin ISV',
  `isv` decimal(14,2) NOT NULL DEFAULT 0.00,
  `total` decimal(14,2) NOT NULL DEFAULT 0.00,
  `metodo_pago` enum('efectivo','tarjeta','transferencia','credito') NOT NULL DEFAULT 'efectivo',
  `referencia_pago` varchar(100) DEFAULT NULL,
  `estado` enum('emitida','pagada','pendiente','anulada') NOT NULL DEFAULT 'emitida',
  `observaciones` text DEFAULT NULL,
  `fecha_creacion` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `factura_cotizaciones`
--

CREATE TABLE `factura_cotizaciones` (
  `id` int(10) UNSIGNED NOT NULL,
  `factura_id` int(10) UNSIGNED NOT NULL,
  `cotizacion_id` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `materiales`
--

CREATE TABLE `materiales` (
  `id_material` int(10) UNSIGNED NOT NULL,
  `codigo` varchar(50) DEFAULT NULL,
  `nombre` varchar(150) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `categoria_id` int(10) UNSIGNED DEFAULT NULL,
  `unidad_medida` varchar(20) NOT NULL DEFAULT 'unidad',
  `precio_compra` decimal(12,2) NOT NULL DEFAULT 0.00,
  `precio_venta` decimal(12,2) NOT NULL DEFAULT 0.00,
  `stock` decimal(12,2) NOT NULL DEFAULT 0.00,
  `stock_minimo` decimal(12,2) NOT NULL DEFAULT 0.00,
  `estado` enum('activo','inactivo') NOT NULL DEFAULT 'activo',
  `fecha_creacion` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `movimientos_inventario`
--

CREATE TABLE `movimientos_inventario` (
  `id_movimiento` int(10) UNSIGNED NOT NULL,
  `material_id` int(10) UNSIGNED NOT NULL,
  `tipo` enum('entrada','salida','ajuste') NOT NULL,
  `cantidad` decimal(12,2) NOT NULL,
  `costo_unitario` decimal(12,2) NOT NULL DEFAULT 0.00,
  `fecha` datetime NOT NULL DEFAULT current_timestamp(),
  `tipo_referencia` enum('compra','orden_trabajo','cotizacion','ajuste_manual') NOT NULL DEFAULT 'ajuste_manual',
  `referencia_id` int(10) UNSIGNED DEFAULT NULL,
  `usuario_id` int(10) UNSIGNED NOT NULL,
  `observaciones` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ordenes_trabajo`
--

CREATE TABLE `ordenes_trabajo` (
  `id_orden` int(10) UNSIGNED NOT NULL,
  `numero_orden` varchar(20) NOT NULL COMMENT 'Ej: OT-2025-001',
  `fecha_apertura` date NOT NULL,
  `fecha_cierre` date DEFAULT NULL,
  `cliente_id` int(10) UNSIGNED NOT NULL,
  `usuario_id` int(10) UNSIGNED NOT NULL COMMENT 'Quien crea la OT',
  `placa` varchar(20) DEFAULT NULL,
  `marca` varchar(60) DEFAULT NULL,
  `modelo` varchar(60) DEFAULT NULL,
  `anio` year(4) DEFAULT NULL,
  `color` varchar(30) DEFAULT NULL,
  `kilometraje` int(10) UNSIGNED DEFAULT NULL,
  `numero_motor` varchar(50) DEFAULT NULL,
  `numero_chasis` varchar(50) DEFAULT NULL,
  `descripcion_trabajo` text NOT NULL,
  `estado` enum('borrador','en_proceso','finalizada','cotizado','facturada','anulada') NOT NULL DEFAULT 'borrador',
  `cotizacion_origen_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'Si vino de cotización directa',
  `observaciones` text DEFAULT NULL,
  `fecha_creacion` datetime NOT NULL DEFAULT current_timestamp(),
  `cotizacion_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'Cotización generada desde esta OT'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Disparadores `ordenes_trabajo`
--
DELIMITER $$
CREATE TRIGGER `trg_numero_orden` BEFORE INSERT ON `ordenes_trabajo` FOR EACH ROW BEGIN
  DECLARE v_year CHAR(4);
  DECLARE v_seq  INT;
  SET v_year = YEAR(CURDATE());
  SELECT COALESCE(MAX(CAST(SUBSTRING(numero_orden, 9) AS UNSIGNED)), 0) + 1
    INTO v_seq
    FROM ordenes_trabajo
   WHERE numero_orden LIKE CONCAT('OT-', v_year, '-%');
  SET NEW.numero_orden = CONCAT('OT-', v_year, '-', LPAD(v_seq, 3, '0'));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `orden_tecnicos`
--

CREATE TABLE `orden_tecnicos` (
  `id` int(10) UNSIGNED NOT NULL,
  `orden_id` int(10) UNSIGNED NOT NULL,
  `empleado_id` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pagos_clientes`
--

CREATE TABLE `pagos_clientes` (
  `id_pago` int(10) UNSIGNED NOT NULL,
  `factura_id` int(10) UNSIGNED NOT NULL,
  `cliente_id` int(10) UNSIGNED NOT NULL,
  `usuario_id` int(10) UNSIGNED NOT NULL,
  `fecha` date NOT NULL,
  `monto` decimal(14,2) NOT NULL,
  `retencion_isr` decimal(14,2) NOT NULL DEFAULT 0.00 COMMENT 'Retención ISR 1% sobre subtotal (sin ISV)',
  `retencion_isv` decimal(14,2) NOT NULL DEFAULT 0.00 COMMENT 'Retención ISV 12.5% sobre subtotal (sin ISV)',
  `monto_neto` decimal(14,2) NOT NULL DEFAULT 0.00 COMMENT 'Monto neto recibido = monto - retenciones',
  `metodo_pago` enum('efectivo','tarjeta','transferencia','credito') NOT NULL DEFAULT 'efectivo',
  `referencia` varchar(100) DEFAULT NULL,
  `concepto` varchar(255) DEFAULT NULL,
  `estado` enum('aplicado','anulado') NOT NULL DEFAULT 'aplicado',
  `fecha_creacion` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `permisos`
--

CREATE TABLE `permisos` (
  `id_permiso` int(10) UNSIGNED NOT NULL,
  `rol_id` int(10) UNSIGNED NOT NULL,
  `modulo` varchar(50) NOT NULL,
  `puede_ver` tinyint(1) NOT NULL DEFAULT 0,
  `puede_crear` tinyint(1) NOT NULL DEFAULT 0,
  `puede_editar` tinyint(1) NOT NULL DEFAULT 0,
  `puede_eliminar` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `permisos`
--

INSERT INTO `permisos` (`id_permiso`, `rol_id`, `modulo`, `puede_ver`, `puede_crear`, `puede_editar`, `puede_eliminar`) VALUES
(1, 1, 'usuarios', 1, 1, 1, 1),
(2, 1, 'roles', 1, 1, 1, 1),
(3, 1, 'clientes', 1, 1, 1, 1),
(4, 1, 'ordenes_trabajo', 1, 1, 1, 1),
(5, 1, 'cotizaciones', 1, 1, 1, 1),
(6, 1, 'facturacion', 1, 1, 1, 1),
(7, 1, 'inventario', 1, 1, 1, 1),
(8, 1, 'compras', 1, 1, 1, 1),
(9, 1, 'pagos', 1, 1, 1, 1),
(10, 1, 'planillas', 1, 1, 1, 1),
(11, 1, 'reportes', 1, 1, 1, 1),
(12, 2, 'clientes', 1, 1, 1, 1),
(13, 2, 'cotizaciones', 1, 1, 1, 0),
(14, 2, 'facturacion', 1, 1, 1, 1),
(15, 2, 'ordenes_trabajo', 1, 1, 1, 1),
(16, 2, 'reportes', 1, 0, 0, 0),
(17, 3, 'facturacion', 1, 1, 1, 0),
(18, 3, 'pagos', 1, 1, 1, 1),
(19, 3, 'planillas', 1, 1, 1, 1),
(20, 3, 'reportes', 1, 0, 0, 0),
(21, 3, 'clientes', 1, 0, 0, 0),
(22, 4, 'ordenes_trabajo', 1, 1, 1, 0),
(23, 4, 'inventario', 1, 0, 0, 0),
(24, 4, 'clientes', 1, 0, 0, 0),
(25, 2, 'usuarios', 0, 0, 0, 0),
(26, 2, 'roles', 0, 0, 0, 0),
(31, 2, 'inventario', 1, 1, 1, 1),
(32, 2, 'compras', 0, 0, 0, 0),
(33, 2, 'pagos', 0, 0, 0, 0),
(34, 2, 'planillas', 0, 0, 0, 0),
(146, 4, 'usuarios', 0, 0, 0, 0),
(147, 4, 'roles', 0, 0, 0, 0),
(150, 4, 'cotizaciones', 0, 0, 0, 0),
(151, 4, 'facturacion', 0, 0, 0, 0),
(153, 4, 'compras', 0, 0, 0, 0),
(154, 4, 'pagos', 0, 0, 0, 0),
(155, 4, 'planillas', 0, 0, 0, 0),
(156, 4, 'reportes', 0, 0, 0, 0),
(175, 3, 'usuarios', 0, 0, 0, 0),
(176, 3, 'roles', 0, 0, 0, 0),
(178, 3, 'ordenes_trabajo', 0, 0, 0, 0),
(179, 3, 'cotizaciones', 0, 0, 0, 0),
(181, 3, 'inventario', 0, 0, 0, 0),
(182, 3, 'compras', 1, 1, 1, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `planillas`
--

CREATE TABLE `planillas` (
  `id_planilla` int(10) UNSIGNED NOT NULL,
  `periodo_mes` tinyint(2) NOT NULL COMMENT '1-12',
  `periodo_anio` year(4) NOT NULL,
  `quincena` enum('1ra','2da') NOT NULL DEFAULT '1ra',
  `fecha_pago` date NOT NULL,
  `total_salarios` decimal(14,2) NOT NULL DEFAULT 0.00,
  `total_ihss_emp` decimal(14,2) NOT NULL DEFAULT 0.00 COMMENT 'Deducción empleados',
  `total_ihss_pat` decimal(14,2) NOT NULL DEFAULT 0.00 COMMENT 'Aporte patronal',
  `total_rap` decimal(14,2) NOT NULL DEFAULT 0.00,
  `total_isr` decimal(14,2) NOT NULL DEFAULT 0.00,
  `total_seguro` decimal(14,2) NOT NULL DEFAULT 0.00,
  `total_deducciones` decimal(14,2) NOT NULL DEFAULT 0.00,
  `total_neto` decimal(14,2) NOT NULL DEFAULT 0.00,
  `observaciones` text DEFAULT NULL,
  `estado` enum('borrador','cerrada') NOT NULL DEFAULT 'borrador',
  `usuario_id` int(10) UNSIGNED NOT NULL,
  `fecha_creacion` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `planillas`
--

INSERT INTO `planillas` (`id_planilla`, `periodo_mes`, `periodo_anio`, `quincena`, `fecha_pago`, `total_salarios`, `total_ihss_emp`, `total_ihss_pat`, `total_rap`, `total_isr`, `total_seguro`, `total_deducciones`, `total_neto`, `observaciones`, `estado`, `usuario_id`, `fecha_creacion`) VALUES
(9, 4, '2026', '1ra', '2026-04-15', 187500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 8071.81, 180898.19, '', 'cerrada', 1, '2026-04-16 08:00:26'),
(17, 4, '2026', '2da', '2026-04-30', 187500.00, 0.00, 0.00, 0.00, 0.00, 4438.35, 14726.84, 178978.16, '', 'borrador', 1, '2026-04-23 13:52:22');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `proveedores`
--

CREATE TABLE `proveedores` (
  `id_proveedor` int(10) UNSIGNED NOT NULL,
  `nombre` varchar(150) NOT NULL,
  `rtn` varchar(20) DEFAULT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `direccion` varchar(255) DEFAULT NULL,
  `correo` varchar(100) DEFAULT NULL,
  `contacto` varchar(100) DEFAULT NULL,
  `estado` enum('activo','inactivo') NOT NULL DEFAULT 'activo',
  `fecha_creacion` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `proveedores`
--

INSERT INTO `proveedores` (`id_proveedor`, `nombre`, `rtn`, `telefono`, `direccion`, `correo`, `contacto`, `estado`, `fecha_creacion`) VALUES
(1, 'LA MUNDIAL', '', '', '', '', '', 'activo', '2026-04-01 12:22:18'),
(2, 'ULTRA REPUESTOS', '', '', '', '', '', 'activo', '2026-04-01 12:22:28'),
(3, 'INFRA', '', '', '', '', '', 'activo', '2026-04-01 12:22:36'),
(4, 'ALUCENTER', '', '', '', '', '', 'activo', '2026-04-01 12:22:50'),
(5, 'FERRETERIA ZUMAR', '', '', '', '', '', 'activo', '2026-04-01 12:23:00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `roles`
--

CREATE TABLE `roles` (
  `id_rol` int(10) UNSIGNED NOT NULL,
  `nombre` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `roles`
--

INSERT INTO `roles` (`id_rol`, `nombre`) VALUES
(1, 'Administrador'),
(3, 'Contabilidad'),
(4, 'Operador'),
(2, 'Ventas');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sesiones_admin`
--

CREATE TABLE `sesiones_admin` (
  `id_sesion` int(10) UNSIGNED NOT NULL,
  `usuario_id` int(10) UNSIGNED NOT NULL,
  `token` varchar(64) NOT NULL,
  `ip_address` varchar(45) NOT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `fecha_creacion` datetime NOT NULL DEFAULT current_timestamp(),
  `fecha_ultimo_acceso` datetime NOT NULL DEFAULT current_timestamp(),
  `fecha_expiracion` datetime NOT NULL,
  `estado` enum('activa','expirada','cerrada') NOT NULL DEFAULT 'activa'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `sesiones_admin`
--

INSERT INTO `sesiones_admin` (`id_sesion`, `usuario_id`, `token`, `ip_address`, `user_agent`, `fecha_creacion`, `fecha_ultimo_acceso`, `fecha_expiracion`, `estado`) VALUES
(1, 1, '202e0261f4be3d3cf86a5bc6b6618ef36066fe4e0bafe2151a6a7f00fa70ecd6', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-03-18 13:59:56', '2026-03-18 13:59:56', '2026-03-19 04:59:56', 'activa'),
(2, 1, '07ce45074cfb23681a76ec5f9b49321ed722558f688dab8bc37779fb34676c6e', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-03-18 14:01:04', '2026-03-18 14:01:04', '2026-03-19 05:01:04', 'activa'),
(3, 1, '6c362ff3c90b77f85b2dbf4278faf925abf0ce7f56d1af89f1efca25a80e385e', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-03-18 14:02:17', '2026-03-18 14:02:17', '2026-03-19 05:02:17', 'activa'),
(4, 1, '7421511043df82db29d211eb4080e280690b50411b38e371da594249c7b300b2', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-03-18 14:04:39', '2026-03-18 14:08:28', '2026-03-19 05:04:39', 'cerrada'),
(5, 1, 'b035b47773550cffb79a615e0ab07aa741836affe29a131eb395ed4bb011ff4c', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-03-18 14:08:55', '2026-03-18 14:09:03', '2026-03-19 05:08:55', 'cerrada'),
(6, 2, 'e4c06967872e42f4c9dd48cfb5d685b608dc1a4078431d98d3c8915f906b337f', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-03-18 14:09:13', '2026-03-18 14:09:58', '2026-03-19 05:09:13', 'cerrada'),
(7, 1, 'bd5d7f0d0252bd094428d37f3d9ba79f1adf30dcc383d32ad4c4b20746b34861', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-03-18 14:10:19', '2026-03-18 14:12:56', '2026-03-19 05:10:19', 'cerrada'),
(8, 1, '3d1984a64fe3e5d7c6a1aef2a82604907d6859b2af8af4f553230b974233c388', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-03-18 14:14:37', '2026-03-18 14:35:45', '2026-03-19 05:14:37', 'cerrada'),
(9, 1, 'e36fd7a393d54187c9f7812884b35a9e2761644f6b375d576a80848d626ab34b', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-03-18 14:36:19', '2026-03-18 14:41:27', '2026-03-19 05:36:19', 'cerrada'),
(10, 1, 'dc9c1c91394e2da86c54996852229575288258f4627890d23b070f4403d26fed', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-03-18 14:50:12', '2026-03-18 15:13:47', '2026-03-19 05:50:12', 'cerrada'),
(11, 1, '9ad2f985a914d46eef8547faaf8207df21425c9371db01384c9690e5e5b41224', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-03-18 15:13:56', '2026-03-18 16:39:13', '2026-03-19 06:13:56', 'cerrada'),
(12, 1, 'd2318bfb4e72815a72549aed6eec2d2d62f3834ef341cb82e1c4289496ecb597', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-03-18 16:39:26', '2026-03-18 17:21:12', '2026-03-19 07:39:26', 'activa'),
(13, 1, 'fd51499b2de871ba1aa5a7361055e710650b9df82bf6066d61f4666ac65d61b4', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-03-19 11:02:47', '2026-03-19 14:21:13', '2026-03-20 02:02:47', 'cerrada'),
(14, 1, '2528a9cd5e7baf6efcbbbf737d0447a7316ba608081d5fdd46d8a5cbaa9d6a25', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-03-19 14:21:26', '2026-03-19 14:27:55', '2026-03-20 05:21:26', 'activa'),
(15, 1, '8a03d735c11f4214e5aeef9bc3b95044335bdb87302cfeebc18ff9b4dd1b5ddb', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-03-19 14:50:13', '2026-03-19 17:27:13', '2026-03-20 05:50:13', 'activa'),
(16, 1, 'a6d11abce2a2cabdf49f03b301417dc14dab08265adc0fec86c02bc43911e8d1', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-03-20 10:12:23', '2026-03-20 17:26:36', '2026-03-21 01:12:23', 'activa'),
(17, 1, '0162b543c020ee783692adfba11b2c2d0630b47c4cfb85d80b06b97fc917a045', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-03-21 09:34:37', '2026-03-21 09:36:32', '2026-03-22 00:34:37', 'cerrada'),
(18, 1, '25fdc492e681c541b2bba6d05afefe7d5c617943170f85d115900a54a6b65abc', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-03-21 09:36:52', '2026-03-21 12:33:39', '2026-03-22 00:36:52', 'activa'),
(19, 1, 'ddec049a7586cacaede3c9e96b3c85beeeada111936b809410b6641fb1d5aa0a', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-03-23 08:11:45', '2026-03-23 13:11:53', '2026-03-23 23:11:45', 'activa'),
(20, 1, '918bb4c91fe658b02e0655c5f9cf0c10c58877146a62fa61f64866c3d8f45336', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-03-24 13:06:14', '2026-03-24 17:27:07', '2026-03-25 04:06:14', 'activa'),
(21, 1, '08f398298996ad57d0ec17a0e603643fda658806c1ff0e8b3ee717e8ae78a7c6', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-03-25 11:40:50', '2026-03-25 13:22:27', '2026-03-26 02:40:50', 'cerrada'),
(22, 1, '1682eb1b548e50c139466d908241b701e33e180194bd50b6d0d4178f04827fc3', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-03-25 13:22:41', '2026-03-25 17:13:21', '2026-03-26 04:22:41', 'activa'),
(23, 1, '5f34bb48f5d2e177e1e42c5350f952d1f8f4dc27529b1be45a24156be90a9717', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-03-26 12:58:38', '2026-03-26 16:59:24', '2026-03-27 03:58:38', 'activa'),
(24, 1, '21ded95f46cf501f5760354f32d6dcd5e3fe204764b6726adeb0b1b764b6983e', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-03-27 08:38:23', '2026-03-27 08:40:44', '2026-03-27 23:38:23', 'cerrada'),
(25, 3, '63d21217aa88d9a7b73c78365f573a303db795ec9e167fdc18f749db4c52b0b1', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-03-27 08:41:00', '2026-03-27 08:43:48', '2026-03-27 23:41:00', 'activa'),
(26, 1, '5024a40daa72a538eb251d6d585f1b54d9518c04a8c04cabdc31c420aae30a3c', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-03-27 09:00:16', '2026-03-27 09:00:30', '2026-03-28 00:00:16', 'cerrada'),
(27, 5, 'c4b7ead16fbdf9d2f86bd52071c3fca9bdb96f4ffaf167ba1073e09b6d37fe99', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-03-27 09:00:36', '2026-03-27 09:02:31', '2026-03-28 00:00:36', 'cerrada'),
(28, 1, '49d6df75925e807756402984ba0b839709c69e1dd7d708770a13c08eabfad126', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-03-27 09:02:55', '2026-03-27 14:44:40', '2026-03-28 00:02:55', 'activa'),
(29, 1, 'a73d4593bdd6857d3f11fab8f2681d91e96c8a4c17062b6d546cb9fb116586bc', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-03-27 14:59:49', '2026-03-27 14:59:49', '2026-03-28 05:59:49', 'activa'),
(30, 1, '871904f0e201e3200ec95dfc663b7a55ba645d69147794ddb6afa891114c9bc4', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-03-27 15:03:25', '2026-03-27 15:03:25', '2026-03-28 06:03:25', 'activa'),
(31, 1, '450892dc1690ca3539ff9b45527d2dd7425d3c45005ce3ed1365d014699b2585', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-03-27 15:05:36', '2026-03-27 15:05:36', '2026-03-28 06:05:36', 'activa'),
(32, 1, 'f9757732d4f95978b13754ad5e7fb1e6b227df25ea95128c8d1678d60a0bfd30', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-03-27 15:10:01', '2026-03-27 15:11:12', '2026-03-28 06:10:01', 'cerrada'),
(33, 1, '91dd37460d479a129d702345ec13aae4c7c059231318259e270ff40175733396', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-03-27 15:11:22', '2026-03-27 15:14:19', '2026-03-28 06:11:22', 'cerrada'),
(34, 2, 'addf304158b9e3d82dea67ed9c1e580bc734c2fe0b6d67326888f4c1e844f284', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-03-27 15:14:26', '2026-03-27 17:40:24', '2026-03-28 06:14:26', 'activa'),
(35, 1, '4a005edcd5aba688d7adfdcc2b353c099b5581fd6639e18372729f27fd0ed13a', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-03-28 07:56:48', '2026-03-28 11:15:35', '2026-03-28 22:56:48', 'activa'),
(36, 1, '25a9eb32d24c564e7b68d0635d67df33313a5ea3b85c825981b12dad831ceb10', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-03-30 08:44:51', '2026-03-30 16:26:04', '2026-03-31 00:44:51', 'activa'),
(37, 1, '8b22cd381a9c31cb69992c42333ece7e24295edfe2ed501f0c29ae426aba249f', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-03-30 16:55:32', '2026-03-30 17:41:27', '2026-03-31 08:55:32', 'activa'),
(38, 1, '660ca64725e210b1dac1f712dd3261b0fd7451095685ba54a8d99991bdc62ac4', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-03-31 13:03:51', '2026-03-31 13:24:22', '2026-04-01 05:03:51', 'activa'),
(39, 1, '8aaa229c0a6fe8554f290fd47548c9cc93d5b79b54833a0b8f3aed684d58614a', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-03-31 13:25:59', '2026-03-31 14:21:37', '2026-04-01 05:25:59', 'activa'),
(40, 1, '65f7d1a891f96a42d6e64c0b3dcc655c01dde47565b7a22ae560021f304577ae', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-03-31 15:46:22', '2026-03-31 17:17:54', '2026-04-01 07:46:22', 'activa'),
(41, 1, '5d3ae00d0c9b84b61c748b73b25042a58bb1cfe09debe45fe2fd82e6d86d7343', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-01 07:55:20', '2026-04-01 15:52:20', '2026-04-01 23:55:20', 'activa'),
(42, 1, '20edf5d6aff9da13f697ccbe9dd0ba2d43b09e5e9b9353e95fd0b5a6a122bdc6', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', '2026-04-01 11:05:43', '2026-04-01 11:29:05', '2026-04-02 03:05:43', 'activa'),
(43, 1, '55d740118c59d7c8f6188e8befc0f49dc072247647fd0080fb81d10b09d83793', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-01 15:57:24', '2026-04-01 16:04:02', '2026-04-02 07:57:24', 'activa'),
(44, 1, '0fbf106942db95527072cc91273de97110c0f68abf81bd0ad51593fd6e8c04c5', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-06 13:51:00', '2026-04-06 17:41:33', '2026-04-07 05:51:00', 'activa'),
(45, 1, 'cc8130d58a37a681df8c2f9b1a240d9592f7216a5b148fd4cec2ccf7513acd71', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-07 12:40:16', '2026-04-07 13:17:26', '2026-04-08 04:40:16', 'activa'),
(46, 1, 'c8b4d6b32818a85c14fceb2d5927f63161acd9c0af7d8aee06deb90ebdc61cdf', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-07 15:58:28', '2026-04-07 15:58:28', '2026-04-08 07:58:28', 'activa'),
(47, 1, 'dc6174d02b029e299bf4bd33a58bd0bea8cf396760067aac0e8265ce3e352659', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-08 13:01:18', '2026-04-08 14:17:09', '2026-04-09 05:01:18', 'cerrada'),
(48, 1, 'd5cee36bb1b28feaf8d4bafb7abf29609610ed861639abda1fdeca4252e170a3', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-08 14:17:24', '2026-04-08 14:18:07', '2026-04-09 06:17:24', 'cerrada'),
(49, 2, '549c8c8d5b72f07394848bef0da5ee282e92e5efe25b01525360a79320c2b980', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-08 14:18:17', '2026-04-08 14:19:18', '2026-04-09 06:18:17', 'cerrada'),
(50, 3, '5a096ef2fab22cb4ed2087342194caf72a480073611b1287c278e700d9f5d301', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-08 14:19:27', '2026-04-08 14:19:47', '2026-04-09 06:19:27', 'cerrada'),
(51, 4, '186a687f86e2c07b37b9f048e3d996da6301c1f97af89458ae313142481673c1', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-08 14:19:58', '2026-04-08 14:22:10', '2026-04-09 06:19:58', 'cerrada'),
(52, 1, '6331b2ad77e6ee6694c49a32e926565e5d40cfd0f37b7aeb3f7d50ad97e4a10b', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-08 14:22:21', '2026-04-08 15:42:04', '2026-04-09 06:22:21', 'activa'),
(53, 1, '42b60fe9c5578bdb2277378b02cd92f8da6be29ee3bc88b9fadd2d03bf757f76', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-10 08:40:36', '2026-04-10 08:49:25', '2026-04-11 00:40:36', 'activa'),
(54, 1, 'deb7bbc961e1294df9f72db95ac660718d540ddd161263a6497e60bb237d1f11', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-10 08:49:40', '2026-04-10 08:50:18', '2026-04-11 00:49:40', 'activa'),
(55, 1, 'b6edd77750ad2d0dfd4df7d5c217aba8a828803d1b1ed4de07fb4c24fa76d969', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-10 08:50:43', '2026-04-10 09:09:58', '2026-04-11 00:50:43', 'activa'),
(56, 1, '6c0400cd65f03b190d71cabf56cdfcec97ab2acb9742dec8f0fd2fd9a45919b4', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-10 09:10:57', '2026-04-10 09:10:57', '2026-04-11 01:10:57', 'activa'),
(57, 1, '74cf10838c62642a7f92711a4cd3931581cf040ff40bb5c1a133fd89f83874aa', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-10 09:11:47', '2026-04-10 09:11:47', '2026-04-11 01:11:47', 'activa'),
(58, 1, '452429ffc2392574f74ea0b2369a5b337824164658860d59f084368d71641539', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-10 09:12:11', '2026-04-10 09:12:11', '2026-04-11 01:12:11', 'activa'),
(59, 1, '100b2e9d9c9c7e86568e6e87aa647279b510af170d4d46e8566079345e5a61d2', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-10 09:13:04', '2026-04-10 09:13:04', '2026-04-11 01:13:04', 'activa'),
(60, 1, '05e98b4fd3ad4909095aa211c5812a635f5f9333c09f1928132e90ebf8bc486c', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-10 09:13:35', '2026-04-10 09:45:23', '2026-04-11 01:13:35', 'activa'),
(61, 1, '01a9aed6454fe66e8891fc674aa08804299a3370035a96ef08c8c2c556439e15', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-10 09:52:40', '2026-04-10 09:52:40', '2026-04-11 01:52:40', 'activa'),
(62, 1, 'a4eb3f7fccd08308f2993717fff4cac87e3524b5d97d9fac8dc98eed2e57d503', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-10 09:53:10', '2026-04-10 09:54:35', '2026-04-11 01:53:10', 'cerrada'),
(63, 1, '164abc3ae730db1b3d9dfb119f565b1cd538384b66281f30ea8abdd9409921a2', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-10 09:54:42', '2026-04-10 09:56:52', '2026-04-11 01:54:42', 'cerrada'),
(64, 1, '0df38c5e3232f42114ac82e477b1b0c52cace18a266f169031f08fbf9baee683', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-10 09:57:01', '2026-04-10 10:13:04', '2026-04-11 01:57:01', 'activa'),
(65, 1, 'f9c5614fb6f085e657420316cd55be30d6501af968f03145e5dae3edeb513006', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-10 14:51:42', '2026-04-10 14:51:43', '2026-04-11 06:51:42', 'activa'),
(66, 1, 'e4a873fda0a06a5e75f4b41ec03b08f1bad49befb1ff5593b0c729b118a3c110', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-11 10:14:13', '2026-04-11 10:22:23', '2026-04-12 02:14:13', 'activa'),
(67, 1, '646cc8ce485f13abd873b960e158e00ab2ef9a0df22d8a6dac15c69c7992f46b', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-11 10:39:34', '2026-04-11 10:42:03', '2026-04-12 02:39:34', 'activa'),
(68, 1, 'e3c790fb22faa5a781c7a79c25431c01e112dd1970e0df200d5147f4f3388e58', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-13 12:16:21', '2026-04-13 14:01:01', '2026-04-14 04:16:21', 'activa'),
(69, 1, '0fcf9eb276811a9983cf877784a0834fdec926a347b754286939f3ae4a8e4087', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-13 15:51:05', '2026-04-13 17:17:56', '2026-04-14 07:51:05', 'activa'),
(70, 1, '2151dddbfa7a39b4d739522fc2bf5147456e6aba0f6613d407b02b9582e31d37', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-14 08:11:54', '2026-04-14 11:01:16', '2026-04-15 00:11:54', 'activa'),
(71, 1, '5a67569ca2e434a932d05f8612a3ced7e41cccdd94b0a7766c4dfffba2907b72', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-14 14:02:38', '2026-04-14 14:36:08', '2026-04-15 06:02:38', 'activa'),
(72, 1, 'e2a38c5782d9ac765be55521f18ee0138d7bf39912ebc72f9e99000ff2e7dfab', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-14 16:25:01', '2026-04-14 17:16:51', '2026-04-15 08:25:01', 'activa'),
(73, 1, 'b46516199ae163aa7e2a8360cdd3b0d492b1933a8d9b701aecc954e219981a87', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-15 10:34:31', '2026-04-15 16:15:18', '2026-04-16 02:34:31', 'activa'),
(74, 1, '751af562c8f8be1f78dce4d2a9fa714a034eb299cf8ef61c10aa467d9eb2d653', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-16 07:43:06', '2026-04-16 12:10:29', '2026-04-16 23:43:06', 'cerrada'),
(75, 1, 'a3414002e8cfa7d00e66d099926f0308e9448ecd74aa302f29b898bb7afb71e0', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-16 12:10:38', '2026-04-16 14:28:38', '2026-04-17 04:10:38', 'activa'),
(76, 1, '010a29e5a43f894c5c226901ad8d46f2279fb33e8d11991e850745d985df4ae8', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-17 07:37:15', '2026-04-17 15:26:58', '2026-04-17 23:37:15', 'activa'),
(77, 1, '60e5609855282a140fdf19384a08df034617a17dab808e4fd590290cc832fdf9', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-17 13:57:15', '2026-04-17 14:06:24', '2026-04-18 05:57:15', 'activa'),
(78, 1, 'bea09706faef9bb1673eb92c48a9e4eab06b5e29c1d13709ddce434c72c13a1c', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-18 08:35:27', '2026-04-18 11:13:03', '2026-04-19 00:35:27', 'cerrada'),
(79, 1, '8f857a4fa3f3a97dd259fb257dc4b8156469b3aa159be3848640484c46733d91', '::1', 'Mozilla/5.0 (Linux; Android 13; SM-G981B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Mobile Safari/537.36 Edg/124.0.0.0', '2026-04-18 11:13:30', '2026-04-18 11:24:17', '2026-04-19 03:13:30', 'cerrada'),
(80, 1, '479d46b6e53cb6000b9289d1ea7283a920c790427d56b94679f5e54fd64f5fad', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-18 11:24:32', '2026-04-18 11:26:09', '2026-04-19 03:24:32', 'activa'),
(81, 1, '2b5ba22b9af9e1a6201fd7318a20bd62de570311a3b7915ca778ccd330e4236a', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-18 11:28:11', '2026-04-18 11:28:11', '2026-04-19 03:28:11', 'activa'),
(82, 1, '0ca3abfc328caea04fc1b0ed81a692188940689b5d76a6fdbdd8f9ac73b77e28', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-18 11:28:38', '2026-04-18 11:28:38', '2026-04-19 03:28:38', 'activa'),
(83, 1, '0888a38add8b525897d59a49223a8a10d4b7d4059c187ee03d165eed27bedfc0', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-18 11:31:35', '2026-04-18 11:31:35', '2026-04-19 03:31:35', 'activa'),
(84, 1, '55f03af2c9902a3ee1eaaa595a6cde37c306fa0c75e232daeb39535bdcdcd2ef', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-04-18 11:33:01', '2026-04-18 11:33:01', '2026-04-19 03:33:01', 'activa'),
(85, 1, 'd55e47fdd69caa629dbbca1b3b79b368f8496fbee73a6bd0cf107a4d975d7c10', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-18 11:46:12', '2026-04-18 12:47:31', '2026-04-19 03:46:12', 'activa'),
(86, 1, 'c4651abb7282919122b05133f142360a11faa483752c6d29bc051e129ddc679c', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-20 08:24:47', '2026-04-20 14:01:33', '2026-04-21 00:24:47', 'activa'),
(87, 1, '03e3eccfbd33afd58a44363adc458c189f35b85d7f5ee2932ccb8f99c034352f', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-20 14:33:01', '2026-04-20 17:47:28', '2026-04-21 06:33:01', 'cerrada'),
(88, 1, '88706e56c1202b99874899f62596844f10febd2d15637ff2e639ae6305cf372b', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-20 17:47:36', '2026-04-20 17:50:37', '2026-04-21 09:47:36', 'activa'),
(89, 1, 'ce0bb6135bfd93623c4b1a874ecc425bfea520ae5fd0b06e6c4fa7d8113e751f', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-21 07:44:55', '2026-04-21 07:46:21', '2026-04-21 23:44:55', 'cerrada'),
(90, 1, '0c907ab2ff86acea0acdd229f9a8ee4d3c551b7ccd845bae16a01539d73b5931', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-21 07:46:38', '2026-04-21 13:03:00', '2026-04-21 23:46:38', 'cerrada'),
(91, 1, '2842af90a99dc47020fd05f7a7cf703fb85f23ecb851ade51ef0c3efbebb6426', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-21 13:07:05', '2026-04-21 17:23:57', '2026-04-22 05:07:05', 'activa'),
(92, 1, 'cd0462b9fe5ab7634b8fdbd7dcdf33664d57f00bd1de24a244ec9fecff7a3804', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-22 07:27:11', '2026-04-22 08:06:06', '2026-04-22 23:27:11', 'cerrada'),
(93, 1, '6df392df802c7f4d30dbf18fef458b157c66fa98a0fdb2007879b11f4bb9bb41', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-22 08:06:15', '2026-04-22 14:27:34', '2026-04-23 00:06:15', 'activa'),
(94, 1, '0a17738adb1d5351a3d30067f3ddef2328342d04ecfe51eeede069e893b83d95', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-23 11:27:10', '2026-04-23 13:52:24', '2026-04-24 03:27:10', 'activa');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id_usuario` int(10) UNSIGNED NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `usuario` varchar(50) NOT NULL,
  `contrasena` varchar(255) NOT NULL,
  `rol_id` int(10) UNSIGNED NOT NULL,
  `estado` enum('activo','inactivo') NOT NULL DEFAULT 'activo',
  `fecha_creacion` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id_usuario`, `nombre`, `usuario`, `contrasena`, `rol_id`, `estado`, `fecha_creacion`) VALUES
(1, 'Administrador', 'admin', '$2y$12$awWsiiGw2sYpKHL8WVVl3en0dRoB/z5Jt.p3ip1qTQezhh4eGqHJW', 1, 'activo', '2026-03-18 13:21:58'),
(2, 'ventas soldymeg', 'ventas', '$2y$10$HXqnzkwgJJ6Z4d8WwA9fLOPyUG3imDvJ/Wv.fMkUjMnmOXa5VBZSe', 2, 'activo', '2026-03-18 14:05:43'),
(3, 'soldymeg', 'soldymeg', '$2y$10$zvDmsXDSIxSOduMDh5ObHO/hbBfJo6dXsk93dOass654QZO2OKeKO', 1, 'activo', '2026-03-27 08:40:31'),
(4, 'Soldymeg Contabilidad', 'contabilidad', '$2y$10$uQEHTZdCGTYmhQzctxd3WeHLGT2B8L0rljU23pHJa/yA.4vhtRyfy', 3, 'activo', '2026-03-27 08:43:27'),
(5, 'Soldymeg Operarador', 'operador', '$2y$10$whPPDyIlpt1VRPxozEmcou0TMNzcVMa1TX8x4tiC6clDhx1h5vIYy', 4, 'activo', '2026-03-27 08:43:48');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `cai_facturacion`
--
ALTER TABLE `cai_facturacion`
  ADD PRIMARY KEY (`id_cai`),
  ADD UNIQUE KEY `uk_cai_codigo` (`cai`),
  ADD KEY `fk_cai_usuario` (`usuario_id`);

--
-- Indices de la tabla `categorias_material`
--
ALTER TABLE `categorias_material`
  ADD PRIMARY KEY (`id_categoria`),
  ADD UNIQUE KEY `uk_cat_nombre` (`nombre`);

--
-- Indices de la tabla `clientes`
--
ALTER TABLE `clientes`
  ADD PRIMARY KEY (`id_cliente`),
  ADD KEY `idx_clientes_nombre` (`nombre`),
  ADD KEY `idx_clientes_rtn` (`rtn`);

--
-- Indices de la tabla `compras`
--
ALTER TABLE `compras`
  ADD PRIMARY KEY (`id_compra`),
  ADD KEY `idx_compra_proveedor` (`proveedor_id`),
  ADD KEY `idx_compra_fecha` (`fecha`),
  ADD KEY `fk_compra_usuario` (`usuario_id`);

--
-- Indices de la tabla `cotizaciones`
--
ALTER TABLE `cotizaciones`
  ADD PRIMARY KEY (`id_cotizacion`),
  ADD UNIQUE KEY `uk_cotizacion_numero` (`numero_cotizacion`),
  ADD KEY `idx_cot_cliente` (`cliente_id`),
  ADD KEY `idx_cot_orden` (`orden_id`),
  ADD KEY `idx_cot_estado` (`estado`),
  ADD KEY `idx_cot_fecha` (`fecha`),
  ADD KEY `fk_cot_usuario` (`usuario_id`);

--
-- Indices de la tabla `detalle_compras`
--
ALTER TABLE `detalle_compras`
  ADD PRIMARY KEY (`id_detalle_compra`),
  ADD KEY `idx_dc_compra` (`compra_id`),
  ADD KEY `idx_dc_material` (`material_id`);

--
-- Indices de la tabla `detalle_cotizacion`
--
ALTER TABLE `detalle_cotizacion`
  ADD PRIMARY KEY (`id_detalle_cot`),
  ADD KEY `idx_dcot_cotizacion` (`cotizacion_id`);

--
-- Indices de la tabla `detalle_factura`
--
ALTER TABLE `detalle_factura`
  ADD PRIMARY KEY (`id_detalle_fac`),
  ADD KEY `idx_dfac_factura` (`factura_id`);

--
-- Indices de la tabla `detalle_orden_mano_obra`
--
ALTER TABLE `detalle_orden_mano_obra`
  ADD PRIMARY KEY (`id_mano_obra`),
  ADD KEY `idx_dmo_orden` (`orden_id`);

--
-- Indices de la tabla `detalle_orden_materiales`
--
ALTER TABLE `detalle_orden_materiales`
  ADD PRIMARY KEY (`id_detalle_om`),
  ADD KEY `idx_dom_orden` (`orden_id`),
  ADD KEY `idx_dom_material` (`material_id`);

--
-- Indices de la tabla `detalle_planilla`
--
ALTER TABLE `detalle_planilla`
  ADD PRIMARY KEY (`id_detalle`),
  ADD UNIQUE KEY `uk_detalle_planilla_emp` (`planilla_id`,`empleado_id`),
  ADD KEY `idx_detalle_empleado` (`empleado_id`);

--
-- Indices de la tabla `empleados`
--
ALTER TABLE `empleados`
  ADD PRIMARY KEY (`id_empleado`),
  ADD KEY `idx_emp_nombre` (`nombre`);

--
-- Indices de la tabla `facturas`
--
ALTER TABLE `facturas`
  ADD PRIMARY KEY (`id_factura`),
  ADD UNIQUE KEY `uk_factura_numero` (`numero_factura`),
  ADD KEY `idx_fac_cliente` (`cliente_id`),
  ADD KEY `idx_fac_cotizacion` (`cotizacion_id`),
  ADD KEY `idx_fac_orden` (`orden_id`),
  ADD KEY `idx_fac_fecha` (`fecha`),
  ADD KEY `idx_fac_estado` (`estado`),
  ADD KEY `fk_fac_cai` (`cai_id`),
  ADD KEY `fk_fac_usuario` (`usuario_id`);

--
-- Indices de la tabla `factura_cotizaciones`
--
ALTER TABLE `factura_cotizaciones`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_fac_cot` (`factura_id`,`cotizacion_id`),
  ADD KEY `fk_faccot_cot` (`cotizacion_id`);

--
-- Indices de la tabla `materiales`
--
ALTER TABLE `materiales`
  ADD PRIMARY KEY (`id_material`),
  ADD UNIQUE KEY `uk_material_codigo` (`codigo`),
  ADD KEY `idx_material_nombre` (`nombre`),
  ADD KEY `idx_material_categoria` (`categoria_id`);

--
-- Indices de la tabla `movimientos_inventario`
--
ALTER TABLE `movimientos_inventario`
  ADD PRIMARY KEY (`id_movimiento`),
  ADD KEY `idx_mov_material` (`material_id`),
  ADD KEY `idx_mov_fecha` (`fecha`),
  ADD KEY `fk_mov_usuario` (`usuario_id`);

--
-- Indices de la tabla `ordenes_trabajo`
--
ALTER TABLE `ordenes_trabajo`
  ADD PRIMARY KEY (`id_orden`),
  ADD UNIQUE KEY `uk_orden_numero` (`numero_orden`),
  ADD KEY `idx_ot_cliente` (`cliente_id`),
  ADD KEY `idx_ot_estado` (`estado`),
  ADD KEY `idx_ot_fecha` (`fecha_apertura`),
  ADD KEY `fk_ot_usuario` (`usuario_id`),
  ADD KEY `idx_ot_cotizacion` (`cotizacion_id`);

--
-- Indices de la tabla `orden_tecnicos`
--
ALTER TABLE `orden_tecnicos`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_orden_empleado` (`orden_id`,`empleado_id`),
  ADD KEY `fk_otem_empleado` (`empleado_id`);

--
-- Indices de la tabla `pagos_clientes`
--
ALTER TABLE `pagos_clientes`
  ADD PRIMARY KEY (`id_pago`),
  ADD KEY `idx_pago_factura` (`factura_id`),
  ADD KEY `idx_pago_cliente` (`cliente_id`),
  ADD KEY `idx_pago_fecha` (`fecha`),
  ADD KEY `fk_pago_usuario` (`usuario_id`);

--
-- Indices de la tabla `permisos`
--
ALTER TABLE `permisos`
  ADD PRIMARY KEY (`id_permiso`),
  ADD UNIQUE KEY `uk_permisos_rol_modulo` (`rol_id`,`modulo`);

--
-- Indices de la tabla `planillas`
--
ALTER TABLE `planillas`
  ADD PRIMARY KEY (`id_planilla`),
  ADD UNIQUE KEY `uk_planilla_periodo_quincena` (`periodo_mes`,`periodo_anio`,`quincena`),
  ADD KEY `idx_planilla_estado` (`estado`),
  ADD KEY `fk_planilla_usuario` (`usuario_id`);

--
-- Indices de la tabla `proveedores`
--
ALTER TABLE `proveedores`
  ADD PRIMARY KEY (`id_proveedor`),
  ADD KEY `idx_prov_nombre` (`nombre`);

--
-- Indices de la tabla `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id_rol`),
  ADD UNIQUE KEY `uk_roles_nombre` (`nombre`);

--
-- Indices de la tabla `sesiones_admin`
--
ALTER TABLE `sesiones_admin`
  ADD PRIMARY KEY (`id_sesion`),
  ADD UNIQUE KEY `uk_sesiones_token` (`token`),
  ADD KEY `fk_sesiones_usuario` (`usuario_id`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id_usuario`),
  ADD UNIQUE KEY `uk_usuarios_usuario` (`usuario`),
  ADD KEY `fk_usuarios_rol` (`rol_id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `cai_facturacion`
--
ALTER TABLE `cai_facturacion`
  MODIFY `id_cai` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `categorias_material`
--
ALTER TABLE `categorias_material`
  MODIFY `id_categoria` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `clientes`
--
ALTER TABLE `clientes`
  MODIFY `id_cliente` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `compras`
--
ALTER TABLE `compras`
  MODIFY `id_compra` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `cotizaciones`
--
ALTER TABLE `cotizaciones`
  MODIFY `id_cotizacion` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `detalle_compras`
--
ALTER TABLE `detalle_compras`
  MODIFY `id_detalle_compra` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `detalle_cotizacion`
--
ALTER TABLE `detalle_cotizacion`
  MODIFY `id_detalle_cot` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `detalle_factura`
--
ALTER TABLE `detalle_factura`
  MODIFY `id_detalle_fac` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `detalle_orden_mano_obra`
--
ALTER TABLE `detalle_orden_mano_obra`
  MODIFY `id_mano_obra` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `detalle_orden_materiales`
--
ALTER TABLE `detalle_orden_materiales`
  MODIFY `id_detalle_om` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `detalle_planilla`
--
ALTER TABLE `detalle_planilla`
  MODIFY `id_detalle` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=362;

--
-- AUTO_INCREMENT de la tabla `empleados`
--
ALTER TABLE `empleados`
  MODIFY `id_empleado` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT de la tabla `facturas`
--
ALTER TABLE `facturas`
  MODIFY `id_factura` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `factura_cotizaciones`
--
ALTER TABLE `factura_cotizaciones`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `materiales`
--
ALTER TABLE `materiales`
  MODIFY `id_material` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `movimientos_inventario`
--
ALTER TABLE `movimientos_inventario`
  MODIFY `id_movimiento` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `ordenes_trabajo`
--
ALTER TABLE `ordenes_trabajo`
  MODIFY `id_orden` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `orden_tecnicos`
--
ALTER TABLE `orden_tecnicos`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `pagos_clientes`
--
ALTER TABLE `pagos_clientes`
  MODIFY `id_pago` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `permisos`
--
ALTER TABLE `permisos`
  MODIFY `id_permiso` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=191;

--
-- AUTO_INCREMENT de la tabla `planillas`
--
ALTER TABLE `planillas`
  MODIFY `id_planilla` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT de la tabla `proveedores`
--
ALTER TABLE `proveedores`
  MODIFY `id_proveedor` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `roles`
--
ALTER TABLE `roles`
  MODIFY `id_rol` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `sesiones_admin`
--
ALTER TABLE `sesiones_admin`
  MODIFY `id_sesion` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=95;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id_usuario` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `cai_facturacion`
--
ALTER TABLE `cai_facturacion`
  ADD CONSTRAINT `fk_cai_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id_usuario`);

--
-- Filtros para la tabla `compras`
--
ALTER TABLE `compras`
  ADD CONSTRAINT `fk_compra_proveedor` FOREIGN KEY (`proveedor_id`) REFERENCES `proveedores` (`id_proveedor`),
  ADD CONSTRAINT `fk_compra_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id_usuario`);

--
-- Filtros para la tabla `cotizaciones`
--
ALTER TABLE `cotizaciones`
  ADD CONSTRAINT `fk_cot_cliente` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id_cliente`),
  ADD CONSTRAINT `fk_cot_orden` FOREIGN KEY (`orden_id`) REFERENCES `ordenes_trabajo` (`id_orden`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_cot_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id_usuario`);

--
-- Filtros para la tabla `detalle_compras`
--
ALTER TABLE `detalle_compras`
  ADD CONSTRAINT `fk_dc_compra` FOREIGN KEY (`compra_id`) REFERENCES `compras` (`id_compra`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_dc_material` FOREIGN KEY (`material_id`) REFERENCES `materiales` (`id_material`);

--
-- Filtros para la tabla `detalle_cotizacion`
--
ALTER TABLE `detalle_cotizacion`
  ADD CONSTRAINT `fk_dcot_cotizacion` FOREIGN KEY (`cotizacion_id`) REFERENCES `cotizaciones` (`id_cotizacion`) ON DELETE CASCADE;

--
-- Filtros para la tabla `detalle_factura`
--
ALTER TABLE `detalle_factura`
  ADD CONSTRAINT `fk_dfac_factura` FOREIGN KEY (`factura_id`) REFERENCES `facturas` (`id_factura`) ON DELETE CASCADE;

--
-- Filtros para la tabla `detalle_orden_mano_obra`
--
ALTER TABLE `detalle_orden_mano_obra`
  ADD CONSTRAINT `fk_dmo_orden` FOREIGN KEY (`orden_id`) REFERENCES `ordenes_trabajo` (`id_orden`) ON DELETE CASCADE;

--
-- Filtros para la tabla `detalle_orden_materiales`
--
ALTER TABLE `detalle_orden_materiales`
  ADD CONSTRAINT `fk_dom_material` FOREIGN KEY (`material_id`) REFERENCES `materiales` (`id_material`),
  ADD CONSTRAINT `fk_dom_orden` FOREIGN KEY (`orden_id`) REFERENCES `ordenes_trabajo` (`id_orden`) ON DELETE CASCADE;

--
-- Filtros para la tabla `detalle_planilla`
--
ALTER TABLE `detalle_planilla`
  ADD CONSTRAINT `fk_detalle_empleado` FOREIGN KEY (`empleado_id`) REFERENCES `empleados` (`id_empleado`),
  ADD CONSTRAINT `fk_detalle_planilla` FOREIGN KEY (`planilla_id`) REFERENCES `planillas` (`id_planilla`) ON DELETE CASCADE;

--
-- Filtros para la tabla `facturas`
--
ALTER TABLE `facturas`
  ADD CONSTRAINT `fk_fac_cai` FOREIGN KEY (`cai_id`) REFERENCES `cai_facturacion` (`id_cai`),
  ADD CONSTRAINT `fk_fac_cliente` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id_cliente`),
  ADD CONSTRAINT `fk_fac_cotizacion` FOREIGN KEY (`cotizacion_id`) REFERENCES `cotizaciones` (`id_cotizacion`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_fac_orden` FOREIGN KEY (`orden_id`) REFERENCES `ordenes_trabajo` (`id_orden`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_fac_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id_usuario`);

--
-- Filtros para la tabla `factura_cotizaciones`
--
ALTER TABLE `factura_cotizaciones`
  ADD CONSTRAINT `fk_faccot_cot` FOREIGN KEY (`cotizacion_id`) REFERENCES `cotizaciones` (`id_cotizacion`),
  ADD CONSTRAINT `fk_faccot_factura` FOREIGN KEY (`factura_id`) REFERENCES `facturas` (`id_factura`) ON DELETE CASCADE;

--
-- Filtros para la tabla `materiales`
--
ALTER TABLE `materiales`
  ADD CONSTRAINT `fk_material_categoria` FOREIGN KEY (`categoria_id`) REFERENCES `categorias_material` (`id_categoria`) ON DELETE SET NULL;

--
-- Filtros para la tabla `movimientos_inventario`
--
ALTER TABLE `movimientos_inventario`
  ADD CONSTRAINT `fk_mov_material` FOREIGN KEY (`material_id`) REFERENCES `materiales` (`id_material`),
  ADD CONSTRAINT `fk_mov_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id_usuario`);

--
-- Filtros para la tabla `ordenes_trabajo`
--
ALTER TABLE `ordenes_trabajo`
  ADD CONSTRAINT `fk_ot_cliente` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id_cliente`),
  ADD CONSTRAINT `fk_ot_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id_usuario`);

--
-- Filtros para la tabla `orden_tecnicos`
--
ALTER TABLE `orden_tecnicos`
  ADD CONSTRAINT `fk_otem_empleado` FOREIGN KEY (`empleado_id`) REFERENCES `empleados` (`id_empleado`),
  ADD CONSTRAINT `fk_otem_orden` FOREIGN KEY (`orden_id`) REFERENCES `ordenes_trabajo` (`id_orden`) ON DELETE CASCADE;

--
-- Filtros para la tabla `pagos_clientes`
--
ALTER TABLE `pagos_clientes`
  ADD CONSTRAINT `fk_pago_cliente` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id_cliente`),
  ADD CONSTRAINT `fk_pago_factura` FOREIGN KEY (`factura_id`) REFERENCES `facturas` (`id_factura`),
  ADD CONSTRAINT `fk_pago_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id_usuario`);

--
-- Filtros para la tabla `permisos`
--
ALTER TABLE `permisos`
  ADD CONSTRAINT `fk_permisos_rol` FOREIGN KEY (`rol_id`) REFERENCES `roles` (`id_rol`);

--
-- Filtros para la tabla `planillas`
--
ALTER TABLE `planillas`
  ADD CONSTRAINT `fk_planilla_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id_usuario`);

--
-- Filtros para la tabla `sesiones_admin`
--
ALTER TABLE `sesiones_admin`
  ADD CONSTRAINT `fk_sesiones_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id_usuario`);

--
-- Filtros para la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD CONSTRAINT `fk_usuarios_rol` FOREIGN KEY (`rol_id`) REFERENCES `roles` (`id_rol`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
