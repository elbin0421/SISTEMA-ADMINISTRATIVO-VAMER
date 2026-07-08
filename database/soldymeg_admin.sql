-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 26-03-2026 a las 21:49:36
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
(1, '465070-C7598A-896EE0-63BE03-0909D7-2F', '000-001-01-00001051', '000-001-01-00001300', '000-001-01-00001051', '2026-06-19', '001', '001', '01', 'activo', '2026-03-21 10:06:11', 1);

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
  `estado` enum('activo','inactivo') NOT NULL DEFAULT 'activo',
  `fecha_creacion` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `clientes`
--

INSERT INTO `clientes` (`id_cliente`, `nombre`, `tipo_cliente`, `rtn`, `telefono`, `telefono2`, `direccion`, `correo`, `contacto`, `estado`, `fecha_creacion`) VALUES
(1, 'CARGILL DE HONDURAS S DE R.L', 'empresa', '05019001049230', '99999999', '99999999', 'Bufalo, Villanueva, Cortes', 'cargill@cargill.com', 'Fredy Lopez', 'activo', '2026-03-18 15:15:19'),
(2, 'GRANEL S.A DE C.V', 'empresa', '05019002063180', '', '', '33 calle sps', '', '', 'activo', '2026-03-18 15:47:19'),
(3, 'VESTA LOGISTIC SERVICE PROVIDER S.A DE C.V', 'empresa', '05019023478612', '', '', '', '', '', 'activo', '2026-03-18 15:47:35'),
(4, 'RCJ LOGISTIC S.A DE C.V', 'empresa', '05029021315488', '', '', 'Carretera a Puerto Cortes km 18 Rio Nance Choloma, Cortes', '', '', 'activo', '2026-03-18 15:47:55'),
(5, 'SERVICIOS MULTIPLES DEL CARIBE S.A', 'empresa', '05019015809639', '', '', '27 calle, Col. La Pradera, esquina opuesta a escuela La Salle', '', '', 'activo', '2026-03-18 15:48:13');

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

--
-- Volcado de datos para la tabla `compras`
--

INSERT INTO `compras` (`id_compra`, `numero_documento`, `proveedor_id`, `fecha`, `subtotal`, `impuesto`, `total`, `estado`, `metodo_pago`, `referencia_pago`, `usuario_id`, `observaciones`, `fecha_creacion`) VALUES
(1, '89', 1, '2026-03-21', 50.00, 7.50, 57.50, 'pagada', 'efectivo', NULL, 1, 'compra de consumibles', '2026-03-21 12:29:08'),
(2, '90', 1, '2026-03-21', 2500.00, 375.00, 2875.00, 'pagada', 'efectivo', NULL, 1, '', '2026-03-21 12:32:05'),
(3, '89', 1, '2026-03-24', 5000.00, 750.00, 5750.00, 'pagada', 'tarjeta', '7777', 1, '', '2026-03-24 13:09:20'),
(4, '89', 1, '2026-03-24', 50.00, 7.50, 57.50, 'pagada', 'efectivo', NULL, 1, '', '2026-03-24 13:16:51'),
(5, '89', 1, '2026-03-24', 60.00, 9.00, 69.00, 'pagada', 'efectivo', NULL, 1, '', '2026-03-24 13:21:21'),
(6, '100', 1, '2026-03-25', 2500.00, 375.00, 2875.00, 'pagada', 'efectivo', NULL, 1, '', '2026-03-25 15:48:36');

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
-- Volcado de datos para la tabla `detalle_compras`
--

INSERT INTO `detalle_compras` (`id_detalle_compra`, `compra_id`, `material_id`, `cantidad`, `precio_unitario`, `subtotal`) VALUES
(1, 1, 1, 1.00, 50.00, 50.00),
(2, 2, 1, 50.00, 50.00, 2500.00),
(3, 3, 1, 100.00, 50.00, 5000.00),
(4, 4, 1, 1.00, 50.00, 50.00),
(5, 5, 1, 1.00, 60.00, 60.00),
(6, 6, 2, 5.00, 500.00, 2500.00);

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
-- Estructura de tabla para la tabla `empleados`
--

CREATE TABLE `empleados` (
  `id_empleado` int(10) UNSIGNED NOT NULL,
  `nombres` varchar(100) NOT NULL,
  `apellidos` varchar(100) NOT NULL,
  `identidad` varchar(20) DEFAULT NULL,
  `puesto` varchar(80) DEFAULT NULL,
  `tipo_contrato` enum('tiempo_completo','medio_tiempo','por_obra') NOT NULL DEFAULT 'tiempo_completo',
  `salario_mensual` decimal(12,2) NOT NULL DEFAULT 0.00,
  `fecha_ingreso` date DEFAULT NULL,
  `ihss_numero` varchar(20) DEFAULT NULL,
  `rap_numero` varchar(20) DEFAULT NULL,
  `estado` enum('activo','inactivo') NOT NULL DEFAULT 'activo',
  `fecha_creacion` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `empleados`
--

INSERT INTO `empleados` (`id_empleado`, `nombres`, `apellidos`, `identidad`, `puesto`, `tipo_contrato`, `salario_mensual`, `fecha_ingreso`, `ihss_numero`, `rap_numero`, `estado`, `fecha_creacion`) VALUES
(1, 'Elbin', 'Arita', '0421198700799', 'Soldador', 'tiempo_completo', 22000.00, '2026-01-21', NULL, NULL, 'activo', '2026-03-19 13:26:24'),
(2, 'Melvin', 'Gomez', '999999999', 'Supervior', 'tiempo_completo', 26000.00, '2024-03-01', NULL, NULL, 'activo', '2026-03-19 13:30:43'),
(3, 'Empleado', '1', NULL, 'Soldador', 'tiempo_completo', 0.00, '2026-03-19', NULL, NULL, 'activo', '2026-03-19 14:14:11'),
(4, 'Empleado', '2', NULL, 'Mecánico', 'tiempo_completo', 0.00, '2026-03-19', NULL, NULL, 'activo', '2026-03-19 14:14:11'),
(5, 'Empleado', '3', NULL, 'Ayudante', 'tiempo_completo', 0.00, '2026-03-19', NULL, NULL, 'activo', '2026-03-19 14:14:11'),
(6, 'Empleado', '4', NULL, 'Técnico Eléctrico', 'tiempo_completo', 0.00, '2026-03-19', NULL, NULL, 'activo', '2026-03-19 14:14:11');

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

--
-- Volcado de datos para la tabla `materiales`
--

INSERT INTO `materiales` (`id_material`, `codigo`, `nombre`, `descripcion`, `categoria_id`, `unidad_medida`, `precio_compra`, `precio_venta`, `stock`, `stock_minimo`, `estado`, `fecha_creacion`) VALUES
(1, '00001', 'Disco para cortar metal de 7', 'Disco para cortar metales hierro y aluminio', 4, 'unidad', 50.00, 67.50, 154.00, 25.00, 'activo', '2026-03-21 12:26:11'),
(2, '00002', 'GRASA MULTIPROPOSITO', '', 2, 'unidad', 500.00, 675.00, 5.00, 2.00, 'activo', '2026-03-25 15:47:41');

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

--
-- Volcado de datos para la tabla `movimientos_inventario`
--

INSERT INTO `movimientos_inventario` (`id_movimiento`, `material_id`, `tipo`, `cantidad`, `costo_unitario`, `fecha`, `tipo_referencia`, `referencia_id`, `usuario_id`, `observaciones`) VALUES
(1, 1, 'entrada', 1.00, 0.00, '2026-03-21 12:26:33', 'ajuste_manual', NULL, 1, 'Error en inventario'),
(2, 1, 'entrada', 1.00, 0.00, '2026-03-21 12:26:48', 'ajuste_manual', NULL, 1, 'Error en inventario'),
(3, 1, 'salida', 1.00, 0.00, '2026-03-21 12:27:12', 'ajuste_manual', NULL, 1, 'Error en inventario'),
(4, 1, 'entrada', 1.00, 50.00, '2026-03-21 12:29:08', 'compra', 1, 1, 'Compra #1'),
(5, 1, 'entrada', 50.00, 50.00, '2026-03-21 12:32:05', 'compra', 2, 1, 'Compra #2'),
(6, 1, 'salida', 52.00, 67.50, '2026-03-21 12:32:32', 'orden_trabajo', 1, 1, 'OT OT-2026-001'),
(7, 1, 'entrada', 100.00, 50.00, '2026-03-24 13:09:20', 'compra', 3, 1, 'Compra #3'),
(8, 1, 'salida', 20.00, 67.50, '2026-03-24 13:10:16', 'orden_trabajo', 2, 1, 'OT OT-2026-002'),
(9, 1, 'salida', 10.00, 67.50, '2026-03-24 13:15:03', 'orden_trabajo', 3, 1, 'OT OT-2026-003'),
(10, 1, 'entrada', 1.00, 50.00, '2026-03-24 13:16:51', 'compra', 4, 1, 'Compra #4'),
(11, 1, 'entrada', 1.00, 60.00, '2026-03-24 13:21:21', 'compra', 5, 1, 'Compra #5'),
(12, 1, 'salida', 1.00, 67.50, '2026-03-24 13:22:47', 'orden_trabajo', 3, 1, 'OT OT-2026-003'),
(13, 1, 'salida', 1.00, 67.50, '2026-03-24 13:22:58', 'orden_trabajo', 3, 1, 'OT OT-2026-003'),
(14, 1, 'salida', 1.00, 67.50, '2026-03-24 13:32:15', 'orden_trabajo', 3, 1, 'OT OT-2026-003'),
(15, 1, 'salida', 1.00, 67.50, '2026-03-24 16:14:54', 'orden_trabajo', 4, 1, 'OT OT-2026-004'),
(16, 1, 'salida', 5.00, 67.50, '2026-03-24 17:03:07', 'orden_trabajo', 7, 1, 'OT OT-2026-007'),
(17, 1, 'salida', 7.00, 67.50, '2026-03-25 12:40:37', 'orden_trabajo', 1, 1, 'OT OT-2026-001'),
(18, 1, 'salida', 20.00, 67.50, '2026-03-25 15:40:04', 'orden_trabajo', 5, 1, 'OT OT-2026-005'),
(19, 2, 'entrada', 5.00, 500.00, '2026-03-25 15:48:36', 'compra', 6, 1, 'Compra #6'),
(20, 2, 'salida', 2.00, 0.00, '2026-03-25 15:50:11', 'orden_trabajo', 1, 1, 'OT OT-2026-001'),
(21, 2, 'salida', 2.00, 675.00, '2026-03-25 15:50:48', 'orden_trabajo', 1, 1, 'OT OT-2026-001'),
(22, 1, 'salida', 20.00, 67.50, '2026-03-26 13:08:44', 'orden_trabajo', 2, 1, 'OT OT-2026-002'),
(23, 1, 'salida', 10.00, 67.50, '2026-03-26 13:23:19', 'orden_trabajo', 3, 1, 'OT OT-2026-003'),
(24, 1, 'salida', 5.00, 67.50, '2026-03-26 13:27:26', 'orden_trabajo', 4, 1, 'OT OT-2026-004'),
(25, 2, 'salida', 3.00, 675.00, '2026-03-26 14:32:23', 'orden_trabajo', 5, 1, 'OT OT-2026-005'),
(26, 1, 'salida', 1.00, 67.50, '2026-03-26 14:40:22', 'orden_trabajo', 6, 1, 'OT OT-2026-006');

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
(18, 3, 'pagos', 1, 1, 1, 0),
(19, 3, 'planillas', 1, 1, 1, 0),
(20, 3, 'reportes', 1, 0, 0, 0),
(21, 3, 'clientes', 1, 0, 0, 0),
(22, 4, 'ordenes_trabajo', 1, 1, 1, 0),
(23, 4, 'inventario', 1, 0, 0, 0),
(24, 4, 'clientes', 1, 0, 0, 0),
(25, 2, 'usuarios', 0, 0, 0, 0),
(26, 2, 'roles', 0, 0, 0, 0),
(31, 2, 'inventario', 0, 0, 0, 0),
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
(156, 4, 'reportes', 0, 0, 0, 0);

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
(1, 'La mundial', '999999-9999', '99', 'primera calla sps', 'lamundial@lamundial.com', '95969999', 'activo', '2026-03-18 15:27:47'),
(2, 'Ultra Repuestos', '999999', '9999', 'segunda calle sps', 'ul@ultra.com', '9696699', 'activo', '2026-03-18 15:43:20'),
(3, 'Infra', '222', '', '', '', '', 'activo', '2026-03-20 10:41:30');

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
(23, 1, '5f34bb48f5d2e177e1e42c5350f952d1f8f4dc27529b1be45a24156be90a9717', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-03-26 12:58:38', '2026-03-26 14:48:59', '2026-03-27 03:58:38', 'activa');

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
(2, 'ventas soldymeg', 'ventas', '$2y$10$HXqnzkwgJJ6Z4d8WwA9fLOPyUG3imDvJ/Wv.fMkUjMnmOXa5VBZSe', 2, 'activo', '2026-03-18 14:05:43');

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
  MODIFY `id_cliente` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `compras`
--
ALTER TABLE `compras`
  MODIFY `id_compra` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `cotizaciones`
--
ALTER TABLE `cotizaciones`
  MODIFY `id_cotizacion` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `detalle_compras`
--
ALTER TABLE `detalle_compras`
  MODIFY `id_detalle_compra` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `detalle_cotizacion`
--
ALTER TABLE `detalle_cotizacion`
  MODIFY `id_detalle_cot` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

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
-- AUTO_INCREMENT de la tabla `empleados`
--
ALTER TABLE `empleados`
  MODIFY `id_empleado` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `facturas`
--
ALTER TABLE `facturas`
  MODIFY `id_factura` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `materiales`
--
ALTER TABLE `materiales`
  MODIFY `id_material` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `movimientos_inventario`
--
ALTER TABLE `movimientos_inventario`
  MODIFY `id_movimiento` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

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
  MODIFY `id_permiso` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=164;

--
-- AUTO_INCREMENT de la tabla `proveedores`
--
ALTER TABLE `proveedores`
  MODIFY `id_proveedor` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `roles`
--
ALTER TABLE `roles`
  MODIFY `id_rol` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `sesiones_admin`
--
ALTER TABLE `sesiones_admin`
  MODIFY `id_sesion` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id_usuario` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

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
-- Filtros para la tabla `facturas`
--
ALTER TABLE `facturas`
  ADD CONSTRAINT `fk_fac_cai` FOREIGN KEY (`cai_id`) REFERENCES `cai_facturacion` (`id_cai`),
  ADD CONSTRAINT `fk_fac_cliente` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id_cliente`),
  ADD CONSTRAINT `fk_fac_cotizacion` FOREIGN KEY (`cotizacion_id`) REFERENCES `cotizaciones` (`id_cotizacion`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_fac_orden` FOREIGN KEY (`orden_id`) REFERENCES `ordenes_trabajo` (`id_orden`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_fac_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id_usuario`);

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
-- Filtros para la tabla `sesiones_admin`
--
ALTER TABLE `sesiones_admin`
  ADD CONSTRAINT `fk_sesiones_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id_usuario`);

--
-- Filtros para la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD CONSTRAINT `fk_usuarios_rol` FOREIGN KEY (`rol_id`) REFERENCES `roles` (`id_rol`);

-- ============================================================
--  PATCH v2 — Tabla vehiculos + empleado_id en usuarios
-- ============================================================

--
-- Tabla vehiculos (vinculada a clientes)
--
CREATE TABLE IF NOT EXISTS `vehiculos` (
  `id_vehiculo` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `cliente_id`  int(10) UNSIGNED NOT NULL,
  `placa`       varchar(20)  NOT NULL,
  `marca`       varchar(80)  DEFAULT NULL,
  `modelo`      varchar(80)  DEFAULT NULL,
  `anio`        year(4)      DEFAULT NULL,
  `color`       varchar(50)  DEFAULT NULL,
  `numero_motor`  varchar(50) DEFAULT NULL,
  `numero_chasis` varchar(50) DEFAULT NULL,
  `observaciones` varchar(255) DEFAULT NULL,
  `estado`      enum('activo','inactivo') NOT NULL DEFAULT 'activo',
  `fecha_creacion` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id_vehiculo`),
  UNIQUE KEY `uq_placa` (`placa`),
  KEY `fk_veh_cliente` (`cliente_id`),
  CONSTRAINT `fk_veh_cliente` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id_cliente`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Agregar empleado_id a usuarios (si no existe)
--
ALTER TABLE `usuarios`
  ADD COLUMN IF NOT EXISTS `empleado_id` int(10) UNSIGNED DEFAULT NULL AFTER `rol_id`,
  ADD CONSTRAINT `fk_usr_empleado` FOREIGN KEY (`empleado_id`) REFERENCES `empleados` (`id_empleado`) ON DELETE SET NULL;

--
-- Agregar columna unidad (placa/unidad del vehículo) a cotizaciones
--
ALTER TABLE `cotizaciones`
  ADD COLUMN IF NOT EXISTS `unidad` varchar(30) DEFAULT NULL COMMENT 'Placa o identificador del vehículo/unidad' AFTER `orden_compra`;

--
-- Agregar columna motivo_rechazo a cotizaciones
--
ALTER TABLE `cotizaciones`
  ADD COLUMN IF NOT EXISTS `motivo_rechazo` varchar(300) DEFAULT NULL COMMENT 'Motivo al rechazar la cotización' AFTER `unidad`;

--
-- Guardar elaborado_por y telefono en cotizaciones al momento de crear
--
ALTER TABLE `cotizaciones`
  ADD COLUMN IF NOT EXISTS `elaborado_por`     varchar(120) DEFAULT NULL COMMENT 'Nombre empleado que elaboró' AFTER `motivo_rechazo`,
  ADD COLUMN IF NOT EXISTS `telefono_elaborado` varchar(30)  DEFAULT NULL COMMENT 'Teléfono del empleado' AFTER `elaborado_por`;

COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
