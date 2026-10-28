-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 26-10-2026 a las 21:48:49
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
-- Base de datos: `vamer_admin`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `asistencia_registros`
--

CREATE TABLE `asistencia_registros` (
  `id_registro` int(10) UNSIGNED NOT NULL,
  `empleado_id` int(10) UNSIGNED NOT NULL,
  `fecha` date NOT NULL,
  `tipo` enum('horas_extra','dia_faltado') NOT NULL,
  `cantidad` decimal(6,2) NOT NULL COMMENT 'Horas (horas_extra) o días (dia_faltado)',
  `motivo` varchar(255) DEFAULT NULL,
  `planilla_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'Planilla donde se aplicó (NULL = pendiente)',
  `usuario_id` int(10) UNSIGNED DEFAULT NULL,
  `fecha_creacion` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `asistencia_registros`
--

INSERT INTO `asistencia_registros` (`id_registro`, `empleado_id`, `fecha`, `tipo`, `cantidad`, `motivo`, `planilla_id`, `usuario_id`, `fecha_creacion`) VALUES
(1, 20, '2026-10-16', 'dia_faltado', 1.00, 'NO PRESENTO INCAPACIDAD', NULL, 6, '2026-10-20 13:57:56'),
(2, 20, '2026-10-17', 'dia_faltado', 1.00, 'NO PRESENTO INCAPACIDAD', NULL, 6, '2026-10-20 13:58:21');

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
(1, '4ED252-6E9F76-20DCE0-63BE03-09091A-59', '000-001-01-00000001', '000-001-01-00000050', '000-001-01-00000051', '2027-04-06', '001', '001', '01', 'agotado', '2026-04-20 17:46:52', 1),
(2, '5BA376-929154-2226E0-63BE03-090996-93', '000-001-01-00000051', '000-001-01-00000200', '000-001-01-00000063', '2027-06-16', '001', '001', '01', 'activo', '2026-10-13 16:12:41', 6);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `catalogo_precios`
--

CREATE TABLE `catalogo_precios` (
  `id_catalogo` int(10) UNSIGNED NOT NULL,
  `codigo` varchar(10) NOT NULL,
  `descripcion` varchar(255) NOT NULL,
  `tipo` enum('material','mano_obra','otro') NOT NULL DEFAULT 'material',
  `categoria` varchar(100) DEFAULT NULL,
  `precio` decimal(12,2) NOT NULL DEFAULT 0.00,
  `estado` enum('activo','inactivo') NOT NULL DEFAULT 'activo',
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `catalogo_precios`
--

INSERT INTO `catalogo_precios` (`id_catalogo`, `codigo`, `descripcion`, `tipo`, `categoria`, `precio`, `estado`, `fecha_creacion`) VALUES
(1, '0001', 'FABRICADO E INSTALADO DE COLGANTE DE MANGUERAS FRONTALES', 'mano_obra', 'Soldadura', 3800.00, 'activo', '2026-05-26 20:33:41'),
(2, '0002', 'FABRICADO EN INSTALADO TAPADERA SEGURIDAD DE CAJA DE BATERIAS', 'mano_obra', 'Otros', 4000.00, 'activo', '2026-05-26 20:35:29'),
(3, '0003', 'FABRICACION DE TORNILLO SIN FIN HORIZONTAL', 'mano_obra', 'Otros', 53250.75, 'activo', '2026-07-14 21:13:58');

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
(4, 'Consumibles'),
(5, 'Eléctrico y Electrónico'),
(7, 'FILTROS'),
(2, 'Grasas y lubricantes'),
(8, 'Herramientas'),
(3, 'Materiales de Soldadura'),
(6, 'Neumáticos y Suspensión'),
(9, 'Otros'),
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
(2, 'GRANEL S.A DE C.V', 'empresa', '05019002063180', '9290-0356', '', 'SECTOR ALDEA RIO BLANQUITO, CHOLOMA, CORTES.', 'josue.alvarez@somoscmi.com', 'JOSUE ALVARES', 60, 'activo', '2026-04-01 12:17:38'),
(3, 'VESTA LOGISTIC SERVICE PROVIDER S.A DE C.V', 'empresa', '05019023478612', '3141-1835', '', '', '', 'FERNANDA GALLARDO', 30, 'activo', '2026-04-01 12:19:08'),
(4, 'CONSTRUCCIONES CERRATO Y ASOCIADOS SRL DE CV', 'empresa', '05019000045593', '', '', '', '', '', 15, 'activo', '2026-04-01 12:19:46'),
(5, 'RCJ LOGISTIC S.A DE C.V', 'empresa', '05029021315488', '', '', '', '', 'LUIS LÓPEZ', 30, 'activo', '2026-04-01 12:20:29'),
(6, 'TRANYCOP', 'empresa', '', '', '', '', '', '', 15, 'activo', '2026-04-01 12:21:31'),
(7, 'TRANSPORTES EMAGRO', 'empresa', '', '', '', '', '', '', 30, 'activo', '2026-04-14 16:30:32'),
(8, 'CEMCOL COMERCIAL S.A. DE C.V.', 'empresa', '05019000046793', '9949-7122', '', '', '', 'ORLIN VARDALES', 15, 'activo', '2026-04-18 11:49:12'),
(9, 'CASA COMERCIAL MATHEWS S.A. DE C.V.', 'empresa', '08019995104551', '9492-4552', '', 'COL. CALPULES KM 5 – CARRETERA A LA LIMA EDIF. CEMCOL AA SAN PEDRO SULA', '', 'JOSUE LOPEZ', 15, 'activo', '2026-06-19 15:55:05'),
(10, 'VASTAGO LOGISTIC SOLUTION S. DE R.L. DE C.V.', 'empresa', '05019014640937', '', '', '', '', '', 8, 'activo', '2026-07-02 14:09:36'),
(11, 'CM INVERSIONES', 'empresa', '05019025133444', '', '', '', '', '', 15, 'activo', '2026-07-22 10:41:42'),
(12, 'DISTRIBUIDORA HECTOR GODOY S. DE R.L. DE C.V', 'empresa', '05069003083477', '', '', '', '', '', 8, 'activo', '2026-07-29 16:30:33'),
(13, 'VALLECILLO', 'empresa', '', '', '', '', '', '', 15, 'activo', '2026-08-20 10:56:41'),
(14, 'VAMER', 'empresa', '05019026315890', '', '', '', '', '', 0, 'activo', '2026-09-28 11:41:00'),
(15, 'BAHIA SHIPPING', 'empresa', '08019004513306', '', '', '', '', '', 0, 'activo', '2026-10-24 11:57:15');

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
  `estado` enum('pendiente','pendiente_aprobacion','aprobada','aprobada_cliente','rechazada','enviada','facturada') DEFAULT 'pendiente',
  `subtotal_materiales` decimal(14,2) NOT NULL DEFAULT 0.00,
  `subtotal_mano_obra` decimal(14,2) NOT NULL DEFAULT 0.00,
  `costo_base` decimal(14,2) NOT NULL DEFAULT 0.00,
  `subtotal_con_soldymeg` decimal(14,2) NOT NULL DEFAULT 0.00 COMMENT '+35% margen SOLDYMEG',
  `subtotal_comercial` decimal(14,2) NOT NULL DEFAULT 0.00 COMMENT '+15% margen comercial',
  `isv` decimal(14,2) NOT NULL DEFAULT 0.00,
  `total` decimal(14,2) NOT NULL DEFAULT 0.00,
  `descuento_porcentaje` decimal(5,2) NOT NULL DEFAULT 0.00,
  `descuento_monto` decimal(12,2) NOT NULL DEFAULT 0.00,
  `total_con_descuento` decimal(12,2) NOT NULL DEFAULT 0.00,
  `observaciones` text DEFAULT NULL,
  `ot_cliente` varchar(50) DEFAULT NULL COMMENT 'Número de OT del cliente (ej: 4007731855)',
  `orden_compra` varchar(50) DEFAULT NULL COMMENT 'Número de Orden de Compra del cliente (ej: 5503905114)',
  `unidad` varchar(30) DEFAULT NULL COMMENT 'Placa o identificador del vehículo/unidad',
  `motivo_rechazo` varchar(300) DEFAULT NULL,
  `elaborado_por` varchar(120) DEFAULT NULL COMMENT 'Nombre empleado que elaboró',
  `telefono_elaborado` varchar(30) DEFAULT NULL COMMENT 'Teléfono del empleado',
  `fecha_creacion` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `cotizaciones`
--

INSERT INTO `cotizaciones` (`id_cotizacion`, `numero_cotizacion`, `cliente_id`, `orden_id`, `usuario_id`, `fecha`, `vigencia_dias`, `modo`, `estado`, `subtotal_materiales`, `subtotal_mano_obra`, `costo_base`, `subtotal_con_soldymeg`, `subtotal_comercial`, `isv`, `total`, `descuento_porcentaje`, `descuento_monto`, `total_con_descuento`, `observaciones`, `ot_cliente`, `orden_compra`, `unidad`, `motivo_rechazo`, `elaborado_por`, `telefono_elaborado`, `fecha_creacion`) VALUES
(1, 'COT-2026-001', 8, NULL, 1, '2026-04-18', 15, 'DIRECTA', 'rechazada', 0.00, 7500.00, 7500.00, 7500.00, 7500.00, 1125.00, 8625.00, 0.00, 0.00, 0.00, 'INCLUYE MANO DE OBRA Y MATERIALES', NULL, NULL, 'TEA3565 ', 'EL CLIENTE SOLICITO UN DESCUENTO Y FUE NECESARIO HACERLE UNA NUEVA COTIZACION.', NULL, NULL, '2026-04-18 11:51:16'),
(2, 'COT-2026-002', 8, NULL, 1, '2026-04-18', 15, 'DIRECTA', 'facturada', 0.00, 8181.95, 8181.95, 8181.95, 8181.95, 1227.29, 9409.24, 0.00, 0.00, 0.00, '', NULL, 'OC00000171', 'HAE7990 ', NULL, NULL, NULL, '2026-04-18 11:53:24'),
(3, 'COT-2026-003', 8, NULL, 1, '2026-04-18', 15, 'DIRECTA', 'enviada', 0.00, 6000.00, 6000.00, 6000.00, 6000.00, 900.00, 6900.00, 0.00, 0.00, 0.00, '', NULL, 'OC00000651', 'F-329 ', NULL, NULL, NULL, '2026-04-18 11:53:58'),
(4, 'COT-2026-004', 8, NULL, 1, '2026-04-18', 15, 'DIRECTA', 'rechazada', 0.00, 141552.90, 141552.90, 141552.90, 141552.90, 21232.94, 162785.84, 0.00, 0.00, 0.00, 'INCLUYE MANO DE OBRA Y MATERIALES', NULL, NULL, 'TRC8861', 'EL CLIENTE PIDIO REBAJA SE LE ENVIO NUEVA COTIZACION COT-05', NULL, NULL, '2026-04-18 11:54:45'),
(5, 'COT-2026-005', 8, NULL, 1, '2026-04-24', 15, 'DIRECTA', 'facturada', 0.00, 134475.26, 134475.26, 134475.26, 134475.26, 20171.29, 154646.55, 0.00, 0.00, 0.00, '', NULL, '0A056950SP', 'TRC8861', NULL, NULL, NULL, '2026-04-24 08:02:13'),
(6, 'COT-2026-006', 8, NULL, 4, '2026-06-05', 15, 'DIRECTA', 'facturada', 0.00, 6975.00, 6975.00, 6975.00, 6975.00, 1046.25, 8021.25, 0.00, 0.00, 0.00, '', NULL, '0A056949SP', 'TEA3565', NULL, 'SANTOS ARITA', '96271914', '2026-06-05 17:05:33'),
(7, 'COT-2026-007', 8, NULL, 4, '2026-06-10', 15, 'DIRECTA', 'rechazada', 0.00, 26000.00, 26000.00, 26000.00, 26000.00, 3900.00, 29900.00, 0.00, 0.00, 0.00, '', NULL, NULL, 'TRC8861', 'EL CLIENTE PIDIO UN DESCUENTO APLICADO A LA PRIMERA COTIZACION.', 'SANTOS ARITA', '96271914', '2026-06-10 08:58:07'),
(8, 'COT-2026-008', 8, NULL, 4, '2026-06-11', 15, 'DIRECTA', 'facturada', 24700.00, 0.00, 24700.00, 24700.00, 24700.00, 3705.00, 28405.00, 0.00, 1300.00, 28405.00, '', NULL, 'OC00000149', 'TRC8861', NULL, 'SANTOS ARITA', '96271914', '2026-06-11 10:45:22'),
(9, 'COT-2026-009', 8, NULL, 6, '2026-06-17', 15, 'DIRECTA', 'rechazada', 80017.40, 0.00, 80017.40, 80017.40, 80017.40, 12002.61, 92020.01, 0.00, 0.00, 0.00, '1. Tiempo de 2 semanas para finalizar el tabajo 2. El tiempo de garantia es de 90 dias ', NULL, NULL, 'D-54', 'EL CLIENTE PIDIO REBAJA SE LE ENVIO NUEVA COTIZACION CON 5% DE REBAJA', 'ELBIN ARITA', '9596-9903', '2026-06-17 15:57:45'),
(10, 'COT-2026-010', 8, NULL, 6, '2026-06-19', 15, 'DIRECTA', 'facturada', 0.00, 76016.53, 76016.53, 76016.53, 76016.53, 11402.48, 87419.01, 0.00, 0.00, 87419.01, '', NULL, 'OC00000161', 'D-54', NULL, 'ELBIN ARITA', '9596-9903', '2026-06-19 11:49:43'),
(11, 'COT-2026-011', 9, NULL, 6, '2026-07-02', 15, 'DIRECTA', 'facturada', 0.00, 50247.00, 50247.00, 50247.00, 50247.00, 7537.05, 57784.05, 0.00, 0.00, 57784.05, '', NULL, 'OC00000128', '320DL', NULL, 'ELBIN ARITA', '9596-9903', '2026-07-02 15:14:03'),
(12, 'COT-2026-012', 8, NULL, 6, '2026-07-02', 15, 'DIRECTA', 'enviada', 0.00, 113106.91, 113106.91, 113106.91, 113106.91, 16966.04, 130072.95, 0.00, 0.00, 130072.95, '1. TIEMPO DE 8 DIAS PARA FINALIZAR EL TABAJO 2. EL TIEMPO DE GARANTIA ES DE 90 DIAS  3. NO INCLUYE LOS SISTEMAS HIDRAULICO Y ELECTRICO', NULL, NULL, 'VW', NULL, 'ELBIN ARITA', '9596-9903', '2026-07-02 15:18:36'),
(13, 'COT-2026-013', 8, NULL, 6, '2026-07-02', 15, 'DIRECTA', 'enviada', 0.00, 129171.91, 129171.91, 129171.91, 129171.91, 19375.79, 148547.70, 0.00, 0.00, 148547.70, '1. TIEMPO DE 8 DIAS PARA FINALIZAR EL TABAJO 2. EL TIEMPO DE GARANTIA ES DE 90 DIAS  3. NO INCLUYE LOS SISTEMAS HIDRAULICO Y ELECTRICO', NULL, NULL, 'IH', NULL, 'ELBIN ARITA', '9596-9903', '2026-07-02 15:20:43'),
(14, 'COT-2026-014', 8, NULL, 6, '2026-07-02', 15, 'DIRECTA', 'rechazada', 0.00, 14000.00, 14000.00, 14000.00, 14000.00, 2100.00, 16100.00, 0.00, 0.00, 16100.00, '1. TIEMPO DE 8 DIAS PARA FINALIZAR EL TABAJO 2. EL TIEMPO DE GARANTIA ES DE 90 DIAS', NULL, NULL, 'F-1907', 'EL CLIENTE PIDIO REBAJA SE HIZO NUEVA COTIZACION', 'ELBIN ARITA', '9596-9903', '2026-07-02 15:22:14'),
(15, 'COT-2026-015', 8, NULL, 6, '2026-07-06', 15, 'DIRECTA', 'facturada', 0.00, 13300.00, 13300.00, 13300.00, 13300.00, 1995.00, 15295.00, 0.00, 0.00, 15295.00, '', NULL, 'OC00000239', 'F-1907', NULL, 'ELBIN ARITA', '9596-9903', '2026-07-06 09:25:39'),
(16, 'COT-2026-016', 8, NULL, 6, '2026-07-07', 15, 'DIRECTA', 'enviada', 0.00, 52300.00, 52300.00, 52300.00, 52300.00, 7845.00, 60145.00, 0.00, 0.00, 60145.00, '', NULL, NULL, 'TEA3899', NULL, 'ELBIN ARITA', '9596-9903', '2026-07-07 15:54:03'),
(17, 'COT-2026-017', 8, NULL, 6, '2026-07-07', 15, 'DIRECTA', 'enviada', 0.00, 60300.00, 60300.00, 60300.00, 60300.00, 9045.00, 69345.00, 0.00, 0.00, 69345.00, '', NULL, NULL, 'TEA3899', NULL, 'ELBIN ARITA', '9596-9903', '2026-07-07 15:55:07'),
(18, 'COT-2026-018', 12, NULL, 6, '2026-07-29', 15, 'DIRECTA', 'rechazada', 0.00, 26500.00, 26500.00, 26500.00, 26500.00, 3975.00, 30475.00, 0.00, 0.00, 30475.00, '', NULL, NULL, 'TRC4601', 'CLIENTE PIDIO ACTUALIZAR EL PRECIO', 'ELBIN ARITA', '9596-9903', '2026-07-29 16:34:50'),
(19, 'COT-2026-019', 3, NULL, 6, '2026-07-29', 15, 'DIRECTA', 'enviada', 0.00, 60371.50, 60371.50, 60371.50, 60371.50, 9055.73, 69427.23, 0.00, 0.00, 69427.23, '', NULL, NULL, 'CONT.6464', NULL, 'ELBIN ARITA', '9596-9903', '2026-07-29 16:46:58'),
(20, 'COT-2026-020', 3, NULL, 6, '2026-07-30', 15, 'DIRECTA', 'enviada', 30984.48, 28000.00, 58984.48, 58984.48, 58984.48, 8847.67, 67832.15, 0.00, 0.00, 67832.15, '', NULL, NULL, 'CONT.6464', NULL, 'ELBIN ARITA', '9596-9903', '2026-07-30 07:37:10'),
(21, 'COT-2026-021', 3, NULL, 6, '2026-07-30', 15, 'DIRECTA', 'enviada', 0.00, 25596.90, 25596.90, 25596.90, 25596.90, 3839.54, 29436.44, 0.00, 0.00, 29436.44, '', NULL, NULL, 'CONT.2377', NULL, 'ELBIN ARITA', '9596-9903', '2026-07-30 07:40:44'),
(22, 'COT-2026-022', 3, NULL, 6, '2026-07-30', 15, 'DIRECTA', 'enviada', 18948.00, 12000.00, 30948.00, 30948.00, 30948.00, 4642.20, 35590.20, 0.00, 0.00, 35590.20, '', NULL, NULL, 'CONT.8259', NULL, 'ELBIN ARITA', '9596-9903', '2026-07-30 07:44:21'),
(23, 'COT-2026-023', 3, NULL, 6, '2026-07-30', 15, 'DIRECTA', 'rechazada', 0.00, 16350.00, 16350.00, 16350.00, 16350.00, 2452.50, 18802.50, 0.00, 0.00, 18802.50, '', NULL, NULL, 'TRA0811', 'EL CLIENTE PIDIO REBAJA', 'ELBIN ARITA', '9596-9903', '2026-07-30 07:46:08'),
(24, 'COT-2026-024', 4, NULL, 6, '2026-07-30', 15, 'DIRECTA', 'enviada', 0.00, 7000.00, 7000.00, 7000.00, 7000.00, 1050.00, 8050.00, 0.00, 0.00, 8050.00, '', NULL, NULL, 'N/A', NULL, 'ELBIN ARITA', '9596-9903', '2026-07-30 07:47:29'),
(25, 'COT-2026-025', 3, NULL, 6, '2026-08-03', 15, 'DIRECTA', 'facturada', 0.00, 8000.00, 8000.00, 8000.00, 8000.00, 1200.00, 9200.00, 0.00, 0.00, 9200.00, '', NULL, NULL, 'TRB3713', NULL, 'ELBIN ARITA', '9596-9903', '2026-08-03 10:30:15'),
(26, 'COT-2026-026', 3, NULL, 6, '2026-08-03', 15, 'DIRECTA', 'facturada', 0.00, 15500.00, 15500.00, 15500.00, 15500.00, 2325.00, 17825.00, 0.00, 0.00, 17825.00, '', NULL, NULL, '2795', NULL, 'ELBIN ARITA', '9596-9903', '2026-08-03 10:31:52'),
(27, 'COT-2026-027', 3, NULL, 6, '2026-08-03', 15, 'DIRECTA', 'facturada', 0.00, 17450.00, 17450.00, 17450.00, 17450.00, 2617.50, 20067.50, 0.00, 0.00, 20067.50, '', NULL, NULL, '2718', NULL, 'ELBIN ARITA', '9596-9903', '2026-08-03 10:33:08'),
(28, 'COT-2026-028', 3, NULL, 6, '2026-08-03', 15, 'DIRECTA', 'facturada', 0.00, 2800.00, 2800.00, 2800.00, 2800.00, 420.00, 3220.00, 0.00, 0.00, 3220.00, '', NULL, NULL, '0966', NULL, 'ELBIN ARITA', '9596-9903', '2026-08-03 10:34:14'),
(29, 'COT-2026-029', 8, NULL, 6, '2026-08-20', 15, 'DIRECTA', 'rechazada', 0.00, 105609.00, 105609.00, 105609.00, 105609.00, 15841.35, 121450.35, 0.00, 0.00, 121450.35, 'TIEMPO ESTIMADO PARA REALIZAR EL TRABAJO 8 DIAS HABILES.', NULL, NULL, '320GC', 'EL CLIENTE PIDIO DESCUENTO SE LE ENVIO NUEVA COTIZACION', 'ELBIN ARITA', '9596-9903', '2026-08-20 10:53:03'),
(30, 'COT-2026-030', 8, NULL, 6, '2026-08-20', 15, 'DIRECTA', 'enviada', 0.00, 98216.37, 98216.37, 98216.37, 98216.37, 14732.46, 112948.83, 0.00, 0.00, 112948.83, '', NULL, NULL, '320GC', NULL, 'ELBIN ARITA', '9596-9903', '2026-08-20 10:55:01'),
(31, 'COT-2026-031', 3, NULL, 6, '2026-08-20', 15, 'DIRECTA', 'facturada', 0.00, 25650.00, 25650.00, 25650.00, 25650.00, 3847.50, 29497.50, 0.00, 0.00, 29497.50, '', NULL, NULL, 'CONT. 8253', NULL, 'ELBIN ARITA', '9596-9903', '2026-08-20 11:00:36'),
(32, 'COT-2026-032', 3, NULL, 6, '2026-08-20', 15, 'DIRECTA', 'facturada', 0.00, 19700.00, 19700.00, 19700.00, 19700.00, 2955.00, 22655.00, 0.00, 0.00, 22655.00, '', NULL, NULL, 'CONT. 2823', NULL, 'ELBIN ARITA', '9596-9903', '2026-08-20 11:02:09'),
(33, 'COT-2026-033', 3, NULL, 6, '2026-08-20', 15, 'DIRECTA', 'facturada', 0.00, 29000.00, 29000.00, 29000.00, 29000.00, 4350.00, 33350.00, 0.00, 0.00, 33350.00, '', NULL, NULL, 'CONT. 9927', NULL, 'ELBIN ARITA', '9596-9903', '2026-08-20 11:05:58'),
(34, 'COT-2026-034', 13, NULL, 6, '2026-08-20', 15, 'DIRECTA', 'enviada', 0.00, 160000.00, 160000.00, 160000.00, 160000.00, 24000.00, 184000.00, 0.00, 0.00, 184000.00, '', NULL, NULL, NULL, NULL, 'ELBIN ARITA', '9596-9903', '2026-08-20 11:25:02'),
(35, 'COT-2026-035', 8, NULL, 6, '2026-09-01', 15, 'DIRECTA', 'enviada', 0.00, 9450.00, 9450.00, 9450.00, 9450.00, 1417.50, 10867.50, 0.00, 0.00, 10867.50, '', NULL, NULL, 'ESTANTE', NULL, 'ELBIN ARITA', '9596-9903', '2026-09-01 09:22:43'),
(36, 'COT-2026-036', 8, NULL, 6, '2026-09-01', 15, 'DIRECTA', 'facturada', 0.00, 10435.00, 10435.00, 10435.00, 10435.00, 1565.25, 12000.25, 0.00, 0.00, 12000.25, '', 'R232609', 'OC00000590', 'R23', NULL, 'ELBIN ARITA', '9596-9903', '2026-09-01 09:25:12'),
(37, 'COT-2026-037', 8, NULL, 6, '2026-09-01', 15, 'DIRECTA', 'enviada', 0.00, 9000.00, 9000.00, 9000.00, 9000.00, 1350.00, 10350.00, 0.00, 0.00, 10350.00, '', NULL, NULL, 'R19', NULL, 'ELBIN ARITA', '9596-9903', '2026-09-01 09:26:12'),
(38, 'COT-2026-038', 3, NULL, 6, '2026-09-01', 15, 'DIRECTA', 'facturada', 0.00, 7000.00, 7000.00, 7000.00, 7000.00, 1050.00, 8050.00, 0.00, 0.00, 8050.00, '', NULL, NULL, 'CONT.8621', NULL, 'ELBIN ARITA', '9596-9903', '2026-09-01 09:27:34'),
(39, 'COT-2026-039', 8, NULL, 6, '2026-09-01', 15, 'DIRECTA', 'enviada', 0.00, 83478.26, 83478.26, 83478.26, 83478.26, 12521.74, 96000.00, 0.00, 0.00, 96000.00, '', NULL, NULL, 'RETRO.349', NULL, 'ELBIN ARITA', '9596-9903', '2026-09-01 09:28:39'),
(40, 'COT-2026-040', 8, NULL, 6, '2026-09-09', 15, 'DIRECTA', 'rechazada', 0.00, 15000.00, 15000.00, 15000.00, 15000.00, 2250.00, 17250.00, 0.00, 0.00, 17250.00, '', NULL, NULL, NULL, 'EL CLIENTE PIDIO REBAJA', 'ELBIN ARITA', '9596-9903', '2026-09-09 11:18:04'),
(41, 'COT-2026-041', 8, NULL, 6, '2026-09-09', 15, 'DIRECTA', 'enviada', 0.00, 28500.00, 28500.00, 28500.00, 28500.00, 4275.00, 32775.00, 0.00, 0.00, 32775.00, '', NULL, NULL, NULL, NULL, 'ELBIN ARITA', '9596-9903', '2026-09-09 11:28:48'),
(42, 'COT-2026-042', 12, NULL, 6, '2026-09-09', 15, 'DIRECTA', 'facturada', 0.00, 30077.50, 30077.50, 30077.50, 30077.50, 4511.63, 34589.13, 0.00, 0.00, 34589.13, '', NULL, NULL, 'TRC4601', NULL, 'ELBIN ARITA', '9596-9903', '2026-09-09 11:31:49'),
(43, 'COT-2026-043', 3, NULL, 6, '2026-09-09', 15, 'DIRECTA', 'facturada', 0.00, 14715.00, 14715.00, 14715.00, 14715.00, 2207.25, 16922.25, 0.00, 0.00, 16922.25, '', NULL, NULL, 'TRA0811', NULL, 'ELBIN ARITA', '9596-9903', '2026-09-09 11:59:49'),
(44, 'COT-2026-044', 8, NULL, 6, '2026-09-18', 15, 'DIRECTA', 'rechazada', 52000.00, 0.00, 52000.00, 52000.00, 52000.00, 7800.00, 59800.00, 0.00, 0.00, 59800.00, '', NULL, NULL, 'PISTON GRUA', 'CLIENTE PIDIO REBAJA', 'ELBIN ARITA', '9596-9903', '2026-09-18 12:39:02'),
(45, 'COT-2026-045', 8, NULL, 6, '2026-09-18', 15, 'DIRECTA', 'rechazada', 0.00, 18900.00, 18900.00, 18900.00, 18900.00, 2835.00, 21735.00, 0.00, 0.00, 21735.00, '', NULL, NULL, 'PISTON AZUL', 'EL CLIENTE PIDIO REBAJA', 'ELBIN ARITA', '9596-9903', '2026-09-18 12:40:53'),
(46, 'COT-2026-046', 8, NULL, 6, '2026-09-18', 15, 'DIRECTA', 'facturada', 0.00, 49400.00, 49400.00, 49400.00, 49400.00, 7410.00, 56810.00, 0.00, 0.00, 56810.00, '', NULL, NULL, 'PISTON GRUA', NULL, 'ELBIN ARITA', '9596-9903', '2026-09-18 12:44:04'),
(47, 'COT-2026-047', 8, NULL, 6, '2026-09-18', 15, 'DIRECTA', 'enviada', 0.00, 17955.00, 17955.00, 17955.00, 17955.00, 2693.25, 20648.25, 0.00, 0.00, 20648.25, '', NULL, NULL, 'PISTON AZUL', NULL, 'ELBIN ARITA', '9596-9903', '2026-09-18 12:45:58'),
(48, 'COT-2026-048', 8, NULL, 6, '2026-09-18', 15, 'DIRECTA', 'enviada', 0.00, 22000.00, 22000.00, 22000.00, 22000.00, 3300.00, 25300.00, 0.00, 0.00, 25300.00, '', NULL, NULL, 'EXIBIDOR', NULL, 'ELBIN ARITA', '9596-9903', '2026-09-18 12:46:55'),
(49, 'COT-2026-049', 8, NULL, 6, '2026-09-23', 15, 'DIRECTA', 'rechazada', 0.00, 54000.00, 54000.00, 54000.00, 54000.00, 8100.00, 62100.00, 0.00, 0.00, 62100.00, '', NULL, NULL, 'N/A', 'EL CLIENTE PIDIO REBAJA', 'ELBIN ARITA', '9596-9903', '2026-09-23 14:08:02'),
(50, 'COT-2026-050', 8, NULL, 6, '2026-09-23', 15, 'DIRECTA', 'rechazada', 0.00, 33000.00, 33000.00, 33000.00, 33000.00, 4950.00, 37950.00, 0.00, 0.00, 37950.00, '', NULL, NULL, 'N/A', 'EL CLIENTE PIDIO REBAJA', 'ELBIN ARITA', '9596-9903', '2026-09-23 14:08:48'),
(51, 'COT-2026-051', 8, NULL, 6, '2026-09-23', 15, 'DIRECTA', 'enviada', 0.00, 52920.00, 52920.00, 52920.00, 52920.00, 7938.00, 60858.00, 0.00, 0.00, 60858.00, '', NULL, NULL, 'N/A', NULL, 'ELBIN ARITA', '9596-9903', '2026-09-23 14:09:40'),
(52, 'COT-2026-052', 8, NULL, 6, '2026-09-23', 15, 'DIRECTA', 'enviada', 0.00, 32340.00, 32340.00, 32340.00, 32340.00, 4851.00, 37191.00, 0.00, 0.00, 37191.00, '', NULL, NULL, 'N/A', NULL, 'ELBIN ARITA', '9596-9903', '2026-09-23 14:10:25'),
(53, 'COT-2026-053', 3, NULL, 6, '2026-09-23', 15, 'DIRECTA', 'facturada', 0.00, 2877.90, 2877.90, 2877.90, 2877.90, 431.69, 3309.59, 0.00, 0.00, 3309.59, '', NULL, NULL, 'N/A', NULL, 'ELBIN ARITA', '9596-9903', '2026-09-23 14:12:55'),
(54, 'COT-2026-054', 8, NULL, 6, '2026-09-29', 15, 'DIRECTA', 'enviada', 0.00, 25000.00, 25000.00, 25000.00, 25000.00, 3750.00, 28750.00, 0.00, 0.00, 28750.00, '', NULL, NULL, 'CAMION', NULL, 'ELBIN ARITA', '9596-9903', '2026-09-29 17:03:55'),
(55, 'COT-2026-055', 7, NULL, 6, '2026-09-29', 15, 'DIRECTA', 'enviada', 0.00, 230000.00, 230000.00, 230000.00, 230000.00, 34500.00, 264500.00, 0.00, 0.00, 264500.00, 'NO INCLUYE TORNILLOS, COMPONENTES  DE SISTEMA DE  AIRE, SISTEMA DE HIDRAULICO,  ALARGARMIENTO DE CARDAN, SUMINISTROS ELECTRICOS, CHASIS Y PUENTES.', NULL, NULL, 'MULITA', NULL, 'ELBIN ARITA', '9596-9903', '2026-09-29 17:05:47'),
(56, 'COT-2026-056', 7, NULL, 6, '2026-09-29', 15, 'DIRECTA', 'enviada', 0.00, 80000.00, 80000.00, 80000.00, 80000.00, 12000.00, 92000.00, 0.00, 0.00, 92000.00, 'NO INLCUYE CHUMACERAS, Y OTROS MATERIALES DE SER REQUERIDOS', NULL, NULL, 'TANQUE', NULL, 'ELBIN ARITA', '9596-9903', '2026-09-29 17:07:08'),
(57, 'COT-2026-057', 7, NULL, 6, '2026-09-29', 15, 'DIRECTA', 'enviada', 0.00, 480000.00, 480000.00, 480000.00, 480000.00, 72000.00, 552000.00, 0.00, 0.00, 552000.00, 'NO INCLUYE MATERIALES, SPROCEKT, SISTEMA HIDRAULICO,CHUMACERAS, CADENA DE GIRO, TOMA  FUERZA, TORNILLERIA Y REMACHES.', NULL, NULL, 'FABRICAR TANQUE', NULL, 'ELBIN ARITA', '9596-9903', '2026-09-29 17:08:21'),
(58, 'COT-2026-058', 3, NULL, 6, '2026-09-29', 15, 'DIRECTA', 'facturada', 0.00, 26000.00, 26000.00, 26000.00, 26000.00, 3900.00, 29900.00, 0.00, 0.00, 29900.00, '', NULL, NULL, 'V5103', NULL, 'ELBIN ARITA', '9596-9903', '2026-09-29 17:10:57'),
(59, 'COT-2026-059', 7, NULL, 6, '2026-09-29', 15, 'DIRECTA', 'enviada', 0.00, 70000.00, 70000.00, 70000.00, 70000.00, 10500.00, 80500.00, 0.00, 0.00, 80500.00, '', NULL, NULL, 'CHASIS CAMION', NULL, 'ELBIN ARITA', '9596-9903', '2026-09-29 17:12:21');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `departamentos`
--

CREATE TABLE `departamentos` (
  `id_departamento` int(10) UNSIGNED NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `estado` enum('activo','inactivo') NOT NULL DEFAULT 'activo',
  `fecha_creacion` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `departamentos`
--

INSERT INTO `departamentos` (`id_departamento`, `nombre`, `descripcion`, `estado`, `fecha_creacion`) VALUES
(1, 'TALLER', NULL, 'activo', '2026-06-06 09:24:04'),
(2, 'COMPRAS', NULL, 'activo', '2026-06-06 09:24:04'),
(3, 'CONTABILIDAD', NULL, 'activo', '2026-06-06 09:24:04'),
(4, 'RRHH', NULL, 'activo', '2026-06-06 09:24:04'),
(5, 'ALMACEN', NULL, 'activo', '2026-06-06 09:24:04'),
(6, 'ADMINISTRACION', NULL, 'activo', '2026-06-06 09:24:04'),
(7, 'MANTENIMINETO', NULL, 'activo', '2026-06-06 09:24:04'),
(8, 'SERVICIOS GENERALES', NULL, 'activo', '2026-06-06 09:24:04');

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
  `subtotal_final` decimal(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Con márgenes + ISV',
  `descuento_porcentaje` decimal(5,2) NOT NULL DEFAULT 0.00,
  `descuento_monto` decimal(12,2) NOT NULL DEFAULT 0.00,
  `subtotal_con_descuento` decimal(12,2) NOT NULL DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `detalle_cotizacion`
--

INSERT INTO `detalle_cotizacion` (`id_detalle_cot`, `cotizacion_id`, `tipo`, `descripcion`, `cantidad`, `precio_unitario`, `subtotal_base`, `subtotal_final`, `descuento_porcentaje`, `descuento_monto`, `subtotal_con_descuento`) VALUES
(1, 1, 'mano_obra', 'FABRICADO E INSTALADO BASE DE PISTON DE PLATAFORMA', 1.00, 7500.00, 7500.00, 7500.00, 0.00, 0.00, 0.00),
(2, 2, 'mano_obra', 'FABRICADO E INSTALADO DE COMPUERTA DE PICKUP', 1.00, 8181.95, 8181.95, 8181.95, 0.00, 0.00, 0.00),
(3, 3, 'mano_obra', 'DESMONTAJE DE CARROCERIA, MANTENIMIENTO E INSTALACION EN OTRO VEHICULO', 1.00, 6000.00, 6000.00, 6000.00, 0.00, 0.00, 0.00),
(4, 4, 'mano_obra', 'REPARACION DE PLATAFORMA LONBOY INCLUYE MANO DE OBRA Y MATERIALES', 1.00, 141552.90, 141552.90, 141552.90, 0.00, 0.00, 0.00),
(5, 5, 'mano_obra', 'REPARACION DE PLATAFORMA LONBOY INCLUYE MANO DE  OBRA Y MATERIALES', 1.00, 134475.26, 134475.26, 134475.26, 0.00, 0.00, 0.00),
(6, 6, 'mano_obra', 'FABRICADO E INSTALADO BASE DE PISTON DE PLATAFORMA', 1.00, 6975.00, 6975.00, 6975.00, 0.00, 0.00, 0.00),
(7, 7, 'mano_obra', 'PINTURA GENERAL EXTERNA DE PLATAFORMA LOMBOY', 1.00, 26000.00, 26000.00, 26000.00, 0.00, 0.00, 0.00),
(8, 8, 'mano_obra', 'PINTURA GENERAL EXTERNA PLATAFORMA DE LOMBOY', 1.00, 26000.00, 26000.00, 26000.00, 5.00, 1300.00, 24700.00),
(9, 9, 'mano_obra', 'REPARACION DE PLATAFORMA INCLUYE MANO DE OBRA Y MATERIALES', 1.00, 80017.40, 80017.40, 80017.40, 0.00, 0.00, 0.00),
(10, 9, 'mano_obra', 'SUMINISTRO E INSTALACION DE MADERA', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(11, 9, 'mano_obra', 'REPARACION DE BASE DE PISTONES', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(12, 9, 'mano_obra', 'FABRICADO DE GUIAS DE PLATAFORMA FRONTAL', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(13, 9, 'mano_obra', 'REPARACION DE DEFENSA FRONTAL', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(14, 9, 'mano_obra', 'FABRICACION DE PORTALLANTA', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(15, 9, 'mano_obra', 'ENGRASE GENERAL', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(16, 9, 'mano_obra', 'PINTURA GENERAL', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(17, 10, 'mano_obra', 'REPARACION DE PLATAFORMA INCLUYE MANO DE OBRA Y MATERIALES', 1.00, 76016.53, 76016.53, 76016.53, 0.00, 0.00, 76016.53),
(18, 10, 'mano_obra', 'SUMINISTRO E INSTALACION DE MADERA', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(19, 10, 'mano_obra', 'REPARACION DE BASE DE PISTONES', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(20, 10, 'mano_obra', 'FABRICADO DE GUIAS DE PLATAFORMA FRONTAL', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(21, 10, 'mano_obra', 'REPARACION DE DEFENSA FRONTAL', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(22, 10, 'mano_obra', 'FABRICACION DE PORTALLANTA', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(23, 10, 'mano_obra', 'ENGRASE GENERAL', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(24, 10, 'mano_obra', 'PINTURA GENERAL', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(27, 11, 'mano_obra', 'REPARACION DE STICK DE 320DL', 1.00, 50247.00, 50247.00, 50247.00, 0.00, 0.00, 50247.00),
(28, 12, 'mano_obra', 'INSTALCION DE COMPACTADORA DE 18 Y 20 YDS EN CAMION  VW', 1.00, 113106.91, 113106.91, 113106.91, 0.00, 0.00, 113106.91),
(29, 12, 'mano_obra', 'MODICACION DE PUENTES Y SUSPENSIÓN', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(30, 12, 'mano_obra', 'MODIFICACION DE SUSPENSIÓN ADAPTAR HOJAS DE  RESORTE', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(31, 12, 'mano_obra', 'PERFORACION DE CHASIS', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(32, 13, 'mano_obra', 'INSTALCION DE COMPACTADORA DE 25 YDS EN CAMION IH', 1.00, 129171.91, 129171.91, 129171.91, 0.00, 0.00, 129171.91),
(33, 13, 'mano_obra', 'MODICACION DE PUENTES Y SUSPENSIÓN', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(34, 13, 'mano_obra', 'MODIFICACION DE SUSPENSIÓN DE TANDY', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(35, 13, 'mano_obra', 'PERFORACION DE CHASIS', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(36, 14, 'mano_obra', 'RECONSTRUCCION DE CHASIS Y REFORZADO CON LAMINA DE  HIERRO DE 1/4 Y PLACA DE 5/16,INSTALACION DE REMOLQUE Y  PINTURA', 1.00, 14000.00, 14000.00, 14000.00, 0.00, 0.00, 14000.00),
(37, 15, 'mano_obra', 'RECONSTRUCCION DE CHASIS Y REFORZADO CON LAMINA DE  HIERRO DE 1/4 Y PLACA DE 5/16,INSTALACION DE REMOLQUE Y  PINTURA', 1.00, 13300.00, 13300.00, 13300.00, 0.00, 0.00, 13300.00),
(38, 16, 'mano_obra', 'MANTENIMIENTO Y REPARACION DE UNIDAD', 1.00, 52300.00, 52300.00, 52300.00, 0.00, 0.00, 52300.00),
(39, 16, 'mano_obra', 'REPARACION DE COMPUERTA, REPARACION DE FILTRACION DE AGUA EN TECHO', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(40, 16, 'mano_obra', 'CAMBIAR MADERA DE PISO, FABRICACION DE BASE DE RETOVISOR, INSTALACION DE CABLEADO ELECTRICO', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(41, 16, 'mano_obra', 'SUMINISTRO DE MATERIALES', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(42, 17, 'mano_obra', 'MANTENIMIENTO Y REPARACION DE UNIDAD', 1.00, 60300.00, 60300.00, 60300.00, 0.00, 0.00, 60300.00),
(43, 17, 'mano_obra', 'FABRICACION DE COMPUERTA, REPARACION DE FILTRACION DE AGUA EN TECHO', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(44, 17, 'mano_obra', 'CAMBIAR MADERA DE PISO, FABRICACION DE BASE DE RETOVISOR, INSTALACION DE CABLEADO ELECTRICO', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(45, 17, 'mano_obra', 'SUMINISTRO DE MATERIALES', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(46, 18, 'mano_obra', 'REPARACION DE CONTENEDOR INCLUYE', 1.00, 26500.00, 26500.00, 26500.00, 0.00, 0.00, 26500.00),
(47, 18, 'mano_obra', 'CAMBIO DE PERFIL', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(48, 18, 'mano_obra', 'CAMBIO DE LAMINA', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(49, 18, 'mano_obra', 'FABRICADO DE DEFENSA', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(50, 18, 'mano_obra', 'REMACHADO DE LAMINAS INTERNAS', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(51, 18, 'mano_obra', 'TORNILLERIA', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(52, 19, 'mano_obra', 'MANO DE OBRA', 1.00, 22000.00, 22000.00, 22000.00, 0.00, 0.00, 22000.00),
(53, 19, 'mano_obra', 'INSTALACIO DE 6 CHANELES', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(54, 19, 'mano_obra', 'REPARACION DE PERFIL INFERIOR', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(55, 19, 'mano_obra', 'CAMBIO DE MADERA  DE PISO', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(56, 19, 'mano_obra', 'FABRICACION DE BASES DE PATAS E INSTALACION DE PATAS', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(57, 19, 'material', 'SUMINISTRO DE MATERIALES', 1.00, 38371.50, 38371.50, 38371.50, 0.00, 0.00, 38371.50),
(58, 19, 'material', 'LAMINA NEGRA 4X8 X 1/4', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(59, 19, 'material', 'CHANELES DE 4X2X20', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(60, 19, 'material', 'MADERA 10X8', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(61, 19, 'material', 'TORNILLOS DE PISO', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(62, 19, 'material', 'TORNILLOS DE 3/8 PARA CHANELES', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(63, 19, 'material', 'TORNILLOS DE BASES DE PATAS 5/8X1.1/2', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(64, 19, 'material', 'BROCAS DE 3/8', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(65, 19, 'material', 'BROCAS DE 3/4', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(66, 19, 'material', 'BROCAS DE 1/2', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(67, 19, 'material', 'BROCAS DE 5/8', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(68, 19, 'material', 'BROCAS 9/32', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(69, 19, 'material', 'PINTURA NEGRA', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(70, 19, 'material', 'THINNER', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(71, 19, 'material', 'CILICON GRIS', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(72, 20, 'mano_obra', 'MANO DE OBRA', 1.00, 28000.00, 28000.00, 28000.00, 0.00, 0.00, 28000.00),
(73, 20, 'mano_obra', 'FABRICACION DE TORNAMESA', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(74, 20, 'material', 'SUMINISTRO DE MATERIALES', 1.00, 30984.48, 30984.48, 30984.48, 0.00, 0.00, 30984.48),
(75, 20, 'material', 'LAMINA NEGRA 4X8 X 1/8', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(76, 20, 'material', 'LAMINA NEGRA 4X8 X 1/4', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(77, 20, 'material', 'LAMINA NEGRA 4X8 X 3/8', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(78, 20, 'material', 'KIN PIN', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(79, 20, 'material', 'PLATINA DE 1/4 X 4  6MTS', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(80, 20, 'material', 'TORNILLOS PARA TORNAMESA 3/8X1.1/2', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(81, 20, 'material', 'ELECTRODO 60/11', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(82, 20, 'material', 'ELECTRODO 70/18', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(83, 20, 'material', 'REMACHES', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(84, 21, 'mano_obra', 'MANO DE OBRA', 1.00, 9000.00, 9000.00, 9000.00, 0.00, 0.00, 9000.00),
(85, 21, 'mano_obra', 'INSTALACION DE DOS LAMINAS PREPINTADAS', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(86, 21, 'mano_obra', 'INSTALACION DE TRES PARALES', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(87, 21, 'mano_obra', 'INSTALACION DE PATA', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(88, 21, 'mano_obra', 'SUMINISTRO DE MATERIALES', 1.00, 16596.90, 16596.90, 16596.90, 0.00, 0.00, 16596.90),
(89, 21, 'mano_obra', 'SUMINISTRO DE LAMINA DE PLYWOOD DE 1/4', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(90, 21, 'mano_obra', 'SUMNISTRO DE CAJA DE REMACHES', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(91, 21, 'mano_obra', 'SUMINISTRO DE MANINA PREPINTADA', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(92, 21, 'mano_obra', 'SUMINISTRO DE PARALES', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(93, 21, 'mano_obra', 'SUMINISTRO  DE PATA', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(94, 22, 'mano_obra', 'MANO DE OBRA', 1.00, 12000.00, 12000.00, 12000.00, 0.00, 0.00, 12000.00),
(95, 22, 'mano_obra', 'INSTALACION DE LAMINA PREPINTADA', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(96, 22, 'mano_obra', 'INSTALACION DE PARAL DE CONTRAMARCO', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(97, 22, 'mano_obra', 'INSTALACION DE PARALES', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(98, 22, 'mano_obra', 'INSTALACION DE LAMINA PLYWOOD', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(99, 22, 'mano_obra', 'INSTALACION DE HANGUER DELANTERO', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(100, 22, 'material', 'SUMINISTRO DE MATERIALES', 1.00, 18948.00, 18948.00, 18948.00, 0.00, 0.00, 18948.00),
(101, 22, 'material', 'SUMINISTRO DE MANINA PREPINTADA', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(102, 22, 'material', 'SUMINISTRO DE PARAL DE CONTRAMARCO', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(103, 22, 'material', 'SUMINISTRO DE PARALES', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(104, 22, 'material', 'SUMINISTRO DE LAMINA DE PLYWOOD DE 1/4', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(105, 22, 'material', 'SUMINISTRO DE HANGUER DELANTERO', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(106, 22, 'material', 'SUMINISTRO DE REMACHES', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(107, 22, 'material', 'SUMNIISTRO DE BROCAS DE 3/4', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(108, 22, 'material', 'SUMINISTRO DE EMPAQUES', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(109, 23, 'mano_obra', 'MANO DE OBRA POR PINTADP DE FURGON SUS TRES COSTADOS', 1.00, 16350.00, 16350.00, 16350.00, 0.00, 0.00, 16350.00),
(110, 23, 'material', 'SUMINISTRO DE MATERIALES', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(111, 23, 'material', 'SUMINISTRO DE DE PINTURA', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(112, 23, 'material', 'SUMINISTRO DE PINTURA DE BASE', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(113, 23, 'material', 'SUMINISTRO DE THINNER', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(114, 24, 'mano_obra', 'RECONSTRUCCION DE TORRE DE SUSPENSIÓN', 1.00, 7000.00, 7000.00, 7000.00, 0.00, 0.00, 7000.00),
(115, 25, 'mano_obra', 'REPARACION DE PISO CAMBIO DE 12 PIES DE MADERA', 1.00, 8000.00, 8000.00, 8000.00, 0.00, 0.00, 8000.00),
(116, 25, 'mano_obra', 'REPARACION DE CHANELES', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(117, 25, 'mano_obra', 'SUMINISTRO E INSTALACION DE TORNILLERIA', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(118, 26, 'mano_obra', 'PUENTES', 1.00, 12500.00, 12500.00, 12500.00, 0.00, 0.00, 12500.00),
(119, 26, 'mano_obra', 'REPARACION DE RODAPIE', 1.00, 3000.00, 3000.00, 3000.00, 0.00, 0.00, 3000.00),
(120, 27, 'mano_obra', 'PUENTES', 1.00, 17450.00, 17450.00, 17450.00, 0.00, 0.00, 17450.00),
(121, 27, 'mano_obra', 'SOLDADURA PERFIL', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(122, 27, 'mano_obra', 'REPARACION DE EMPAQUES', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(123, 27, 'mano_obra', 'REPARACION DE RODAPIE', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(124, 28, 'mano_obra', 'SOLDADURA PERFIL', 1.00, 500.00, 500.00, 500.00, 0.00, 0.00, 500.00),
(125, 28, 'mano_obra', 'REPARACION DE TANDY', 1.00, 800.00, 800.00, 800.00, 0.00, 0.00, 800.00),
(126, 28, 'mano_obra', 'REPARACION DE PISO', 1.00, 1500.00, 1500.00, 1500.00, 0.00, 0.00, 1500.00),
(127, 29, 'mano_obra', 'FABRICACION DE CUCHARA DE RETRO 320GC', 1.00, 105609.00, 105609.00, 105609.00, 0.00, 0.00, 105609.00),
(128, 30, 'mano_obra', 'FABRICACION DE CUCHARA DE RETRO 320GC', 1.00, 98216.37, 98216.37, 98216.37, 0.00, 0.00, 98216.37),
(129, 31, 'mano_obra', 'REPARACION DE CONTENEDOR 8253', 1.00, 25650.00, 25650.00, 25650.00, 0.00, 0.00, 25650.00),
(130, 31, 'mano_obra', 'FABRICADO E INSTALADO DE COMPUERTA', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(131, 31, 'mano_obra', 'FABRICAR BASES DE DEFENSA TRASERA', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(132, 31, 'mano_obra', 'REPARACION DE PARTE LATERAL IZQUIERDA', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(133, 31, 'mano_obra', 'SUMINISTRO DE LAMINA PREPINTADA', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(134, 31, 'mano_obra', 'REMACHES', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(135, 32, 'mano_obra', 'REPARACION DE CONTENEDOR 2823', 1.00, 19700.00, 19700.00, 19700.00, 0.00, 0.00, 19700.00),
(136, 32, 'mano_obra', 'REPARACION DE IZQUINA FRONTAL IZQUIERDA', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(137, 32, 'mano_obra', 'CAMBIO DE DE 6 PARALES DE PARED', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(138, 32, 'mano_obra', 'CAMBIO DE 4 LAMINAS PREPINTADAS', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(139, 33, 'mano_obra', 'REPARACION DE CONTENEDOR 9927', 1.00, 29000.00, 29000.00, 29000.00, 0.00, 0.00, 29000.00),
(140, 33, 'mano_obra', 'REPARACION DE PIERNA DE TANDY', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(141, 33, 'mano_obra', 'CAMBIO DE HANGER', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(142, 33, 'mano_obra', 'CAMBIO DE BASE DE TENSORA', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(143, 33, 'mano_obra', 'RECTIFICACION DE EJE DELANTERO', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(144, 34, 'mano_obra', 'RECONSTRUCCION DE GRANELERA', 1.00, 160000.00, 160000.00, 160000.00, 0.00, 0.00, 160000.00),
(145, 34, 'mano_obra', 'RECONSTRUCCION PARTE FRONTAL', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(146, 34, 'mano_obra', 'FABRICACION E INSTALACION DE TONAMESA CON SU PIN', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(147, 34, 'mano_obra', 'CAMBIO DE PARALES INTERNOS', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(148, 34, 'mano_obra', 'RECONSTRUCCION DE PERFILSUPEROR', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(149, 34, 'mano_obra', 'FABRICACION DE BASE DE UNA PATA', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(150, 34, 'mano_obra', 'SUMINISTRO E INTALACION DE UNA PATA', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(151, 34, 'mano_obra', 'RECONSTRUCCION DE 12 PIES LATERALES IZQUIERDO Y  DERECHO', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(152, 34, 'mano_obra', 'REPARACION DE ESQUINEROS PARTE FRONTAL', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(153, 34, 'mano_obra', 'SUMINISTRO E INSTALCION DE CHANELES DELANTEROS', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(154, 35, 'mano_obra', 'FABRICACION DE ESTANTE', 1.00, 9450.00, 9450.00, 9450.00, 0.00, 0.00, 9450.00),
(155, 36, 'mano_obra', 'FABRICACION DE BARRA DE PISTON YPIN DE PISTON', 1.00, 10435.00, 10435.00, 10435.00, 0.00, 0.00, 10435.00),
(156, 37, 'mano_obra', 'RECONSTRUCCION DE BASE DE SOPORTE DE PISTON', 1.00, 9000.00, 9000.00, 9000.00, 0.00, 0.00, 9000.00),
(157, 38, 'mano_obra', 'REPARACION DE UNIDAD 8621', 1.00, 7000.00, 7000.00, 7000.00, 0.00, 0.00, 7000.00),
(158, 38, 'mano_obra', 'CAMBIO DE CHANELES', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(159, 38, 'mano_obra', 'REPARACION DE COSTADO', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(160, 39, 'mano_obra', 'PINTURA GENERAL DE RETROESCABADORA', 1.00, 83478.26, 83478.26, 83478.26, 0.00, 0.00, 83478.26),
(161, 40, 'mano_obra', 'FABRICACION E INSTACION DE TANQUE HIDRAULICO', 1.00, 15000.00, 15000.00, 15000.00, 0.00, 0.00, 15000.00),
(162, 41, 'mano_obra', 'FABRICACION E INSTACION DE TANQUE HIDRAULICO', 2.00, 14250.00, 28500.00, 28500.00, 0.00, 0.00, 28500.00),
(163, 42, 'mano_obra', 'REPARACION DE CONTENEDOR INCLUYE', 1.00, 30077.50, 30077.50, 30077.50, 0.00, 0.00, 30077.50),
(164, 42, 'mano_obra', 'CAMBIO DE PERFIL', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(165, 42, 'mano_obra', 'CAMBIO DE LAMINA', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(166, 42, 'mano_obra', 'FABRICADO DE DEFENSA', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(167, 42, 'mano_obra', 'REMACHADO DE LAMINAS INTERNAS', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(168, 42, 'mano_obra', 'TORNILLERIA', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(169, 42, 'mano_obra', 'NIVELACION DE FURGON', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(170, 43, 'mano_obra', 'MANO DE OBRA POR PINTADO DE FURGON SUS TRES COSTADOS', 1.00, 14715.00, 14715.00, 14715.00, 0.00, 0.00, 14715.00),
(171, 43, 'mano_obra', 'SUMINISTRO DE MATERIALES', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(172, 43, 'mano_obra', 'SUMINISTRO DE DE PINTURA', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(173, 43, 'mano_obra', 'SUMINISTRO DE PINTURA DE BASE', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(174, 43, 'mano_obra', 'SUMINISTRO DE THINNER', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(175, 44, 'material', 'AREPARACION DE PISTON HIDRAULICO DE GRUA PLATAFORMA', 1.00, 52000.00, 52000.00, 52000.00, 0.00, 0.00, 52000.00),
(176, 44, 'material', 'RELLENAR RECTIFICACION Y PULIR VASTAGO CROMADO', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(177, 44, 'mano_obra', 'RELLENAR Y RECTIFICAR GUIA PORTA ENPAQUES', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(178, 44, 'mano_obra', 'FABRICAR BUJE DE TUERCA SUPERIOR', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(179, 44, 'mano_obra', 'CAMBIO DE KIT DE SELLOS', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(180, 44, 'mano_obra', 'RECONSTRUCCION DE DE REFUERZO DE SUJETADOR DE PISTON', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(181, 44, 'mano_obra', 'MONTAJE Y DESMONTAJE DE PISTON', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(182, 45, 'mano_obra', 'REPARACION DE PISTON HIDRAULICO AZUL', 1.00, 18900.00, 18900.00, 18900.00, 0.00, 0.00, 18900.00),
(183, 45, 'mano_obra', 'PULIR CILINDRO', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(184, 45, 'mano_obra', 'RELLENAR Y RECTIFICAR GUIA PORTA EMPAQUES', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(185, 45, 'mano_obra', 'FABRICAR BUJE INTERNO DE TUERCA SUPERIOR', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(186, 45, 'mano_obra', 'CAMBIO DE KIT DE SELLOS', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(187, 45, 'mano_obra', 'DEMOSNTAJE Y MONTAGE DE PISTON', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(188, 46, 'mano_obra', 'REPARACION DE PISTON HIDRAULICO DE GRUA PLATAFORMA', 1.00, 49400.00, 49400.00, 49400.00, 0.00, 0.00, 49400.00),
(189, 46, 'mano_obra', 'RELLENAR RECTIFICACION Y PULIR VASTAGO CROMADO', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(190, 46, 'mano_obra', 'RELLENAR Y RECTIFICAR GUIA PORTA ENPAQUES', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(191, 46, 'mano_obra', 'FABRICAR BUJE DE TUERCA SUPERIOR', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(192, 46, 'mano_obra', 'CAMBIO DE KIT DE SELLOS', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(193, 46, 'mano_obra', 'RECONSTRUCCION DE DE REFUERZO DE SUJETADOR DE PISTON', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(194, 46, 'mano_obra', 'MONTAJE Y DESMONTAJE DE PISTON', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(195, 47, 'mano_obra', 'REPARACION DE PISTON HIDRAULICO AZUL', 1.00, 17955.00, 17955.00, 17955.00, 0.00, 0.00, 17955.00),
(196, 47, 'mano_obra', 'PULIR CILINDRO', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(197, 47, 'mano_obra', 'RELLENAR Y RECTIFICAR GUIA PORTA EMPAQUES', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(198, 47, 'mano_obra', 'FABRICAR BUJE INTERNO DE TUERCA SUPERIOR', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(199, 47, 'mano_obra', 'CAMBIO DE KIT DE SELLOS', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(200, 47, 'mano_obra', 'DEMOSNTAJE Y MONTAGE DE PISTON', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(201, 48, 'mano_obra', 'FABRICACION DE EXIBIDOR DE TIMON DE CAMION', 1.00, 22000.00, 22000.00, 22000.00, 0.00, 0.00, 22000.00),
(202, 48, 'mano_obra', 'ESPACIO PARA 12 UNIDADES', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(203, 49, 'mano_obra', 'EXHIBIDOR', 6.00, 9000.00, 54000.00, 54000.00, 0.00, 0.00, 54000.00),
(204, 50, 'mano_obra', 'EXHIBIDOR DE DISCOS', 6.00, 5500.00, 33000.00, 33000.00, 0.00, 0.00, 33000.00),
(205, 51, 'mano_obra', 'EXHIBIDOR', 6.00, 8820.00, 52920.00, 52920.00, 0.00, 0.00, 52920.00),
(206, 52, 'mano_obra', 'EXHIBIDOR DE DISCOS', 6.00, 5390.00, 32340.00, 32340.00, 0.00, 0.00, 32340.00),
(207, 53, 'mano_obra', 'ELTHON SAMUEL URBINA MELGAR', 1.00, 287.79, 287.79, 287.79, 0.00, 0.00, 287.79),
(208, 53, 'mano_obra', 'DANIEL EDGARDO MEJIA RODRIGUEZ', 1.00, 287.79, 287.79, 287.79, 0.00, 0.00, 287.79),
(209, 53, 'mano_obra', 'DENIS JOEL LOPEZ MARADIAGA', 1.00, 287.79, 287.79, 287.79, 0.00, 0.00, 287.79),
(210, 53, 'mano_obra', 'ERICK FERNANDO ULLOA MIRANDA', 1.00, 287.79, 287.79, 287.79, 0.00, 0.00, 287.79),
(211, 53, 'mano_obra', 'ESDRAS JOEL CALIX MOREIRA', 1.00, 287.79, 287.79, 287.79, 0.00, 0.00, 287.79),
(212, 53, 'mano_obra', 'JUAN CARLOS ECHEVERRIA MARTINEZ', 1.00, 287.79, 287.79, 287.79, 0.00, 0.00, 287.79),
(213, 53, 'mano_obra', 'LUANIS ISRAEL RIVERA MARADIAGA', 1.00, 287.79, 287.79, 287.79, 0.00, 0.00, 287.79),
(214, 53, 'mano_obra', 'WILLIAN DANIEL BAUTISTA GUEVARA', 1.00, 287.79, 287.79, 287.79, 0.00, 0.00, 287.79),
(215, 53, 'mano_obra', 'WILLIAN NORTIE ARDON CRUZ', 1.00, 287.79, 287.79, 287.79, 0.00, 0.00, 287.79),
(216, 53, 'mano_obra', 'YEFRI YAFETH ESTRADA MURILLO', 1.00, 287.79, 287.79, 287.79, 0.00, 0.00, 287.79),
(217, 54, 'mano_obra', 'FABRICADO E INSTALADO DE CAJA Y GRADA DE CAMION', 1.00, 25000.00, 25000.00, 25000.00, 0.00, 0.00, 25000.00),
(218, 55, 'mano_obra', 'ALARGAR CHASIS DE MULITA', 2.00, 115000.00, 230000.00, 230000.00, 0.00, 0.00, 230000.00),
(219, 55, 'mano_obra', 'ALARGAR CHASIS Y ENCAJUELADO, DESMONTAJE Y MONTAJE DE  LOS 3 EJES, MONTAJE DE CARDAN.', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(220, 56, 'mano_obra', 'REPARAR TANQUE', 1.00, 80000.00, 80000.00, 80000.00, 0.00, 0.00, 80000.00),
(221, 56, 'mano_obra', 'SOLDADURA EXTERIOR, SOLDADURA INTERIOR, MANTENIMIENTO  DE LOS 4 SIN FINES Y SUSTITUIR SUS CHUMACERAS, PINTADO  DE LOS 2 BOOM, MANTENIMIENTO DE CANOA, REPARACION DE  GUARDAFANGOS, ENGRASE DE SISETMA DE DESCARGA,  REPARACION DE BOOM PLUMA,SUSTITUCION DE MAN', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(222, 57, 'mano_obra', 'FABRICAR TANQUE', 1.00, 480000.00, 480000.00, 480000.00, 0.00, 0.00, 480000.00),
(223, 57, 'mano_obra', 'MANO DE OBRA DE FABRICACION DE TANQUE GRANELERO Y SU  MONTAJE EN CAMION', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(224, 58, 'mano_obra', 'RECONSTRUCCIÓN DE PARED FRONTAL Y ESQUINERO', 1.00, 26000.00, 26000.00, 26000.00, 0.00, 0.00, 26000.00),
(225, 58, 'mano_obra', 'MANO DE OBRA Y MATERIALES', 1.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00),
(226, 59, 'mano_obra', 'RESTAURACION DE CHASIS DE CAMION', 1.00, 70000.00, 70000.00, 70000.00, 0.00, 0.00, 70000.00);

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

--
-- Volcado de datos para la tabla `detalle_factura`
--

INSERT INTO `detalle_factura` (`id_detalle_fac`, `factura_id`, `tipo`, `descripcion`, `cantidad`, `precio_unitario`, `subtotal_base`, `subtotal_final`) VALUES
(1, 1, 'mano_obra', 'REPARACION DE PLATAFORMA LONBOY INCLUYE MANO DE  OBRA Y MATERIALES', 1.00, 134475.26, 134475.26, 134475.26),
(2, 2, 'mano_obra', 'FABRICADO E INSTALADO BASE DE PISTON DE PLATAFORMA', 1.00, 6975.00, 6975.00, 6975.00),
(3, 3, 'otro', 'PINTURA GENERAL EXTERNA DE LOMBO', 1.00, 26000.00, 26000.00, 26000.00),
(4, 4, 'mano_obra', 'PINTURA GENERAL EXTERNA PLATAFORMA DE LOMBOY', 1.00, 26000.00, 26000.00, 26000.00),
(5, 5, 'otro', 'REPARACION DE PLATAFORMA LOMBOY, INCLUYE MANO DE OBRA Y MATERIALES', 1.00, 134475.26, 134475.26, 134475.26),
(6, 6, 'mano_obra', 'REPARACION DE PLATAFORMA LOMBOY, INCLUYE MANO DE OBRA Y MATERIALES', 1.00, 134475.26, 134475.26, 134475.26),
(7, 7, 'otro', 'REPARACION DE PLATAFORMA INCLUYE MANO DE OBRA Y MATERIALES', 1.00, 76016.53, 76016.53, 76016.53),
(8, 8, 'mano_obra', 'REPARACION DE PLATAFORMA INCLUYE MANO DE OBRA Y MATERIALES', 1.00, 76016.53, 76016.53, 76016.53),
(9, 8, 'mano_obra', 'SUMINISTRO E INSTALACION DE MADERA', 1.00, 0.00, 0.00, 0.00),
(10, 8, 'mano_obra', 'REPARACION DE BASE DE PISTONES', 1.00, 0.00, 0.00, 0.00),
(11, 8, 'mano_obra', 'FABRICADO DE GUIAS DE PLATAFORMA FRONTAL', 1.00, 0.00, 0.00, 0.00),
(12, 8, 'mano_obra', 'REPARACION DE DEFENSA FRONTAL', 1.00, 0.00, 0.00, 0.00),
(13, 8, 'mano_obra', 'FABRICACION DE PORTALLANTA', 1.00, 0.00, 0.00, 0.00),
(14, 8, 'mano_obra', 'ENGRASE GENERAL', 1.00, 0.00, 0.00, 0.00),
(15, 8, 'mano_obra', 'PINTURA GENERAL', 1.00, 0.00, 0.00, 0.00),
(16, 9, 'otro', 'MOVIMIENTOS MAERSK', 1.00, 1299.00, 1299.00, 1299.00),
(17, 10, 'mano_obra', 'REPARACION DE PLATAFORMA INCLUYE MANO DE OBRA Y MATERIALES', 1.00, 76016.53, 76016.53, 76016.53),
(18, 10, 'mano_obra', 'SUMINISTRO E INSTALACION DE MADERA', 1.00, 0.00, 0.00, 0.00),
(19, 10, 'mano_obra', 'REPARACION DE BASE DE PISTONES', 1.00, 0.00, 0.00, 0.00),
(20, 10, 'mano_obra', 'FABRICADO DE GUIAS DE PLATAFORMA FRONTAL', 1.00, 0.00, 0.00, 0.00),
(21, 10, 'mano_obra', 'REPARACION DE DEFENSA FRONTAL', 1.00, 0.00, 0.00, 0.00),
(22, 10, 'mano_obra', 'FABRICACION DE PORTALLANTA', 1.00, 0.00, 0.00, 0.00),
(23, 10, 'mano_obra', 'ENGRASE GENERAL', 1.00, 0.00, 0.00, 0.00),
(24, 10, 'mano_obra', 'PINTURA GENERAL', 1.00, 0.00, 0.00, 0.00),
(25, 11, 'otro', 'FLETE F-LOCAL SPS SEMANA 19-25 JUNIO 2026 VALENTIN MEJIA', 3.00, 2128.00, 6384.00, 6384.00),
(26, 11, 'otro', 'FLETE F-LOCAL SPS SEMAN 19-25 DE JUNIIO 206 EFRAIN SARMIENTO', 3.00, 2128.00, 6384.00, 6384.00),
(27, 12, 'otro', 'PUERTO CORTES SPS-OW/FRO#67010253136', 1.00, 3000.00, 3000.00, 3000.00),
(28, 12, 'otro', 'PUERTO CORTES SPS-OW/FRO#67010303545', 1.00, 3000.00, 3000.00, 3000.00),
(29, 12, 'otro', 'TRASLADO SPS-RT OT/FRO#67010302990', 1.00, 1800.00, 1800.00, 1800.00),
(30, 12, 'otro', 'PUERTO CORTES SPS-OW/FRO#67010322718', 1.00, 3000.00, 3000.00, 3000.00),
(31, 12, 'otro', 'PUERTO CORTES SPS-OW/FRO#67010322979', 1.00, 3000.00, 3000.00, 3000.00),
(32, 12, 'otro', 'TRASLADO SPS-RT OT/FRO#67010357557', 1.00, 1800.00, 1800.00, 1800.00),
(33, 12, 'otro', 'PUERTO CORTES SPS-OW/FRO#67010357557', 1.00, 3000.00, 3000.00, 3000.00),
(34, 12, 'otro', 'PUERTO CORTES SPS-OW/FRO#67010357551', 1.00, 3000.00, 3000.00, 3000.00),
(35, 12, 'otro', 'TRASLADO INETERNO SPS OT/FRO PDT CNT MAEU 9270920', 1.00, 1800.00, 1800.00, 1800.00),
(36, 13, 'mano_obra', 'FABRICADO E INSTALADO DE COMPUERTA DE PICKUP', 1.00, 8181.95, 8181.95, 8181.95),
(37, 14, 'mano_obra', 'RECONSTRUCCION DE CHASIS Y REFORZADO CON LAMINA DE  HIERRO DE 1/4 Y PLACA DE 5/16,INSTALACION DE REMOLQUE Y  PINTURA', 1.00, 13300.00, 13300.00, 13300.00),
(38, 15, 'otro', 'REPARACION DE CHIMBO DE AIRE', 1.00, 3000.00, 3000.00, 3000.00),
(39, 16, 'mano_obra', 'PUENTES', 1.00, 12500.00, 12500.00, 12500.00),
(40, 16, 'mano_obra', 'REPARACION DE RODAPIE', 1.00, 3000.00, 3000.00, 3000.00),
(41, 17, 'mano_obra', 'PUENTES', 1.00, 17450.00, 17450.00, 17450.00),
(42, 17, 'mano_obra', 'SOLDADURA PERFIL', 1.00, 0.00, 0.00, 0.00),
(43, 17, 'mano_obra', 'REPARACION DE EMPAQUES', 1.00, 0.00, 0.00, 0.00),
(44, 17, 'mano_obra', 'REPARACION DE RODAPIE', 1.00, 0.00, 0.00, 0.00),
(45, 19, 'otro', 'REPARACION DE PISO', 1.00, 8000.00, 8000.00, 8000.00),
(46, 20, 'mano_obra', 'REPARACION DE PISO CAMBIO DE 12 PIES DE MADERA', 1.00, 8000.00, 8000.00, 8000.00),
(47, 20, 'mano_obra', 'REPARACION DE CHANELES', 1.00, 0.00, 0.00, 0.00),
(48, 20, 'mano_obra', 'SUMINISTRO E INSTALACION DE TORNILLERIA', 1.00, 0.00, 0.00, 0.00),
(49, 18, 'mano_obra', 'SOLDADURA PERFIL', 1.00, 500.00, 500.00, 500.00),
(50, 18, 'mano_obra', 'REPARACION DE TANDY', 1.00, 800.00, 800.00, 800.00),
(51, 18, 'mano_obra', 'REPARACION DE PISO', 1.00, 1500.00, 1500.00, 1500.00),
(53, 21, 'otro', 'DIAS DE TRABAJO MOTORISTA RUBEN DARIO AMAYA CABEZAL TCA8427', 31.00, 1774.19, 55000.00, 55000.00),
(54, 22, 'otro', 'TRASLADO PTO/S.P.S SEAC410254', 1.00, 3000.00, 3000.00, 3000.00),
(55, 22, 'otro', 'TRASLADO S.P.S MRSU8217112', 1.00, 1810.00, 1810.00, 1810.00),
(56, 22, 'otro', 'TRASLADO S.P.S MRSU621614', 1.00, 1810.00, 1810.00, 1810.00),
(57, 22, 'otro', 'TRASLADO PTO/S.P.S SEAC850401', 1.00, 3000.00, 3000.00, 3000.00),
(58, 22, 'otro', 'TRASLADO S.P.S GCXU5791458', 1.00, 1810.00, 1810.00, 1810.00),
(59, 22, 'otro', 'TRASLADO S.P.S TCKU6626970', 1.00, 1810.00, 1810.00, 1810.00),
(60, 22, 'otro', 'TRASLADO S.P.S URTU8132411', 1.00, 1810.00, 1810.00, 1810.00),
(61, 22, 'otro', 'TRASLADO PTO/S.P.S MRKU4277506', 1.00, 1810.00, 1810.00, 1810.00),
(62, 22, 'otro', 'TRASLADO S.P.S/R.NANCE TCKU7087180', 1.00, 3000.00, 3000.00, 3000.00),
(63, 22, 'otro', 'TRASLADO S.P.S MRSU8126563', 1.00, 1810.00, 1810.00, 1810.00),
(64, 22, 'otro', 'TRASLADO S.P.S/R.NANCA CAAU6560655', 1.00, 3000.00, 3000.00, 3000.00),
(65, 22, 'otro', 'TRASLADO S.P.S/R.NANCE MRSU5503920', 1.00, 3000.00, 3000.00, 3000.00),
(66, 22, 'otro', 'TRASLADO S.P.S MAKU5507291', 1.00, 1810.00, 1810.00, 1810.00),
(67, 22, 'otro', 'TRASLADO S.P.S/R.NANCE FFAU7167250', 1.00, 3000.00, 3000.00, 3000.00),
(68, 22, 'otro', 'TRASLADO S.P.S MRKU4490949', 1.00, 1810.00, 1810.00, 1810.00),
(69, 22, 'otro', 'TRASLADO S.P.S MRSU3008378', 1.00, 1810.00, 1810.00, 1810.00),
(70, 22, 'otro', 'TRASLADO S.P.S MRSU5510153', 1.00, 1810.00, 1810.00, 1810.00),
(71, 23, 'otro', 'FLETE F-LOCAL SPS SEMAN 22-29 JUNIO 2026 VALENTIN MEJIA', 1.00, 6384.00, 6384.00, 6384.00),
(72, 24, 'otro', 'DIAS DE TRABAJO MULERO TAPREDIO/WILIAN ARDON', 31.00, 1066.94, 33075.14, 33075.14),
(73, 25, 'otro', 'DANI DANIEL MARTIMEZ MANZANAREZ', 1.00, 28377.44, 28377.44, 28377.44),
(74, 25, 'otro', 'DANIEL EDGARDO MEJIA RODRIGUEZ', 1.00, 22959.27, 22959.27, 22959.27),
(75, 25, 'otro', 'DENIS JOEL LOPEZ MARADIAGA', 1.00, 25419.19, 25419.19, 25419.19),
(76, 25, 'otro', 'WILSON JOSUE FUNEZ FIGUEROA', 1.00, 22139.29, 22139.29, 22139.29),
(77, 25, 'otro', 'ESDRAS JOEL CALIX MOREIRA', 1.00, 30334.50, 30334.50, 30334.50),
(78, 25, 'otro', 'JOEL ANDRES JIMENEZ TORREZ', 1.00, 18592.11, 18592.11, 18592.11),
(79, 25, 'otro', 'JUAN ANGEL ULLOA GUTIERREZ', 1.00, 25419.19, 25419.19, 25419.19),
(80, 25, 'otro', 'JUAN CARLOS ECHEVERRIA MARTINEZ', 1.00, 31177.13, 31177.13, 31177.13),
(81, 25, 'otro', 'LUANIS ISRRAEL RIVERA MARADIAGA', 1.00, 25419.19, 25419.19, 25419.19),
(82, 25, 'otro', 'WILLIAN DANIEL BAUTISTA GUEVARA', 1.00, 24599.22, 24599.22, 24599.22),
(83, 25, 'otro', 'YEFRY YAFETH ESTRADA', 1.00, 23779.24, 23779.24, 23779.24),
(84, 25, 'otro', 'HERRAMIENTAS', 1.00, 16000.00, 16000.00, 16000.00),
(85, 25, 'otro', 'HORRAS EXTRAS', 1.00, 1870.00, 1870.00, 1870.00),
(86, 26, 'otro', 'DANI DANIEL  MARTINEZ MANZANAREZ', 1.00, 287.79, 287.79, 287.79),
(87, 26, 'otro', 'DANIEL EDGARDO MEJIA RODIGUEZ', 1.00, 287.79, 287.79, 287.79),
(88, 26, 'otro', 'DENIS JOUEL LOPEZ MARDIAGA', 1.00, 287.79, 287.79, 287.79),
(89, 26, 'otro', 'ERIK FERNADO ULLOA MIRANDA', 1.00, 287.79, 287.79, 287.79),
(90, 26, 'otro', 'ESDRAS JOEL CALIX MOREIRA', 1.00, 287.79, 287.79, 287.79),
(91, 26, 'otro', 'JOEL ANDRES JIMENES TORRES', 1.00, 287.79, 287.79, 287.79),
(92, 26, 'otro', 'JUAN CARLOS ECHEVERRIA MARTINEZ', 1.00, 287.79, 287.79, 287.79),
(93, 26, 'otro', 'LUANIS ISRRAEL RIVERA MARADIAGA', 1.00, 287.79, 287.79, 287.79),
(94, 26, 'otro', 'WILLIAN DANIEL BAUTISTA GUEVARA', 1.00, 287.79, 287.79, 287.79),
(95, 26, 'otro', 'WILLIAN NORTIE ARDON CRUZ', 1.00, 287.79, 287.79, 287.79),
(96, 26, 'otro', 'YEFRY YAFETH ESTRADA MURILLO', 1.00, 287.79, 287.79, 287.79),
(97, 27, 'otro', 'DANI DANIEL MARTINEZ MANZANAREZ', 1.00, 28377.44, 28377.44, 28377.44),
(98, 27, 'otro', 'DANIEL EDGARDO MEJIA RODRIGUEZ', 1.00, 22959.27, 22959.27, 22959.27),
(99, 27, 'otro', 'DENIS JOEL LOPESZ MARADIAGA', 1.00, 25419.19, 25419.19, 25419.19),
(100, 27, 'otro', 'WILSON JOSUE FUNEZ FIGUEROA', 1.00, 22959.27, 22959.27, 22959.27),
(101, 27, 'otro', 'ESDRAS JOEL CALIX MOREIRA', 1.00, 30334.50, 30334.50, 30334.50),
(102, 27, 'otro', 'JOEL ANDRES JIMENES TORRES', 1.00, 18592.11, 18592.11, 18592.11),
(103, 27, 'otro', 'JUAN ANGEL ULLOA GUTIERREZ', 1.00, 25419.19, 25419.19, 25419.19),
(104, 27, 'otro', 'JUAN CARLOS ECHEVERRIA MARTINEZ', 1.00, 31177.13, 31177.13, 31177.13),
(105, 27, 'otro', 'LUANIS ISRRAEL RIVERA MARADIAGA', 1.00, 25419.19, 25419.19, 25419.19),
(106, 27, 'otro', 'WILLIAN DANIEL BAUTISTA GUEVARA', 1.00, 24599.22, 24599.22, 24599.22),
(107, 27, 'otro', 'YEFRY YAFETH ESTRADA', 1.00, 23779.24, 23779.24, 23779.24),
(108, 27, 'otro', 'HERRAMIENTAS', 1.00, 16000.00, 16000.00, 16000.00),
(109, 27, 'otro', 'HORAS EXTRAS', 1.00, 1870.00, 1870.00, 1870.00),
(110, 28, 'mano_obra', 'REPARACION DE STICK DE 320DL', 1.00, 50247.00, 50247.00, 50247.00),
(111, 29, 'mano_obra', 'REPARACION DE UNIDAD 8621', 1.00, 7000.00, 7000.00, 7000.00),
(112, 29, 'mano_obra', 'CAMBIO DE CHANELES', 1.00, 0.00, 0.00, 0.00),
(113, 29, 'mano_obra', 'REPARACION DE COSTADO', 1.00, 0.00, 0.00, 0.00),
(114, 30, 'otro', 'MOVIMIENTOS MAERSK', 1.00, 101680.00, 101680.00, 101680.00),
(115, 31, '', 'MOVIMIENTOS MAERSK DEL 04 DE AGOSTO AL 27 DE AGOSTO 2026', 1.00, 101680.00, 101680.00, 101680.00),
(116, 32, '', 'MOVIMIENTOS ALPLA AGOSTO 2026', 1.00, 10640.00, 10640.00, 10640.00),
(117, 33, 'mano_obra', 'MANO DE OBRA POR PINTADO DE FURGON SUS TRES COSTADOS', 1.00, 14715.00, 14715.00, 14715.00),
(118, 33, 'mano_obra', 'SUMINISTRO DE MATERIALES', 1.00, 0.00, 0.00, 0.00),
(119, 33, 'mano_obra', 'SUMINISTRO DE DE PINTURA', 1.00, 0.00, 0.00, 0.00),
(120, 33, 'mano_obra', 'SUMINISTRO DE PINTURA DE BASE', 1.00, 0.00, 0.00, 0.00),
(121, 33, 'mano_obra', 'SUMINISTRO DE THINNER', 1.00, 0.00, 0.00, 0.00),
(122, 34, 'mano_obra', 'REPARACION DE CONTENEDOR INCLUYE', 1.00, 30077.50, 30077.50, 30077.50),
(123, 34, 'mano_obra', 'CAMBIO DE PERFIL', 1.00, 0.00, 0.00, 0.00),
(124, 34, 'mano_obra', 'CAMBIO DE LAMINA', 1.00, 0.00, 0.00, 0.00),
(125, 34, 'mano_obra', 'FABRICADO DE DEFENSA', 1.00, 0.00, 0.00, 0.00),
(126, 34, 'mano_obra', 'REMACHADO DE LAMINAS INTERNAS', 1.00, 0.00, 0.00, 0.00),
(127, 34, 'mano_obra', 'TORNILLERIA', 1.00, 0.00, 0.00, 0.00),
(128, 34, 'mano_obra', 'NIVELACION DE FURGON', 1.00, 0.00, 0.00, 0.00),
(129, 35, 'mano_obra', 'FABRICACOPN DE BARRA DE PISTON', 1.00, 10435.00, 10435.00, 10435.00),
(130, 36, 'mano_obra', 'FABRICACION DE BARRA DE PISTON YPIN DE PISTON', 1.00, 10435.00, 10435.00, 10435.00),
(131, 37, 'mano_obra', 'DIAS DE TRABAJO MOTORISTA RUBEN DARIO RODRIGUEZ AMAYA UNIDAD TCA8427', 31.00, 1774.19, 55000.00, 55000.00),
(132, 38, 'mano_obra', 'REPARACION DE CONTENEDOR 9927', 1.00, 29000.00, 29000.00, 29000.00),
(133, 38, 'mano_obra', 'REPARACION DE PIERNA DE TANDY', 1.00, 0.00, 0.00, 0.00),
(134, 38, 'mano_obra', 'CAMBIO DE HANGER', 1.00, 0.00, 0.00, 0.00),
(135, 38, 'mano_obra', 'CAMBIO DE BASE DE TENSORA', 1.00, 0.00, 0.00, 0.00),
(136, 38, 'mano_obra', 'RECTIFICACION DE EJE DELANTERO', 1.00, 0.00, 0.00, 0.00),
(137, 39, 'mano_obra', 'REPARACION DE STICK DE 320DL', 1.00, 50247.00, 50247.00, 50247.00),
(138, 40, 'mano_obra', 'REPARACION DE PISTON HIDRAULICO DE GRUA PLATAFORMA', 1.00, 49400.00, 49400.00, 49400.00),
(139, 40, 'mano_obra', 'RELLENAR RECTIFICACION Y PULIR VASTAGO CROMADO', 1.00, 0.00, 0.00, 0.00),
(140, 40, 'mano_obra', 'RELLENAR Y RECTIFICAR GUIA PORTA ENPAQUES', 1.00, 0.00, 0.00, 0.00),
(141, 40, 'mano_obra', 'FABRICAR BUJE DE TUERCA SUPERIOR', 1.00, 0.00, 0.00, 0.00),
(142, 40, 'mano_obra', 'CAMBIO DE KIT DE SELLOS', 1.00, 0.00, 0.00, 0.00),
(143, 40, 'mano_obra', 'RECONSTRUCCION DE DE REFUERZO DE SUJETADOR DE PISTON', 1.00, 0.00, 0.00, 0.00),
(144, 40, 'mano_obra', 'MONTAJE Y DESMONTAJE DE PISTON', 1.00, 0.00, 0.00, 0.00),
(145, 41, 'otro', 'DANIEL EDGARDO MEJIA RODRIGUEZ', 1.00, 26239.16, 26239.16, 26239.16),
(146, 41, 'otro', 'DENIS JOEL LOPEZ MARADIAGA', 1.00, 25419.19, 25419.19, 25419.19),
(147, 41, 'otro', 'WILSON JOSUE FUNEZ FIGUEROA', 1.00, 25419.19, 25419.19, 25419.19),
(148, 41, 'otro', 'ESDRAS JOEL CALIX MOREIRA', 1.00, 28377.44, 28377.44, 28377.44),
(149, 41, 'otro', 'JUAN ANGEL ULLOA GUTIERREZ', 1.00, 25419.19, 25419.19, 25419.19),
(150, 41, 'otro', 'JUAN CARLOS ECHEVERRIA MARTINEZ', 1.00, 30171.41, 30171.41, 30171.41),
(151, 41, 'otro', 'LUANIS ISRAEL RIVERA MARADIAGA', 1.00, 25419.19, 25419.19, 25419.19),
(152, 41, 'otro', 'WILLIAN DANIEL BAUTISTA GUEVARA', 1.00, 25419.15, 25419.15, 25419.15),
(153, 41, 'otro', 'YEFRY YAFETH ESTRADA', 1.00, 24599.21, 24599.21, 24599.21),
(154, 41, 'otro', 'ELTHON SAMUEL URBINA MELGAR', 1.00, 30334.50, 30334.50, 30334.50),
(155, 41, 'otro', 'HERRAMIENTAS', 1.00, 16000.00, 16000.00, 16000.00),
(156, 41, 'otro', 'HORAS EXTRA', 1.00, 1529.98, 1529.98, 1529.98),
(157, 42, 'mano_obra', 'ELTHON SAMUEL URBINA MELGAR', 1.00, 287.79, 287.79, 287.79),
(158, 42, 'mano_obra', 'DANIEL EDGARDO MEJIA RODRIGUEZ', 1.00, 287.79, 287.79, 287.79),
(159, 42, 'mano_obra', 'DENIS JOEL LOPEZ MARADIAGA', 1.00, 287.79, 287.79, 287.79),
(160, 42, 'mano_obra', 'ERICK FERNANDO ULLOA MIRANDA', 1.00, 287.79, 287.79, 287.79),
(161, 42, 'mano_obra', 'ESDRAS JOEL CALIX MOREIRA', 1.00, 287.79, 287.79, 287.79),
(162, 42, 'mano_obra', 'JUAN CARLOS ECHEVERRIA MARTINEZ', 1.00, 287.79, 287.79, 287.79),
(163, 42, 'mano_obra', 'LUANIS ISRAEL RIVERA MARADIAGA', 1.00, 287.79, 287.79, 287.79),
(164, 42, 'mano_obra', 'WILLIAN DANIEL BAUTISTA GUEVARA', 1.00, 287.79, 287.79, 287.79),
(165, 42, 'mano_obra', 'WILLIAN NORTIE ARDON CRUZ', 1.00, 287.79, 287.79, 287.79),
(166, 42, 'mano_obra', 'YEFRI YAFETH ESTRADA MURILLO', 1.00, 287.79, 287.79, 287.79),
(167, 43, 'otro', 'PILOTO WILLIAM ARDON', 1.00, 33075.00, 33075.00, 33075.00),
(168, 44, 'mano_obra', 'REPARACION DE CONTENEDOR 2823', 1.00, 19700.00, 19700.00, 19700.00),
(169, 44, 'mano_obra', 'REPARACION DE IZQUINA FRONTAL IZQUIERDA', 1.00, 0.00, 0.00, 0.00),
(170, 44, 'mano_obra', 'CAMBIO DE DE 6 PARALES DE PARED', 1.00, 0.00, 0.00, 0.00),
(171, 44, 'mano_obra', 'CAMBIO DE 4 LAMINAS PREPINTADAS', 1.00, 0.00, 0.00, 0.00),
(172, 45, 'mano_obra', 'REPARACION DE CONTENEDOR 8253', 1.00, 25650.00, 25650.00, 25650.00),
(173, 45, 'mano_obra', 'FABRICADO E INSTALADO DE COMPUERTA', 1.00, 0.00, 0.00, 0.00),
(174, 45, 'mano_obra', 'FABRICAR BASES DE DEFENSA TRASERA', 1.00, 0.00, 0.00, 0.00),
(175, 45, 'mano_obra', 'REPARACION DE PARTE LATERAL IZQUIERDA', 1.00, 0.00, 0.00, 0.00),
(176, 45, 'mano_obra', 'SUMINISTRO DE LAMINA PREPINTADA', 1.00, 0.00, 0.00, 0.00),
(177, 45, 'mano_obra', 'REMACHES', 1.00, 0.00, 0.00, 0.00),
(178, 46, 'otro', 'REPARACION DE CONTENEDOR TRC2823', 1.00, 19700.00, 19700.00, 19700.00),
(179, 47, 'mano_obra', 'RECONSTRUCCIÓN DE PARED FRONTAL Y ESQUINERO', 1.00, 26000.00, 26000.00, 26000.00),
(180, 47, 'mano_obra', 'MANO DE OBRA Y MATERIALES', 1.00, 0.00, 0.00, 0.00),
(181, 48, 'otro', 'MOVIMIENTOS MAERSK DEL 28/08/2026 AL 30/09/2026', 1.00, 115955.00, 115955.00, 115955.00),
(182, 49, 'otro', 'MOVIMIENTOS ALPLA 10/09/2026', 1.00, 2128.00, 2128.00, 2128.00),
(183, 51, 'otro', 'MOVIMIENTOS ALPLA 10/09/2026', 1.00, 2128.00, 2128.00, 2128.00),
(184, 52, '', 'MOVIMIENTOS MAERSK DEL 28/8/26 AL 30/9/26', 1.00, 79955.00, 79955.00, 79955.00),
(185, 53, '', 'MOVIMIENTOS ALPLA 10/09/2026', 1.00, 2128.00, 2128.00, 2128.00),
(186, 54, 'otro', 'SERVICIO DE TRANSPORTE UNIDAD TCA 8427 MOTORISTA RUBEN', 1.00, 44177.08, 44177.08, 44177.08),
(187, 55, 'otro', 'SERVICIO DE TRANSPORTE UNIDAD TCA 8427 MOTORISTA RUBEN', 1.00, 43878.99, 43878.99, 43878.99),
(188, 56, 'mano_obra', 'CAMBIO DE VALVULA NIVELADORA Y CORRECCION DE LINEAS DE AIRE DE SUSPENCION', 1.00, 4800.00, 4800.00, 4800.00),
(189, 56, 'otro', 'REGULACION DE FRENOS DE CHASIS', 1.00, 0.00, 0.00, 0.00),
(190, 56, 'otro', 'ASISTENCIA EN INSTALACIONEONES DEL CLIENTE', 1.00, 0.00, 0.00, 0.00),
(191, 57, 'otro', 'PLANILLA MENSUAL DEL 21 DE SEPTIEMBRE AL 20 DE OCTUBRE', 1.00, 258557.32, 258557.32, 258557.32),
(192, 58, 'otro', 'SEGURO PRIVADO MES DE OCTUBRE', 1.00, 2877.90, 2877.90, 2877.90),
(193, 59, 'otro', 'SEGURO PRIVADO MES DE OCTUBRE 2026', 1.00, 2877.90, 2877.90, 2877.90),
(194, 60, 'otro', 'SEGURO PRIVADO MES DE OCTUBRE 2026', 1.00, 2591.11, 2591.11, 2591.11),
(195, 61, 'otro', 'SEGURO PRIVADO MES DE OCTUBRE 2026', 1.00, 2590.11, 2590.11, 2590.11),
(196, 62, 'otro', 'DANIEL MEJIA', 1.00, 287.79, 287.79, 287.79),
(197, 62, 'otro', 'DENIS LOPEZ', 1.00, 287.79, 287.79, 287.79),
(198, 62, 'otro', 'ELTHON URBINA', 1.00, 287.79, 287.79, 287.79),
(199, 62, 'otro', 'ESDRAS CALIX', 1.00, 287.79, 287.79, 287.79),
(200, 62, 'otro', 'JUAN ECHEVERRIA', 1.00, 287.79, 287.79, 287.79),
(201, 62, 'otro', 'LUANIS RIVERA', 1.00, 287.79, 287.79, 287.79),
(202, 62, 'otro', 'WILLIAN BAUTISTA', 1.00, 287.79, 287.79, 287.79),
(203, 62, 'otro', 'YEFRY ESTRADA', 1.00, 287.79, 287.79, 287.79),
(204, 62, 'otro', 'SEGURO PRIVADO MES DE OCTUBRE 2026', 1.00, 0.00, 0.00, 0.00),
(205, 63, 'otro', 'MOVIMIENTOS MAERSK DEL 28/8/26 AL 30/10/26', 1.00, 78765.00, 78765.00, 78765.00);

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

--
-- Volcado de datos para la tabla `detalle_orden_mano_obra`
--

INSERT INTO `detalle_orden_mano_obra` (`id_mano_obra`, `orden_id`, `descripcion`, `dias`, `tarifa_dia`, `subtotal`) VALUES
(10, 10, 'TRABAJO 1: CAMBIAR PUENTE DE EJE MUERTO', 1.00, 666.67, 900.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalle_orden_materiales`
--

CREATE TABLE `detalle_orden_materiales` (
  `id_detalle_om` int(10) UNSIGNED NOT NULL,
  `orden_id` int(10) UNSIGNED NOT NULL,
  `material_id` int(10) UNSIGNED DEFAULT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `unidad_medida` varchar(30) DEFAULT NULL,
  `cantidad` decimal(12,2) NOT NULL,
  `precio_unitario` decimal(12,2) NOT NULL COMMENT 'Precio al momento del uso',
  `subtotal` decimal(12,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
  `viatico_s1` decimal(10,2) NOT NULL DEFAULT 0.00,
  `viatico_s2` decimal(10,2) NOT NULL DEFAULT 0.00,
  `viatico_s3` decimal(10,2) NOT NULL DEFAULT 0.00,
  `viatico_s4` decimal(10,2) NOT NULL DEFAULT 0.00,
  `ihss_empleado` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT '2.5% salario',
  `ihss_patronal` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT '5% salario',
  `rap_empleado` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT '1.5% salario',
  `isr_mensual` decimal(10,2) NOT NULL DEFAULT 0.00,
  `seguro_privado` decimal(10,2) NOT NULL DEFAULT 0.00,
  `aplicar_seguro` tinyint(1) NOT NULL DEFAULT 1,
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

INSERT INTO `detalle_planilla` (`id_detalle`, `planilla_id`, `empleado_id`, `salario_base`, `horas_extra`, `monto_horas_extra`, `dias_faltados`, `monto_dias_faltados`, `abono_prestamo`, `abono_vale`, `viatico_s1`, `viatico_s2`, `viatico_s3`, `viatico_s4`, `ihss_empleado`, `ihss_patronal`, `rap_empleado`, `isr_mensual`, `seguro_privado`, `aplicar_seguro`, `otras_deducciones`, `total_deducciones`, `salario_neto`, `vacaciones_acum`, `decimo_acum`, `observaciones`) VALUES
(173, 9, 1, 14000.00, 3.00, 210.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 14210.00, 0.00, 0.00, NULL),
(174, 9, 2, 11000.00, 3.00, 210.00, 1.00, 733.33, 2000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 2733.33, 8476.67, 0.00, 0.00, NULL),
(175, 9, 3, 9000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 9000.00, 0.00, 0.00, NULL),
(176, 9, 4, 7500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 7500.00, 0.00, 0.00, NULL),
(177, 9, 5, 6000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 6000.00, 0.00, 0.00, NULL),
(178, 9, 6, 11000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 11000.00, 0.00, 0.00, NULL),
(179, 9, 7, 7500.00, 3.00, 210.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 7710.00, 0.00, 0.00, NULL),
(180, 9, 8, 7500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 7500.00, 0.00, 0.00, NULL),
(181, 9, 9, 9000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 9000.00, 0.00, 0.00, NULL),
(182, 9, 10, 5000.00, 3.00, 210.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 5210.00, 0.00, 0.00, NULL),
(183, 9, 11, 9000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 9000.00, 0.00, 0.00, NULL),
(184, 9, 12, 9250.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 9250.00, 0.00, 0.00, NULL),
(185, 9, 13, 9000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 9000.00, 0.00, 0.00, NULL),
(186, 9, 14, 6000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 6000.00, 0.00, 0.00, NULL),
(187, 9, 15, 14000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 14000.00, 0.00, 0.00, NULL),
(188, 9, 16, 13000.00, 3.00, 210.00, 0.00, 0.00, 2000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 2000.00, 11210.00, 0.00, 0.00, NULL),
(189, 9, 17, 10000.00, 3.00, 210.00, 2.00, 1333.33, 1005.15, 1000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 3338.48, 6871.52, 0.00, 0.00, NULL),
(190, 9, 18, 8000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 8000.00, 0.00, 0.00, NULL),
(191, 9, 19, 10500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 10500.00, 0.00, 0.00, NULL),
(192, 9, 20, 5000.00, 3.00, 210.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 5210.00, 0.00, 0.00, NULL),
(193, 9, 21, 6250.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 6250.00, 0.00, 0.00, NULL),
(719, 35, 1, 14000.00, 1.00, 70.00, 0.00, 0.00, 0.00, 1000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 352.25, 1, 0.00, 1352.25, 12717.75, 0.00, 0.00, NULL),
(720, 35, 2, 11000.00, 0.00, 0.00, 1.00, 733.33, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 352.25, 1, 0.00, 1085.58, 9914.42, 0.00, 0.00, NULL),
(721, 35, 3, 9000.00, 15.00, 1275.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 211.35, 1, 0.00, 211.35, 10063.65, 0.00, 0.00, NULL),
(722, 35, 4, 7500.00, 13.00, 1105.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 211.35, 1, 0.00, 211.35, 8393.65, 0.00, 0.00, NULL),
(723, 35, 5, 6000.00, 12.00, 1020.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 211.35, 1, 0.00, 211.35, 6808.65, 0.00, 0.00, NULL),
(724, 35, 6, 11000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 352.25, 1, 0.00, 352.25, 10647.75, 0.00, 0.00, NULL),
(725, 35, 7, 7500.00, 1.00, 70.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 352.25, 1, 0.00, 352.25, 7217.75, 0.00, 0.00, NULL),
(726, 35, 8, 7500.00, 15.00, 1275.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 211.35, 1, 0.00, 211.35, 8563.65, 0.00, 0.00, NULL),
(727, 35, 9, 9000.00, 12.00, 1020.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 211.35, 1, 0.00, 211.35, 9808.65, 0.00, 0.00, NULL),
(728, 35, 10, 5000.00, 1.00, 70.00, 2.00, 666.67, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 666.67, 4403.33, 0.00, 0.00, NULL),
(729, 35, 11, 9000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 211.35, 1, 0.00, 211.35, 8788.65, 0.00, 0.00, NULL),
(730, 35, 12, 9250.00, 12.00, 1020.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 0.00, 10270.00, 0.00, 0.00, NULL),
(731, 35, 13, 9000.00, 12.00, 1020.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 211.35, 1, 0.00, 211.35, 9808.65, 0.00, 0.00, NULL),
(732, 35, 14, 6000.00, 12.00, 1020.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 211.35, 1, 0.00, 211.35, 6808.65, 0.00, 0.00, NULL),
(733, 35, 15, 14000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 352.25, 1, 0.00, 352.25, 13647.75, 0.00, 0.00, NULL),
(734, 35, 16, 13000.00, 1.00, 70.00, 0.00, 0.00, 2000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 352.25, 1, 0.00, 2352.25, 10717.75, 0.00, 0.00, NULL),
(735, 35, 17, 10000.00, 1.00, 70.00, 1.00, 666.67, 1005.15, 800.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 2471.82, 7598.18, 0.00, 0.00, NULL),
(736, 35, 19, 10500.00, 12.00, 1020.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 211.35, 1, 0.00, 211.35, 11308.65, 0.00, 0.00, NULL),
(737, 35, 18, 8000.00, 12.00, 1020.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 211.35, 1, 0.00, 211.35, 8808.65, 0.00, 0.00, NULL),
(738, 35, 20, 5000.00, 1.00, 70.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 0.00, 5070.00, 0.00, 0.00, NULL),
(739, 35, 21, 6250.00, 12.00, 1020.00, 1.00, 416.67, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 211.35, 1, 0.00, 628.02, 6641.98, 0.00, 0.00, NULL),
(845, 41, 1, 14000.00, 3.00, 210.00, 0.00, 0.00, 0.00, 1000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 1000.00, 13210.00, 0.00, 0.00, NULL),
(846, 41, 3, 9000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 9000.00, 0.00, 0.00, NULL),
(847, 41, 4, 7500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 7500.00, 0.00, 0.00, NULL),
(848, 41, 5, 6000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 6000.00, 0.00, 0.00, NULL),
(849, 41, 6, 11000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 11000.00, 0.00, 0.00, NULL),
(850, 41, 7, 7500.00, 3.00, 210.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 7710.00, 0.00, 0.00, NULL),
(851, 41, 8, 7500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 7500.00, 0.00, 0.00, NULL),
(852, 41, 9, 9000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 9000.00, 0.00, 0.00, NULL),
(853, 41, 10, 5000.00, 3.00, 210.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 5210.00, 0.00, 0.00, NULL),
(854, 41, 22, 9000.00, 3.00, 210.00, 8.00, 4800.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 4800.00, 4410.00, 0.00, 0.00, NULL),
(855, 41, 11, 9000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 9000.00, 0.00, 0.00, NULL),
(856, 41, 12, 9250.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 9250.00, 0.00, 0.00, NULL),
(857, 41, 13, 9000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 9000.00, 0.00, 0.00, NULL),
(858, 41, 14, 6000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 6000.00, 0.00, 0.00, NULL),
(859, 41, 15, 14000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 14000.00, 0.00, 0.00, NULL),
(860, 41, 16, 13000.00, 3.00, 210.00, 0.00, 0.00, 2000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 2000.00, 11210.00, 0.00, 0.00, NULL),
(861, 41, 17, 10000.00, 3.00, 210.00, 0.00, 0.00, 1005.15, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 1005.15, 9204.85, 0.00, 0.00, NULL),
(862, 41, 19, 10500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 10500.00, 0.00, 0.00, NULL),
(863, 41, 18, 8000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 8000.00, 0.00, 0.00, NULL),
(864, 41, 20, 5000.00, 1.00, 70.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 5070.00, 0.00, 0.00, NULL),
(865, 41, 21, 6250.00, 0.00, 0.00, 1.00, 416.67, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 416.67, 5833.33, 0.00, 0.00, NULL),
(1013, 49, 22, 10000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 1000.00, 9000.00, 0.00, 0.00, NULL),
(1014, 49, 19, 10500.00, 8.00, 680.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 10964.16, 0.00, 0.00, NULL),
(1015, 49, 6, 11000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 359.74, 1, 0.00, 359.74, 10640.26, 0.00, 0.00, NULL),
(1016, 49, 18, 8000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 7784.16, 0.00, 0.00, NULL),
(1017, 49, 9, 9000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 8784.16, 0.00, 0.00, NULL),
(1018, 49, 15, 14000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 359.74, 1, 0.00, 359.74, 13640.26, 0.00, 0.00, NULL),
(1019, 49, 13, 9000.00, 3.00, 255.00, 2.00, 1200.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 1415.84, 7839.16, 0.00, 0.00, NULL),
(1020, 49, 21, 6250.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 6034.16, 0.00, 0.00, NULL),
(1021, 49, 20, 5000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 0.00, 5000.00, 0.00, 0.00, NULL),
(1022, 49, 16, 13000.00, 0.00, 0.00, 0.00, 0.00, 2000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 359.74, 1, 0.00, 2359.74, 10640.26, 0.00, 0.00, NULL),
(1023, 49, 1, 14000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 359.74, 1, 0.00, 1359.74, 12640.26, 0.00, 0.00, NULL),
(1024, 49, 11, 9000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 8784.16, 0.00, 0.00, NULL),
(1025, 49, 5, 6000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 5784.16, 0.00, 0.00, NULL),
(1026, 49, 10, 5000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 0.00, 5000.00, 0.00, 0.00, NULL),
(1027, 49, 3, 9000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 8784.16, 0.00, 0.00, NULL),
(1028, 49, 4, 7500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 7284.16, 0.00, 0.00, NULL),
(1029, 49, 17, 10000.00, 0.00, 0.00, 0.00, 0.00, 1005.15, 1500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 2505.15, 7494.85, 0.00, 0.00, NULL),
(1030, 49, 14, 6000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 5784.16, 0.00, 0.00, NULL),
(1031, 49, 12, 9250.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 0.00, 9250.00, 0.00, 0.00, NULL),
(1032, 49, 8, 7500.00, 6.00, 510.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 7794.16, 0.00, 0.00, NULL),
(1033, 49, 7, 7500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 359.74, 1, 0.00, 359.74, 7140.26, 0.00, 0.00, NULL),
(1298, 62, 22, 10000.00, 24.05, 1683.50, 0.00, 0.00, 0.00, 1000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 1000.00, 10683.50, 0.00, 0.00, NULL),
(1299, 62, 19, 10500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 10500.00, 0.00, 0.00, NULL),
(1300, 62, 6, 11000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 11000.00, 0.00, 0.00, NULL),
(1301, 62, 23, 8000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 8000.00, 0.00, 0.00, NULL),
(1302, 62, 18, 8000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 8000.00, 0.00, 0.00, NULL),
(1303, 62, 9, 9000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 9000.00, 0.00, 0.00, NULL),
(1304, 62, 15, 14000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 14000.00, 0.00, 0.00, NULL),
(1305, 62, 13, 9000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 9000.00, 0.00, 0.00, NULL),
(1306, 62, 21, 6250.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 6250.00, 0.00, 0.00, NULL),
(1307, 62, 20, 5000.00, 3.00, 210.00, 0.00, 0.00, 0.00, 1000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 1000.00, 4210.00, 0.00, 0.00, NULL),
(1308, 62, 16, 13000.00, 5.00, 350.00, 0.00, 0.00, 2000.00, 4500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 6500.00, 6850.00, 0.00, 0.00, NULL),
(1309, 62, 1, 14000.00, 3.00, 210.00, 0.00, 0.00, 0.00, 2000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 2000.00, 12210.00, 0.00, 0.00, NULL),
(1310, 62, 11, 9000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 9000.00, 0.00, 0.00, NULL),
(1311, 62, 5, 6000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 6000.00, 0.00, 0.00, NULL),
(1312, 62, 10, 5000.00, 5.00, 350.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 5350.00, 0.00, 0.00, NULL),
(1313, 62, 3, 9000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 9000.00, 0.00, 0.00, NULL),
(1314, 62, 4, 7500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 7500.00, 0.00, 0.00, NULL),
(1315, 62, 17, 10000.00, 28.05, 1963.50, 0.00, 0.00, 1144.12, 1000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 2144.12, 9819.38, 0.00, 0.00, NULL),
(1316, 62, 14, 6000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 6000.00, 0.00, 0.00, NULL),
(1317, 62, 12, 9250.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 9250.00, 0.00, 0.00, NULL),
(1318, 62, 8, 7500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 7500.00, 0.00, 0.00, NULL),
(1319, 62, 7, 7500.00, 5.00, 350.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 7850.00, 0.00, 0.00, NULL),
(1646, 96, 24, 7000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 3500.00, 3500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 0.00, 14000.00, 0.00, 0.00, NULL),
(1647, 96, 25, 7000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 3500.00, 3500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 0.00, 14000.00, 0.00, 0.00, NULL),
(1648, 96, 26, 7000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 3500.00, 3500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 0.00, 14000.00, 0.00, 0.00, NULL),
(1671, 98, 22, 10000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 359.74, 1, 0.00, 859.74, 9140.26, 0.00, 0.00, NULL),
(1672, 98, 19, 10500.00, 27.00, 2295.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 12579.16, 0.00, 0.00, NULL),
(1673, 98, 6, 11000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 359.74, 1, 0.00, 359.74, 10640.26, 0.00, 0.00, NULL),
(1674, 98, 23, 8000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 0.00, 8000.00, 0.00, 0.00, NULL),
(1675, 98, 18, 8000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 7784.16, 0.00, 0.00, NULL),
(1676, 98, 9, 9000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 8784.16, 0.00, 0.00, NULL),
(1677, 98, 15, 14000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 359.74, 1, 0.00, 359.74, 13640.26, 0.00, 0.00, NULL),
(1678, 98, 13, 9000.00, 9.00, 765.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 9549.16, 0.00, 0.00, NULL),
(1679, 98, 21, 6250.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 6034.16, 0.00, 0.00, NULL),
(1680, 98, 20, 5000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 500.00, 4500.00, 0.00, 0.00, NULL),
(1681, 98, 16, 13000.00, 0.00, 0.00, 0.00, 0.00, 2000.00, 1000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 359.74, 1, 0.00, 3359.74, 9640.26, 0.00, 0.00, NULL),
(1682, 98, 1, 14000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 359.74, 1, 0.00, 359.74, 13640.26, 0.00, 0.00, NULL),
(1683, 98, 11, 9000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 8784.16, 0.00, 0.00, NULL),
(1684, 98, 5, 6000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 5784.16, 0.00, 0.00, NULL),
(1685, 98, 10, 5000.00, 0.00, 0.00, 10.00, 3333.33, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 3333.33, 1666.67, 0.00, 0.00, NULL),
(1686, 98, 3, 9000.00, 15.00, 1275.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 10059.16, 0.00, 0.00, NULL),
(1687, 98, 4, 7500.00, 14.00, 1190.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 8474.16, 0.00, 0.00, NULL),
(1688, 98, 17, 10000.00, 0.00, 0.00, 0.00, 0.00, 1144.12, 500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 359.74, 1, 0.00, 2003.86, 7996.14, 0.00, 0.00, NULL),
(1689, 98, 14, 6000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 5784.16, 0.00, 0.00, NULL),
(1690, 98, 12, 9250.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 0.00, 9250.00, 0.00, 0.00, NULL),
(1691, 98, 8, 7500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 7284.16, 0.00, 0.00, NULL),
(1692, 98, 7, 7500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 359.74, 1, 0.00, 359.74, 7140.26, 0.00, 0.00, NULL),
(1693, 99, 24, 7000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 3500.00, 3500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 14000.00, 0.00, 0.00, NULL),
(1694, 99, 25, 7000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 3500.00, 3500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 14000.00, 0.00, 0.00, NULL),
(1903, 124, 22, 10000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 10000.00, 0.00, 0.00, NULL),
(1904, 124, 19, 10500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 10500.00, 0.00, 0.00, NULL),
(1905, 124, 6, 11000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 11000.00, 0.00, 0.00, NULL),
(1906, 124, 23, 8000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 8000.00, 0.00, 0.00, NULL),
(1907, 124, 18, 8000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 8000.00, 0.00, 0.00, NULL),
(1908, 124, 9, 9000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 9000.00, 0.00, 0.00, NULL),
(1909, 124, 15, 14000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 14000.00, 0.00, 0.00, NULL),
(1910, 124, 13, 9000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 9000.00, 0.00, 0.00, NULL),
(1911, 124, 21, 6250.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 6250.00, 0.00, 0.00, NULL),
(1912, 124, 20, 5000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 5000.00, 0.00, 0.00, NULL),
(1913, 124, 16, 13000.00, 0.00, 0.00, 0.00, 0.00, 2000.00, 2000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 4000.00, 9000.00, 0.00, 0.00, NULL),
(1914, 124, 1, 14000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 14000.00, 0.00, 0.00, NULL),
(1915, 124, 11, 9000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 9000.00, 0.00, 0.00, NULL),
(1916, 124, 5, 6000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 6000.00, 0.00, 0.00, NULL),
(1917, 124, 3, 9000.00, 0.00, 0.00, 1.00, 600.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 600.00, 8400.00, 0.00, 0.00, NULL),
(1918, 124, 4, 7500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 7500.00, 0.00, 0.00, NULL),
(1919, 124, 17, 10000.00, 0.00, 0.00, 2.00, 1333.33, 1144.12, 800.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 3277.45, 6722.55, 0.00, 0.00, NULL),
(1920, 124, 14, 6000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 6000.00, 0.00, 0.00, NULL),
(1921, 124, 12, 9250.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 9250.00, 0.00, 0.00, NULL),
(1922, 124, 8, 7500.00, 0.00, 0.00, 1.00, 500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 500.00, 7000.00, 0.00, 0.00, NULL),
(1923, 124, 7, 7500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 7500.00, 0.00, 0.00, NULL),
(1949, 138, 24, 14000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 'EXCLUIDO'),
(1950, 138, 25, 14000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 'EXCLUIDO'),
(1973, 141, 22, 20000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 'EXCLUIDO'),
(1974, 141, 19, 21000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 0.00, 21000.00, 0.00, 0.00, NULL),
(1975, 141, 6, 22000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 0.00, 9704.11, 0.00, 0.00, NULL),
(1976, 141, 23, 16000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 'EXCLUIDO'),
(1977, 141, 18, 16000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 0.00, 16000.00, 0.00, 0.00, NULL),
(1978, 141, 9, 18000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 0.00, 18000.00, 0.00, 0.00, NULL),
(1979, 141, 15, 28000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 'EXCLUIDO'),
(1980, 141, 13, 18000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 0.00, 15978.08, 0.00, 0.00, NULL),
(1981, 141, 21, 12500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 0.00, 12500.00, 0.00, 0.00, NULL),
(1982, 141, 20, 10000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 0.00, 2493.15, 0.00, 0.00, NULL),
(1983, 141, 16, 26000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 'EXCLUIDO'),
(1984, 141, 1, 28000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 'EXCLUIDO'),
(1985, 141, 11, 18000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 0.00, 18000.00, 0.00, 0.00, NULL),
(1986, 141, 5, 12000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 0.00, 12000.00, 0.00, 0.00, NULL),
(1987, 141, 3, 18000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 0.00, 18000.00, 0.00, 0.00, NULL),
(1988, 141, 4, 15000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 0.00, 15000.00, 0.00, 0.00, NULL),
(1989, 141, 17, 20000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 'EXCLUIDO'),
(1990, 141, 14, 12000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 0.00, 11539.73, 0.00, 0.00, NULL),
(1991, 141, 12, 18500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 0.00, 18500.00, 0.00, 0.00, NULL),
(1992, 141, 8, 15000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 0.00, 15000.00, 0.00, 0.00, NULL),
(1993, 141, 7, 15000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 0.00, 0.00, 0.00, 0.00, 'EXCLUIDO'),
(1994, 142, 25, 7000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 3500.00, 3500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 14000.00, 0.00, 0.00, NULL),
(2016, 144, 22, 10000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 359.74, 1, 0.00, 1359.74, 8640.26, 0.00, 0.00, NULL),
(2017, 144, 19, 10500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 10284.16, 0.00, 0.00, NULL),
(2018, 144, 6, 11000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 359.74, 1, 0.00, 359.74, 10640.26, 0.00, 0.00, NULL),
(2019, 144, 23, 8000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 359.74, 1, 0.00, 359.74, 7640.26, 0.00, 0.00, NULL),
(2020, 144, 18, 8000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 7784.16, 0.00, 0.00, NULL),
(2021, 144, 9, 9000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 8784.16, 0.00, 0.00, NULL),
(2022, 144, 15, 14000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 359.74, 1, 0.00, 359.74, 13640.26, 0.00, 0.00, NULL),
(2023, 144, 13, 9000.00, 19.00, 1615.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 10399.16, 0.00, 0.00, NULL),
(2024, 144, 21, 6250.00, 20.00, 1700.00, 2.00, 833.33, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 1049.17, 6900.83, 0.00, 0.00, NULL),
(2025, 144, 20, 5000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 500.00, 4500.00, 0.00, 0.00, NULL),
(2026, 144, 16, 13000.00, 0.00, 0.00, 0.00, 0.00, 2000.00, 500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 359.74, 1, 0.00, 2859.74, 10140.26, 0.00, 0.00, NULL),
(2027, 144, 1, 14000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 359.74, 1, 0.00, 1359.74, 12640.26, 0.00, 0.00, NULL),
(2028, 144, 11, 9000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 8784.16, 0.00, 0.00, NULL),
(2029, 144, 5, 6000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 5784.16, 0.00, 0.00, NULL),
(2030, 144, 3, 9000.00, 21.00, 1785.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 10569.16, 0.00, 0.00, NULL),
(2031, 144, 4, 7500.00, 20.00, 1700.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 8984.16, 0.00, 0.00, NULL),
(2032, 144, 17, 10000.00, 0.00, 0.00, 2.00, 1333.33, 0.00, 1000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 359.74, 1, 0.00, 2693.07, 7306.93, 0.00, 0.00, NULL),
(2033, 144, 14, 6000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 5784.16, 0.00, 0.00, NULL),
(2034, 144, 12, 9250.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 0.00, 9250.00, 0.00, 0.00, NULL),
(2035, 144, 8, 7500.00, 0.00, 0.00, 3.00, 1500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 1715.84, 5784.16, 0.00, 0.00, NULL),
(2036, 144, 7, 7500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 359.74, 1, 0.00, 859.74, 6640.26, 0.00, 0.00, NULL),
(2744, 189, 28, 7000.00, 0.00, 0.00, 7.50, 3500.00, 0.00, 0.00, 0.00, 3500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 3500.00, 7000.00, 0.00, 0.00, NULL),
(2745, 189, 19, 10500.00, 26.67, 1866.90, 4.00, 2800.00, 0.00, 0.00, 0.00, 3500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 2800.00, 13066.90, 0.00, 0.00, NULL),
(2746, 189, 6, 11000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 11000.00, 0.00, 0.00, NULL),
(2747, 189, 18, 8000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 8000.00, 0.00, 0.00, NULL),
(2748, 189, 9, 9000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 9000.00, 0.00, 0.00, NULL),
(2749, 189, 15, 14000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 14000.00, 0.00, 0.00, NULL),
(2750, 189, 13, 9000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 9000.00, 0.00, 0.00, NULL),
(2751, 189, 21, 6250.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 6250.00, 0.00, 0.00, NULL),
(2752, 189, 20, 5000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 5000.00, 0.00, 0.00, NULL),
(2753, 189, 16, 14000.00, 0.00, 0.00, 0.00, 0.00, 2000.00, 2000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 4000.00, 10000.00, 0.00, 0.00, NULL),
(2754, 189, 31, 20000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 20000.00, 0.00, 0.00, NULL),
(2755, 189, 33, 7500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 7500.00, 0.00, 0.00, NULL),
(2756, 189, 5, 6000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 6000.00, 0.00, 0.00, NULL),
(2757, 189, 4, 7500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 7500.00, 0.00, 0.00, NULL),
(2758, 189, 30, 7000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 3500.00, 3500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 14000.00, 0.00, 0.00, NULL),
(2759, 189, 14, 6000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 6000.00, 0.00, 0.00, NULL),
(2760, 189, 25, 7000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 3500.00, 3500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 14000.00, 0.00, 0.00, NULL),
(2761, 189, 12, 9250.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 9250.00, 0.00, 0.00, NULL),
(2762, 189, 8, 7500.00, 0.00, 0.00, 2.00, 1000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 1000.00, 6500.00, 0.00, 0.00, NULL),
(2763, 189, 7, 8500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 8500.00, 0.00, 0.00, NULL),
(2764, 190, 22, 10000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 10000.00, 0.00, 0.00, NULL),
(2765, 190, 1, 14000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 14000.00, 0.00, 0.00, NULL),
(2766, 190, 32, 9000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 9000.00, 0.00, 0.00, NULL),
(2767, 190, 17, 10000.00, 0.00, 0.00, 0.00, 0.00, 1144.12, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 1144.12, 8855.88, 0.00, 0.00, NULL),
(2768, 191, 22, 10000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 500.00, 9500.00, 0.00, 0.00, NULL),
(2769, 191, 1, 14000.00, 16.00, 1120.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 15120.00, 0.00, 0.00, NULL),
(2770, 191, 17, 10000.00, 16.00, 1120.00, 0.00, 0.00, 1144.12, 2000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 3144.12, 7975.88, 0.00, 0.00, NULL),
(2815, 194, 28, 7000.00, 0.00, 0.00, 3.00, 1400.00, 0.00, 0.00, 3500.00, 3500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 1400.00, 12600.00, 0.00, 0.00, NULL),
(2816, 194, 19, 10500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 10500.00, 0.00, 0.00, NULL),
(2817, 194, 6, 11000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 11000.00, 0.00, 0.00, NULL),
(2818, 194, 23, 8000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 8000.00, 0.00, 0.00, NULL),
(2819, 194, 18, 8000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 8000.00, 0.00, 0.00, NULL),
(2820, 194, 9, 9000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 9000.00, 0.00, 0.00, NULL),
(2821, 194, 15, 14000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 14000.00, 0.00, 0.00, NULL),
(2822, 194, 27, 7000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 3500.00, 3500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 14000.00, 0.00, 0.00, NULL),
(2823, 194, 13, 9000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 9000.00, 0.00, 0.00, NULL),
(2824, 194, 21, 6250.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 6250.00, 0.00, 0.00, NULL),
(2825, 194, 20, 5000.00, 0.00, 0.00, 1.00, 333.33, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 333.33, 4666.67, 0.00, 0.00, NULL),
(2826, 194, 16, 13000.00, 0.00, 0.00, 0.00, 0.00, 2000.00, 1000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 3000.00, 10000.00, 0.00, 0.00, NULL),
(2827, 194, 29, 7000.00, 0.00, 0.00, 12.00, 5600.00, 0.00, 0.00, 3500.00, 3500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 5600.00, 8400.00, 0.00, 0.00, NULL),
(2828, 194, 11, 9000.00, 0.00, 0.00, 8.00, 4800.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 4800.00, 4200.00, 0.00, 0.00, NULL),
(2829, 194, 5, 6000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 6000.00, 0.00, 0.00, NULL),
(2830, 194, 3, 9000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 9000.00, 0.00, 0.00, NULL),
(2831, 194, 4, 7500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 7500.00, 0.00, 0.00, NULL),
(2832, 194, 14, 6000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 6000.00, 0.00, 0.00, NULL),
(2833, 194, 25, 7000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 3500.00, 3500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 14000.00, 0.00, 0.00, NULL),
(2834, 194, 12, 9250.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 9250.00, 0.00, 0.00, NULL),
(2835, 194, 8, 7500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 7500.00, 0.00, 0.00, NULL),
(2836, 194, 7, 7500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 1000.00, 6500.00, 0.00, 0.00, NULL),
(2837, 195, 22, 10000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 359.74, 1, 0.00, 359.74, 9640.26, 0.00, 0.00, NULL),
(2838, 195, 1, 14000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 359.74, 1, 0.00, 359.74, 13640.26, 0.00, 0.00, NULL),
(2839, 195, 17, 10000.00, 0.00, 0.00, 0.00, 0.00, 1144.12, 2300.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 359.74, 1, 0.00, 3803.86, 6196.14, 0.00, 0.00, NULL),
(2928, 200, 28, 7000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 3500.00, 3500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 0.00, 14000.00, 0.00, 0.00, NULL),
(2929, 200, 19, 10500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 10284.16, 0.00, 0.00, NULL),
(2930, 200, 6, 11000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 359.74, 1, 0.00, 359.74, 10640.26, 0.00, 0.00, NULL),
(2931, 200, 23, 8000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 359.74, 1, 0.00, 359.74, 7640.26, 0.00, 0.00, NULL),
(2932, 200, 18, 8000.00, 0.00, 0.00, 1.00, 533.33, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 749.17, 7250.83, 0.00, 0.00, NULL),
(2933, 200, 9, 9000.00, 6.00, 510.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 9294.16, 0.00, 0.00, NULL),
(2934, 200, 15, 14000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 359.74, 1, 0.00, 359.74, 13640.26, 0.00, 0.00, NULL),
(2935, 200, 27, 7000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 3500.00, 3500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 14000.00, 0.00, 0.00, NULL),
(2936, 200, 13, 9000.00, 4.00, 340.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 9124.16, 0.00, 0.00, NULL),
(2937, 200, 21, 6250.00, 0.00, 0.00, 2.00, 833.33, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 1049.17, 5200.83, 0.00, 0.00, NULL),
(2938, 200, 20, 5000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 5000.00, 0.00, 0.00, NULL),
(2939, 200, 16, 13000.00, 0.00, 0.00, 0.00, 0.00, 2000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 359.74, 1, 0.00, 2359.74, 10640.26, 0.00, 0.00, NULL),
(2940, 200, 29, 7000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 3500.00, 3500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 14000.00, 0.00, 0.00, NULL),
(2941, 200, 11, 9000.00, 0.00, 0.00, 15.00, 9000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 9000.00, 0.00, 0.00, 0.00, NULL),
(2942, 200, 5, 6000.00, 3.00, 255.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 6039.16, 0.00, 0.00, NULL),
(2943, 200, 3, 9000.00, 0.00, 0.00, 15.00, 9000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 9000.00, 0.00, 0.00, 0.00, NULL),
(2944, 200, 4, 7500.00, 0.00, 0.00, 1.00, 500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 715.84, 6784.16, 0.00, 0.00, NULL),
(2945, 200, 14, 6000.00, 9.00, 765.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 6549.16, 0.00, 0.00, NULL),
(2946, 200, 25, 7000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 3500.00, 3500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 14000.00, 0.00, 0.00, NULL),
(2947, 200, 12, 9250.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 9250.00, 0.00, 0.00, NULL),
(2948, 200, 8, 7500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 7284.16, 0.00, 0.00, NULL),
(2949, 200, 7, 7500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 359.74, 1, 0.00, 1359.74, 6140.26, 0.00, 0.00, NULL),
(2950, 201, 22, 10000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 500.00, 9500.00, 0.00, 0.00, NULL),
(2951, 201, 1, 14000.00, 8.00, 560.00, 0.00, 0.00, 0.00, 500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 500.00, 14060.00, 0.00, 0.00, NULL),
(2952, 201, 32, 8000.00, 0.00, 0.00, 8.00, 4266.67, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 4266.67, 3733.33, 0.00, 0.00, NULL),
(2953, 201, 17, 10000.00, 8.00, 560.00, 0.00, 0.00, 1144.12, 1300.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 2444.12, 8115.88, 0.00, 0.00, NULL),
(2954, 202, 28, 7000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 3500.00, 3500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 14000.00, 0.00, 0.00, NULL),
(2955, 202, 19, 10500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 10500.00, 0.00, 0.00, NULL),
(2956, 202, 6, 11000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 11000.00, 0.00, 0.00, NULL),
(2957, 202, 23, 8000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 8000.00, 0.00, 0.00, NULL),
(2958, 202, 18, 8000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 8000.00, 0.00, 0.00, NULL),
(2959, 202, 9, 9000.00, 0.00, 0.00, 2.00, 1200.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 1200.00, 7800.00, 0.00, 0.00, NULL),
(2960, 202, 15, 14000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 14000.00, 0.00, 0.00, NULL),
(2961, 202, 13, 9000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 9000.00, 0.00, 0.00, NULL),
(2962, 202, 21, 6250.00, 9.80, 833.00, 1.00, 416.67, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 416.67, 6666.33, 0.00, 0.00, NULL),
(2963, 202, 20, 5000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 5000.00, 0.00, 0.00, NULL),
(2964, 202, 16, 13000.00, 0.00, 0.00, 0.00, 0.00, 2000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 2000.00, 11000.00, 0.00, 0.00, NULL),
(2965, 202, 29, 7000.00, 0.00, 0.00, 2.00, 933.33, 0.00, 2000.00, 3500.00, 3500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 2933.33, 11066.67, 0.00, 0.00, NULL),
(2966, 202, 31, 20000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 20000.00, 0.00, 0.00, NULL),
(2967, 202, 5, 6000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 6000.00, 0.00, 0.00, NULL),
(2968, 202, 4, 7500.00, 5.88, 499.80, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 7999.80, 0.00, 0.00, NULL),
(2969, 202, 30, 7000.00, 0.00, 0.00, 2.00, 933.33, 0.00, 0.00, 3500.00, 3500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 933.33, 13066.67, 0.00, 0.00, NULL),
(2970, 202, 14, 6000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 6000.00, 0.00, 0.00, NULL),
(2971, 202, 25, 7000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 3500.00, 3500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 14000.00, 0.00, 0.00, NULL),
(2972, 202, 12, 9250.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 9250.00, 0.00, 0.00, NULL),
(2973, 202, 8, 7500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 7500.00, 0.00, 0.00, NULL),
(2974, 202, 7, 7500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 7500.00, 0.00, 0.00, NULL),
(2996, 204, 28, 7000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 359.74, 1, 0.00, 359.74, 6640.26, 0.00, 0.00, NULL),
(2997, 204, 19, 10500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 10284.16, 0.00, 0.00, NULL),
(2998, 204, 6, 11000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 359.74, 1, 0.00, 359.74, 10640.26, 0.00, 0.00, NULL),
(2999, 204, 23, 8000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 359.74, 1, 0.00, 359.74, 7640.26, 0.00, 0.00, NULL),
(3000, 204, 18, 8000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 7784.16, 0.00, 0.00, NULL),
(3001, 204, 9, 9000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 8784.16, 0.00, 0.00, NULL),
(3002, 204, 15, 14000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 359.74, 1, 0.00, 359.74, 13640.26, 0.00, 0.00, NULL),
(3003, 204, 13, 9000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 8784.16, 0.00, 0.00, NULL),
(3004, 204, 21, 6250.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 6034.16, 0.00, 0.00, NULL),
(3005, 204, 20, 5000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 5000.00, 0.00, 0.00, NULL),
(3006, 204, 16, 13000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 359.74, 1, 0.00, 359.74, 12640.26, 0.00, 0.00, NULL),
(3007, 204, 29, 7000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 7000.00, 0.00, 0.00, NULL),
(3008, 204, 31, 20000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 359.74, 1, 0.00, 359.74, 19640.26, 0.00, 0.00, NULL);
INSERT INTO `detalle_planilla` (`id_detalle`, `planilla_id`, `empleado_id`, `salario_base`, `horas_extra`, `monto_horas_extra`, `dias_faltados`, `monto_dias_faltados`, `abono_prestamo`, `abono_vale`, `viatico_s1`, `viatico_s2`, `viatico_s3`, `viatico_s4`, `ihss_empleado`, `ihss_patronal`, `rap_empleado`, `isr_mensual`, `seguro_privado`, `aplicar_seguro`, `otras_deducciones`, `total_deducciones`, `salario_neto`, `vacaciones_acum`, `decimo_acum`, `observaciones`) VALUES
(3009, 204, 5, 6000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 5784.16, 0.00, 0.00, NULL),
(3010, 204, 4, 7500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 7284.16, 0.00, 0.00, NULL),
(3011, 204, 30, 7000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 7000.00, 0.00, 0.00, NULL),
(3012, 204, 14, 6000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 5784.16, 0.00, 0.00, NULL),
(3013, 204, 25, 7000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 7000.00, 0.00, 0.00, NULL),
(3014, 204, 12, 9250.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 9250.00, 0.00, 0.00, NULL),
(3015, 204, 8, 7500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 7284.16, 0.00, 0.00, NULL),
(3016, 204, 7, 7500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 359.74, 1, 0.00, 359.74, 7140.26, 0.00, 0.00, NULL),
(3017, 205, 22, 10000.00, 4.00, 280.00, 0.00, 0.00, 0.00, 500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 359.74, 1, 0.00, 859.74, 9420.26, 0.00, 0.00, NULL),
(3018, 205, 1, 14000.00, 6.00, 420.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 359.74, 1, 0.00, 359.74, 14060.26, 0.00, 0.00, NULL),
(3019, 205, 32, 9000.00, 4.00, 280.00, 0.00, 0.00, 0.00, 500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 500.00, 8780.00, 0.00, 0.00, NULL),
(3020, 205, 17, 10000.00, 4.00, 280.00, 1.00, 666.67, 1144.12, 500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 359.74, 1, 0.00, 2670.53, 7609.47, 0.00, 0.00, NULL),
(3084, 209, 28, 7000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 3500.00, 3500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 0.00, 14000.00, 0.00, 0.00, NULL),
(3085, 209, 19, 10500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 10284.16, 0.00, 0.00, NULL),
(3086, 209, 6, 11000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 359.74, 1, 0.00, 359.74, 10640.26, 0.00, 0.00, NULL),
(3087, 209, 23, 8000.00, 0.00, 0.00, 14.33, 7640.26, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 359.74, 1, 0.00, 8000.00, 0.00, 0.00, 0.00, NULL),
(3088, 209, 18, 8000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 7784.16, 0.00, 0.00, NULL),
(3089, 209, 9, 9000.00, 6.00, 510.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 9294.16, 0.00, 0.00, NULL),
(3090, 209, 15, 14000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 359.74, 1, 0.00, 359.74, 13640.26, 0.00, 0.00, NULL),
(3091, 209, 13, 9000.00, 0.00, 0.00, 1.00, 600.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 815.84, 8184.16, 0.00, 0.00, NULL),
(3092, 209, 21, 6250.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 6034.16, 0.00, 0.00, NULL),
(3093, 209, 20, 5000.00, 0.00, 0.00, 1.00, 333.33, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 333.33, 4666.67, 0.00, 0.00, NULL),
(3094, 209, 16, 14000.00, 14.29, 1000.30, 0.00, 0.00, 2000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 359.74, 1, 0.00, 2359.74, 12640.56, 0.00, 0.00, NULL),
(3095, 209, 31, 20000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0, 0.00, 0.00, 20000.00, 0.00, 0.00, NULL),
(3096, 209, 33, 7500.00, 0.00, 0.00, 7.00, 3500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 3500.00, 4000.00, 0.00, 0.00, NULL),
(3097, 209, 5, 6000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 5784.16, 0.00, 0.00, NULL),
(3098, 209, 4, 7500.00, 6.00, 510.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 7794.16, 0.00, 0.00, NULL),
(3099, 209, 30, 7000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 3500.00, 3500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 14000.00, 0.00, 0.00, NULL),
(3100, 209, 14, 6000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 5784.16, 0.00, 0.00, NULL),
(3101, 209, 25, 7000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 3500.00, 3500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 14000.00, 0.00, 0.00, NULL),
(3102, 209, 12, 9250.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1, 0.00, 0.00, 9250.00, 0.00, 0.00, NULL),
(3103, 209, 8, 7500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 7284.16, 0.00, 0.00, NULL),
(3104, 209, 7, 8500.00, 6.00, 420.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 215.84, 1, 0.00, 215.84, 8704.16, 0.00, 0.00, NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empleados`
--

CREATE TABLE `empleados` (
  `id_empleado` int(10) UNSIGNED NOT NULL,
  `nombres` varchar(100) NOT NULL DEFAULT '',
  `apellidos` varchar(100) NOT NULL DEFAULT '',
  `ubicacion` enum('SOLDYMEG','VESTA') NOT NULL DEFAULT 'SOLDYMEG',
  `empresa_id` int(10) UNSIGNED DEFAULT NULL,
  `departamento_id` int(10) UNSIGNED DEFAULT NULL,
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

INSERT INTO `empleados` (`id_empleado`, `nombres`, `apellidos`, `ubicacion`, `empresa_id`, `departamento_id`, `identidad`, `puesto`, `tipo_contrato`, `salario_mensual`, `fecha_ingreso`, `ihss_numero`, `rap_numero`, `correo`, `telefono`, `direccion`, `cuenta_banco`, `banco`, `aplica_ihss`, `aplica_rap`, `aplica_isr`, `seguro_privado`, `estado`, `fecha_creacion`) VALUES
(1, 'ANGEL DANIEL', 'GUDIEL DIAZ', 'SOLDYMEG', 1, 1, '1503-1992-00266', 'MECANICO INDUSTRIAL', 'tiempo_completo', 28000.00, '2026-12-02', '', '', '', '', '', '753579951', 'BAC', 0, 0, 0, 359.74, 'activo', '2026-04-01 12:35:23'),
(2, 'ANGEL DAVID', 'GEORGE ORELLANA', 'SOLDYMEG', 1, NULL, '', 'SOLDADOR', 'tiempo_completo', 22000.00, '2026-04-01', '', '', '', '', '', '', 'BAC', 0, 0, 0, 359.74, 'inactivo', '2026-04-01 12:36:25'),
(3, 'DANI DANIEL', 'MARTINEZ MANZANAREZ', 'VESTA', 2, 1, '', 'SOLDADOR', 'tiempo_completo', 18000.00, '2025-02-01', '', '', '', '', '', '754428011', 'BAC', 0, 0, 0, 215.84, 'inactivo', '2026-04-01 12:37:10'),
(4, 'DANIEL EDGARDO', 'MEJIA RODRIGUEZ', 'VESTA', 2, 1, '1804-2003-00053', 'AYUDANTE', 'tiempo_completo', 15000.00, '2025-02-01', '', '', '', '', '', '750475481', 'BAC', 0, 0, 0, 215.84, 'activo', '2026-04-01 14:46:45'),
(5, 'DENIS JOEL', 'LOPEZ MARADIAGA', 'VESTA', 2, 1, '0606-1987-01049', 'AYUDANTE', 'tiempo_completo', 12000.00, '2025-06-10', '', '', '', '', '', '758308591', 'BAC', 0, 0, 0, 215.84, 'activo', '2026-04-01 14:47:15'),
(6, 'ELBIN MAURICIO', 'ARITA ARITA', 'SOLDYMEG', 2, 6, '0421-1987-00799', 'ADMINISTRACION', 'tiempo_completo', 22000.00, '2026-01-21', '', '', '', '9596-9903', '', '741455171', 'BAC', 0, 0, 0, 359.74, 'activo', '2026-04-01 14:48:06'),
(7, 'ELTHON SAMUEL', 'URBINA MELGAR', 'SOLDYMEG', 2, 1, '0501-2006-14093', 'SOLDADOR', 'tiempo_completo', 17000.00, '2025-02-26', '', '', '', '', '', '756000051', 'BAC', 0, 0, 0, 215.84, 'activo', '2026-04-01 14:48:24'),
(8, 'ERICK FERNANDO', 'ULLOA MIRANDA', 'SOLDYMEG', 1, 1, '0510-1998-01192', 'AYUDANTE', 'tiempo_completo', 15000.00, '2025-02-01', '', '', '', '', '', '750504391', 'BAC', 0, 0, 0, 359.74, 'activo', '2026-04-01 14:48:53'),
(9, 'ESDRAS JOEL', 'CALIX MOREIRA', 'VESTA', 2, 1, '1801-2006-01513', 'SOLDADOR', 'tiempo_completo', 18000.00, '2025-01-02', '', '', '', '', '', '753361471', 'BAC', 0, 0, 0, 215.84, 'activo', '2026-04-01 14:49:47'),
(10, 'GERSON MANUEL', 'LOPEZ URBINA', 'SOLDYMEG', 1, 1, '', 'AYUDANTE', 'tiempo_completo', 10000.00, '2026-04-01', '', '', '', '', '', '', 'BAC', 0, 0, 0, 0.00, 'inactivo', '2026-04-01 14:50:18'),
(11, 'JOEL ANDRES', 'JIMENEZ TORRES', 'VESTA', 2, 1, '', 'MECANICO AUTOMOTRIZ', 'tiempo_completo', 18000.00, '2025-02-17', '', '', '', '', '', '755862501', 'BAC', 0, 0, 0, 215.84, 'inactivo', '2026-04-01 14:50:50'),
(12, 'JUAN ANGEL', 'ULLOA GUTIERREZ', 'SOLDYMEG', 1, 1, '1804-1954-00223', 'MECANICO AUTOMOTRIZ', 'tiempo_completo', 18500.00, '2025-01-16', '', '', '', '', '', '755861871', 'BAC', 0, 0, 0, 359.74, 'activo', '2026-04-01 14:52:22'),
(13, 'JUAN CARLOS', 'ECHEVERRIA MARTINEZ', 'VESTA', 2, 1, '0314-1999-00020', 'MECANICO AUTOMOTRIZ', 'tiempo_completo', 18000.00, '2025-08-11', '', '', '', '', '', '759305841', 'BAC', 0, 0, 0, 215.84, 'activo', '2026-04-01 14:52:59'),
(14, 'LUANIS ISRAEL', 'RIVERA MARADIAGA', 'VESTA', 2, 1, '0606-2001-00166', 'AYUDANTE', 'tiempo_completo', 12000.00, '2025-07-15', '', '', '', '', '', '759232041', 'BAC', 0, 0, 0, 215.84, 'activo', '2026-04-01 14:53:33'),
(15, 'MARLENI YOSIBEL', 'CALIX MOREIRA', 'SOLDYMEG', 2, 6, '1801-1993-00896', 'ADMINISTRACION', 'tiempo_completo', 28000.00, '2023-02-20', '', '', '', '', '', '747238281', 'BAC', 0, 0, 0, 359.74, 'activo', '2026-04-01 14:53:58'),
(16, 'MELVIN DANILSON', 'GOMEZ AGUILAR', 'SOLDYMEG', 2, 1, '0606-1992-01062', 'JEFE DE TALLER', 'tiempo_completo', 28000.00, '2026-04-01', '', '', '', '', '', '725949601', 'BAC', 0, 0, 0, 359.74, 'activo', '2026-04-01 14:54:26'),
(17, 'WALTER ISAIAS', 'OVIEDO ESPINAL', 'SOLDYMEG', 1, 1, '0609-1996-00452', 'SOLDADOR', 'tiempo_completo', 20000.00, '2026-04-01', '', '', '', '', '', '759921081', 'BAC', 0, 0, 0, 359.74, 'activo', '2026-04-01 14:54:49'),
(18, 'WILLIAN DANIEL', 'BAUTISTA GUEVARA', 'VESTA', 2, 2, '1413-2004-00278', 'AYUDANTE', 'tiempo_completo', 16000.00, '2025-01-02', '', '', '', '', '', '755833971', 'BAC', 0, 0, 0, 215.84, 'activo', '2026-04-01 14:55:11'),
(19, 'WILLIAM NORTIE', 'ARDON CRUZ', 'SOLDYMEG', 2, 8, '0703-1981-05217', 'MOTORISTA', 'tiempo_completo', 14000.00, '2025-02-16', '', '', '', '', '', '740336441', 'BAC', 0, 0, 0, 359.74, 'activo', '2026-04-01 14:55:34'),
(20, 'WILSON JOSUE', 'FUNEZ FIGUEROA', 'SOLDYMEG', 2, 8, '1709-2025-00159', 'AYUDANTE', 'tiempo_completo', 10000.00, '2026-04-01', '', '', '', '', '', '759920611', 'BAC', 0, 0, 0, 0.00, 'activo', '2026-04-01 14:56:00'),
(21, 'YEFRY YAFETH', 'ESTRADA MURILLO', 'VESTA', 2, 1, '0501-2012-16478', 'AYUDANTE', 'tiempo_completo', 12500.00, '2025-01-06', '', '', '', '', '', '755849311', 'BAC', 0, 0, 0, 215.84, 'activo', '2026-04-01 14:56:28'),
(22, 'JASON ARIEL', 'ACEVEDO MEJIA', 'SOLDYMEG', 1, 1, '0501-2005-02527', 'SOLDADOR', 'tiempo_completo', 20000.00, '2026-05-08', '', '', '', '', '', '754573291', 'BAC', 0, 0, 0, 359.74, 'activo', '2026-05-09 11:29:50'),
(23, 'SANTOS', 'ARITA BELLOZA', 'SOLDYMEG', 2, 6, '0421197400393', 'ADMINISTRACION', 'tiempo_completo', 16000.00, '2026-06-01', '', '', 'ARITASANTOS319@GMAIL.COM', '96271914', '', '746254741', 'BAC', 0, 0, 0, 359.74, 'inactivo', '2026-06-01 14:17:24'),
(24, 'VALENTIN', 'MEJIA GOMEZ', 'SOLDYMEG', 2, 8, '1001-1967-00072', 'MOTORISTA', 'tiempo_completo', 14000.00, '2026-06-16', '', '', '', '3309-0619', '', '', '', 0, 0, 0, 0.00, 'inactivo', '2026-07-02 17:23:39'),
(25, 'RUBEN DARIO', 'RODRIGUEZ AMAYA', 'SOLDYMEG', 2, 8, '0509-1967-00116', 'MOTORISTA', 'tiempo_completo', 14000.00, '2026-06-16', '', '', '', '', '', '752936941', 'BAC', 0, 0, 0, 0.00, 'activo', '2026-07-06 14:51:58'),
(26, 'EFRAIN ALBERTO', 'SARMIENTO REYES', 'SOLDYMEG', 2, 8, '0501197707441', 'MOTORISTA', 'tiempo_completo', 14000.00, '2026-06-16', '', '', '', '', '', '', '', 0, 0, 0, 0.00, 'inactivo', '2026-07-06 14:53:19'),
(27, 'ORLANDO GUEVARA', 'CHAVEZ', 'SOLDYMEG', 2, 8, '0511198600120', 'MOTORISTA', 'tiempo_completo', 14000.00, '2026-08-01', '', '', '', '', '', '', '', 0, 0, 0, 0.00, 'inactivo', '2026-08-19 12:10:22'),
(28, 'MANUEL ANTONIO', 'AGUILAR DIAZ', 'SOLDYMEG', 2, 8, '1613197200942', 'MOTORISTA', 'tiempo_completo', 14000.00, '2026-08-04', '', '', '', '', '', '', '', 0, 0, 0, 359.74, 'inactivo', '2026-08-19 12:11:08'),
(29, 'JOSE LUIS', 'HERNANDEZ ZUNIGA', 'SOLDYMEG', 2, 8, '0511199200104', 'MOTORISTA', 'tiempo_completo', 14000.00, '2026-08-13', '', '', '', '', '', '', '', 0, 0, 0, 0.00, 'inactivo', '2026-08-19 12:12:17'),
(30, 'BIENVENIDO', 'MONCADA', 'SOLDYMEG', 2, 8, '0801-1979-17520', 'MOTORISTA', 'tiempo_completo', 14000.00, '2026-08-31', '', '', '', '', '', '759515461', 'BAC', 0, 0, 0, 0.00, 'activo', '2026-09-04 10:08:11'),
(31, 'OSMAR ANTONIO', 'JOVEL GUEVARA', 'SOLDYMEG', 2, 6, '0411-1990-00188', 'OPERACIONES', 'tiempo_completo', 40000.00, '2026-09-01', '', '', '', '', '', '', '', 0, 0, 0, 359.74, 'activo', '2026-09-09 15:39:46'),
(32, 'FRANKLIN DONAY', 'LIRA MARADIAGA', 'SOLDYMEG', 1, 1, '0719-1989-00485', 'SOLDADOR', 'tiempo_completo', 18000.00, '2026-09-07', '', '', '', '', '', '791713910', 'BAC', 0, 0, 0, 0.00, 'activo', '2026-09-19 08:00:10'),
(33, 'JEIMY SCARLETH', 'LOPEZ BU', 'SOLDYMEG', 2, 6, '0501-2001-04348', 'ASISTENTE ADMINISTRACION', 'tiempo_completo', 15000.00, '2026-09-23', '', '', '', '', '', '749877461', 'BAC', 0, 0, 0, 0.00, 'activo', '2026-09-23 09:56:02'),
(34, 'EDUARDO FALCONERY', 'POLANCO PERELLO', 'SOLDYMEG', 2, 6, '1804-1991-01215', '', 'tiempo_completo', 28000.00, '2026-10-21', '', '', '', '', '', '750019251', 'BAC', 0, 0, 0, 0.00, 'activo', '2026-10-21 18:33:03'),
(35, 'JUAN RENEE', 'CASTILLO FERNANDEZ', 'SOLDYMEG', 2, 8, '0511-1980-00218', 'MOTORISTA', 'tiempo_completo', 14000.00, '2026-10-21', '', '', '', '', '', '', '', 0, 0, 0, 0.00, 'activo', '2026-10-22 09:20:02'),
(36, 'DONNY MARIANO', 'HERNANDEZ GODOY', 'SOLDYMEG', 2, 8, '1503-1978-01296', 'MOTORISTA', 'tiempo_completo', 14000.00, '2026-10-24', '', '', '', '', '', '', '', 0, 0, 0, 0.00, 'activo', '2026-10-26 09:23:09');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empresas`
--

CREATE TABLE `empresas` (
  `id_empresa` int(10) UNSIGNED NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `rtn` varchar(20) DEFAULT NULL,
  `direccion` varchar(255) DEFAULT NULL,
  `telefono` varchar(30) DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `creado_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `empresas`
--

INSERT INTO `empresas` (`id_empresa`, `nombre`, `rtn`, `direccion`, `telefono`, `activo`, `creado_at`) VALUES
(1, 'SOLDYMEG', NULL, NULL, NULL, 1, '2026-07-02 19:17:06'),
(2, 'VAMER', NULL, NULL, NULL, 1, '2026-07-02 19:17:06');

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
  `descuento_porcentaje` decimal(5,2) NOT NULL DEFAULT 0.00,
  `descuento_monto` decimal(12,2) NOT NULL DEFAULT 0.00,
  `metodo_pago` enum('efectivo','tarjeta','transferencia','credito') NOT NULL DEFAULT 'efectivo',
  `referencia_pago` varchar(100) DEFAULT NULL,
  `estado` enum('emitida','pagada','pendiente','anulada') NOT NULL DEFAULT 'emitida',
  `observaciones` text DEFAULT NULL,
  `fecha_creacion` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `facturas`
--

INSERT INTO `facturas` (`id_factura`, `numero_factura`, `cai_id`, `cliente_id`, `cotizacion_id`, `orden_id`, `usuario_id`, `fecha`, `subtotal`, `isv`, `total`, `descuento_porcentaje`, `descuento_monto`, `metodo_pago`, `referencia_pago`, `estado`, `observaciones`, `fecha_creacion`) VALUES
(1, '000-001-01-00000001', 1, 8, NULL, NULL, 4, '2026-06-11', 134475.26, 20171.29, 154646.55, 0.00, 0.00, 'credito', NULL, 'anulada', ' | ANULADA: ERROR EN EL NOMBRE DEL CLIENTE SE EMITIO NUEVA FACTURA', '2026-06-11 16:38:02'),
(2, '000-001-01-00000002', 1, 8, 6, NULL, 4, '2026-06-11', 6975.00, 1046.25, 8021.25, 0.00, 0.00, 'credito', NULL, 'pagada', NULL, '2026-06-11 16:42:36'),
(3, '000-001-01-00000003', 1, 8, NULL, NULL, 4, '2026-06-17', 26000.00, 3900.00, 29900.00, 0.00, 0.00, 'credito', NULL, 'anulada', ' | ANULADA: ERROR EN VALOR NO TIENE DESCUENTOS Y REBAJAS', '2026-06-18 10:52:55'),
(4, '000-001-01-00000004', 1, 8, 8, NULL, 6, '2026-06-18', 24700.00, 3705.00, 28405.00, 0.00, 0.00, 'credito', NULL, 'pagada', NULL, '2026-06-19 16:45:55'),
(5, '000-001-01-00000005', 1, 9, NULL, NULL, 6, '2026-06-19', 134475.26, 20171.29, 154646.55, 0.00, 0.00, 'credito', NULL, 'anulada', ' | ANULADA: ERROS EN NOMBRE DE CLIENTE', '2026-06-19 16:47:21'),
(6, '000-001-01-00000006', 1, 9, 5, NULL, 6, '2026-06-19', 134475.26, 20171.29, 154646.55, 0.00, 0.00, 'credito', NULL, 'pagada', 'PERTENECE A LA COTIZACION NO.05', '2026-06-19 16:50:14'),
(7, '000-001-01-00000007', 1, 8, NULL, NULL, 6, '2026-06-22', 76016.53, 11402.48, 87419.01, 0.00, 0.00, 'credito', NULL, 'anulada', ' | ANULADA: ERROR EN PRECIO', '2026-07-01 13:23:43'),
(8, '000-001-01-00000008', 1, 8, NULL, NULL, 6, '2026-06-22', 76016.53, 11402.48, 87419.01, 0.00, 0.00, 'credito', NULL, 'anulada', ' | ANULADA: ERROR EN FECHA', '2026-07-01 13:30:29'),
(9, '000-001-01-00000009', 1, 10, NULL, NULL, 6, '2026-06-26', 1299.00, 194.85, 1493.85, 0.00, 0.00, 'credito', NULL, 'pagada', NULL, '2026-07-01 13:31:38'),
(10, '000-001-01-00000010', 1, 8, 10, NULL, 6, '2026-07-01', 76016.53, 11402.48, 87419.01, 0.00, 0.00, 'credito', NULL, 'pagada', NULL, '2026-07-01 13:32:17'),
(11, '000-001-01-00000011', 1, 10, NULL, NULL, 6, '2026-07-03', 12768.00, 1915.20, 14683.20, 0.00, 0.00, 'credito', NULL, 'pagada', NULL, '2026-07-06 09:30:48'),
(12, '000-001-01-00000012', 1, 10, NULL, NULL, 6, '2026-07-03', 23400.00, 3510.00, 26910.00, 0.00, 0.00, 'credito', NULL, 'pagada', NULL, '2026-07-06 09:39:58'),
(13, '000-001-01-00000013', 1, 8, 2, NULL, 6, '2026-07-13', 8181.95, 1227.29, 9409.24, 0.00, 0.00, 'credito', NULL, 'pagada', NULL, '2026-07-13 15:04:41'),
(14, '000-001-01-00000014', 1, 8, 15, NULL, 6, '2026-07-28', 13300.00, 1995.00, 15295.00, 0.00, 0.00, 'credito', NULL, 'pagada', NULL, '2026-07-28 11:08:18'),
(15, '000-001-01-00000015', 1, 10, NULL, NULL, 6, '2026-07-28', 3000.00, 450.00, 3450.00, 0.00, 0.00, 'credito', NULL, 'pagada', NULL, '2026-07-28 11:09:10'),
(16, '000-001-01-00000016', 1, 3, 26, NULL, 4, '2026-08-03', 15500.00, 2325.00, 17825.00, 0.00, 0.00, 'credito', NULL, 'pagada', NULL, '2026-08-03 10:51:56'),
(17, '000-001-01-00000017', 1, 3, 27, NULL, 4, '2026-08-03', 17450.00, 2617.50, 20067.50, 0.00, 0.00, 'credito', NULL, 'pagada', NULL, '2026-08-03 10:56:46'),
(18, '000-001-01-00000018', 1, 3, 28, NULL, 4, '2026-08-03', 2800.00, 420.00, 3220.00, 0.00, 0.00, 'credito', NULL, 'pagada', NULL, '2026-08-03 11:13:35'),
(19, '000-001-01-00000019', 1, 3, NULL, NULL, 4, '2026-08-03', 8000.00, 1200.00, 9200.00, 0.00, 0.00, 'credito', NULL, 'anulada', ' | ANULADA: ERROR AL TRANCRIBIR DATOS', '2026-08-03 11:15:43'),
(20, '000-001-01-00000020', 1, 3, 25, NULL, 4, '2026-08-03', 8000.00, 1200.00, 9200.00, 0.00, 0.00, 'credito', NULL, 'pagada', NULL, '2026-08-03 11:24:54'),
(21, '000-001-01-00000021', 1, 3, NULL, NULL, 6, '2026-08-12', 55000.00, 8250.00, 63250.00, 0.00, 0.00, 'credito', NULL, 'pagada', NULL, '2026-08-18 13:30:27'),
(22, '000-001-01-00000022', 1, 10, NULL, NULL, 6, '2026-08-13', 37910.00, 5686.50, 43596.50, 0.00, 0.00, 'credito', NULL, 'pagada', NULL, '2026-08-18 13:43:14'),
(23, '000-001-01-00000023', 1, 10, NULL, NULL, 6, '2026-08-13', 6384.00, 957.60, 7341.60, 0.00, 0.00, 'credito', NULL, 'pagada', NULL, '2026-08-18 13:45:43'),
(24, '000-001-01-00000024', 1, 3, NULL, NULL, 4, '2026-08-27', 33075.14, 4961.27, 38036.41, 0.00, 0.00, 'credito', NULL, 'pagada', NULL, '2026-08-27 13:38:17'),
(25, '000-001-01-00000025', 1, 3, NULL, NULL, 4, '2026-08-27', 296085.77, 44412.87, 340498.64, 0.00, 0.00, 'credito', NULL, 'anulada', ' | ANULADA: POR QUE EL DATO DE UN EMPLEADO ESTABA MAL CALCULADO', '2026-08-27 14:24:26'),
(26, '000-001-01-00000026', 1, 3, NULL, NULL, 4, '2026-08-27', 3165.69, 474.85, 3640.54, 0.00, 0.00, 'credito', NULL, 'pagada', NULL, '2026-08-27 14:35:36'),
(27, '000-001-01-00000027', 1, 3, NULL, NULL, 4, '2026-08-27', 296905.75, 44535.86, 341441.61, 0.00, 0.00, 'credito', NULL, 'pagada', NULL, '2026-08-27 14:46:49'),
(28, '000-001-01-00000028', 1, 9, NULL, NULL, 4, '2026-08-28', 50247.00, 7537.05, 57784.05, 0.00, 0.00, 'credito', NULL, 'anulada', ' | ANULADA: SE HIZO NOTA DE CREDITO NO. 01 Y NUEVA FACTURA NO.39', '2026-08-28 15:01:18'),
(29, '000-001-01-00000029', 1, 3, 38, NULL, 4, '2026-09-03', 7000.00, 1050.00, 8050.00, 0.00, 0.00, 'credito', NULL, 'pagada', NULL, '2026-09-03 15:50:06'),
(30, '000-001-01-00000030', 1, 10, NULL, NULL, 6, '2026-09-07', 101680.00, 15252.00, 116932.00, 0.00, 0.00, 'credito', NULL, 'anulada', ' | ANULADA: ERROR EN VALOR', '2026-09-07 14:55:25'),
(31, '000-001-01-00000031', 1, 10, NULL, NULL, 6, '2026-09-07', 101680.00, 15252.00, 116932.00, 0.00, 0.00, 'credito', NULL, 'pagada', 'Se dedujo L. 24,000.00 por combustible cobrado directamente por el cliente.', '2026-09-08 16:58:26'),
(32, '000-001-01-00000032', 1, 10, NULL, NULL, 6, '2026-09-07', 10640.00, 1596.00, 12236.00, 0.00, 0.00, 'credito', NULL, 'pagada', NULL, '2026-09-08 17:00:24'),
(33, '000-001-01-00000033', 1, 3, 43, NULL, 6, '2026-09-09', 14715.00, 2207.25, 16922.25, 0.00, 0.00, 'credito', NULL, 'pagada', NULL, '2026-09-10 15:37:02'),
(34, '000-001-01-00000034', 1, 12, 42, NULL, 6, '2026-09-12', 30077.50, 4511.63, 34589.13, 0.00, 0.00, 'credito', NULL, 'pagada', NULL, '2026-09-12 08:22:34'),
(35, '000-001-01-00000035', 1, 8, NULL, NULL, 6, '2026-09-16', 10435.00, 1565.25, 12000.25, 0.00, 0.00, 'credito', NULL, 'anulada', ' | ANULADA: ERROR EN VALORES', '2026-09-16 09:23:01'),
(36, '000-001-01-00000036', 1, 8, 36, NULL, 6, '2026-09-16', 10435.00, 1565.25, 12000.25, 0.00, 0.00, 'credito', NULL, 'pagada', NULL, '2026-09-16 09:24:10'),
(37, '000-001-01-00000037', 1, 3, NULL, NULL, 6, '2026-09-14', 55000.00, 8250.00, 63250.00, 0.00, 0.00, 'credito', NULL, 'pagada', NULL, '2026-09-16 09:26:38'),
(38, '000-001-01-00000038', 1, 3, 33, NULL, 6, '2026-09-17', 29000.00, 4350.00, 33350.00, 0.00, 0.00, 'credito', NULL, 'pagada', NULL, '2026-09-17 11:27:46'),
(39, '000-001-01-00000039', 1, 9, 11, NULL, 6, '2026-09-18', 50247.00, 7537.05, 57784.05, 0.00, 0.00, 'credito', NULL, 'pagada', NULL, '2026-09-21 09:39:34'),
(40, '000-001-01-00000040', 1, 8, 46, NULL, 6, '2026-09-23', 49400.00, 7410.00, 56810.00, 0.00, 0.00, 'credito', NULL, 'pagada', NULL, '2026-09-23 14:16:52'),
(41, '000-001-01-00000041', 1, 3, NULL, NULL, 6, '2026-09-23', 284347.61, 42652.14, 326999.75, 0.00, 0.00, 'credito', NULL, 'pagada', NULL, '2026-09-23 14:34:45'),
(42, '000-001-01-00000042', 1, 3, 53, NULL, 6, '2026-09-23', 2877.90, 431.69, 3309.59, 0.00, 0.00, 'credito', NULL, 'pagada', NULL, '2026-09-23 14:35:10'),
(43, '000-001-01-00000043', 1, 3, NULL, NULL, 8, '2026-09-28', 33075.00, 4961.25, 38036.25, 0.00, 0.00, 'credito', NULL, 'pagada', NULL, '2026-09-28 14:22:08'),
(44, '000-001-01-00000044', 1, 3, 32, NULL, 8, '2026-10-03', 19700.00, 2955.00, 22655.00, 0.00, 0.00, 'credito', NULL, 'pendiente', NULL, '2026-10-03 10:50:24'),
(45, '000-001-01-00000045', 1, 3, 31, NULL, 8, '2026-10-01', 25650.00, 3847.50, 29497.50, 0.00, 0.00, 'credito', NULL, 'pendiente', NULL, '2026-10-01 10:51:19'),
(46, '000-001-01-00000046', 1, 3, NULL, NULL, 8, '2026-10-03', 19700.00, 2955.00, 22655.00, 0.00, 0.00, 'credito', NULL, 'anulada', ' | ANULADA: ERROR EN DETALLE DE FACTURA', '2026-10-03 10:54:50'),
(47, '000-001-01-00000047', 1, 3, 58, NULL, 6, '2026-10-12', 26000.00, 3900.00, 29900.00, 0.00, 0.00, 'credito', NULL, 'pendiente', NULL, '2026-10-12 11:18:32'),
(48, '000-001-01-00000048', 1, 10, NULL, NULL, 8, '2026-10-13', 115955.00, 17393.25, 133348.25, 0.00, 0.00, 'credito', NULL, 'anulada', ' | ANULADA: ERROR EN EL VALOR', '2026-10-13 11:52:42'),
(49, '000-001-01-00000049', 1, 10, NULL, NULL, 8, '2026-10-13', 2128.00, 319.20, 2447.20, 0.00, 0.00, 'credito', NULL, 'anulada', ' | ANULADA: ERROR EN VALORES', '2026-10-13 11:55:15'),
(51, '000-001-01-00000050', 1, 10, NULL, NULL, 6, '2026-10-14', 2128.00, 319.20, 2447.20, 0.00, 0.00, 'credito', NULL, 'anulada', ' | ANULADA: ERROR EN VALORES', '2026-10-14 08:17:52'),
(52, '000-001-01-00000051', 2, 10, NULL, NULL, 6, '2026-10-14', 79955.00, 11993.25, 91948.25, 0.00, 0.00, 'credito', NULL, 'anulada', 'Se dedujo L. 36,000.00 por combustible cobrado directamente por el cliente. | ANULADA: ERROR EN VALOR', '2026-10-14 09:42:43'),
(53, '000-001-01-00000052', 2, 10, NULL, NULL, 8, '2026-10-14', 2128.00, 319.20, 2447.20, 0.00, 0.00, 'credito', NULL, 'pendiente', NULL, '2026-10-14 09:46:32'),
(54, '000-001-01-00000053', 2, 3, NULL, NULL, 8, '2026-10-15', 44177.08, 6626.56, 50803.64, 0.00, 0.00, 'credito', NULL, 'anulada', ' | ANULADA: RECHAZADA POR CLIENTE', '2026-10-15 16:57:16'),
(55, '000-001-01-00000054', 2, 3, NULL, NULL, 8, '2026-10-16', 43878.99, 6581.85, 50460.84, 0.00, 0.00, 'credito', NULL, 'pendiente', NULL, '2026-10-16 11:04:15'),
(56, '000-001-01-00000055', 2, 15, NULL, NULL, 6, '2026-10-22', 4800.00, 720.00, 5520.00, 0.00, 0.00, 'efectivo', NULL, 'pagada', NULL, '2026-10-26 10:41:15'),
(57, '000-001-01-00000056', 2, 3, NULL, NULL, 6, '2026-10-26', 258557.32, 38783.60, 297340.92, 0.00, 0.00, 'credito', NULL, 'pendiente', NULL, '2026-10-26 10:43:22'),
(58, '000-001-01-00000057', 2, 3, NULL, NULL, 6, '2026-10-26', 2877.90, 431.69, 3309.59, 0.00, 0.00, 'credito', NULL, 'anulada', ' | ANULADA: ERROR EN DESCRIPCION', '2026-10-26 10:44:13'),
(59, '000-001-01-00000058', 2, 3, NULL, NULL, 6, '2026-10-26', 2877.90, 431.69, 3309.59, 0.00, 0.00, 'credito', NULL, 'anulada', ' | ANULADA: ERROR EN VALORES', '2026-10-26 10:45:14'),
(60, '000-001-01-00000059', 2, 3, NULL, NULL, 6, '2026-10-26', 2591.11, 388.67, 2979.78, 0.00, 0.00, 'credito', NULL, 'anulada', ' | ANULADA: ERROR EN VALORES', '2026-10-26 10:46:33'),
(61, '000-001-01-00000060', 2, 3, NULL, NULL, 6, '2026-10-26', 2590.11, 388.52, 2978.63, 0.00, 0.00, 'credito', NULL, 'anulada', ' | ANULADA: ERROR EN VALORES', '2026-10-26 10:48:39'),
(62, '000-001-01-00000061', 2, 3, NULL, NULL, 6, '2026-10-26', 2302.32, 345.35, 2647.67, 0.00, 0.00, 'credito', NULL, 'pendiente', NULL, '2026-10-26 10:51:30'),
(63, '000-001-01-00000062', 2, 10, NULL, NULL, 6, '2026-10-26', 78765.00, 11814.75, 90579.75, 0.00, 0.00, 'credito', NULL, 'pendiente', 'Se dedujo L. 36,000.00 por combustible cobrado directamente por el cliente. ', '2026-10-26 10:52:24');

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
-- Estructura de tabla para la tabla `gastos_dmc`
--

CREATE TABLE `gastos_dmc` (
  `id_gasto` int(10) UNSIGNED NOT NULL,
  `fecha` date NOT NULL,
  `rtn_proveedor` varchar(20) DEFAULT NULL COMMENT 'RTN 14 dígitos empresa / 13 persona natural',
  `nombre_proveedor` varchar(150) NOT NULL,
  `tipo_documento` enum('factura','recibo','ticket','otro') NOT NULL DEFAULT 'factura',
  `numero_factura` varchar(60) DEFAULT NULL,
  `categoria` enum('materiales','servicios','alquiler','combustible','publicidad','mantenimiento','sueldos','honorarios','utilities','otros') NOT NULL DEFAULT 'otros',
  `descripcion` varchar(255) NOT NULL,
  `uso_en` varchar(150) DEFAULT NULL COMMENT 'Dónde se usa el gasto (unidad, taller, etc.)',
  `subtotal` decimal(14,2) NOT NULL DEFAULT 0.00,
  `tasa_isv` tinyint(3) UNSIGNED NOT NULL DEFAULT 15 COMMENT '0, 15 o 18',
  `isv` decimal(14,2) NOT NULL DEFAULT 0.00,
  `total` decimal(14,2) NOT NULL DEFAULT 0.00,
  `deducible` tinyint(1) NOT NULL DEFAULT 1,
  `mes_declaracion` tinyint(3) UNSIGNED NOT NULL COMMENT '1-12',
  `anio_declaracion` smallint(5) UNSIGNED NOT NULL,
  `estado` enum('pendiente','declarado') NOT NULL DEFAULT 'pendiente',
  `observaciones` varchar(255) DEFAULT NULL,
  `usuario_id` int(10) UNSIGNED DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `gastos_dmc`
--

INSERT INTO `gastos_dmc` (`id_gasto`, `fecha`, `rtn_proveedor`, `nombre_proveedor`, `tipo_documento`, `numero_factura`, `categoria`, `descripcion`, `uso_en`, `subtotal`, `tasa_isv`, `isv`, `total`, `deducible`, `mes_declaracion`, `anio_declaracion`, `estado`, `observaciones`, `usuario_id`, `created_at`) VALUES
(2, '2026-03-03', NULL, 'ULTRA REPUESTOS', 'factura', '000-003-01-00225833', 'otros', 'COMPRA DE FILTRO DE DIESEL,FILTRO DE DIESEL RACOR', NULL, 14354.13, 15, 2153.12, 16507.25, 1, 4, 2026, 'declarado', NULL, 6, '2026-05-11 13:16:56'),
(3, '2026-03-09', NULL, 'ULTRA REPUESTOS', 'factura', '000-0003-01-00227500', 'otros', 'COMPRA DE SELLO DE RUEDA TRASERO N37000A', NULL, 990.00, 15, 148.50, 1138.50, 1, 4, 2026, 'declarado', NULL, 6, '2026-05-11 13:20:08'),
(4, '2026-04-07', NULL, 'REPACASA', 'factura', '000-002-01-00754677', 'otros', 'COMPRA DE GANCHO CAJA DE BATERIA, HOODLATCCH,LUZ CORTESIA,', NULL, 2933.88, 15, 440.08, 3373.96, 1, 4, 2026, 'declarado', NULL, 6, '2026-05-11 13:21:32'),
(5, '2026-04-11', NULL, 'FRIOPARTES S.A. DE C.V.', 'factura', '009-001-01-00500051', 'otros', 'LIMPIA SERPENTINA', NULL, 521.74, 15, 78.26, 600.00, 1, 4, 2026, 'declarado', NULL, 6, '2026-05-11 13:22:57'),
(6, '2026-05-19', '05019995149469', 'ULTRA REPUESTOS', 'factura', '000-003-01-00230328', 'materiales', 'CUBETA DE ACEITE ATF, CUBETA DE ACEITE 15W40, SUPREME EC, CUBETA DE 85W140 4 CUARTES DE 15W40', NULL, 8520.57, 15, 1278.09, 9798.66, 1, 5, 2026, 'declarado', NULL, 6, '2026-05-22 13:51:04'),
(7, '2026-05-21', '05011971018375', 'ABOGADA DENIA MAYTE VILLANUEVA RIVERA', 'recibo', '000-001-0400000458', 'servicios', 'ELABORACION DE ESCRITURA DE PODER  PARA REPRESENTACION', NULL, 4347.83, 15, 652.17, 5000.00, 1, 5, 2026, 'declarado', NULL, 6, '2026-05-22 13:54:51'),
(8, '2026-05-23', NULL, 'ULTRA REPUESTOS', 'factura', NULL, 'otros', 'KIT DE RODOS Y SEGURO , ZAPATA REENFIBRADA', NULL, 3809.09, 15, 571.36, 4380.45, 1, 5, 2026, 'declarado', NULL, 4, '2026-06-04 10:09:55'),
(9, '2026-05-21', '05019007104630', 'REPUESTOS Y ACCESORIOS BENJAMIN S. DE R.L.DE C.V.', 'recibo', '003923', 'otros', '8 LLANTAS USADAS', NULL, 25000.00, 15, 3750.00, 28750.00, 0, 5, 2026, 'declarado', 'SOLO SE RECONOCE LOS L.25000', 4, '2026-06-04 10:14:58'),
(14, '2026-06-17', '0501995149469', 'ULTRA REPUESTOS DE HONDURAS S.A DE C.V.', 'factura', '231923', 'materiales', 'KIT DE MANGUERA DE AIRE ROJA/AZUL 115 | MANIVLA AUTOMAN | CABLE 7 LINEAS CON CONECTORES | MEMBRANA DOBLE 30/30', NULL, 5960.92, 15, 894.14, 6855.06, 1, 6, 2026, 'declarado', 'PARA USO EN MULITA', 1, '2026-07-15 10:17:53'),
(15, '2026-06-09', '05011971018375', 'ABOGADA DENIA MAYTE VILLANUEVA RIVERA', 'factura', '461', 'servicios', 'PAGO DEL 50% A TRAMITE DE 4 PERMISOS DE EXPLOTACION , SOLVENCIA PROCADURIA, ANTECEDENTES', NULL, 25000.00, 0, 0.00, 25000.00, 1, 6, 2026, 'declarado', NULL, 6, '2026-07-24 13:58:23'),
(16, '2026-06-03', NULL, 'YC INDUSTRIAL S. DE R.L.', 'factura', '13837', 'materiales', 'RUSTICA CCA 25 2X6X12 | RUSTICA CCA 25 2X6X10 | RUSTICA CCA 25 2X8X12 | RUSTICA CCA 25 2X10X12', NULL, 15315.36, 15, 2297.30, 17612.66, 1, 6, 2026, 'declarado', 'PARA USO EN REPARACION DE PLATAFORMA CEMCOL', 6, '2026-07-25 08:18:16'),
(17, '2026-06-06', NULL, 'CEMCOL COMERCIAL, S.A DE C.V.', 'factura', '212852', 'servicios', 'BUJIA 9007 DE 65 WHATTS 13 VOLTIOS HALOGENA COLOR CLARO', NULL, 267.44, 15, 40.12, 307.56, 1, 6, 2026, 'declarado', 'PARA USO EN MULITA', 6, '2026-07-25 08:55:01'),
(18, '2026-06-16', NULL, 'INVERSIONES EBEN EZER', 'factura', '37674', 'materiales', 'MAGUERA DE AGUA USADA', NULL, 700.00, 0, 0.00, 700.00, 1, 6, 2026, 'declarado', 'PARA USO EN MULITA', 6, '2026-07-25 08:57:35'),
(19, '2026-06-12', NULL, 'GRUPO HMC S.A.', 'factura', '260623', 'materiales', 'ESCOBILLA LIMPIA PARA BRISAS DE 22 LARSSON MET', NULL, 300.06, 15, 45.01, 345.07, 1, 6, 2026, 'declarado', 'PARA USO DE MULITA', 6, '2026-07-25 09:00:12'),
(20, '2026-06-17', NULL, 'INVERSIONES M.C.R', 'factura', '126', 'materiales', 'RECARGA DE GAS 2 LATAS DE FRION', NULL, 800.00, 0, 0.00, 800.00, 1, 6, 2026, 'declarado', 'PARA USO DE CABEZAL INTER', 6, '2026-07-25 09:02:54'),
(21, '2026-06-17', NULL, 'ULTRA REPUESTOS DE HONDURAS S.A DE C.V.', 'factura', '231959', 'materiales', 'MANITO DE AIRE DE FRENO SERVICIO AZUL | MANITO DE AIRE DE FRENO MERGENCIA ROJA', NULL, 252.96, 15, 37.94, 290.90, 1, 6, 2026, 'declarado', 'PARA CABEZALES', 6, '2026-07-25 10:20:52'),
(22, '2026-06-17', NULL, 'ULTRA REPUESTOS DE HONDURAS S.A DE C.V.', 'factura', '231964', 'materiales', 'BUJE DE HOJA TENSORA DE FREIGHTLINER MANSONS', NULL, 1379.04, 15, 206.86, 1585.90, 1, 6, 2026, 'declarado', NULL, 6, '2026-07-25 10:24:16'),
(23, '2026-06-18', NULL, 'ULTRA REPUESTOS DE HONDURAS S.A DE C.V.', 'factura', '232006', 'materiales', 'FILTRO AIRE', NULL, 5800.00, 15, 870.00, 6670.00, 1, 6, 2026, 'declarado', NULL, 6, '2026-07-25 10:25:27'),
(27, '2026-06-18', NULL, 'ULTRA REPUESTOS DE HONDURAS S.A DE C.V.', 'factura', '232009', 'materiales', 'CUBETA DE ACEITE DE 15W40 CK -4 FLEET SUPREME EC PHILLIPS 66 | GALON DE 15W40 CK-4 GUARDOL FLEET EC PHILLIPS 66', NULL, 5342.13, 15, 801.32, 6143.45, 1, 6, 2026, 'declarado', NULL, 6, '2026-07-25 10:39:44'),
(28, '2026-06-18', NULL, 'ULTRA REPUESTOS DE HONDURAS S.A. DE C.V.', 'factura', '232003', 'materiales', 'FILTRO DE GASOLINA | FILTRO DE ACEITE | FILTRO DE GASOLINA', NULL, 8260.00, 15, 1239.00, 9499.00, 1, 6, 2026, 'declarado', 'PARA CABEZAL INTER LT', 6, '2026-07-25 10:44:23'),
(29, '2026-06-18', NULL, 'CASA COMERCIAL MATHEWS S.A.', 'factura', '287899', 'materiales', 'CUBETA DE ACEITE PARA TRANSMISION', NULL, 3310.95, 15, 496.64, 3807.59, 1, 6, 2026, 'declarado', 'PARA CABEZAL INTER LT', 6, '2026-07-25 10:51:47'),
(30, '2026-06-16', NULL, 'INVERSIONES PALCON S. DE R.L. DE C.V.', 'factura', '12932', 'materiales', 'MANGUERA DE AGUA', NULL, 1150.00, 0, 0.00, 1150.00, 1, 6, 2026, 'declarado', NULL, 6, '2026-07-25 10:53:59'),
(31, '2026-06-22', NULL, 'SOLUCIONES INTEGRALES S. DE R.L DE C.V', 'factura', '17978', 'combustible', 'DIESEL', NULL, 2000.00, 0, 0.00, 2000.00, 1, 6, 2026, 'declarado', NULL, 6, '2026-07-25 10:56:10'),
(32, '2026-06-24', NULL, 'SOLUCIONES INTEGRALES S. DE R.L DE C.V', 'factura', '18143', 'combustible', 'DIESEL', NULL, 2000.00, 0, 0.00, 2000.00, 1, 6, 2026, 'declarado', 'PARA CABEZAL INTER LT', 6, '2026-07-25 10:57:15'),
(33, '2026-06-16', NULL, 'SOLUCIONES INTEGRALES S. DE R.L DE C.V', 'factura', '177230', 'combustible', 'DIESEL', NULL, 12845.98, 0, 0.00, 12845.98, 1, 6, 2026, 'declarado', 'PARA CABEZAL INTER LT', 6, '2026-07-25 10:58:29'),
(34, '2026-06-18', NULL, 'SOLUCIONES INTEGRALES S. DE R.L DE C.V', 'factura', '17714', 'combustible', 'DIESEL', NULL, 2000.08, 0, 0.00, 2000.08, 1, 6, 2026, 'declarado', NULL, 6, '2026-07-25 11:01:19'),
(35, '2026-06-22', NULL, 'SOLUCIONES INTEGRALES S. DE R.L DE C.V', 'factura', '17970', 'combustible', 'DIESEL', NULL, 2000.00, 0, 0.00, 2000.00, 1, 6, 2026, 'declarado', NULL, 6, '2026-07-29 12:57:07'),
(39, '2026-06-25', NULL, 'INVERSIONES M.C.R', 'factura', '00', 'servicios', 'REPARACION ELECTRICA DE AIRE DE MULITA VOLVO JAS1458', NULL, 800.00, 0, 0.00, 800.00, 1, 6, 2026, 'declarado', NULL, 6, '2026-07-29 13:02:45'),
(40, '2026-06-26', NULL, 'RECASER S. DE R.L.', 'factura', '599', 'servicios', 'CALIBRACION DE SENSOR DE PEDAL DE FRENO DEL ABS INTER LT', NULL, 5000.00, 15, 750.00, 5750.00, 1, 6, 2026, 'declarado', NULL, 6, '2026-07-29 13:04:32'),
(41, '2026-06-25', NULL, 'INEVERSIONES DEL ATLANTICO NORTE S. DE R.L. DE C.V', 'factura', '51468', 'servicios', '2X8X14 RUSTICO CURADO | 2X8X10 RUSTICO CURADO | 2X4X14 RUSTICO CURADO | 2X4X10 RUSTICO CURADO', NULL, 8064.00, 15, 1209.60, 9273.60, 1, 6, 2026, 'declarado', NULL, 6, '2026-07-29 13:13:01'),
(42, '2026-06-26', NULL, 'TECNO FUEGO S. DE R.L. DE C.V', 'factura', '46775', 'materiales', 'EXTINTOR DE 5 LBS POLVO QUIMICO', NULL, 900.00, 15, 135.00, 1035.00, 1, 6, 2026, 'declarado', NULL, 6, '2026-07-29 13:21:37'),
(43, '2026-06-26', NULL, 'INSA TEXACO ARENALES', 'factura', '145124', 'servicios', 'DIESEL', NULL, 2500.12, 0, 0.00, 2500.12, 1, 6, 2026, 'declarado', NULL, 6, '2026-07-29 13:22:52'),
(44, '2026-06-29', NULL, 'ULTRA REPUESTOS DE HONDURAS S.A DE C.V.', 'factura', '232674', 'materiales', 'FILTRO DE COMBUSTIBLE  CARTUCHO MOTOR 460 PARA FREIGHTLINER | CABLE DE 7 LINEAS  CON CONECTORES VELVAC', NULL, 2891.38, 15, 433.71, 3325.09, 1, 6, 2026, 'declarado', NULL, 6, '2026-07-29 13:25:20'),
(45, '2026-06-30', NULL, 'LUBRICANTES Y COMBUSTIBLES S.A DE C.V.', 'factura', '1394157', 'combustible', 'DIESEL', NULL, 2500.00, 0, 0.00, 2500.00, 1, 6, 2026, 'declarado', NULL, 6, '2026-07-29 13:27:02'),
(46, '2026-06-30', NULL, 'LUBRICANTES Y COMBUSTIBLES S.A DE C.V.', 'factura', '1394165', 'combustible', 'DIESEL', NULL, 200.00, 0, 0.00, 200.00, 1, 6, 2026, 'declarado', NULL, 6, '2026-07-29 13:28:01'),
(47, '2026-06-20', NULL, 'COMERCIAL Y FERRETERIA EXPRESS HONDURAS  DE RL', 'factura', '22418', 'materiales', 'LLAVE 14 JADEVER JD A1114', NULL, 204.00, 15, 30.60, 234.60, 1, 6, 2026, 'declarado', NULL, 6, '2026-07-29 13:32:06'),
(48, '2026-06-18', NULL, 'HELIOS, S.A.', 'factura', '5662', 'servicios', 'MANO DE OBRA INSTALACION | MANO DE OBRA-ACTIVACION | ACCESORIIOS KIT PROTECCION', NULL, 1121.06, 15, 168.16, 1289.22, 1, 7, 2026, 'declarado', 'PARA INTER LT', 4, '2026-07-29 15:55:22'),
(49, '2026-07-23', NULL, 'RECASER S.DE R.L.DE C.V.', 'factura', '0603', 'servicios', 'DIAGNOSTICO ELECTRONICO UNIDAD VOLVO', NULL, 1500.00, 15, 225.00, 1725.00, 1, 7, 2026, 'declarado', 'UNIDAD VOLVOTCA8427', 4, '2026-07-29 16:03:33'),
(51, '2026-07-02', NULL, 'DISTRIBUIDORA PANTING ZELAYA S.A.DE C.V.', 'factura', NULL, 'combustible', 'DIESEL', NULL, 1304.00, 15, 195.60, 1499.60, 1, 7, 2026, 'declarado', NULL, 4, '2026-07-29 16:23:19'),
(54, '2026-07-03', NULL, 'GRUPO HMC S.A.', 'factura', '1800', 'mantenimiento', 'LOGO FREIHTLINER | PARRILLA PAR FLD CASCADIA | BOMPER CROMADO', NULL, 17664.26, 15, 2649.64, 20313.90, 1, 7, 2026, 'declarado', NULL, 4, '2026-07-30 10:15:05'),
(55, '2026-07-14', NULL, 'GRUPO HMC S.A.', 'factura', '001-001-01-00266214', 'mantenimiento', 'COMPLEMENTO SUPERIOR DE BUMPER CROMADO', NULL, 1529.84, 15, 229.48, 1759.32, 1, 7, 2026, 'declarado', NULL, 4, '2026-07-30 10:22:12'),
(65, '2026-07-14', NULL, 'HELIOS', 'factura', '5828', 'servicios', 'GPS SUSCRIPCION MENSUALL/SEGUIMIENTO PREMIUN PERIODO JULIO', NULL, 322.41, 15, 48.36, 370.77, 1, 7, 2026, 'declarado', NULL, 4, '2026-07-30 11:43:36'),
(66, '2026-07-14', NULL, 'HELIOS', 'factura', '5838', 'servicios', 'MANO DE OBRA INSTALACION EQUIPO | MONO DE OBRA - ACTIVACION | ACCCESORIO KIT DE PROTCCION | ACCESORIO KIT DE ENCENDIDO 12 V | GASTOS DE VIAJE /ALIMENTACION TECNICO(UN DIA)', NULL, 7637.00, 15, 1145.55, 8782.55, 1, 7, 2026, 'declarado', NULL, 4, '2026-07-30 11:50:39'),
(68, '2026-07-24', NULL, 'INSA TEXACO ARENALES', 'factura', '007-002-01-00153149', 'combustible', 'DIESEL', NULL, 2000.00, 0, 0.00, 2000.00, 1, 7, 2026, 'declarado', NULL, 4, '2026-07-30 11:59:04'),
(69, '2026-08-13', '08019021289810', 'HELIOS', 'factura', '000-001-01-00006026', 'servicios', 'SUSCRIPCION MENSUAL SEGUIMIENTO PRIMIUN PERIODO AGOSTO', NULL, 1293.40, 15, 194.01, 1487.41, 1, 8, 2026, 'declarado', NULL, 6, '2026-09-02 08:03:58'),
(70, '2026-09-04', '05019995119481', 'REPUESTOS PARA CAMIONES , S.A DE C.V.', 'factura', '000-002-01-00803076', 'materiales', 'GRASA CALCIO', NULL, 1606.00, 15, 240.90, 1846.90, 1, 9, 2026, 'declarado', NULL, 6, '2026-09-09 09:19:31'),
(71, '2026-09-07', '05019024065037', 'OPERADORA DE ESTACIONES DE SERVICIO S.A DE C.V.', 'factura', '003-001-01-00175078', 'combustible', 'DIESEL', NULL, 500.00, 0, 0.00, 500.00, 1, 9, 2026, 'declarado', NULL, 6, '2026-09-09 09:29:54'),
(72, '2026-09-04', '03011900044953', 'MUNICIPALIDAD DE PUERTO CORTES', 'factura', '004-224-35', 'servicios', 'PEAJE', NULL, 6.00, 0, 0.00, 6.00, 1, 9, 2026, 'declarado', NULL, 6, '2026-09-09 09:30:53'),
(73, '2026-09-02', '03019000044953', 'MUNICIPALIDAD DE UERTO CORTES', 'factura', '004-015-11', 'servicios', 'PEAJE', NULL, 6.00, 0, 0.00, 6.00, 1, 9, 2026, 'declarado', NULL, 6, '2026-09-09 09:32:07'),
(74, '2026-09-04', '03019000044953', 'MUNICIPALIDAD DE PUERTO CORTES', 'factura', '004-204-89', 'servicios', 'PEAJE', NULL, 28.00, 0, 0.00, 28.00, 1, 9, 2026, 'declarado', NULL, 6, '2026-09-09 09:33:02'),
(75, '2026-09-02', '03019000044953', 'MUNICIPALIDAD DE PUERTO CORTES', 'factura', '003-898-79', 'servicios', 'PEAJE', NULL, 28.00, 0, 0.00, 28.00, 1, 9, 2026, 'declarado', NULL, 6, '2026-09-09 09:33:54'),
(77, '2026-09-09', '05019000046793', 'CEMCOL COMERCIAL S.A. DE C,V.', 'factura', '000-002-01-04039526', 'servicios', 'JUEGO DE MANGUERAS ESPIRALES DE FRENOS AZUL Y', NULL, 836.86, 15, 125.53, 962.39, 1, 9, 2026, 'declarado', NULL, 6, '2026-09-12 09:11:00'),
(78, '2026-09-09', '05019995128071', 'FERRETERIA ZUMMAR S.A DE C.V.', 'factura', '000-008-01-00288822', 'materiales', 'REMACHE ALUMINIO LARGE FLANGE CEBEZON 19MM 1/4X3/4 200/CAJA', NULL, 332.62, 15, 49.89, 382.51, 1, 9, 2026, 'declarado', NULL, 6, '2026-09-12 09:15:34'),
(79, '2026-09-09', '05029003077846', 'ESTACION DE SERVICIO TEXACO CHOLOMA SRL', 'factura', '008-001-01-00307690', 'combustible', 'DIESEL', NULL, 1000.00, 0, 0.00, 1000.00, 1, 9, 2026, 'declarado', NULL, 6, '2026-09-12 09:17:04'),
(80, '2026-09-10', NULL, 'PURIFICADORA DE AGUA EL PROGRESO S. DE R.L. DE C.V.', 'factura', '005-012-01-00029946', 'servicios', 'AGUA ARROLLO-5 GLNS', NULL, 480.00, 0, 0.00, 480.00, 1, 9, 2026, 'declarado', NULL, 6, '2026-09-12 09:19:58'),
(81, '2026-09-11', '05019998173837', 'FERRETERIA CALPULES, S. DE R.L.', 'factura', '000-001-01-00111231', 'materiales', 'LIJA  #200 | LIJA  #100 | LIJA  #360 | LIJA  #1000 | BROCHAS # 2', NULL, 166.00, 0, 0.00, 166.00, 1, 9, 2026, 'declarado', NULL, 6, '2026-09-12 09:25:01'),
(82, '2026-09-04', '05019995128071', 'FERRETERIA ZUMMAR S.A. DE C.V.', 'factura', '000-008-01-00288381', 'materiales', 'REMACHE DE LUMINIO LARGE FLANGE CABEZON 19MM 1/4X7/8 200/CAJA', NULL, 668.64, 15, 100.30, 768.94, 1, 9, 2026, 'declarado', NULL, 6, '2026-09-12 11:03:42'),
(83, '2026-09-04', '08011956038279', 'TODO FACIL FERRETERIA', 'factura', '000-001-01-00478835', 'servicios', 'TUBO ESTRUCTURAL CUADRADO 4X20 CH-11', NULL, 2049.00, 15, 307.35, 2356.35, 1, 9, 2026, 'declarado', NULL, 6, '2026-09-12 11:05:28'),
(84, '2026-09-12', '08029995457769', 'UNO HONDURAS S.A DE C.V', 'factura', '062-001-01-00044489', 'combustible', 'GASOLINA', NULL, 500.00, 0, 0.00, 500.00, 1, 9, 2026, 'declarado', NULL, 6, '2026-09-12 11:48:19'),
(85, '2026-09-11', '05019026315890', 'REPUESTOS PARA CAMIONES , S.A DE C.V.', 'factura', '000-002-01-00805309', 'materiales', 'HANGER FRONTAL | BOLT | TUERCAS DE SEGURIDAD | WASHA 7/8', NULL, 1380.55, 15, 207.08, 1587.63, 1, 9, 2026, 'declarado', NULL, 6, '2026-09-17 12:50:49'),
(86, '2026-09-06', '08019995224132', 'SUPERMERCADOS LA COLONIA S.A DE C.V', 'factura', '076-001-01-00362674', 'servicios', 'ALIMENTACION', NULL, 954.27, 0, 0.00, 954.27, 1, 9, 2026, 'declarado', NULL, 6, '2026-09-17 12:52:55'),
(87, '2026-09-14', '05019026315890', 'AGENCIA LA MUNDIAL, S.A DE C.V', 'factura', '021-001-01-01655169', 'materiales', 'SELLADOR PERMANENTE 50ML | SELLADOR PERMANENTE 6ML | SELLADOR PERMANENTE 6ML', NULL, 271.31, 15, 40.70, 312.01, 1, 9, 2026, 'declarado', NULL, 6, '2026-09-17 13:02:33'),
(88, '2026-09-14', '05019001188508', 'COMERCIALIZADORA ELVIR COELLO S DE R.L.', 'factura', '000-001-01-00210333', 'combustible', 'DIESEL', NULL, 500.00, 0, 0.00, 500.00, 1, 9, 2026, 'declarado', NULL, 6, '2026-09-17 13:04:09'),
(89, '2026-09-12', '05011940011860', 'ESTACION DE SERVICIO TARA NORTE', 'factura', '001-001-01-00292648', 'combustible', 'DIESEL', NULL, 500.00, 0, 0.00, 500.00, 1, 9, 2026, 'declarado', NULL, 6, '2026-09-17 13:05:25'),
(90, '2026-09-19', '05019007065665', 'OXIMAYA, S.A DE C.V', 'factura', '000-001-01-00099976', 'materiales', 'RECARGA DE ARGON 220', NULL, 2869.56, 15, 430.43, 3299.99, 1, 9, 2026, 'declarado', NULL, 6, '2026-09-21 16:57:37'),
(91, '2026-09-17', '08019021289810', 'HELIOS', 'factura', '000-001-01-00006196', 'servicios', 'SUSCRIPCION MENSUAL SEGUIMIENTO PREMIUN PERIODO SEPTIEMBRE', NULL, 1296.00, 15, 194.40, 1490.40, 1, 9, 2026, 'declarado', NULL, 6, '2026-09-21 16:59:16'),
(92, '2026-09-09', '05019000046793', 'CEMCOL COMERCIAL, S.A DE C.V.', 'factura', '000-002-01-04039526', 'combustible', 'DIESEL', NULL, 3000.00, 0, 0.00, 3000.00, 1, 9, 2026, 'declarado', NULL, 6, '2026-09-21 17:21:36'),
(93, '2026-09-03', '05019995119481', 'REPUESTOS PARA CAMIONES , S.A DE C.V.', 'factura', '000-002-01-00802613', 'materiales', 'CUBETA DE ACEITE', NULL, 2175.00, 15, 326.25, 2501.25, 1, 9, 2026, 'declarado', NULL, 6, '2026-09-21 17:23:53'),
(94, '2026-09-02', '05019995108892', 'ACCESORIOS PARA COMPUTADORAS Y OFICINAS S.A. DE C.V.', 'factura', '032-001-01-00016034', 'otros', 'TINTA NEGRA PARA IMPRESORA', NULL, 308.70, 15, 46.31, 355.01, 1, 9, 2026, 'declarado', NULL, 6, '2026-09-21 17:32:27'),
(95, '2026-09-02', '05019995119481', 'REPUESTOS PARA CAMIONES , S.A DE C.V.', 'factura', '000-002-01-00802297', 'materiales', 'FILTRO DE ACEITE | CUBETA DE ACEITE | BUJE', NULL, 5814.13, 15, 872.12, 6686.25, 1, 9, 2026, 'declarado', NULL, 6, '2026-09-21 17:33:52'),
(96, '2026-09-17', '05019002074089', 'FORMAS EXCEL S. DE R.L. DE C.V.', 'factura', '000-001-01-00004662', 'otros', 'TAL NOTA DE CREDITO ORIG 1 COPIAS PQ SEXTO 1C | TAL FACTURA ORIG 1 COPIAS PQ C 1C', NULL, 2980.00, 15, 447.00, 3427.00, 1, 9, 2026, 'declarado', NULL, 6, '2026-09-21 17:35:44'),
(97, '2026-09-19', '05011987055996', 'IMPORTACIONES C.B', 'factura', '000-001-01-00003762', 'servicios', 'REPARACION DE PISTON HIDRAULICO DE GRUA PLATAFORMA', NULL, 37000.00, 15, 5550.00, 42550.00, 1, 9, 2026, 'declarado', NULL, 6, '2026-09-21 17:37:13'),
(98, '2026-09-19', '05011987055996', 'IMPORTACIONES C.B', 'factura', '000-001-01-00003763', 'servicios', 'REPARACION DE PISTON HIDRAULICO AZUL', NULL, 12000.00, 15, 1800.00, 13800.00, 1, 9, 2026, 'declarado', NULL, 6, '2026-09-21 17:38:04'),
(99, '2026-09-17', '05019026315890', 'AGENCIA LA MUNDIAL, S.A DE C.V', 'factura', '021-001-01-01661561', 'materiales', 'TUBO HN ESTRCT CUAD 1.1/2X6MT', NULL, 460.87, 15, 69.13, 530.00, 1, 9, 2026, 'declarado', NULL, 6, '2026-09-21 17:39:14'),
(100, '2026-09-13', '05111965003263', 'INVERSIONES HERNNDEZ MATA', 'factura', '000-006-01-00610976', 'combustible', 'GASOLINA', NULL, 400.00, 0, 0.00, 400.00, 1, 9, 2026, 'declarado', NULL, 6, '2026-09-21 17:40:03'),
(101, '2026-09-21', '05019998173837', 'FERRETERIA CALPULES S. DE R. L', 'factura', '000-001-01-00111340', 'materiales', 'GALON THINER', NULL, 235.00, 0, 0.00, 235.00, 1, 9, 2026, 'declarado', NULL, 8, '2026-09-23 14:27:57'),
(102, '2026-09-23', '05019009217340', 'CORPORACION PETROLERA MONTECRISTO S.A DE C.V', 'factura', '011-002-01-02763905', 'combustible', 'GASOLINA', NULL, 1253.00, 0, 0.00, 1253.00, 1, 9, 2026, 'declarado', NULL, 8, '2026-09-23 14:30:59'),
(103, '2026-09-22', '05019000044923', 'REENFRIO SULA S. DE R. L', 'factura', '000-001-01-00812441', 'servicios', 'GITICONTROL | BALANCEO', NULL, 2130.44, 15, 319.57, 2450.01, 1, 9, 2026, 'declarado', NULL, 8, '2026-09-23 14:39:23'),
(104, '2026-09-23', '05019000046793', 'CEMCOL COMERCIAL, S.A DE C.V.', 'factura', '000-006-01-00220198', 'materiales', 'HEMBRA GIRATORIA | ACOPLE HIDRAULICO | MANGUERA 3/4', NULL, 5140.60, 15, 771.09, 5911.69, 1, 9, 2026, 'declarado', NULL, 8, '2026-09-23 14:44:04'),
(105, '2026-09-19', '05019998173837', 'FERRETERIA CALPULES S. DE R. L', 'factura', '000-001-01-00111374', 'materiales', 'TORNILLOS 1/2 X 3 1/2 | TOPE NEGRO | ELECTRODO', NULL, 337.40, 15, 50.61, 388.01, 1, 9, 2026, 'declarado', NULL, 8, '2026-09-23 14:50:42'),
(106, '2026-09-17', '03019000004495', 'MUNICIPALIDAD DE PUERTO CORTES', 'ticket', '005-608-21', 'servicios', 'PEAJE', NULL, 6.00, 0, 0.00, 6.00, 1, 9, 2026, 'declarado', NULL, 8, '2026-09-23 14:54:55'),
(107, '2026-09-23', '18049018017451', 'SOLUCIONES INTEGRALES S. DE R. L DE C. V', 'factura', '000-004-01-00025366', 'materiales', 'GAS LPG', NULL, 350.00, 0, 0.00, 350.00, 1, 9, 2026, 'declarado', NULL, 8, '2026-09-23 14:57:54'),
(109, '2026-08-04', NULL, 'GASOLINERA UNO EL EDEN', 'factura', '034-001-01-03915703', 'combustible', 'DIESEL', NULL, 3000.00, 0, 0.00, 3000.00, 1, 8, 2026, 'declarado', NULL, 8, '2026-09-24 09:13:50'),
(110, '2026-08-06', NULL, 'SELECTORNILLOS', 'factura', '000-001-01-00013176', 'materiales', 'TORNILLOS 5/8X2COMPLT | TORNILLO 3/4X3 COMPLST', NULL, 2671.35, 0, 0.00, 2671.35, 1, 8, 2026, 'declarado', NULL, 8, '2026-09-24 09:35:48'),
(111, '2026-08-05', NULL, 'CORPORACION PETROLERA MONTE CRISTOS.A. DE C.V.', 'factura', '004-002-01-01796035', 'combustible', 'DIESEL', NULL, 2500.00, 0, 0.00, 2500.00, 1, 8, 2026, 'declarado', NULL, 8, '2026-09-24 09:37:34'),
(112, '2026-08-08', NULL, 'UNO EL EDEN', 'factura', '034-001-01-03919574', 'combustible', 'DIESEL', NULL, 2500.00, 0, 0.00, 2500.00, 1, 8, 2026, 'declarado', NULL, 8, '2026-09-24 09:39:02'),
(113, '2026-08-14', NULL, 'TEXACO EL SAUCE', 'factura', '003-001-01-00357556', 'combustible', 'DIESEL', NULL, 2500.00, 0, 0.00, 2500.00, 1, 8, 2026, 'declarado', NULL, 8, '2026-09-24 09:41:07'),
(114, '2026-08-19', NULL, 'ACOSA', 'factura', '032-001-01-00015174', 'materiales', 'PAPEL BOND CARTA B20 8.5X11\"H', NULL, 112.17, 15, 16.83, 129.00, 1, 8, 2026, 'declarado', NULL, 8, '2026-09-24 09:43:12'),
(115, '2026-08-19', NULL, 'TALLER MECANICO PENIEL', 'factura', '000-002-01-00000097', 'servicios', 'REVISIONES MECANICA DE CABEZAL JAH9040-JDM16604', NULL, 3000.00, 15, 450.00, 3450.00, 1, 8, 2026, 'declarado', NULL, 8, '2026-09-24 09:44:46'),
(116, '2026-08-26', NULL, 'TEXACO ARENALES', 'factura', '007-002-01-00162855', 'combustible', 'DIESEL', NULL, 3000.00, 0, 0.00, 3000.00, 1, 8, 2026, 'declarado', NULL, 8, '2026-09-24 09:46:36'),
(117, '2026-08-26', NULL, 'GENESIS COLOR S. DE R.L.', 'factura', '000-001-01-00036627', 'materiales', 'M/C BLANCO COMBO | RESINA | ONZAS CATALIZADOR', NULL, 1450.00, 0, 0.00, 1450.00, 1, 8, 2026, 'declarado', NULL, 8, '2026-09-24 09:50:50'),
(118, '2026-08-20', NULL, 'MUNICIPALIDAD DE PUERTO CORTES', 'factura', '290', 'servicios', 'PEAJE', NULL, 28.00, 0, 0.00, 28.00, 1, 8, 2026, 'declarado', NULL, 8, '2026-09-24 09:52:37'),
(119, '2026-08-21', NULL, 'MUNICIPALIDAD DE PUERTO CORTES', 'ticket', '284', 'servicios', 'PEAJE', NULL, 6.00, 0, 0.00, 6.00, 1, 8, 2026, 'declarado', NULL, 8, '2026-09-24 09:53:52'),
(120, '2026-08-22', NULL, 'MUNICIPALIDAD DE PUERTO CORTES', 'factura', '505-6', 'servicios', 'PEAJE', NULL, 28.00, 0, 0.00, 28.00, 1, 8, 2026, 'declarado', NULL, 8, '2026-09-24 09:54:53'),
(121, '2026-08-26', NULL, 'MUNICIPALIDAD DE PUERTO CORTES', 'factura', '480-7', 'servicios', 'PEAJE', NULL, 42.00, 0, 0.00, 42.00, 1, 8, 2026, 'declarado', NULL, 8, '2026-09-24 09:55:52'),
(122, '2026-08-11', NULL, 'MUNICIPALIDAD DE PUERTO CORTES', 'factura', '986', 'servicios', 'PEAJE', NULL, 6.00, 0, 0.00, 6.00, 1, 8, 2026, 'declarado', NULL, 8, '2026-09-24 09:56:57'),
(123, '2026-08-22', NULL, 'MUNICIPALIDAD DE PUERTO CORTES', 'ticket', '289', 'servicios', 'PEAJE', NULL, 35.00, 0, 0.00, 35.00, 1, 8, 2026, 'declarado', NULL, 8, '2026-09-24 09:58:06'),
(124, '2026-08-28', NULL, 'AUTOSERVICIOS VILLACORTA', 'factura', '000-001-01-00010998', 'materiales', 'LLANTAS USADAS AMERICANAS', NULL, 10000.00, 0, 0.00, 10000.00, 1, 8, 2026, 'declarado', NULL, 8, '2026-09-24 10:00:18'),
(125, '2026-08-26', NULL, 'MUNICIPALIDAD DE PUERTO CORTES', 'factura', '340-522', 'servicios', 'PEAJE', NULL, 28.00, 0, 0.00, 28.00, 1, 8, 2026, 'declarado', NULL, 8, '2026-09-24 10:01:35'),
(126, '2026-08-31', NULL, 'YONKER Y AUTOS LA ESPERA S.DE R.L', 'factura', '000-001-01-00020603', 'materiales', 'ABRAZADERAS DE INTERCOLER DE  \"4\"', NULL, 450.00, 0, 0.00, 450.00, 1, 8, 2026, 'declarado', NULL, 8, '2026-09-24 10:03:41'),
(127, '2026-08-29', NULL, 'REPACASA', 'factura', '000-001-01-00801259', 'materiales', 'AMORTIGUADOR TRASERO | BOLSA DE AIRE', NULL, 12784.28, 15, 1917.64, 14701.92, 1, 8, 2026, 'declarado', NULL, 8, '2026-09-24 10:11:04'),
(128, '2026-08-31', NULL, 'N Y G IMPORT TRUCK PARTS', 'factura', '108-66', 'materiales', 'COLCHON USADO P/CABINA', NULL, 1700.00, 0, 0.00, 1700.00, 1, 8, 2026, 'declarado', NULL, 8, '2026-09-24 10:12:45'),
(129, '2026-08-13', NULL, 'MUNICIPALIDAD DE PUERTO CORTES', 'factura', '192-212', 'servicios', 'PEAJE', NULL, 6.00, 0, 0.00, 6.00, 1, 8, 2026, 'declarado', NULL, 8, '2026-09-24 10:14:55'),
(130, '2026-08-31', NULL, 'REPACASA', 'factura', '000-002-01-00801745', 'materiales', 'MEMBRANA | MANGUERA DE FRENO 72\" | STRET ELBOW 90 DEG 3/8NPT | FITTING', NULL, 3556.02, 15, 533.40, 4089.42, 1, 8, 2026, 'declarado', NULL, 8, '2026-09-24 10:31:41'),
(132, '2026-09-23', '18049018017451', 'SOLUCIONES INTEGRALES S. DE R.L DE C.V', 'factura', '000-004-01-00025390', 'combustible', 'DIESEL', NULL, 1000.00, 0, 0.00, 1000.00, 1, 9, 2026, 'declarado', NULL, 8, '2026-09-24 10:55:31'),
(133, '2026-09-24', '16211977003081', 'ESTACION DE SERVICIO UNO VIDA NUEVA', 'factura', '004-001-01-00012588', 'combustible', 'GASOLINA', NULL, 1006.00, 0, 0.00, 1006.00, 1, 9, 2026, 'declarado', NULL, 8, '2026-09-24 11:44:52'),
(134, '2026-09-24', '18049995000264', 'PURIFICADORA DE AGUA EL PROGRESO S. DE R.L. DE C.V.', 'factura', '000-026-01-00001188', 'materiales', 'BOTELLONES CON AGUA', NULL, 297.00, 0, 0.00, 297.00, 1, 9, 2026, 'declarado', NULL, 8, '2026-09-24 14:08:14'),
(135, '2026-08-15', '03019000044953', 'MUNICIPALIDAD DE PUERTO CORTES', 'factura', '002-102-79', 'servicios', 'PEAJE', NULL, 35.00, 0, 0.00, 35.00, 1, 9, 2026, 'declarado', NULL, 8, '2026-09-25 10:41:45'),
(136, '2026-09-24', '05019995108892', 'ACCESORIOS PARA COMPUTADORAS Y OFICINAS S.A DE C.V', 'factura', '032-002-01-00019362', 'materiales', 'MOUSE', NULL, 68.70, 15, 10.31, 79.01, 1, 9, 2026, 'declarado', NULL, 8, '2026-09-25 13:35:29'),
(137, '2026-09-24', '03019000044953', 'MUNICIPALIDAD DE PUERTO CORTES', 'factura', '005-429-38', 'servicios', 'PEAJE', NULL, 28.00, 0, 0.00, 28.00, 1, 9, 2026, 'declarado', NULL, 8, '2026-09-25 15:28:04'),
(138, '2026-09-24', '03019000044953', 'MUNICIPALIDAD DE PUERTO CORTES', 'factura', '006-380-83', 'servicios', 'PEAJE', NULL, 28.00, 0, 0.00, 28.00, 1, 9, 2026, 'declarado', NULL, 8, '2026-09-25 15:28:57'),
(139, '2026-09-25', '05019998173837', 'FERRETERIA CALPULES S. DE. R.', 'factura', '000-001-01-00111477', 'materiales', 'TORNILLOS 5 16X2 | SALCHICHA | TAPICERO', NULL, 610.00, 0, 0.00, 610.00, 1, 9, 2026, 'declarado', NULL, 8, '2026-09-25 15:38:22'),
(140, '2026-09-25', NULL, 'INSTITUTO DE LA PROPIEDAD', 'factura', '099-353-4', 'servicios', 'MATRICULA CASCADIA', NULL, 25.00, 0, 0.00, 25.00, 1, 9, 2026, 'declarado', NULL, 8, '2026-09-25 15:42:30'),
(141, '2026-09-25', '0501999514927', 'REFRIGERACION Y TRANSPORTE S.A DE C.V', 'factura', '000-003-01-00005205', 'materiales', 'EMPAQUE PARA PUERTA DE CARROCERIA DE 1 PULGADA', NULL, 2000.00, 15, 300.00, 2300.00, 1, 9, 2026, 'declarado', NULL, 8, '2026-09-26 09:26:50'),
(142, '2026-09-25', '05011974023940', 'PUMA LOS LAURELES', 'factura', '008-001-01-01029449', 'combustible', 'DIESEL', NULL, 500.02, 0, 0.00, 500.02, 1, 9, 2026, 'declarado', NULL, 8, '2026-09-26 09:30:16'),
(143, '2026-09-26', '05019998173837', 'FERRETERIA CALPULES S. DE R.L', 'factura', '000-001-01-00111483', 'materiales', 'SALCHICHA | TORNILLOS 3/3 X1 | MACHUELO', NULL, 393.88, 15, 59.08, 452.96, 1, 9, 2026, 'declarado', NULL, 8, '2026-09-28 10:54:29'),
(144, '2026-09-28', '05019995142927', 'REFRIGERACION Y TRANSPORTE S.A DE C.V', 'factura', '000-003-01-00005217', 'materiales', 'EMPAQUE PARA PUERTA DE CARROCERIA DE 3/4', NULL, 1800.00, 15, 270.00, 2070.00, 1, 9, 2026, 'declarado', NULL, 8, '2026-09-28 13:53:23'),
(145, '2026-09-28', '05019998173837', 'FERRETERIA CALPULES S. DE R.L', 'factura', '000-001-01-00111447', 'materiales', 'THINER', NULL, 113.04, 15, 16.96, 130.00, 1, 9, 2026, 'declarado', NULL, 8, '2026-09-30 08:06:06'),
(146, '2026-09-29', '05019001188508', 'COMERCIALIZADORA ELVIR COELLO S. DE. R.L', 'factura', '000-001-01-00210645', 'combustible', 'DIESEL', NULL, 500.00, 0, 0.00, 500.00, 1, 9, 2026, 'declarado', NULL, 8, '2026-09-30 08:09:18'),
(147, '2026-10-01', '08019002282087', 'FERROMAX S.A DE C.V', 'factura', '010-001-01-00079725', 'materiales', 'COLARUM BLCO', NULL, 2062.27, 15, 309.34, 2371.61, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-01 11:17:59'),
(148, '2026-10-01', '05019995128071', 'FERRETERIA ZUMMAR S.A. DE C.V.', 'factura', '000-009-01-00181353', 'materiales', 'LAMINA 1/16X4X10 | REMACHE ALUMINIO LARGE FLANGE', NULL, 3825.86, 15, 573.88, 4399.74, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-01 11:20:15'),
(149, '2026-09-27', '05019019094968', 'GASOLINERA UNO BELLA VISTA', 'factura', '000-001-01-00260116', 'combustible', 'GASOLINA SUPER', NULL, 843.00, 0, 0.00, 843.00, 1, 9, 2026, 'declarado', NULL, 8, '2026-10-02 08:36:58'),
(150, '2026-10-01', '05019019094968', 'GASOLINERA NACO BELLA VISTA', 'factura', '000-001-01-00260297', 'combustible', 'GASOLINA REGULAR', NULL, 870.00, 0, 0.00, 870.00, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-02 08:39:39'),
(152, '2026-10-03', '05019995128071', 'FERRETERIA ZUMMAR S.A. DE C.V.', 'factura', '000-008-01-00290985', 'materiales', 'REMACHE ALUMINIO LARGE FLANGE', NULL, 665.25, 15, 99.79, 765.04, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-03 10:18:52'),
(153, '2026-10-01', '18049018017451', 'SOLUCIONES INTEGRALES S. DE R.L DE C.V', 'factura', '000-004-01-00026135', 'combustible', 'GASOLINA SUPER', NULL, 1000.01, 0, 0.00, 1000.01, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-03 11:07:08'),
(154, '2026-09-29', '18049018017451', 'SOLUCIONES INTEGRALES S. DE R.L DE C.V', 'factura', '000-004-01-00025929', 'combustible', 'GASOLINA SUPER', NULL, 399.87, 0, 0.00, 399.87, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-03 11:10:22'),
(155, '2026-10-05', '05019019094968', 'GASOLINERA UNO BELLA VISTA', 'factura', '000-001-01-00260553', 'combustible', 'GASOLINA SUPER', NULL, 974.00, 0, 0.00, 974.00, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-05 09:17:45'),
(156, '2026-10-05', '05019998173837', 'FERRETERIA CALPULES S. DE R.L', 'factura', '000-001-01-00111539', 'materiales', 'BROCA 1/4 | BROCA 9/32 | BROCA 3/8', NULL, 320.00, 0, 0.00, 320.00, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-05 09:20:38'),
(157, '2026-10-03', '05011940011860', 'ESTACION DE SERVICIO TARA NORTE', 'factura', '001-001-01-00294569', 'combustible', 'GASOLINA SUPER', NULL, 50.00, 0, 0.00, 50.00, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-05 09:26:28'),
(158, '2026-10-05', '18049995000264', 'PURIFICADORA DE AGUA EL PROGRESO S. DE R.L DE C.V', 'factura', '005-001-01-00016819', 'materiales', 'BOTELLONES CON AGUA', NULL, 377.00, 0, 0.00, 377.00, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-06 08:31:59'),
(159, '2026-10-05', '08011975206706', 'INSA TEXACO ARENALES', 'factura', '007-002-01-00175565', 'combustible', 'GASOLINA SUPER', NULL, 100.00, 0, 0.00, 100.00, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-06 08:36:14'),
(160, '2026-10-06', '05019003076139', 'AGENCIA LA MUNDIAL S.A DE C.V', 'factura', '021-001-01-01693461', 'materiales', 'MASILLA | SELLADOR ADHESIVO SALCHICHA', NULL, 514.78, 15, 77.22, 592.00, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-06 10:17:23'),
(161, '2026-10-06', '05019995125457', 'UNO SATELITE', 'factura', '003-001-01-00493904', 'combustible', 'GASOLINA SUPER', NULL, 100.00, 0, 0.00, 100.00, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-06 10:29:03'),
(162, '2026-10-06', '05019998173837', 'FERRETERIA CALPULES S. DE R.L', 'factura', '000-001-01-00111656', 'materiales', 'REMACHE 1/4 X1', NULL, 260.87, 15, 39.13, 300.00, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-06 10:37:06'),
(163, '2026-10-06', '05019998173837', 'FERRETERIA CALPULES S. DE R.L', 'factura', '000-001-01-00111614', 'materiales', 'THINER', NULL, 130.00, 0, 0.00, 130.00, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-06 11:54:36'),
(164, '2026-10-06', '05019998173837', 'FERRETERIA CALPULES S. DE R.L', 'factura', '000-001-01-00111659', 'materiales', 'TORNILLOS 3/8 X1', NULL, 81.00, 0, 0.00, 81.00, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-06 11:55:29'),
(165, '2026-10-10', '05019019094968', 'GASOLINERA UNO BELLA VISTA', 'factura', '000-001-01-00260877', 'combustible', 'GASOLINA SUPER', NULL, 950.00, 0, 0.00, 950.00, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-12 13:57:28'),
(166, '2026-10-03', '05019017923435', 'LUBRICANTES Y COMBUSTIBLES S.A DE C.V.', 'factura', '000-001-01-02278193', 'combustible', 'GASOLINA REGULAR', NULL, 200.01, 0, 0.00, 200.01, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-12 13:59:43'),
(167, '2026-10-08', '06011965008257', 'ASADOS Y LACTEOS DON MARIO', 'factura', '000-004-01-00010474', 'materiales', 'ARROZ Y SHOP SUEY | PLATOS | KIT TENEDOR', NULL, 843.51, 15, 126.53, 970.04, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-12 14:05:28'),
(168, '2026-10-07', '08011975206706', 'INSA TEXACO ARENALES', 'factura', '007-002-01-00176121', 'combustible', 'DIESEL', NULL, 2000.01, 0, 0.00, 2000.01, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-13 15:25:55'),
(169, '2026-10-13', '05019013595890', 'INVERSIONES ROHI SIVEL S DE R.L', 'factura', '000-002-01-01794168', 'combustible', 'GASOLINA SUPER', NULL, 1500.02, 0, 0.00, 1500.02, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-13 15:27:59'),
(170, '2026-10-13', '03019000044953', 'MUNICIPALIDAD DE PUERTO CORTES', 'factura', '007-656-41', 'servicios', 'PEAJE', NULL, 15.00, 0, 0.00, 15.00, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-13 15:30:58'),
(171, '2026-10-13', '05019020214097', 'RECASER S. DE R.L DE C.V', 'factura', '000-001-01-00000615', 'servicios', 'DIAGNOSTICO ELECTRONICO, REVISION DE TRANSMISION', NULL, 1500.00, 15, 225.00, 1725.00, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-13 15:34:04'),
(172, '2026-10-14', '05019000046793', 'CEMCOL COMERCIAL, S.A DE C.V.', 'factura', '000-006-01-00221473', 'materiales', 'MACHO DE CABEZA HEXAGONAL', NULL, 12.22, 15, 1.83, 14.05, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-14 10:15:35'),
(173, '2026-10-13', '08019003250060', 'SERCOM DE HONDURAS S.A DE C.V', 'factura', '000-009-01-25896752', 'servicios', 'PAQUETE DE INTERNET CELULAR', NULL, 108.69, 15, 16.30, 124.99, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-14 10:28:08'),
(174, '2026-10-13', '05019011369436', 'RECOINFE', 'factura', '000-001-01-00018948', 'materiales', 'CODO TUERCA Y ANILLO DE 5/8X1/2 SOLDAD EN ROCA DE MEDIA', NULL, 610.00, 15, 91.50, 701.50, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-14 10:31:06'),
(175, '2026-10-14', '05019995125457', 'UNO SATELITE', 'factura', '003-001-01-00497437', 'combustible', 'GASOLINA SUPER', NULL, 50.00, 0, 0.00, 50.00, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-14 13:29:27'),
(176, '2026-10-14', '05019995108892', 'ACCESORIOS PARA COMPUTADORAS Y OFICINAS S.A DE C.V', 'factura', '032-001-01-00017833', 'materiales', 'RESMA DE PAPEL BOND', NULL, 83.48, 15, 12.52, 96.00, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-14 13:31:34'),
(177, '2026-10-14', '05019995119481', 'REPUESTOS PARA CAMIONES , S.A DE C.V.', 'factura', '000-002-01-00813862', 'materiales', 'KIT MANGUERA  ROJO AZUL | MANITO UNIVERSAL', NULL, 1249.28, 15, 187.39, 1436.67, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-14 16:53:56'),
(178, '2026-10-15', '05019007065665', 'OXIMAYA S.A DE C.V', 'factura', '000-001-01-00100576', 'materiales', 'RECARGA DE ARGON 220', NULL, 2869.57, 15, 430.44, 3300.01, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-15 11:54:56'),
(179, '2026-10-14', '05019019094968', 'GASOLINERA UNO BELLA VISTA', 'factura', '000-001-01-00261075', 'combustible', 'GASOLINA SUPER', NULL, 888.00, 0, 0.00, 888.00, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-15 12:54:36'),
(180, '2026-10-16', '03019000044953', 'MUNICIPALIDAD DE PUERTO CORTES', 'factura', '008-807-60', 'servicios', 'PEAJE', NULL, 6.00, 0, 0.00, 6.00, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-16 16:20:09'),
(181, '2026-10-19', '08019003243825', 'EMPRESA NACIONAL DE ENERGIA ELECTRICA', 'factura', NULL, 'servicios', 'ENERGIA ELECTRICA OCTUBRE 2026', NULL, 4566.98, 0, 0.00, 4566.98, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-19 13:28:34'),
(182, '2026-10-17', '05019026315890', 'AGENCIA LA MUNDIAL, S.A DE C.V', 'factura', '007-001-01-07101744', 'materiales', 'LIMPIAPARABRISAS 16 | LIMPIAPARABRISAS 24', NULL, 137.40, 15, 20.61, 158.01, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-19 13:30:43'),
(183, '2026-10-17', '05019011413357', 'SUPER PUNTAS DE SULA', 'factura', '001-001-01-00002007', 'materiales', 'PEINE / BARRAS EST / MEDIA LUNA / ALINEAMIENTO', NULL, 6869.56, 15, 1030.43, 7899.99, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-19 13:34:16'),
(184, '2026-10-19', '05019019094968', 'GASOLINERA UNO BELLA VISTA', 'factura', '000-001-01-00261451', 'combustible', 'GASOLINA SUPER', NULL, 1215.00, 0, 0.00, 1215.00, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-19 13:36:02'),
(185, '2026-10-17', '08011975206706', 'INSA TEXACO ARENALES', 'factura', '007-002-01-00178980', 'combustible', 'DIESEL', NULL, 3000.00, 0, 0.00, 3000.00, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-19 13:39:21'),
(186, '2026-10-15', '18049018017451', 'SOLUCIONES INTEGRALES S. DE R.L DE C.V', 'factura', '000-004-01-00027177', 'combustible', 'GASOLINA SUPER', NULL, 2554.00, 0, 0.00, 2554.00, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-19 13:42:59'),
(187, '2026-10-19', '05019995119481', 'REPUESTOS PARA CAMIONES , S.A DE C.V.', 'factura', '000-002-01-00815345', 'materiales', 'AIR SPRING | MEMBRANA 3030', NULL, 2287.21, 15, 343.08, 2630.29, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-20 09:05:31'),
(188, '2026-10-21', '08011975206706', 'INSA TEXACO ARENALES', 'factura', '007-002-01-00180469', 'combustible', 'DIESEL', NULL, 2000.01, 0, 0.00, 2000.01, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-22 08:38:07'),
(189, '2026-10-23', '05019017923435', 'LUBRICANTES Y COMBUSTIBLES S.A DE C.V.', 'factura', '000-001-01-02298391', 'combustible', 'DIESEL', 'JDK8613', 3000.02, 0, 0.00, 3000.02, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-26 14:35:42'),
(190, '2026-10-22', '18049018017451', 'TEXACO ABASTOS', 'factura', '000-004-01-00027691', 'combustible', 'DIESEL', NULL, 2000.00, 0, 0.00, 2000.00, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-26 14:38:25'),
(191, '2026-10-22', '04011990001918', 'POLLOS EL PECHUGON', 'factura', NULL, 'materiales', 'ALMUERZO TALLER', NULL, 207.83, 15, 31.17, 239.00, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-26 14:44:27'),
(192, '2026-10-23', '08011975206706', 'INSA TEXACO ARENALES', 'factura', '007-002-01-00181042', 'combustible', 'DIESEL', NULL, 2000.01, 0, 0.00, 2000.01, 1, 10, 2026, 'pendiente', NULL, 8, '2026-10-26 14:47:32');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `gastos_dmc_items`
--

CREATE TABLE `gastos_dmc_items` (
  `id_item` int(10) UNSIGNED NOT NULL,
  `gasto_id` int(10) UNSIGNED NOT NULL,
  `descripcion` varchar(255) NOT NULL,
  `cantidad` decimal(10,2) NOT NULL DEFAULT 1.00,
  `monto` decimal(12,2) NOT NULL DEFAULT 0.00,
  `total_item` decimal(12,2) NOT NULL DEFAULT 0.00,
  `isv` decimal(12,2) NOT NULL DEFAULT 0.00,
  `total` decimal(12,2) NOT NULL DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `gastos_dmc_items`
--

INSERT INTO `gastos_dmc_items` (`id_item`, `gasto_id`, `descripcion`, `cantidad`, `monto`, `total_item`, `isv`, `total`) VALUES
(7, 15, 'PAGO DEL 50% A TRAMITE DE 4 PERMISOS DE EXPLOTACION , SOLVENCIA PROCADURIA, ANTECEDENTES', 1.00, 25000.00, 25000.00, 0.00, 25000.00),
(12, 17, 'BUJIA 9007 DE 65 WHATTS 13 VOLTIOS HALOGENA COLOR CLARO', 2.00, 133.72, 267.44, 40.12, 307.56),
(17, 16, 'RUSTICA CCA 25 2X6X12', 22.00, 459.12, 10100.64, 1515.10, 11615.74),
(18, 16, 'RUSTICA CCA 25 2X6X10', 8.00, 382.60, 3060.80, 459.12, 3519.92),
(19, 16, 'RUSTICA CCA 25 2X8X12', 2.00, 612.16, 1224.32, 183.65, 1407.97),
(20, 16, 'RUSTICA CCA 25 2X10X12', 1.00, 929.60, 929.60, 139.44, 1069.04),
(27, 19, 'ESCOBILLA LIMPIA PARA BRISAS DE 22 LARSSON MET', 2.00, 150.03, 300.06, 45.01, 345.07),
(28, 20, 'RECARGA DE GAS 2 LATAS DE FRION', 2.00, 400.00, 800.00, 0.00, 800.00),
(29, 21, 'MANITO DE AIRE DE FRENO SERVICIO AZUL', 2.00, 63.24, 126.48, 18.97, 145.45),
(30, 21, 'MANITO DE AIRE DE FRENO MERGENCIA ROJA', 2.00, 63.24, 126.48, 18.97, 145.45),
(31, 22, 'BUJE DE HOJA TENSORA DE FREIGHTLINER MANSONS', 2.00, 689.52, 1379.04, 206.86, 1585.90),
(39, 27, 'CUBETA DE ACEITE DE 15W40 CK -4 FLEET SUPREME EC PHILLIPS 66', 2.00, 2244.00, 4488.00, 673.20, 5161.20),
(40, 27, 'GALON DE 15W40 CK-4 GUARDOL FLEET EC PHILLIPS 66', 1.00, 854.13, 854.13, 128.12, 982.25),
(44, 28, 'FILTRO DE GASOLINA', 1.00, 2200.00, 2200.00, 330.00, 2530.00),
(45, 28, 'FILTRO DE ACEITE', 1.00, 2500.00, 2500.00, 375.00, 2875.00),
(46, 28, 'FILTRO DE GASOLINA', 1.00, 3560.00, 3560.00, 534.00, 4094.00),
(52, 29, 'CUBETA DE ACEITE PARA TRANSMISION', 1.00, 3310.95, 3310.95, 496.64, 3807.59),
(53, 30, 'MANGUERA DE AGUA', 1.00, 1150.00, 1150.00, 0.00, 1150.00),
(54, 31, 'DIESEL', 1.00, 2000.00, 2000.00, 0.00, 2000.00),
(55, 32, 'DIESEL', 1.00, 2000.00, 2000.00, 0.00, 2000.00),
(57, 33, 'DIESEL', 378.49, 33.94, 12845.98, 0.00, 12845.98),
(62, 23, 'FILTRO AIRE', 1.00, 5800.00, 5800.00, 870.00, 6670.00),
(66, 39, 'REPARACION ELECTRICA DE AIRE DE MULITA VOLVO JAS1458', 1.00, 800.00, 800.00, 0.00, 800.00),
(72, 41, '2X8X14 RUSTICO CURADO', 6.00, 672.00, 4032.00, 604.80, 4636.80),
(73, 41, '2X8X10 RUSTICO CURADO', 6.00, 480.00, 2880.00, 432.00, 3312.00),
(74, 41, '2X4X14 RUSTICO CURADO', 2.00, 336.00, 672.00, 100.80, 772.80),
(75, 41, '2X4X10 RUSTICO CURADO', 2.00, 240.00, 480.00, 72.00, 552.00),
(76, 42, 'EXTINTOR DE 5 LBS POLVO QUIMICO', 1.00, 900.00, 900.00, 135.00, 1035.00),
(80, 45, 'DIESEL', 78.94, 31.67, 2500.00, 0.00, 2500.00),
(81, 46, 'DIESEL', 6.32, 31.67, 200.00, 0.00, 200.00),
(82, 44, 'FILTRO DE COMBUSTIBLE  CARTUCHO MOTOR 460 PARA FREIGHTLINER', 2.00, 369.59, 739.18, 110.88, 850.06),
(83, 44, 'CABLE DE 7 LINEAS  CON CONECTORES VELVAC', 1.00, 2152.20, 2152.20, 322.83, 2475.03),
(89, 43, 'DIESEL', 76.55, 32.66, 2500.12, 0.00, 2500.12),
(90, 40, 'CALIBRACION DE SENSOR DE PEDAL DE FRENO DEL ABS INTER LT', 1.00, 5000.00, 5000.00, 750.00, 5750.00),
(94, 48, 'MANO DE OBRA INSTALACION', 1.00, 720.68, 720.68, 108.10, 828.78),
(95, 48, 'MANO DE OBRA-ACTIVACION', 1.00, 133.46, 133.46, 20.02, 153.48),
(96, 48, 'ACCESORIIOS KIT PROTECCION', 1.00, 266.92, 266.92, 40.04, 306.96),
(99, 51, 'DIESEL', 1.00, 1304.00, 1304.00, 195.60, 1499.60),
(102, 49, 'DIAGNOSTICO ELECTRONICO UNIDAD VOLVO', 1.00, 1500.00, 1500.00, 225.00, 1725.00),
(105, 54, 'LOGO FREIHTLINER', 1.00, 203.24, 203.24, 30.49, 233.73),
(106, 54, 'PARRILLA PAR FLD CASCADIA', 1.00, 4927.27, 4927.27, 739.09, 5666.36),
(107, 54, 'BOMPER CROMADO', 1.00, 12533.75, 12533.75, 1880.06, 14413.81),
(124, 55, 'COMPLEMENTO SUPERIOR DE BUMPER CROMADO', 1.00, 1529.84, 1529.84, 229.48, 1759.32),
(128, 65, 'GPS SUSCRIPCION MENSUALL/SEGUIMIENTO PREMIUN PERIODO JULIO', 1.00, 322.41, 322.41, 48.36, 370.77),
(129, 66, 'MANO DE OBRA INSTALACION EQUIPO', 1.00, 3811.80, 3811.80, 571.77, 4383.57),
(130, 66, 'MONO DE OBRA - ACTIVACION', 1.00, 401.25, 401.25, 60.19, 461.44),
(131, 66, 'ACCCESORIO KIT DE PROTCCION', 1.00, 802.50, 802.50, 120.38, 922.88),
(132, 66, 'ACCESORIO KIT DE ENCENDIDO 12 V', 1.00, 2032.96, 2032.96, 304.94, 2337.90),
(133, 66, 'GASTOS DE VIAJE /ALIMENTACION TECNICO(UN DIA)', 1.00, 588.49, 588.49, 88.27, 676.76),
(135, 68, 'DIESEL', 1.00, 2000.00, 2000.00, 0.00, 2000.00),
(138, 18, 'MAGUERA DE AGUA USADA', 2.00, 350.00, 700.00, 0.00, 700.00),
(141, 47, 'LLAVE 14 JADEVER JD A1114', 1.00, 204.00, 204.00, 30.60, 234.60),
(142, 14, 'KIT DE MANGUERA DE AIRE ROJA/AZUL 115', 2.00, 540.60, 1081.20, 162.18, 1243.38),
(143, 14, 'MANIVLA AUTOMAN', 5.00, 560.00, 2800.00, 420.00, 3220.00),
(144, 14, 'CABLE 7 LINEAS CON CONECTORES', 1.00, 879.72, 879.72, 131.96, 1011.68),
(145, 14, 'MEMBRANA DOBLE 30/30', 2.00, 600.00, 1200.00, 180.00, 1380.00),
(146, 35, 'DIESEL', 61.24, 32.66, 2000.00, 0.00, 2000.00),
(147, 34, 'DIESEL', 58.93, 33.94, 2000.08, 0.00, 2000.08),
(226, 101, 'GALON THINER', 1.00, 235.00, 235.00, 0.00, 235.00),
(227, 102, 'GASOLINA', 1.00, 1253.00, 1253.00, 0.00, 1253.00),
(228, 103, 'GITICONTROL', 1.00, 2086.96, 2086.96, 313.04, 2400.00),
(229, 103, 'BALANCEO', 1.00, 43.48, 43.48, 6.52, 50.00),
(230, 104, 'HEMBRA GIRATORIA', 2.00, 1206.62, 2413.24, 361.99, 2775.23),
(231, 104, 'ACOPLE HIDRAULICO', 2.00, 316.62, 633.24, 94.99, 728.23),
(232, 104, 'MANGUERA 3/4', 252.00, 8.31, 2094.12, 314.12, 2408.24),
(233, 105, 'TORNILLOS 1/2 X 3 1/2', 4.00, 45.22, 180.88, 27.13, 208.01),
(234, 105, 'TOPE NEGRO', 1.00, 60.86, 60.86, 9.13, 69.99),
(235, 105, 'ELECTRODO', 2.00, 47.83, 95.66, 14.35, 110.01),
(236, 106, 'PEAJE', 1.00, 6.00, 6.00, 0.00, 6.00),
(237, 107, 'GAS LPG', 1.00, 350.00, 350.00, 0.00, 350.00),
(239, 79, 'DIESEL', 1.00, 1000.00, 1000.00, 0.00, 1000.00),
(241, 100, 'GASOLINA', 1.00, 400.00, 400.00, 0.00, 400.00),
(242, 99, 'TUBO HN ESTRCT CUAD 1.1/2X6MT', 1.00, 460.87, 460.87, 69.13, 530.00),
(243, 98, 'REPARACION DE PISTON HIDRAULICO AZUL', 1.00, 12000.00, 12000.00, 1800.00, 13800.00),
(244, 97, 'REPARACION DE PISTON HIDRAULICO DE GRUA PLATAFORMA', 1.00, 37000.00, 37000.00, 5550.00, 42550.00),
(245, 96, 'TAL NOTA DE CREDITO ORIG 1 COPIAS PQ SEXTO 1C', 1.00, 700.00, 700.00, 105.00, 805.00),
(246, 96, 'TAL FACTURA ORIG 1 COPIAS PQ C 1C', 3.00, 760.00, 2280.00, 342.00, 2622.00),
(247, 94, 'TINTA NEGRA PARA IMPRESORA', 1.00, 308.70, 308.70, 46.31, 355.01),
(248, 93, 'CUBETA DE ACEITE', 1.00, 2175.00, 2175.00, 326.25, 2501.25),
(250, 91, 'SUSCRIPCION MENSUAL SEGUIMIENTO PREMIUN PERIODO SEPTIEMBRE', 4.00, 324.00, 1296.00, 194.40, 1490.40),
(251, 89, 'DIESEL', 1.00, 500.00, 500.00, 0.00, 500.00),
(252, 88, 'DIESEL', 1.00, 500.00, 500.00, 0.00, 500.00),
(257, 85, 'HANGER FRONTAL', 1.00, 1177.54, 1177.54, 176.63, 1354.17),
(258, 85, 'BOLT', 1.00, 141.40, 141.40, 21.21, 162.61),
(259, 85, 'TUERCAS DE SEGURIDAD', 1.00, 51.69, 51.69, 7.75, 59.44),
(260, 85, 'WASHA 7/8', 1.00, 9.92, 9.92, 1.49, 11.41),
(261, 81, 'LIJA  #200', 2.00, 14.00, 28.00, 0.00, 28.00),
(262, 81, 'LIJA  #100', 2.00, 15.00, 30.00, 0.00, 30.00),
(263, 81, 'LIJA  #360', 2.00, 14.00, 28.00, 0.00, 28.00),
(264, 81, 'LIJA  #1000', 2.00, 20.00, 40.00, 0.00, 40.00),
(265, 81, 'BROCHAS # 2', 2.00, 20.00, 40.00, 0.00, 40.00),
(266, 80, 'AGUA ARROLLO-5 GLNS', 12.00, 40.00, 480.00, 0.00, 480.00),
(267, 77, 'JUEGO DE MANGUERAS ESPIRALES DE FRENOS AZUL Y', 1.00, 836.86, 836.86, 125.53, 962.39),
(268, 78, 'REMACHE ALUMINIO LARGE FLANGE CEBEZON 19MM 1/4X3/4 200/CAJA', 2.00, 166.31, 332.62, 49.89, 382.51),
(272, 86, 'ALIMENTACION', 1.00, 954.27, 954.27, 0.00, 954.27),
(273, 83, 'TUBO ESTRUCTURAL CUADRADO 4X20 CH-11', 1.00, 2049.00, 2049.00, 307.35, 2356.35),
(274, 82, 'REMACHE DE LUMINIO LARGE FLANGE CABEZON 19MM 1/4X7/8 200/CAJA', 4.00, 167.16, 668.64, 100.30, 768.94),
(275, 74, 'PEAJE', 1.00, 28.00, 28.00, 0.00, 28.00),
(276, 72, 'PEAJE', 1.00, 6.00, 6.00, 0.00, 6.00),
(277, 70, 'GRASA CALCIO', 1.00, 1606.00, 1606.00, 240.90, 1846.90),
(278, 73, 'PEAJE', 1.00, 6.00, 6.00, 0.00, 6.00),
(282, 95, 'FILTRO DE ACEITE', 1.00, 811.47, 811.47, 121.72, 933.19),
(283, 95, 'CUBETA DE ACEITE', 2.00, 2175.00, 4350.00, 652.50, 5002.50),
(284, 95, 'BUJE', 2.00, 326.33, 652.66, 97.90, 750.56),
(285, 109, 'DIESEL', 1.00, 3000.00, 3000.00, 0.00, 3000.00),
(286, 110, 'TORNILLOS 5/8X2COMPLT', 12.00, 57.45, 689.40, 0.00, 689.40),
(287, 110, 'TORNILLO 3/4X3 COMPLST', 12.00, 165.16, 1981.92, 0.00, 1981.92),
(288, 111, 'DIESEL', 1.00, 2500.00, 2500.00, 0.00, 2500.00),
(289, 112, 'DIESEL', 1.00, 2500.00, 2500.00, 0.00, 2500.00),
(290, 113, 'DIESEL', 1.00, 2500.00, 2500.00, 0.00, 2500.00),
(291, 114, 'PAPEL BOND CARTA B20 8.5X11\"H', 1.00, 112.17, 112.17, 16.83, 129.00),
(292, 115, 'REVISIONES MECANICA DE CABEZAL JAH9040-JDM16604', 2.00, 1500.00, 3000.00, 450.00, 3450.00),
(293, 116, 'DIESEL', 1.00, 3000.00, 3000.00, 0.00, 3000.00),
(294, 117, 'M/C BLANCO COMBO', 1.00, 1000.00, 1000.00, 0.00, 1000.00),
(295, 117, 'RESINA', 1.00, 250.00, 250.00, 0.00, 250.00),
(296, 117, 'ONZAS CATALIZADOR', 1.00, 200.00, 200.00, 0.00, 200.00),
(297, 118, 'PEAJE', 1.00, 28.00, 28.00, 0.00, 28.00),
(299, 120, 'PEAJE', 1.00, 28.00, 28.00, 0.00, 28.00),
(301, 122, 'PEAJE', 1.00, 6.00, 6.00, 0.00, 6.00),
(303, 124, 'LLANTAS USADAS AMERICANAS', 4.00, 2500.00, 10000.00, 0.00, 10000.00),
(304, 125, 'PEAJE', 1.00, 28.00, 28.00, 0.00, 28.00),
(305, 126, 'ABRAZADERAS DE INTERCOLER DE  \"4\"', 3.00, 150.00, 450.00, 0.00, 450.00),
(306, 127, 'AMORTIGUADOR TRASERO', 4.00, 1530.07, 6120.28, 918.04, 7038.32),
(307, 127, 'BOLSA DE AIRE', 4.00, 1666.00, 6664.00, 999.60, 7663.60),
(309, 129, 'PEAJE', 1.00, 6.00, 6.00, 0.00, 6.00),
(310, 130, 'MEMBRANA', 2.00, 647.80, 1295.60, 194.34, 1489.94),
(311, 130, 'MANGUERA DE FRENO 72\"', 4.00, 313.45, 1253.80, 188.07, 1441.87),
(312, 130, 'STRET ELBOW 90 DEG 3/8NPT', 4.00, 95.33, 381.32, 57.20, 438.52),
(313, 130, 'FITTING', 4.00, 156.33, 625.32, 93.80, 719.12),
(315, 132, 'DIESEL', 25.77, 38.80, 1000.00, 0.00, 1000.00),
(316, 69, 'SUSCRIPCION MENSUAL SEGUIMIENTO PRIMIUN PERIODO AGOSTO', 4.00, 323.35, 1293.40, 194.01, 1487.41),
(317, 133, 'GASOLINA', 1.00, 1006.00, 1006.00, 0.00, 1006.00),
(318, 134, 'BOTELLONES CON AGUA', 11.00, 27.00, 297.00, 0.00, 297.00),
(319, 128, 'COLCHON USADO P/CABINA', 1.00, 1700.00, 1700.00, 0.00, 1700.00),
(320, 121, 'PEAJE', 1.00, 42.00, 42.00, 0.00, 42.00),
(323, 119, 'PEAJE', 1.00, 6.00, 6.00, 0.00, 6.00),
(324, 123, 'PEAJE', 1.00, 35.00, 35.00, 0.00, 35.00),
(326, 136, 'MOUSE', 1.00, 68.70, 68.70, 10.31, 79.01),
(327, 75, 'PEAJE', 1.00, 28.00, 28.00, 0.00, 28.00),
(328, 71, 'DIESEL', 13.37, 37.40, 500.00, 0.00, 500.00),
(329, 92, 'DIESEL', 80.19, 37.41, 3000.00, 0.00, 3000.00),
(330, 84, 'GASOLINA', 13.94, 35.86, 500.00, 0.00, 500.00),
(331, 87, 'SELLADOR PERMANENTE 50ML', 1.00, 184.35, 184.35, 27.65, 212.00),
(332, 87, 'SELLADOR PERMANENTE 6ML', 1.00, 43.48, 43.48, 6.52, 50.00),
(333, 87, 'SELLADOR PERMANENTE 6ML', 1.00, 43.48, 43.48, 6.52, 50.00),
(334, 90, 'RECARGA DE ARGON 220', 1.00, 2869.56, 2869.56, 430.43, 3299.99),
(335, 137, 'PEAJE', 1.00, 28.00, 28.00, 0.00, 28.00),
(336, 138, 'PEAJE', 1.00, 28.00, 28.00, 0.00, 28.00),
(337, 139, 'TORNILLOS 5 16X2', 26.00, 9.00, 234.00, 0.00, 234.00),
(338, 139, 'SALCHICHA', 1.00, 365.00, 365.00, 0.00, 365.00),
(339, 139, 'TAPICERO', 15.00, 0.73, 10.95, 0.00, 10.95),
(341, 135, 'PEAJE', 1.00, 35.00, 35.00, 0.00, 35.00),
(342, 141, 'EMPAQUE PARA PUERTA DE CARROCERIA DE 1 PULGADA', 2.00, 1000.00, 2000.00, 300.00, 2300.00),
(343, 142, 'DIESEL', 12.89, 38.80, 500.02, 0.00, 500.02),
(344, 143, 'SALCHICHA', 1.00, 291.30, 291.30, 43.70, 335.00),
(345, 143, 'TORNILLOS 3/3 X1', 4.00, 6.08, 24.32, 3.65, 27.97),
(346, 143, 'MACHUELO', 1.00, 78.26, 78.26, 11.74, 90.00),
(347, 144, 'EMPAQUE PARA PUERTA DE CARROCERIA DE 3/4', 2.00, 900.00, 1800.00, 270.00, 2070.00),
(348, 145, 'THINER', 1.00, 113.04, 113.04, 16.96, 130.00),
(349, 146, 'DIESEL', 1.00, 500.00, 500.00, 0.00, 500.00),
(350, 147, 'COLARUM BLCO', 1.00, 2062.27, 2062.27, 309.34, 2371.61),
(353, 148, 'LAMINA 1/16X4X10', 1.00, 2828.00, 2828.00, 424.20, 3252.20),
(354, 148, 'REMACHE ALUMINIO LARGE FLANGE', 6.00, 166.31, 997.86, 149.68, 1147.54),
(355, 149, 'GASOLINA SUPER', 1.00, 843.00, 843.00, 0.00, 843.00),
(356, 150, 'GASOLINA REGULAR', 1.00, 870.00, 870.00, 0.00, 870.00),
(357, 140, 'MATRICULA CASCADIA', 1.00, 25.00, 25.00, 0.00, 25.00),
(362, 152, 'REMACHE ALUMINIO LARGE FLANGE', 4.00, 166.31, 665.24, 99.79, 765.03),
(364, 153, 'GASOLINA SUPER', 25.46, 39.28, 1000.01, 0.00, 1000.01),
(366, 154, 'GASOLINA SUPER', 10.18, 39.28, 399.87, 0.00, 399.87),
(367, 155, 'GASOLINA SUPER', 1.00, 974.00, 974.00, 0.00, 974.00),
(368, 156, 'BROCA 1/4', 1.00, 70.00, 70.00, 0.00, 70.00),
(369, 156, 'BROCA 9/32', 1.00, 100.00, 100.00, 0.00, 100.00),
(370, 156, 'BROCA 3/8', 1.00, 150.00, 150.00, 0.00, 150.00),
(371, 157, 'GASOLINA SUPER', 1.00, 50.00, 50.00, 0.00, 50.00),
(372, 158, 'BOTELLONES CON AGUA', 13.00, 29.00, 377.00, 0.00, 377.00),
(373, 159, 'GASOLINA SUPER', 2.49, 40.16, 100.00, 0.00, 100.00),
(374, 160, 'MASILLA', 1.00, 200.87, 200.87, 30.13, 231.00),
(375, 160, 'SELLADOR ADHESIVO SALCHICHA', 1.00, 313.91, 313.91, 47.09, 361.00),
(376, 161, 'GASOLINA SUPER', 2.49, 40.16, 100.00, 0.00, 100.00),
(377, 162, 'REMACHE 1/4 X1', 150.00, 1.74, 261.00, 39.15, 300.15),
(378, 163, 'THINER', 2.00, 65.00, 130.00, 0.00, 130.00),
(379, 164, 'TORNILLOS 3/8 X1', 9.00, 9.00, 81.00, 0.00, 81.00),
(380, 165, 'GASOLINA SUPER', 1.00, 950.00, 950.00, 0.00, 950.00),
(381, 166, 'GASOLINA REGULAR', 5.78, 34.61, 200.01, 0.00, 200.01),
(382, 167, 'ARROZ Y SHOP SUEY', 1.00, 782.61, 782.61, 117.39, 900.00),
(383, 167, 'PLATOS', 10.00, 1.74, 17.40, 2.61, 20.01),
(384, 167, 'KIT TENEDOR', 10.00, 4.35, 43.50, 6.53, 50.03),
(385, 168, 'DIESEL', 50.74, 39.42, 2000.01, 0.00, 2000.01),
(386, 169, 'GASOLINA SUPER', 37.35, 40.16, 1500.02, 0.00, 1500.02),
(387, 170, 'PEAJE', 1.00, 15.00, 15.00, 0.00, 15.00),
(388, 171, 'DIAGNOSTICO ELECTRONICO, REVISION DE TRANSMISION', 1.00, 1500.00, 1500.00, 225.00, 1725.00),
(389, 172, 'MACHO DE CABEZA HEXAGONAL', 1.00, 12.22, 12.22, 1.83, 14.05),
(391, 174, 'CODO TUERCA Y ANILLO DE 5/8X1/2 SOLDAD EN ROCA DE MEDIA', 1.00, 610.00, 610.00, 91.50, 701.50),
(392, 173, 'PAQUETE DE INTERNET CELULAR', 1.00, 108.69, 108.69, 16.30, 124.99),
(393, 175, 'GASOLINA SUPER', 1.24, 40.46, 50.00, 0.00, 50.00),
(394, 176, 'RESMA DE PAPEL BOND', 1.00, 83.48, 83.48, 12.52, 96.00),
(395, 177, 'KIT MANGUERA  ROJO AZUL', 2.00, 478.26, 956.52, 143.48, 1100.00),
(396, 177, 'MANITO UNIVERSAL', 4.00, 73.19, 292.76, 43.91, 336.67),
(397, 178, 'RECARGA DE ARGON 220', 1.00, 2869.57, 2869.57, 430.44, 3300.01),
(398, 179, 'GASOLINA SUPER', 1.00, 888.00, 888.00, 0.00, 888.00),
(399, 180, 'PEAJE', 1.00, 6.00, 6.00, 0.00, 6.00),
(400, 181, 'ENERGIA ELECTRICA OCTUBRE 2026', 1.00, 4566.98, 4566.98, 0.00, 4566.98),
(403, 183, 'PEINE / BARRAS EST / MEDIA LUNA / ALINEAMIENTO', 1.00, 6869.56, 6869.56, 1030.43, 7899.99),
(404, 184, 'GASOLINA SUPER', 1.00, 1215.00, 1215.00, 0.00, 1215.00),
(405, 182, 'LIMPIAPARABRISAS 16', 1.00, 68.70, 68.70, 10.31, 79.01),
(406, 182, 'LIMPIAPARABRISAS 24', 1.00, 68.70, 68.70, 10.31, 79.01),
(407, 185, 'DIESEL', 1.00, 3000.00, 3000.00, 0.00, 3000.00),
(409, 187, 'AIR SPRING', 1.00, 1562.21, 1562.21, 234.33, 1796.54),
(410, 187, 'MEMBRANA 3030', 1.00, 725.00, 725.00, 108.75, 833.75),
(411, 186, 'GASOLINA SUPER', 1.00, 2554.00, 2554.00, 0.00, 2554.00),
(412, 188, 'DIESEL', 50.74, 39.42, 2000.01, 0.00, 2000.01),
(413, 189, 'DIESEL', 76.10, 39.42, 3000.02, 0.00, 3000.02),
(414, 190, 'DIESEL', 50.74, 39.42, 2000.00, 0.00, 2000.00),
(415, 191, 'ALMUERZO TALLER', 1.00, 207.83, 207.83, 31.17, 239.00),
(416, 192, 'DIESEL', 50.74, 39.42, 2000.01, 0.00, 2000.01);

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
(1, '00001', 'GRASA LITIO 14-OZ TUBO', 'GRASA PARA ENGRASAR PIPAS', 2, 'unidad', 105.22, 123.68, 0.00, 1.00, 'activo', '2026-05-09 10:11:37'),
(2, '00002', 'ACEITE PENETRANTE SPRAY 10-OZ/400ML', 'SPRAY PARA AFLOJAR TORNILLOS', 2, 'unidad', 66.08, 104.68, 0.00, 1.00, 'activo', '2026-05-09 10:15:11'),
(3, '00003', 'GRASA LITIO 16-OZ LATA', 'GRASA PARA ENGRASE DE PIPA', 2, 'unidad', 98.26, 154.07, 0.00, 1.00, 'activo', '2026-05-09 10:16:15'),
(4, '00004', 'CHUMACERA F205 DE 1/2', 'DISCO PARA DESBASTAR METAL', 1, 'unidad', 0.00, 0.00, 0.00, 7.00, 'activo', '2026-05-09 10:17:37'),
(5, '00005', 'CHUMACERA F207  DE 1/4', 'DISCO PARA LIJAR METAL', 1, 'unidad', 0.00, 0.00, 0.00, 7.00, 'activo', '2026-05-09 10:21:51'),
(6, '00006', 'DISCO CORT/MET 5X3/64X7/8', 'DISCO PARA CORTAR METAL', 4, 'unidad', 13.00, 17.55, 0.00, 10.00, 'activo', '2026-05-09 10:24:18'),
(7, '00007', 'ANTEOJOS TRANSPARENTES', '', 8, 'unidad', 30.00, 40.50, 0.00, 5.00, 'activo', '2026-06-08 13:50:22'),
(8, '00008', 'VIDRIO OSCURO PARA SOLDADORA', '', 8, 'unidad', 30.00, 40.50, 0.00, 1.00, 'activo', '2026-06-08 13:53:19'),
(9, '00009', 'TOMA CORRIENTE HEMBRA 110', '', 5, 'unidad', 0.00, 0.00, 0.00, 5.00, 'activo', '2026-06-08 14:09:53'),
(10, '00010', 'TOMA CORRIENTE MACHO 110', '', 5, 'unidad', 0.00, 0.00, 0.00, 5.00, 'activo', '2026-06-08 14:11:03'),
(11, '00011', 'TOMA CORRIENTE  MACHO 220', '', 5, 'unidad', 0.00, 0.00, 0.00, 5.00, 'activo', '2026-06-08 14:11:57'),
(12, '00012', 'TOMA CORRIENTE HEMBRA 220', '', 5, 'unidad', 0.00, 0.00, 0.00, 5.00, 'activo', '2026-06-08 14:13:11'),
(13, '00013', 'SIKAFLEX - 415 UNIVERSAL', '', 2, 'unidad', 0.00, 0.00, 0.00, 3.00, 'activo', '2026-06-08 14:14:34'),
(14, '00014', 'PORTA ELECTRODOS', '', 3, 'unidad', 0.00, 0.00, 0.00, 2.00, 'activo', '2026-06-08 14:17:16'),
(15, '00015', 'SELLADOR ADHES 300ML', '', 2, 'unidad', 0.00, 0.00, 0.00, 1.00, 'activo', '2026-06-08 14:19:00'),
(16, '00016', 'MANGAS DE CUERO PARA SOLDAR', '', 3, 'unidad', 0.00, 0.00, 0.00, 4.00, 'activo', '2026-06-08 14:20:55'),
(17, '00017', 'ELECTRODO CAJA 70/11', '', 4, 'unidad', 0.00, 0.00, 0.00, 1.00, 'activo', '2026-06-08 14:28:04'),
(18, '00018', 'ELECTRODO CAJA 70/18', '', 4, 'unidad', 0.00, 0.00, 0.00, 1.00, 'activo', '2026-06-08 14:29:12'),
(19, '00019', 'DISCO PARA PULIR  DE 5 PULG.', '', 4, 'unidad', 0.00, 0.00, 0.00, 6.00, 'activo', '2026-06-08 14:53:52'),
(20, '00020', 'CILICON SALCHICHA', '', 2, 'unidad', 0.00, 0.00, 0.00, 2.00, 'activo', '2026-06-08 14:57:32'),
(21, '00021', 'CEPILLO ALAMBRE T/COPA 3', '', 4, 'unidad', 0.00, 0.00, 0.00, 4.00, 'activo', '2026-06-08 14:58:53'),
(22, '00022', 'CARETA PARA SOLDAR', '', 8, 'unidad', 0.00, 0.00, 0.00, 2.00, 'activo', '2026-06-08 15:02:22'),
(23, '00023', 'BROCA DE 5/8', '', 8, 'unidad', 0.00, 0.00, 0.00, 2.00, 'activo', '2026-06-08 15:08:33'),
(24, '00024', 'BROCA DE 3/8', '', 8, 'unidad', 0.00, 0.00, 0.00, 2.00, 'activo', '2026-06-08 15:09:12'),
(25, '00025', 'BROCA PARA HIERRO  DE 1/4', '', 8, 'unidad', 0.00, 0.00, 0.00, 2.00, 'activo', '2026-06-08 15:10:49'),
(26, '00026', 'BROCA PARA HIERRO  DE 1/2', '', 8, 'unidad', 0.00, 0.00, 0.00, 2.00, 'activo', '2026-06-08 15:15:37'),
(27, '00027', 'BROCA PARA HIERRO  5/16', '', 8, 'unidad', 0.00, 0.00, 0.00, 2.00, 'activo', '2026-06-08 15:16:31'),
(28, '00028', 'LIMPIA SERPENTINA AIR LEANER EN GALON', 'ESTE PRODUCTO SE REQUIERE , CUANDO LAS UNIDADES QUE SON PIPAS PARA ACARREO A GRANEL, NECESITAN LIMPIZA EXTERIOR', 2, 'unidad', 0.00, 0.00, 0.00, 1.00, 'activo', '2026-06-08 15:18:54'),
(29, '00029', 'ANTEOJOS OSCUROS', '', 8, 'unidad', 0.00, 0.00, 0.00, 2.00, 'activo', '2026-06-08 15:20:48'),
(30, '00030', 'ALAMBRE DE ALUMINIO PARA SOLDAR', '', 4, 'unidad', 0.00, 0.00, 0.00, 5.00, 'activo', '2026-06-08 15:22:23'),
(31, '00031', 'DISCO DE DESVASTE 7*1/4*7/8', '', 4, 'unidad', 0.00, 0.00, 0.00, 7.00, 'activo', '2026-06-08 15:34:50'),
(32, '00032', 'PINTURA BASE BUILDERS ANTICORROSIVO', '', 4, 'unidad', 0.00, 0.00, 0.00, 1.00, 'activo', '2026-06-08 15:37:01'),
(33, '00033', 'PISTOLA PARA SILICON', '', 8, 'unidad', 0.00, 0.00, 0.00, 1.00, 'activo', '2026-06-08 15:40:02'),
(34, '00034', 'GUANTES PARA SOLDAR', '', 8, 'unidad', 0.00, 0.00, 0.00, 2.00, 'activo', '2026-06-08 15:43:00'),
(35, '00035', 'DISCO DE DESVASTE DE 9X1/4', '', 4, 'unidad', 0.00, 0.00, 0.00, 10.00, 'activo', '2026-06-08 15:47:46'),
(36, '00036', 'DISCO ZIRCONIO 4.1/2X1/4X7/8', '', 4, 'unidad', 120.00, 162.00, 0.00, 5.00, 'activo', '2026-06-08 15:49:35'),
(37, '00037', 'DESENGRASANTE ABRO', '', 4, 'unidad', 113.91, 76.89, 0.00, 1.00, 'activo', '2026-06-08 15:50:59'),
(38, '00038', 'BOQUILLA PARA SOLDAR ALUMINIO', '', 8, 'unidad', 0.00, 0.00, 0.00, 5.00, 'activo', '2026-06-08 15:55:30'),
(39, '00039', 'DESENGRASANTE MULTIUSO 1-GLN', '', 4, 'unidad', 214.78, 289.95, 0.00, 1.00, 'activo', '2026-06-09 16:04:26'),
(40, '00040', 'THINER LACA 1-GLN', '', 2, 'unidad', 342.00, 461.70, 0.00, 1.00, 'activo', '2026-06-10 10:48:25'),
(41, '00041', 'XILENO REDUCTOR INDUSTRIAL GLN', '', 2, 'unidad', 422.00, 569.70, 0.00, 1.00, 'activo', '2026-06-10 10:50:12'),
(42, '00042', 'BASE BUILDERS ANT.4000BRILLAN 1-GLN', '', 2, 'unidad', 840.00, 1134.00, 0.00, 1.00, 'activo', '2026-06-10 10:52:25'),
(43, '00043', 'BRACA DE 1/4', '', 8, 'unidad', 10.00, 13.50, 0.00, 1.00, 'activo', '2026-06-12 16:34:57');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `movimientos`
--

CREATE TABLE `movimientos` (
  `id_movimiento` int(10) UNSIGNED NOT NULL,
  `tipo` enum('MAERSK','ALPLA') NOT NULL,
  `fecha` date NOT NULL,
  `hora` time DEFAULT NULL,
  `periodo` varchar(20) DEFAULT NULL COMMENT 'Ej: 2026-08 (periodo/semana de facturación)',
  `flete` varchar(150) DEFAULT NULL COMMENT 'Ruta / descripción del flete',
  `destino` varchar(150) DEFAULT NULL COMMENT 'Cliente / destino del movimiento',
  `cliente_id` int(10) UNSIGNED DEFAULT NULL,
  `ot` varchar(50) DEFAULT NULL COMMENT 'Número de orden de transporte (texto libre)',
  `contenedor` varchar(50) DEFAULT NULL,
  `chasis` varchar(50) DEFAULT NULL,
  `motorista_id` int(10) UNSIGNED DEFAULT NULL,
  `motorista` varchar(100) DEFAULT NULL,
  `placa` varchar(20) DEFAULT NULL,
  `tarifa` decimal(12,2) NOT NULL DEFAULT 0.00,
  `estado` enum('pendiente','facturado','anulado') NOT NULL DEFAULT 'pendiente',
  `factura_id` int(10) UNSIGNED DEFAULT NULL,
  `observacion` text DEFAULT NULL,
  `usuario_id` int(10) UNSIGNED NOT NULL,
  `fecha_creacion` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `movimientos`
--

INSERT INTO `movimientos` (`id_movimiento`, `tipo`, `fecha`, `hora`, `periodo`, `flete`, `destino`, `cliente_id`, `ot`, `contenedor`, `chasis`, `motorista_id`, `motorista`, `placa`, `tarifa`, `estado`, `factura_id`, `observacion`, `usuario_id`, `fecha_creacion`) VALUES
(1, 'MAERSK', '2026-06-16', '12:00:00', 'JUN-16-JUN-21', 'TRASLADO DE SICARGA DIRECTO  A CLIENTE A DESCARGAR', 'INVERSIONES MULTIPLES S.A. SAN PEDRO SULA', 10, 'ASTER', 'MRSU4668993', '2 EJES-40', NULL, 'EFRAIN ALBERTO SARMIENTO REYES', 'JAH9044', 1810.00, 'facturado', 9, '', 6, '2026-08-18 13:51:13'),
(2, 'MAERSK', '2026-06-16', '12:00:00', 'JUN-16-JUN-21', 'SUBIR VACION EN REINTER SAN PEDRO SULA Y POSICIONAR EN GILDAN RIO NANCE', 'GILDAN HONDURAS DITRIBUTION CENTER (HDC) RIO NANCE', 10, '-', 'MRSU8841725', '2 EJES-40', NULL, 'VELENTIN MEJIA GOMEZ', 'TCB1850', 3000.00, 'facturado', 9, '', 6, '2026-08-18 13:51:13'),
(3, 'MAERSK', '2026-06-17', '04:00:00', 'JUN-16-JUN-21', 'SUBIR VACIO EN REINTER POSICIONAR VACIO EN RIO NANCE', 'GILDAN HONDURAS PROPERIES, RIO NANCE', 10, '90114356', 'TRHU5234886', '2 EJES-40', NULL, 'EFRAIN ALBERTO SARMIENTO REYES', 'JAH9044', 3000.00, 'facturado', 9, '', 6, '2026-08-18 13:51:13'),
(4, 'MAERSK', '2026-06-18', '01:00:00', 'JUN-16-JUN-21', 'BOLETEAR CHASIS DE 40 EN PREDIO REINTER', 'GILDAN/CARIBEX, ZIP SAN JOSE ', 10, '-', 'MRSU6972330', '2 EJES-40-TRA8596', NULL, 'RUBEN DARIO RODRIGUEZ AMAYA', 'JAS1458', 1810.00, 'facturado', 9, '', 6, '2026-08-18 13:51:13'),
(5, 'MAERSK', '2026-06-19', '12:00:00', 'JUN-16-JUN-21', 'TRASLADO DE SICARGA DIRECTO  A CLIENTE A DESCARGAR', 'INMOVILIARIA LA MUNDIAL, SAN PEDRO SULA', 10, 'ASTER', 'MRSU9255734', '2 EJES-40-TRC6294', NULL, 'RUBEN DARIO RODRIGUEZ AMAYA', 'JAS1458', 1810.00, 'facturado', 9, '', 6, '2026-08-18 13:51:13'),
(6, 'MAERSK', '2026-06-20', '12:00:00', 'JUN-16-JUN-21', 'TRASLADO DE SICARGA DIRECTO  A CLIENTE A DESCARGAR', 'INMOVILIARIA LA MUNDIAL, SAN PEDRO SULA', 10, 'ASTER', 'MRKU4724456', '2 EJES-40-TRA9439', NULL, 'RUBEN DARIO RODRIGUEZ AMAYA', 'JAS1458', 905.00, 'facturado', 9, 'MOVIMIENTO EN FALSO', 6, '2026-08-18 13:51:13'),
(7, 'MAERSK', '2026-06-20', '12:45:00', 'JUN-16-JUN-21', 'TRASLADO DE SICARGA DIRECTO  A CLIENTE A DESCARGAR', 'INMOVILIARIA LA MUNDIAL, SAN PEDRO SULA', 10, 'ASTER', 'MRKU4724456', '2 EJES-40', NULL, 'RUBEN DARIO RODRIGUEZ AMAYA', 'JAS1458', 1810.00, 'facturado', 9, '', 6, '2026-08-18 13:51:13'),
(8, 'MAERSK', '2026-06-22', '08:00:00', 'JUN-22-JUN-25', 'SUBIR VACIO EN REINTER SAN PEDRO SULA  POSICIONAR EN PLANTA DEL CLIENTE', 'NET LEVEL MANUFACTURING SERVICES S.A. -CHOLOMA', 10, '-', 'UETU784618-4', '2 EJES-40', NULL, 'EFRAIN ALBERTO SARMIENTO REYES', 'JAH9044', 3000.00, 'facturado', 12, '', 6, '2026-08-18 13:51:13'),
(9, 'MAERSK', '2026-06-22', '02:00:00', 'JUN-22-JUN-25', 'POSICIONAMIENTO DE VACIO EN RIO NANCE', 'GILDAN DISTRIBUTION CENTER (HDC) RIO NANCE', 10, '67010303545', 'MRSU7757754', '2 EJES-40', NULL, 'EFRAIN ALBERTO SARMIENTO REYES', 'JAH9044', 3000.00, 'facturado', 12, '', 6, '2026-08-18 13:51:13'),
(10, 'MAERSK', '2026-06-22', '01:00:00', 'JUN-22-JUN-25', 'SUBIR VACIO EN PREDIO REINTER S.P.S. COLOCAR VACIO CLIENTE', 'GILDAN/CARIBEX, ZIP SAN JOSE SAN PEDRO SULA', 10, '-', 'MRSU9011281', '2 EJES-40', NULL, 'RUBEN DARIO RODRIGUEZ AMAYA', 'JAS1458', 1810.00, 'facturado', 12, '', 6, '2026-08-18 13:51:13'),
(11, 'MAERSK', '2026-06-24', '08:00:00', 'JUN-22-JUN-25', 'BOLETAER CHASIS DE 40 EN REINTER S.P.S. Y POSICIONARSE VACIO-RIO NANCE', 'GILDAN HODURAS PROPERTIES -RIO NANCE ', 10, '-', 'MRSU8040367', '2 EJES 40', NULL, 'VELENTIN MEJIA GOMEZ', 'JDK8613', 3000.00, 'facturado', 12, '', 6, '2026-08-18 13:51:13'),
(12, 'MAERSK', '2026-06-24', '08:00:00', 'JUN-22-JUN-25', 'BOLETEAR CHASIS DE 40 EN REINTER S.P.S. Y POSICIONAR VACIO', 'GILDAN HONDUERAS DISTRIBUTION CENTER (HDC)', 10, '-', 'MRSU4408255', '2 EJES 40', NULL, 'RUBEN DARIO RODRIGUEZ AMAYA', 'JAS1458', 3000.00, 'facturado', 12, '', 6, '2026-08-18 13:51:13'),
(13, 'MAERSK', '2026-06-25', '00:00:01', 'JUN-22-JUN-25', 'TRASLADO DE GRUPO LOGISTICO DIRECTO AL CLIENTE ESPERA DESCARGA', 'ATLANTIDA EXPRES-SAN PEDRO SULA', 10, 'ASTER', 'MAEU9270920', '2 EJES 45', NULL, 'VELENTIN MEJIA GOMEZ', 'JDK8613', 1810.00, 'facturado', 12, '', 6, '2026-08-18 13:51:13'),
(14, 'MAERSK', '2026-06-25', '00:00:01', 'JUN-22-JUN-25', 'POSICIONAMIENTO DE VACIO EN RIO NANCE', 'GILDAN HONDURAS DISTRIBUTION CENTER(HDC)', 10, '67010357551', 'CAAU8386809', '2 EJES 470', NULL, 'EFRAIN ALBERTO SARMIENTO REYES', 'JAH9044', 3000.00, 'facturado', 12, '', 6, '2026-08-18 13:51:13'),
(15, 'MAERSK', '2026-06-25', '00:00:01', 'JUN-22-JUN-25', 'SUBIR VACIO EN REINTER SAN PEDRO SULA  POSICIONARSE  ENPLANTA DEL CLIENTE', 'GILDAN/CARIBEX WORLDWIDE HONDURAS -SAN PEDRO SULA ', 10, '67010357567', 'CAAH902104-5', '2 EJES', NULL, 'EFRAIN ALBERTO SARMIENTO REYES', 'JAH9044', 1810.00, 'facturado', 12, '', 6, '2026-08-18 13:51:13'),
(16, 'MAERSK', '2026-06-25', '00:00:01', 'JUN-22-JUN-25', 'POSICIONAMIENTO DE VACIO EN RIO NANCE', 'GILDAN HONDURAS DISTRIBUTION CENTER(HDC)', 10, '67010357557', 'GAOU7770787', '2 EJES', NULL, 'RUBEN DARIO RODRIGUEZ AMAYA', 'JAS1458', 3000.00, 'facturado', 12, '', 6, '2026-08-18 13:51:13'),
(17, 'MAERSK', '2026-06-30', '08:56:00', 'JUN-26-JUL-02', 'PREDIO PUERTO CORTES APMPUCAB', 'MAERSK HN PUCAB', 10, '', 'SEAC410254', 'SEAC410254 40EX', NULL, 'EFRAIN ALBERTO SARMIENTO REYES', 'JAH9044', 3000.00, 'facturado', 22, '', 6, '2026-08-18 13:51:13'),
(18, 'MAERSK', '2026-06-30', '00:00:08', 'JUN-26-JUL-02', 'POSICIONAMIENTO VACIO EN ZIP SAN JOSE', 'GILDAN/CARIBEX-SAN PEDRO SULA', 10, '', 'MRSU8217112', '2 EJES 40', NULL, 'EMILIO YOVANY RODRIGUEZ AMAYA', 'JDK8613', 1810.00, 'facturado', 22, '', 6, '2026-08-18 13:51:13'),
(19, 'MAERSK', '2026-06-30', '00:00:08', 'JUN-26-JUL-02', 'TRASLADA DE SICARGA DIRECTO AL CLIENTE AGENCIA LA MUNDIAL', 'AGENCIA LA MUNDIAL SAN PEDRO SULA', 10, 'ASTER', 'MRSU621614', '2 EJES 40', NULL, 'VELENTIN MEJIA GOMEZ', 'TCB1850', 1810.00, 'facturado', 22, '', 6, '2026-08-18 13:51:13'),
(20, 'MAERSK', '2026-06-30', '00:00:00', 'JUN-26-JUL-02', 'APMT PUCAP', 'MAERSK HNPUCAP PREDIO PUERTO CORTES', 10, '', 'SEAC850401', 'CC  CHASISS: SEAC850401', NULL, 'VELENTIN MEJIA GOMEZ', 'TCB1850', 3000.00, 'facturado', 22, '', 6, '2026-08-18 13:51:13'),
(21, 'MAERSK', '2026-06-30', '00:00:10', 'JUN-26-JUL-02', 'MOV.LOCAL SUBIR VACIO A REINTER', 'PREDIO VLS', 10, '', 'GCXU5791458', '2 EJES 40', NULL, 'EFRAIN ALBERTO SARMIENTO REYES', 'JAH9044', 1810.00, 'facturado', 22, '', 6, '2026-08-18 13:51:13'),
(22, 'MAERSK', '2026-07-01', '11:00:00', 'JUN-26-JUL-02', 'SUBIR VACIO EN REINTER SPS. POSICIONAR ', 'RIO NANCE-GIKDAN PROPERTIES', 10, '', 'TCKU7087180', '2 EJES 40', NULL, 'VELENTIN MEJIA GOMEZ', 'JDK8613', 3000.00, 'facturado', 22, '', 6, '2026-08-18 13:51:13'),
(23, 'MAERSK', '2026-07-01', '03:45:00', 'JUN-26-JUL-02', 'MOV.LOCAL PREDIO REINTER', 'PREDIO VLS', 10, '', 'MRKU4277506', '2 EJES 40 TRA9756', NULL, 'VELENTIN MEJIA GOMEZ', 'JDK8613', 1810.00, 'facturado', 22, '', 6, '2026-08-18 13:51:13'),
(24, 'MAERSK', '2026-07-01', '08:30:00', 'JUN-26-JUL-02', 'MOV. LOCAL PREDIO REINTER', 'PREDIO VLS SUBIR VACIO', 10, '6701032416', 'TCKU6626970', '2 EJES 40 TRA9791', NULL, 'EFRAIN ALBERTO SARMIENTO REYES', 'JAH9044', 1810.00, 'facturado', 22, '', 6, '2026-08-18 13:51:13'),
(25, 'MAERSK', '2026-07-01', '01:00:00', 'JUN-26-JUL-02', 'SUBIR VACIO EN REINTER SAN PEDRO SULA Y POSICIONAR EN PLANTA DEL CLIENTE', 'GILDAN/ CARIBEX-SAN PEDRO SULA', 10, '67010412835', 'UETU8132411', '2 EJES 40', NULL, 'EFRAIN ALBERTO SARMIENTO REYES', 'JAH9044', 1810.00, 'facturado', 22, '', 6, '2026-08-18 13:51:13'),
(26, 'MAERSK', '2026-07-02', '01:00:00', 'JUN-26-JUL-02', 'POSICIONAR VACIO EN GILDAN/CARIBEX SAN PEDRO SULA', 'GILDAN // CARBEX WORLDWIDE HONDURAS-SAN PEDRO SULA', 10, '67010412842', 'MRSU8126563', '2 EJES 40', NULL, 'EFRAIN ALBERTO SARMIENTO REYES', 'JAH9044', 1810.00, 'facturado', 22, '', 6, '2026-08-18 13:51:13'),
(27, 'MAERSK', '2026-07-02', '01:00:00', 'JUN-26-JUL-02', 'POSICIONAR VACIO EN GILDAN PROPERTIES RIO NANCE', 'GILDAN HONDURAS DISTRIBUTION CENTER(HDC) RIO NANCE', 10, '', 'CAAU6560655', '2 EJES 40', NULL, 'VELENTIN MEJIA GOMEZ', 'JDK8613', 3000.00, 'facturado', 22, '', 6, '2026-08-18 13:51:13'),
(28, 'MAERSK', '2026-07-03', '15:05:00', 'JUL-03-JUL-09', 'SUBIR IMPORT EN OPC A ZOLI HANIL', 'GILDAN HONDURAS DISTRIBUTION CENTER (HDC) RIO NANCE', 10, '67010483203', 'MRSU5503920', '2 EJES 40', NULL, 'VELENTIN MEJIA GOMEZ', 'JDK8613', 3000.00, 'facturado', 22, '', 6, '2026-08-18 13:51:14'),
(29, 'MAERSK', '2026-07-08', '00:00:12', 'JUL-03-JUL-09', 'RECOGER VACIO EN PLANTA DEL CLIENTE PARA REINTER S.P.S.', 'MOVESA-SAN PERO SULA', 10, 'ASTER', 'MRKU5507291', '2 EJES 40 TRAB794', NULL, 'VALENTIN MEJIA', 'JDK8613', 1810.00, 'facturado', 22, '', 6, '2026-08-18 13:51:14'),
(30, 'MAERSK', '2026-07-09', '00:00:08', 'JUL-03-JUL-09', 'POSICIONAR VACIO EN GILDAN HDC HDC RIO NANCE', 'GILDAN HONDURAS DISTRIBUTION CENTER (HDC) RIO NANCE', 10, '67010565233', 'FFAU7167250', '2 EJES 40 ', NULL, 'VALENTIN MEJIA', 'JDK8613', 3000.00, 'facturado', 22, '', 6, '2026-08-18 13:51:14'),
(31, 'MAERSK', '2026-07-13', '10:43:00', 'JUL-10-JUL-16', 'RETIRO DE VACIO DEL CLIENTE A BAJAR VACIO A REINTER SPS', 'MOLINEROS COMERCIAL S.A', 10, 'ASTER', 'MRKU4490949', '2 EJES 40 TRA9732', NULL, 'VALENTIN MEJIA', 'JDK8613', 1810.00, 'facturado', 22, '', 6, '2026-08-18 13:51:14'),
(32, 'MAERSK', '2026-07-11', '12:00:00', 'JUL-10-JUL-16', 'TRASLADO DE SICARGA DIRECTO  A CLIENTE A DESCARGAR', 'AGENCIA LA MUNDIAL SAN PEDRO SULA', 10, 'ASTER', 'MRSU3008378', '2 EJES 40 TRA9441', NULL, 'VALENTIN MEJIA', 'JDK8613', 1810.00, 'facturado', 22, '', 6, '2026-08-18 13:51:14'),
(33, 'MAERSK', '2026-07-22', '04:45:00', 'JUL-10-JUL-16', 'TRASLADO DE SICARGA DIRECTO  A CLIENTE A DESCARGAR', 'INVERSIONES ALHCLA SAN PEDRO SULA', 10, 'ASTER', 'MRSU5510153', '2 EJES 40 TRC7342', NULL, 'GALINDO FUNEZ', 'JDK8613', 1810.00, 'facturado', 22, '', 6, '2026-08-18 13:51:14'),
(35, 'ALPLA', '2026-06-19', '00:00:00', '', 'OFIBODEGA CALPULES', 'ALMACEN ALPLA HN', 10, '', '', '', NULL, 'VELENTIN MEJIA GOMEZ', 'TCB1850', 2128.00, 'facturado', 11, '', 6, '2026-08-18 14:14:27'),
(36, 'ALPLA', '2026-06-20', '00:00:00', '', 'OFIBODEGA CALPULES', 'ALMACEN ALPLA HN', 10, '', '', '', NULL, 'VELENTIN MEJIA GOMEZ', 'TCB1850', 2128.00, 'facturado', 11, '', 6, '2026-08-18 14:14:27'),
(37, 'ALPLA', '2026-06-22', '00:00:00', '', 'OFIBODEGA CALPULES', 'ALMACEN ALPLA HN', 10, '', '', '', NULL, 'VELENTIN MEJIA GOMEZ', 'TCB1850', 2128.00, 'facturado', 11, '', 6, '2026-08-18 14:14:27'),
(38, 'ALPLA', '2026-06-23', '00:00:00', '', 'OFIBODEGA CALPULES', 'ALMACEN ALPLA HN', 10, '', '', '', NULL, 'EFRAIN SARMIENTO', 'JAH9044', 2128.00, 'facturado', 11, '', 6, '2026-08-18 14:14:27'),
(39, 'ALPLA', '2026-06-24', '00:00:00', '', 'ALPLA HN', 'OFIBODEGA CALPULES', 10, '', '', '', NULL, 'EFRAIN SARMIENTO', 'JAH9044', 2128.00, 'facturado', 11, '', 6, '2026-08-18 14:14:27'),
(40, 'ALPLA', '2026-06-24', '00:00:00', '', 'OFIBODEGA CALPULES', 'ALMACEN ALPLA HN', 10, '', '', '', NULL, 'EFRAIN SARMIENTO', 'JAH9044', 2128.00, 'facturado', 11, '', 6, '2026-08-18 14:14:27'),
(41, 'ALPLA', '2026-06-26', '00:00:00', '', 'BODEGA CALPULES', 'ALPLAHN', 10, '', '', '', NULL, 'VALENTIN MEJIA', 'TCB1850', 2128.00, 'facturado', 23, '', 6, '2026-08-18 14:14:27'),
(42, 'ALPLA', '2026-06-27', '00:00:00', '', 'OFIBODEGA CALPULES', 'ALMACEN ALPLA HN', 10, '', '', '', NULL, 'VALENTIN MEJIA', 'TCB1850', 2128.00, 'facturado', 23, '', 6, '2026-08-18 14:14:27'),
(43, 'ALPLA', '2026-06-29', '00:00:00', '', 'OFIBODEGA CALPULES', 'ALMACEN ALPLA HN', 10, '', '', '', NULL, 'VALENTIN MEJIA', 'TCB1850', 2128.00, 'facturado', 23, '', 6, '2026-08-18 14:14:27'),
(44, 'ALPLA', '2026-08-06', NULL, 'JUL-31-AGO-06', 'ALMACEN ALPLA HN', 'PREDIO VASTAGO', 10, NULL, NULL, NULL, NULL, NULL, 'TCB1850', 2128.00, 'facturado', 32, 'SOLICITADO POR RENE/ DOCUMENTOS QUEDARON EN VASTAGO', 6, '2026-08-18 14:22:01'),
(45, 'ALPLA', '2026-08-07', NULL, 'AGO-07-AGO-13', 'OFIBODEGA CALPULES', 'BODEGA ENLACE', 10, NULL, NULL, NULL, NULL, NULL, 'TCB1850', 2128.00, 'facturado', 32, NULL, 6, '2026-08-18 14:24:42'),
(46, 'ALPLA', '2026-08-07', NULL, 'AGO-07-AGO-13', 'OFIBODEGA CALPULES', 'BODEGA ENLACE', 10, NULL, NULL, NULL, NULL, NULL, 'TCB1850', 2128.00, 'facturado', 32, NULL, 6, '2026-08-18 14:25:23'),
(47, 'ALPLA', '2026-08-14', NULL, 'AGO-14-AGO-20', 'ALMACEN ALPLA HN', 'PREDIO VASTAGO', 10, NULL, NULL, NULL, 28, 'MANUEL ANTONIO AGUILAR DIAZ', 'JDK8613', 2128.00, 'facturado', 32, NULL, 6, '2026-08-18 14:26:10'),
(48, 'MAERSK', '2026-08-04', '00:00:00', 'JUL-31-AGO-06', 'POSICIONAR VACIO EN PLANTA DEL CLIENTE', 'GILDAN HONDURAS DISTRIBUTION CENTER (HDC) RIO NANCE', 10, '67011021534', 'TLLU4561808', '2 EJES 40 ', 28, 'MANUEL ANTONIO AGUILAR DIAZ', 'JDK8613', 3000.00, 'facturado', 31, '', 6, '2026-08-18 17:25:53'),
(49, 'MAERSK', '2026-08-05', '00:00:00', 'JUL-31-AGO-06', 'MOVIMIENTO LOCAL PREDIO VLS-REINTER', 'ENTREGAR VACIO', 10, '67010962834', 'MRSU6656991', '2 EJES 40 ', 28, 'MANUEL ANTONIO AGUILAR DIAZ', 'JDK8613', 1810.00, 'facturado', 31, '', 6, '2026-08-18 17:25:53'),
(50, 'MAERSK', '2026-08-05', '04:00:00', 'JUL-31-AGO-06', 'RECOLECTA VACIO EN SICARGA PARA REINTER', 'DIUNSA-SAN PEDRO SULA', 10, 'ASTER', 'MRSU7775763', '2 EJES 40 TRA9060', NULL, 'ORLANDO GUEVARA', 'TCA8426', 1810.00, 'facturado', 31, '', 6, '2026-08-18 17:25:53'),
(51, 'MAERSK', '2026-08-05', '10:00:00', 'JUL-31-AGO-06', 'POSICIONAR VACIO EN PLANTA DEL CLIENTE', 'GILDAN PROPIERTEIAS-RIO NANCE', 10, '67011021534', 'MRSU4287169', '2 EJES 40 ', NULL, 'GERMAN POSADAS', 'TCB1850', 3000.00, 'facturado', 31, '', 6, '2026-08-18 17:25:53'),
(52, 'MAERSK', '2026-08-05', '00:00:00', 'JUL-31-AGO-06', 'MOVIMIENTO LOCAL PREDIO SICARGA-REINTER', 'INVERSIONES MALDONADO PEÑA S.A-SAN PEDRO SULA', 10, '67010873318', 'MRSU4733379', '2 EJES 40 ', NULL, 'ORLANDO GUEVARA', 'TCA8426', 1810.00, 'facturado', 31, '', 6, '2026-08-18 17:25:53'),
(53, 'MAERSK', '2026-08-05', '06:30:00', 'JUL-31-AGO-06', 'TRASLADO DE GRUPO LOGISTICO DIRECTO AL CLIENTE PROGRESO-ESPERA DESCARGA', 'ASOCIACION LA PERLA PROGRESO', 10, 'ASTER', 'MRKU900880', '2 EJES 40 ', NULL, 'GERMAN POSADAS', 'TCB1850', 3000.00, 'facturado', 31, '', 6, '2026-08-18 17:25:53'),
(54, 'MAERSK', '2026-08-05', '11:30:00', 'JUL-31-AGO-06', 'RECOLACTA DE VACIO EN HONDUMARES LUEGO BAJAR VACIO REINTER SAN PEDRO SULA', 'DISTRIBUCIONES UNIVERSALES SA DE CV- SAN PEDRO SULA', 10, 'ASTER', 'MRSU4551522', '2 EJES 40 TRA9137', NULL, 'ORLANDO GUEVARA', 'TCA8426', 1810.00, 'facturado', 31, '', 6, '2026-08-18 17:25:53'),
(55, 'MAERSK', '2026-08-06', '10:00:00', 'JUL-31-AGO-06', 'POSICIONAR VACIO EN PLANTA DEL CLIENTE', 'GILDAN HONDURAS DISTRIBUTION CENTER (HDC) RIO NANCE', 10, '', 'CAAU7086290', '2 EJES 40 ', 28, 'MANUEL ANTONIO AGUILAR DIAZ', 'JDK8613', 3000.00, 'facturado', 31, '', 6, '2026-08-18 17:25:53'),
(56, 'MAERSK', '2026-08-06', '00:00:00', 'JUL-31-AGO-06', 'RECOLECTA DE VACIO DEL CLEINTE A PTO. CORTES', 'AGENCIA LA MUNDIAL SA DE CV.-SAN PEDRO SULA', 10, 'ASTER', 'MRSU9956879', '2 EJES 40 TRA8393', NULL, 'GERMAN POSADAS', 'TCB1850', 3000.00, 'facturado', 31, '', 6, '2026-08-18 17:25:53'),
(57, 'MAERSK', '2026-08-07', '08:00:00', 'AGO-07-AGO-13', 'TRASLADO DE SICARGA DIRECTO  A CLIENTE A DESCARGAR', 'AGENCIA LA MUNDIAL SA DE CV.-SAN PEDRO SULA', 10, 'ASTER', 'CAAU5942360', '2 EJES 40 TRA8841', 28, 'MANUEL ANTONIO AGUILAR DIAZ', 'JDK8613', 1810.00, 'facturado', 31, '', 6, '2026-08-18 17:25:53'),
(58, 'MAERSK', '2026-08-08', '00:00:00', 'AGO-07-AGO-13', 'POSICIONAR VACIO EN PLANTA DEL CLIENTE', 'GILDAN HONDURAS DISTRIBUTION CENTER (HDC) RIO NANCE', 10, '', 'MRSU2380101', '2 EJES 40 ', 28, 'MANUEL ANTONIO AGUILAR DIAZ', 'JDK8613', 3000.00, 'facturado', 31, '', 6, '2026-08-18 17:25:53'),
(59, 'MAERSK', '2026-08-10', '00:00:00', 'AGO-07-AGO-13', 'POSICIONAR VACIO EN PLANTA DEL CLIENTE', 'GILDAN MAYAN TEXTILES-RIO NANCE', 10, '67011107301', 'CAJU5031205', '2 EJES 40 ', 28, 'MANUEL ANTONIO AGUILAR DIAZ', 'JDK8613', 3000.00, 'facturado', 31, '', 6, '2026-08-18 17:25:53'),
(60, 'MAERSK', '2026-08-11', '08:00:00', 'AGO-07-AGO-13', 'TRASLADO DE GRUPO FISCAL LOGISTICO DIRECTO AL CLIENTE', 'AGENCIA LA MUNDIAL- SAN PEDRO SULA', 10, 'ASTER', 'MRKU5295016', '2 EJES 40 ', 28, 'MANUEL ANTONIO AGUILAR DIAZ', 'JDK8613', 1810.00, 'facturado', 31, '', 6, '2026-08-18 17:25:53'),
(61, 'MAERSK', '2026-08-11', '08:00:00', 'AGO-07-AGO-13', 'ENTREGA DE VACIO Y CHASIS EN PUCAB', 'MAERKS HNPUCAB', 10, '', 'MRKU5295016', '2 EJES 40 ', 28, 'MANUEL ANTONIO AGUILAR DIAZ', 'JDK8613', 3000.00, 'facturado', 31, '', 6, '2026-08-18 17:25:53'),
(62, 'MAERSK', '2026-08-11', '08:00:00', 'AGO-07-AGO-13', 'TRASLADO DE GRUPO FISCAL LOGISTICO DIRECTO AL CLIENTE', 'ATLANTIDA EXPRES-SAN PEDRO SULA', 10, 'ASTER', 'MSKU4663481', '2 EJES 40 TRA9097', NULL, 'ORLANDO GUEVARA', 'TCA8426', 1810.00, 'facturado', 31, '', 6, '2026-08-18 17:25:54'),
(63, 'MAERSK', '2026-08-11', '06:00:00', 'AGO-07-AGO-13', 'ENTREGA DE VACIO Y CHASIS EN PUCAB', 'MAERKS HNPUCAB', 10, '', 'MAEC763578', '', NULL, 'ORLANDO GUEVARA', 'TCA8426', 3000.00, 'facturado', 31, '', 6, '2026-08-18 17:25:54'),
(64, 'MAERSK', '2026-08-13', '12:00:00', 'AGO-07-AGO-13', 'RETIRO DE VACIO DE REINTER SAP-A PUERTO CORTES', 'OPERADORA DEL ORIENTE SA CV', 10, '', 'MRKU0483453', '2 EJES 40 TRA7989', 28, 'MANUEL ANTONIO AGUILAR DIAZ', 'JDK8613', 3000.00, 'facturado', 31, '', 6, '2026-08-18 17:25:54'),
(65, 'MAERSK', '2026-08-13', '00:00:00', 'AGO-07-AGO-13', 'POSICIONAR EN CHOLOMA', 'UTEXA-CHOLOMA', 10, '67011102746', 'HASU4865204', '', NULL, 'JOSE LUIS HERNANDEZ', 'TCB1850', 3000.00, 'facturado', 31, '', 6, '2026-08-18 17:25:54'),
(69, 'MAERSK', '2026-07-02', NULL, 'JUN-26-JUL-02', 'AJUSTE FALTANTE SEMANA DEL 22-25 DE JUNIO', 'VASTAGO', 10, NULL, 'FALTANTE', NULL, NULL, NULL, NULL, 30.00, 'facturado', NULL, 'FALTANTE DE EN PERIODO DEL JUN-22-JUN-25-SE COMPENSO CON COMBUSTIBLE', 6, '2026-08-19 08:43:23'),
(70, 'MAERSK', '2026-07-13', NULL, 'JUL-10-JUL-16', 'POSICIONAMIENTO DE VACIO EN RIO NANCE', 'GILDAN HONDURAS DISTRIBUTION CENTER (HDC) RIO NANCE', 10, '67010626028', 'MRSU8005432', '2 EJES 40 TRA8359', NULL, 'VALENTIN MEJIA', 'JDK8613', 3000.00, 'facturado', NULL, 'NO LO CONCILIO VASTAGO PARA ICLUIR EN FACTURA-SE COMPENSO CON COMBUSTIBE', 6, '2026-08-19 08:45:03'),
(73, 'MAERSK', '2026-08-14', '15:00:00', 'AGO-14-AGO-20', 'MOV. LOCAL PREDIO DE VLS-REINTER VACIO', 'INVERSONES CROMECA-SAN PEDRO SULA', 10, 'ASTER', 'CAAU6237679', '2 EJES 40 TRB3102', 28, 'MANUEL ANTONIO AGUILAR DIAZ', 'JDK8613', 1810.00, 'facturado', 31, NULL, 6, '2026-08-22 08:00:14'),
(74, 'MAERSK', '2026-08-15', NULL, 'AGO-14-AGO-20', 'SUBIR VACION EN LA CARBONERA PTO CORTES', 'EXTRUM-SAN PEDRO SULA', 10, NULL, 'MRSU5960206', '2 EJES 40', 28, 'MANUEL ANTONIO AGUILAR DIAZ', 'JDK8613', 3000.00, 'facturado', 31, NULL, 6, '2026-08-22 08:00:14'),
(75, 'MAERSK', '2026-08-15', NULL, 'AGO-14-AGO-20', 'SUBIR VACION EN LA CARBONERA PTO CORTES', 'EXTRUM-SAN PEDRO SULA', 10, NULL, 'GAOU7267685', '2 EJES 40', NULL, 'JOSE LUIS HERNANDEZ', 'TCB1850', 3000.00, 'facturado', 31, NULL, 6, '2026-08-22 08:00:14'),
(76, 'MAERSK', '2026-08-18', '08:00:00', 'AGO-14-AGO-20', 'TRASLADO DE SICARGA DIRECTO A CLIENTE A DESCARGAR', 'AGENCIA LA MUNDIAL- SAN PEDRO SULA', 10, 'ASTER', 'MRKU5625083', '2 EJES 40 TRA9214', NULL, 'JOSE LUIS HERNANDEZ', 'TCB1850', 1810.00, 'facturado', 31, NULL, 6, '2026-08-22 08:00:14'),
(77, 'MAERSK', '2026-08-18', '08:00:00', 'AGO-14-AGO-20', 'ENTREGA DE VACIO Y CHASIS EN PUCAB', 'MAERKS HNPUCAB', 10, NULL, 'SEAC410207', '2 EJES 40 TRA9214', NULL, 'JOSE LUIS HERNANDEZ', 'TCB1850', 3000.00, 'facturado', 31, 'SE ENTREGO VACIO Y CHASIS EN PTO. CORTES', 6, '2026-08-22 08:00:14'),
(78, 'MAERSK', '2026-08-14', '13:00:00', 'AGO-14-AGO-20', 'POSICIONAR VACIO EN GILDAN/CARIBEX SAN PEDRO SULA', 'GILDAN/CARIBEX-SAN PEDRO SULA', 10, '67011138282', 'SEKU6895648', '2 EJES 40', NULL, 'ORLANDO GUEVARA', 'TCA8426', 1810.00, 'facturado', 31, NULL, 6, '2026-08-22 08:00:14'),
(79, 'MAERSK', '2026-08-18', NULL, 'AGO-14-AGO-20', 'TRASLADO DE SICARGA AL CLIENTE DIRECTO A DESCARGAR', 'COMPANIA DE INVERSIONES MULTIPLES EBENEZE-SAN PEDRO SULA', 10, 'ASTER', 'FFAU7175195', '2 EJES 40', NULL, 'ORLANDO GUEVARA', 'TCA8426', 1810.00, 'facturado', 31, 'PILOTO PERDIO LA ORIGINAL', 6, '2026-08-22 08:00:14'),
(80, 'MAERSK', '2026-08-19', NULL, 'AGO-14-AGO-20', 'TRASLADO DE SICARGA AL CLIENTE DIRECTO A DESCARGAR', 'INMOVILIARIA LA MUNDIAL, SAN PEDRO SULA', 10, 'ASTER', 'MRKU3060310', '2 EJES 40', NULL, 'ORLANDO GUEVARA', 'TCA8426', 1810.00, 'facturado', 31, NULL, 6, '2026-08-22 08:00:14'),
(81, 'MAERSK', '2026-08-19', NULL, 'AGO-14-AGO-20', 'ENTREGA DE VACIO Y CHASIS EN REINTER SPS', 'VLS', 10, NULL, 'MRSU9260880', 'SEAC454171', NULL, 'ORLANDO GUEVARA', 'TCA8426', 1810.00, 'facturado', 31, NULL, 6, '2026-08-22 08:00:14'),
(82, 'MAERSK', '2026-08-19', NULL, 'AGO-14-AGO-20', 'TRASLADO DE SICARGA AL CLIENTE DIRECTO A DESCARGAR', 'INMOVILIARIA LA MUNDIAL, SAN PEDRO SULA', 10, 'ASTER', 'TCKU7026292', '2 EJES 40', NULL, 'JOSE LUIS HERNANDEZ', 'TCB1850', 1810.00, 'facturado', 31, NULL, 6, '2026-08-22 08:00:14'),
(83, 'MAERSK', '2026-08-18', '11:00:00', 'AGO-14-AGO-20', 'POSICIONAMIENTO DE VACIO EN RIO NANCE', 'GILDAN HONDURAS DISTRIBUTION CENTER (HDC) RIO NANCE', 10, '67011239288', 'MRSU7345952', '2 EJES 40', 28, 'MANUEL ANTONIO AGUILAR DIAZ', 'JDK8613', 3000.00, 'facturado', 31, NULL, 6, '2026-08-22 08:00:14'),
(84, 'MAERSK', '2026-08-18', NULL, 'AGO-14-AGO-20', 'RECOLECTA DE VACIO EN HONDUMARES PARA REINTER SAN PEDRO SULA', 'DISTRIBUCIONES UNIVERSALES SA DE CV- SAN PEDRO SULA', 10, 'ASTER', 'CAAU6914105', '2 EJES 40 TRA8992', 28, 'MANUEL ANTONIO AGUILAR DIAZ', 'JDK8613', 1810.00, 'facturado', 31, NULL, 6, '2026-08-22 08:00:14'),
(85, 'MAERSK', '2026-08-18', NULL, 'AGO-14-AGO-20', 'TRASLADO DE SICARGA AL CLIENTE DIRECTO A DESCARGAR', 'INVERSIONES ALEJANDRA-SANPEDRO SULA', 10, 'ASTER', 'MRSU7683707', '2 EJES 40 TRC7434', 28, 'MANUEL ANTONIO AGUILAR DIAZ', 'JDK8613', 1810.00, 'facturado', 31, NULL, 6, '2026-08-22 08:00:14'),
(86, 'MAERSK', '2026-08-19', NULL, 'AGO-14-AGO-20', 'POSICIONAMIENTO DE VACIO EN RIO NANCE', 'GILDAN HONDURAS PROPERTIES-RIO NACE', 10, NULL, 'CAAU9157725', '2 EJES 40', 28, 'MANUEL ANTONIO AGUILAR DIAZ', 'JDK8613', 3000.00, 'facturado', 31, 'RECOGIO VACIO EN PUCAB PRO. CORTES', 6, '2026-08-22 08:00:14'),
(87, 'MAERSK', '2026-08-20', NULL, 'AGO-14-AGO-20', 'POSICIONAR VACIO EN PLANTA DEL CLIENTE RIO NANCE', 'GILDAN HONDURAS DISTRIBUTION CENTER (HDC) RIO NANCE', 10, '67011345704', 'MRSU9710925', '2 EJES 40', 28, 'MANUEL ANTONIO AGUILAR DIAZ', 'JDK8613', 3000.00, 'facturado', 31, NULL, 6, '2026-08-22 08:00:14'),
(88, 'MAERSK', '2026-08-20', NULL, 'AGO-14-AGO-20', 'POSICIONAR VACIO EN PLANTA DEL CLIENTE ZIP SAN JOSE', 'GILDAN / CARBEX WORLDWIDE HONDURAS-SAN PEDRO SULA', 10, NULL, 'CAAU6914105', '2 EJES 40', 28, 'MANUEL ANTONIO AGUILAR DIAZ', 'JDK8613', 1810.00, 'facturado', 31, NULL, 6, '2026-08-22 08:00:14'),
(89, 'MAERSK', '2026-08-20', NULL, 'AGO-14-AGO-20', 'TRASLADO DE SICARGA AL CLIENTE DIRECTO A DESCARGAR', 'AGENCIA LA MUNDIAL SA DE CV.-SAN PEDRO SULA', 10, 'ASTER', 'TRHU7233169', '2 EJES 40 TRA8595', NULL, 'JOSE LUIS HERNANDEZ', 'TCB1850', 1810.00, 'facturado', 31, NULL, 6, '2026-08-22 08:00:14'),
(90, 'MAERSK', '2026-08-20', NULL, 'AGO-14-AGO-20', 'TRASLADO DE SICARGA DIRECTO A CLIENTE A DESCARGAR', 'AGENCIA LA MUNDIAL SA DE CV.-SAN PEDRO SULA', 10, 'ASTER', 'SUDU6574772', '2 EJES 40 TRA8826 SAC467180', NULL, 'ORLANDO GUEVARA', 'TCA8426', 1810.00, 'facturado', 31, NULL, 6, '2026-08-22 08:00:14'),
(91, 'MAERSK', '2026-08-20', NULL, 'AGO-14-AGO-20', 'ENTREGA DE VACIO Y CHASIS EN PUCAB', 'MAERKS HNPUCAB', 10, NULL, 'SEAC467180', NULL, 27, 'ORLANDO GUEVARA CHAVEZ', 'TCA8426', 3000.00, 'facturado', 31, NULL, 6, '2026-08-22 08:00:14'),
(92, 'MAERSK', '2026-08-21', NULL, 'AGO-21-AGO-27', 'RECOLECTA DE VACIO PLANTA DE CLIENTE VACIO A REINTER', 'AGENCIA LA MUNDIAL S.A DE C.V.-SAN PEDRO SULA', 10, 'ASTER', 'TRHU7233169', '2 EJES 40 SEAC405709', 29, 'JOSE LUIS HERNANDEZ ZUNIGA', 'TCB1850', 1810.00, 'facturado', 31, NULL, 6, '2026-08-22 08:04:09'),
(93, 'MAERSK', '2026-08-22', NULL, 'AGO-21-AGO-27', 'RECOGER VACIO EN SICARGA PARA REINTER', 'DIUNSA-SAN PEDRO SULA', 10, 'ASTER', 'MRSU4733466', '2 EJES 40 SEAC405709', 29, 'JOSE LUIS HERNANDEZ ZUNIGA', 'TCB1850', 1810.00, 'facturado', 31, NULL, 6, '2026-08-22 12:44:42'),
(94, 'MAERSK', '2026-08-21', NULL, 'AGO-21-AGO-27', 'RECOLECTA VACIO PLANTA DEL CLIENTE VACIO A TRAMADE PTO.CORTES', 'AGENCIA LA MUNDIAL S.A DE C.V.-SAN PEDRO SULA', 10, 'ASTER', 'TCKU7026292', '2 EJES 40 TRC5197 SEAC407561', 28, 'MANUEL ANTONIO AGUILAR DIAZ', 'JDK8613', 3000.00, 'facturado', 31, NULL, 6, '2026-08-24 14:41:45'),
(95, 'MAERSK', '2026-08-21', NULL, 'AGO-21-AGO-27', 'RECOLECTA DE VACIO PLANTA DE CLIENTE VACIO A PUCAB CONCORDIA', 'AGENCIA LA MUCIAL S.A DE C.V. -SAN PEDRO SULA', 10, 'ASTER', 'MRKU3060310', '2 EJES 40 TRA8357 SEAC041151', 28, 'MANUEL ANTONIO AGUILAR DIAZ', 'JDK8613', 3000.00, 'facturado', 31, NULL, 6, '2026-08-24 14:45:38'),
(96, 'MAERSK', '2026-08-22', NULL, 'AGO-21-AGO-27', 'RECOLECTAR VACIO EN PTO.CORTES Y POSICIONAR VACIO EN PLANTA DEL CLIENTE RIO NANCE', 'GILDAN HONDURAS DISTRIBUTION CENTER (HDC) RIO NANCE', 10, NULL, 'MRSU2423501', '2 EJES 40', 28, 'MANUEL ANTONIO AGUILAR DIAZ', 'JDK8613', 3000.00, 'facturado', 31, NULL, 6, '2026-08-24 14:46:27'),
(97, 'MAERSK', '2026-08-24', NULL, 'AGO-21-AGO-27', 'POSICIONAR VACIO EN RIO NANCE', 'GILDAN CHOLTEX-RIO NANCE', 10, '67011417692', 'GAOU7138604', '2 EJES 40', 28, 'MANUEL ANTONIO AGUILAR DIAZ', 'JDK8613', 3000.00, 'facturado', 31, 'SOLO FIRMO EL MULERO', 6, '2026-08-25 07:55:49'),
(98, 'MAERSK', '2026-08-25', NULL, 'AGO-21-AGO-27', 'TRASLADO DE HONDUMARES CARGADO DIRECTO AL CLIENTE A DESCARGAR VACIO A', 'INDUSTRIAS IMET S DE RL DE CV-SAN PEDRO SULA', 10, 'ASTER', 'GCXU5668382', '2 EJES 40 TRB3159 APM', NULL, 'ORLANDO GUEVARA', 'TCA8426', 1810.00, 'facturado', 31, NULL, 6, '2026-08-28 14:49:22'),
(99, 'MAERSK', '2026-08-25', '00:00:00', 'AGO-21-AGO-27', 'RECOLECTA DE VACIO ENTREGAR EN REINTER SAN PEDRO SULA', 'AGENCIA LA MUNDIAL S.A DE C.V.-SAN PEDRO SULA', 10, 'ASTER', 'MRSU9161450', '2 EJES 40 SEAC035028', NULL, 'MANUEL AGUILAR', 'JDK8613', 1810.00, 'facturado', 31, NULL, 6, '2026-08-28 14:49:22'),
(100, 'MAERSK', '2026-08-26', NULL, 'AGO-21-AGO-27', 'BOLETEAR CHASIS DE 40 DE 2 EJES EN REINTER Y SUBIR VACIO PARA POSICIONAMIENTO', 'GILDAN / CARBEX WORLDWIDE HONDURAS-SAN PEDRO SULA', 10, '67011447337', 'TRHU4584982', '2 EJES 40', NULL, 'MANUEL AGUILAR', 'JDK8613', 1810.00, 'facturado', 31, NULL, 6, '2026-08-28 14:49:22'),
(101, 'MAERSK', '2026-08-25', '08:00:00', 'AGO-21-AGO-27', 'RECOLECTA DE VACIO EN SICARGA HACIA REINTER', 'DIUNSA-SAN PEDRO SULA', 10, 'ASTER', 'TCNU1825640', '2 EJES 40 SEAC454726', NULL, 'JOSE LUIS HERNANDEZ', 'TCB1850', 1810.00, 'facturado', 31, NULL, 6, '2026-08-28 14:49:22'),
(102, 'MAERSK', '2026-08-25', '15:30:00', 'AGO-21-AGO-27', 'TRASLADO DE GRUPO LOGISTICO DIRECTO AL CLIENTE A DESCARGAR VACIO A ATLANTIDA EXPRES-SAN PEDRO SULA A PREDIO VLS-PTO. CORTES', 'ATLANTIDA EXPRES-SAN PEDRO SULA', 10, 'ASTER', 'MAEU9279383', '2 EJES 40 SEAC467521', NULL, 'JOSE LUIS HERNANDEZ', 'TCB1850', 1810.00, 'facturado', 31, NULL, 6, '2026-08-28 14:49:22'),
(103, 'MAERSK', '2026-08-25', '15:30:00', 'AGO-21-AGO-27', 'ATLANTIDA EXPRES-SAN PEDRO SULA', 'ATLANTIDA EXPRES-SAN PEDRO SULA', 10, 'ASTER', 'SEAC467521', '2 EJES 40 SEAC467521', NULL, 'JOSE LUIS HERNANDEZ', 'TCB1850', 3000.00, 'facturado', 31, 'SE ENTREGAVACIO Y C', 6, '2026-08-28 14:49:22'),
(104, 'MAERSK', '2026-08-25', NULL, 'AGO-21-AGO-27', 'RECOLECTA DE VACIO EN CENTRAL DE ABASTOS IMPORTADORA DE FRUTAS', 'IMPORTADORA DE FRUTAS DE HONDURAS-SAN PEDRO SULA', 10, 'ASTER', 'SUDU8164843', '2 EJES 40 APLZ446001', NULL, 'ORLANDO GUEVARA', 'TCA8426', 3000.00, 'facturado', 31, NULL, 6, '2026-08-28 14:49:22'),
(105, 'MAERSK', '2026-08-26', '11:00:00', 'AGO-21-AGO-27', 'BOLETEAR CHASIS DE 40 DE 3 EJES EN PUCAB Y SUBIR IMPORTACION EN OPC A LAS', 'DIPORM-SAN PEDRO SULA', 10, '67011351720', 'MNBU3576462', '2 EJES 40 TRKH171280', NULL, 'JOSE LUIS HERNANDEZ', 'TCB1850', 3000.00, 'facturado', 31, NULL, 6, '2026-08-28 14:49:22'),
(106, 'MAERSK', '2026-08-26', '13:00:00', 'AGO-21-AGO-27', 'VACIO DE VLS-REINTER SPS', 'KUEHNE+NAGEL / PLYCEM CONSTRUSISTEMAS HONDURAS SA DE CV', 10, '67011441448', 'MRSU2104119', '2 EJES 40', NULL, 'MANUEL AGUILAR', 'JDK8613', 1810.00, 'facturado', 31, NULL, 6, '2026-08-28 14:49:22'),
(107, 'MAERSK', '2026-08-27', '13:00:00', 'AGO-21-AGO-27', 'BOLETEAR CHASIS DE 40 EN REINTER S.P.S. Y SUBIR VACIO PARA POSICIONAMIENTO', 'GILDAN CARIBEX WORLDWIDE HONDURAS', 10, '67011447341', 'MRSU6624675', '2 EJES 40', NULL, 'ORLANDO GUEVARA', 'TCA8426', 1810.00, 'facturado', 31, NULL, 6, '2026-08-28 14:49:22'),
(108, 'MAERSK', '2026-08-28', '08:00:00', 'AGO-28-SEP-03', 'BOLETEAR CHASIS DE 40 DE 2 EJES Y POSICIONAR VACIO EN PLANTA DEL CLIENTE', 'GILDAN MAYAN TEXTILES-RIO NANCE', 10, NULL, 'MRSU9161450', '2 EJES 40', 28, 'MANUEL ANTONIO AGUILAR DIAZ', 'JDK8613', 3000.00, 'facturado', 63, NULL, 6, '2026-09-01 11:28:22'),
(109, 'MAERSK', '2026-08-28', '12:00:00', 'AGO-28-SEP-03', 'RECOLECTA DE VACIO DE ZIP VILLANUEVA A REINTER SAN PEDRO SULA', 'GILDAN ACTIVEWEAR VILLANUEVA S.A-VILLANUEVA', 10, 'ASTER', 'MRSU5415773', '2 EJES 40 SEAC850402', 29, 'JOSE LUIS HERNANDEZ ZUNIGA', 'TCB1850', 3000.00, 'facturado', 63, NULL, 6, '2026-09-01 11:29:27'),
(110, 'MAERSK', '2026-08-29', '09:00:00', 'AGO-28-SEP-03', 'BOLETEAR CHASIS  DE 40 DE 2 EJES Y SUBIR VACIO EN REINTER SPS', 'GILDAN/CARIBEX WORLDWIDE HONDURAS -SAN PEDRO SULA', 10, NULL, 'MRSU9433991', '2 EJES 40', 27, 'ORLANDO GUEVARA CHAVEZ', 'TCA8426', 1810.00, 'facturado', 63, NULL, 6, '2026-09-01 11:30:33'),
(111, 'MAERSK', '2026-09-01', '08:00:00', 'AGO-28-SEP-03', 'BOLETEAR CHASIS DE 40 2 EJES EN REINTER SPS', 'MVP GROUP- SAN PEDRO SULA', 10, '67011525231', 'TCKU7138456', '2 EJES 40', 28, 'MANUEL ANTONIO AGUILAR DIAZ', 'JDK8613', 1810.00, 'facturado', 63, NULL, 6, '2026-09-01 13:02:20'),
(112, 'MAERSK', '2026-09-01', '16:30:00', 'AGO-28-SEP-03', 'RECOLECTA DE VACIO EN PLANTA DEL CLIENTE HACIA PUCAB CONCORDIA', 'IMPORTACIONES EL MUNDO NUEVO-CHOLOMA', 10, 'ASTER', 'MRSU4316204', '2 EJES 40 SEAC047611', 28, 'MANUEL ANTONIO AGUILAR DIAZ', 'JDK8613', 3000.00, 'facturado', 63, NULL, 6, '2026-09-02 13:01:08'),
(113, 'MAERSK', '2026-09-02', NULL, 'AGO-28-SEP-03', 'BOLETEAR CHASIS DE 40 DE 2 EJES EN REINTER SPS Y POSICIONAR VACIO', 'GILDAN HONDURAS DISTRIBUTION CENTER (HDC) RIO NANCE', 10, '67011579008', 'MRSU5415773', '2 EJES 40', 29, 'JOSE LUIS HERNANDEZ ZUNIGA', 'TCB1850', 3000.00, 'facturado', 63, NULL, 6, '2026-09-02 15:05:25'),
(114, 'MAERSK', '2026-09-02', NULL, 'AGO-28-SEP-03', 'BOLETEAR CHASIS DE 40 E 2 EJES EN REINTER SPS Y POSICIONAR VACIO', 'GILDAN HONDURAS DISTRIBUTION CENTER (HDC) RIO NANCE', 10, '67011579009', 'MRSU2007736', '2 EJES 40', 30, 'BIENVENIDO MONCADA', 'TCA8426', 3000.00, 'facturado', 63, NULL, 6, '2026-09-04 10:06:07'),
(115, 'MAERSK', '2026-09-02', '17:00:00', 'AGO-28-SEP-03', 'TRASLADO DE EQUIPO CARGADO DE SICARGA DIRECTO AL CLIENTE A DESCARGAR VACIO REINTER', 'INVERSIONES ALEJANDRA-SANPEDRO SULA', 10, 'ASTER', 'SEKU6965998', '2 EJES 40 TCFH142431', 29, 'JOSE LUIS HERNANDEZ ZUNIGA', 'TCB1850', 905.00, 'facturado', 63, 'MOVIMIENTO EN FALSO, CUANDO LLEGO LUIS OTRO PILOTO LO HABIA RETIRADO', 6, '2026-09-04 10:11:16'),
(116, 'MAERSK', '2026-09-03', '10:00:00', 'AGO-28-SEP-03', 'BOLETEAR CHSIS DE 40 DE 2 EJES EN REINTER Y POSICIONAR VACIO EN RIO NANCE', 'GILDAN MAYAN TEXTILES-RIO NANCE', 10, NULL, 'MRSU9554273', '2 EJES 40', 27, 'ORLANDO GUEVARA CHAVEZ', 'TCA8426', 3000.00, 'facturado', 63, NULL, 6, '2026-09-04 10:15:23'),
(117, 'MAERSK', '2026-09-03', '16:00:00', 'AGO-28-SEP-03', 'RECOGER EQUIPO DE PLANTA DE CLIENTE HACIA REINTER SPS', 'AGENCIA LA MUNDIAL S.A DE C.V.-SAN PEDRO SULA', 10, 'ASTER', 'MSKU1024002', '2 EJES 40 TCFH450018', 27, 'ORLANDO GUEVARA CHAVEZ', 'TCA8426', 1810.00, 'facturado', 63, NULL, 6, '2026-09-04 10:16:16'),
(118, 'MAERSK', '2026-09-03', '08:00:00', 'AGO-28-SEP-03', 'TRASLADO DE EQUIPO CARGADO DE SICARGA DIRECTO AL CLIENTE A DESCARGAR', 'INVERSIONES MULTIPLES-SAN PEDRO SULA', 10, 'ASTER', 'MTSU9621586', '2 EJES 40 APMZ450815', 28, 'MANUEL ANTONIO AGUILAR DIAZ', 'TJDK8613', 1810.00, 'facturado', 63, NULL, 6, '2026-09-08 11:51:25'),
(119, 'MAERSK', '2026-09-03', '08:00:00', 'AGO-28-SEP-03', 'TRASLADO DE SICARGA DIRECTO AL CLIENTE A DESCARGAR VACIO A PUCAB CONCORDIA', 'INVERSIONES MULTIPLES-SAN PEDRO SULA', 10, NULL, 'APMZ450815', '2 EJES 40 APMZ450815', 28, 'MANUEL ANTONIO AGUILAR DIAZ', 'TJDK8613', 3000.00, 'facturado', 63, 'SE ENTREGO VACIO Y CHASIS EN PUCAB PTO.COTES', 6, '2026-09-08 11:53:51'),
(120, 'MAERSK', '2026-09-07', '08:00:00', 'SEP-04-SEP-10', 'BOLETEAR CHASIS DE 40 DE 2 EJES Y SUBIR VACO EN REINTER SAN PEDRO SULA', 'NEXT LEVEL EVERMORE MANUFACTURING SERVICES SA - CHOLOMA', 10, NULL, 'MRSU6313673', '2 EJES 40', 28, 'MANUEL ANTONIO AGUILAR DIAZ', 'TJDK8613', 3000.00, 'facturado', 63, NULL, 6, '2026-09-08 11:56:14'),
(121, 'MAERSK', '2026-09-07', '08:00:00', 'SEP-04-SEP-10', 'BOLETEAR CHASIS DE 40 DE 2 EJES Y SUBIR VACO EN REINTER SAN PEDRO SULA', 'NEXT LEVEL EVERMORE MANUFACTURING SERVICES SA - CHOLOMA', 10, NULL, 'MRSU4442429', '2 EJES 40', 30, 'BIENVENIDO MONCADA', 'JDM6604', 3000.00, 'facturado', 63, NULL, 6, '2026-09-08 12:00:58'),
(122, 'MAERSK', '2026-09-07', '08:00:00', 'SEP-04-SEP-10', 'RETIRAR VACIO DE PLANTA DEL CLIENTE HACIA REINTER', 'AGENCIA LA MUNDIAL', 10, 'ASTER', 'MRSU3645720', '2 EJES 40  SEAC047288', 29, 'JOSE LUIS HERNANDEZ ZUNIGA', 'TCB1850', 1810.00, 'facturado', 63, NULL, 6, '2026-09-08 12:01:47'),
(123, 'ALPLA', '2026-08-27', NULL, 'AGO-21-AGO-27', 'RESINA DOW, RESINA PROFAX, CAJA PARA TAPA, TARIMAS NUEVAS RESINA CB612-OFIBODEGA CALPULES', 'ALMACEN ALPLA HN', 10, NULL, NULL, NULL, 29, 'JOSE LUIS HERNANDEZ ZUNIGA', 'TCB1850', 2128.00, 'facturado', 32, NULL, 6, '2026-09-08 12:50:52'),
(124, 'MAERSK', '2026-09-08', '08:00:00', 'SEP-04-SEP-10', 'RECOLESCTA DE EQUIPO VACIO EN PLANTA DEL CLIENTE HACIA PREDIO REINTER BAJAR VACIO', 'AGENCIA LA MUNDIAL', 10, 'ASTER', 'MRSU5060086', '2 EJES 40', 30, 'BIENVENIDO MONCADA', 'TCB1850', 1810.00, 'facturado', 63, NULL, 6, '2026-09-09 10:47:03'),
(125, 'MAERSK', '2026-09-09', '13:00:00', 'SEP-04-SEP-10', 'BOLETEAR CHASIS DE 40 2 EJES EN REINTER SPS Y PSOSICIONAR VACIO', 'GILDAN HONSURAS DISTRIBUTION CENTER (HDC)- RIO NANCE', 10, '67011680789', 'CAAU5942360', '2 EJES 40', 29, 'JOSE LUIS HERNANDEZ ZUNIGA', 'TCA8426', 3000.00, 'facturado', 63, 'SE HIZO EL 8/9/2026- EN BOLETA ESTA EL TCB1850', 6, '2026-09-09 10:48:29'),
(126, 'MAERSK', '2026-09-09', '13:00:00', 'SEP-04-SEP-10', 'BOLETEAR CHAIS DE 40 DE 2 EJES EN REINTER SPS Y POSICIONAR VACIO', 'GILDAN HONSURAS DISTRIBUTION CENTER (HDC)- RIO NANCE', 10, '67011680788', 'MRSU6789839', '2 EJES 40', 28, 'MANUEL ANTONIO AGUILAR DIAZ', 'JDK8613', 3000.00, 'facturado', 63, 'SE HIZO EL 8/9/2026- EN BOLETA ESTA EL TCB1850', 6, '2026-09-09 10:49:41'),
(127, 'MAERSK', '2026-09-09', '08:00:00', 'SEP-04-SEP-10', 'BOLETEAR CHSIS DE 40 DE 2 EJES EN REINTER Y POSICIONAR VACIO ZIP SAN JOSE', 'GILDAN/CARIBEX WORLWIDE HONDURAS-SAN PEDRO SULA', 10, '67011681717', 'MRKU5922749', '2 EJES 40', 28, 'MANUEL ANTONIO AGUILAR DIAZ', 'JDK8613', 1810.00, 'facturado', 63, NULL, 6, '2026-09-09 17:10:53'),
(129, 'MAERSK', '2026-09-09', '08:00:00', 'SEP-04-SEP-10', 'BOLETEAR CHASIS DE 40 DE EJES Y SUBIR VACIO EN REINTER Y POSICIONAR VACIO EN ZIP SAN JOSE', 'GILDAN/CARIBEX WORLDWIDE HONDURAS-SAN PEDRO SULA', 10, '67011681718', 'MRSU6108473', '2 EJES 40', 29, 'JOSE LUIS HERNANDEZ ZUNIGA', 'JDK8613', 1810.00, 'facturado', 63, NULL, 6, '2026-09-09 17:14:25'),
(130, 'MAERSK', '2026-09-09', '15:32:00', 'SEP-04-SEP-10', 'ENTREGAR VACIO Y CHSIS EN REINTER', 'MOLINEROS COMERCIAL S.A', 10, NULL, 'MRKU5537465', 'CHAS40 SEAC424623', 29, 'JOSE LUIS HERNANDEZ ZUNIGA', 'TCA1850', 800.00, 'facturado', 63, 'PILOTO DE VASTAGO SE QUEDO CON LA ORIGINAL', 6, '2026-09-09 17:15:44'),
(131, 'MAERSK', '2026-09-08', '16:00:00', 'SEP-04-SEP-10', 'RECOGER EQUIPO VACIO EN SICARGA HACIA REINTER SPS', 'VLS', 10, 'ASTER', 'CAAU7069250', 'CHAS40 SEAC402959', 28, 'MANUEL ANTONIO AGUILAR DIAZ', 'JDK8613', 1810.00, 'facturado', 63, NULL, 6, '2026-09-09 17:17:09'),
(132, 'MAERSK', '2026-09-11', '20:00:00', 'SEP-11-SEP-17', 'BOLETEAR CHISIS DE 40 DE 2 EJES EN REINTER SUBIR VACIO EN REINTER POSICIONAMIENTO', 'GILDAN MAYAN TEXTILES-RIO NANCE', 10, NULL, 'MRSU9195234', '2 EJES 40', 28, 'MANUEL ANTONIO AGUILAR DIAZ', 'JDK8613', 3000.00, 'facturado', 63, NULL, 6, '2026-09-11 13:06:45'),
(133, 'ALPLA', '2026-09-10', NULL, NULL, 'RESINA DOW, RESINA PROFAX, CAJA PARA TAPA, TARIMAS NUEVAS RESINA CB612', 'OFIBODEGA CALPULES', 10, NULL, NULL, NULL, 28, 'MANUEL ANTONIO AGUILAR DIAZ', 'TCA1850', 2128.00, 'facturado', 51, NULL, 6, '2026-09-11 13:31:23'),
(134, 'MAERSK', '2026-09-11', '13:00:00', 'SEP-11-SEP-17', 'RECOLECTA DE VACIO DEL CLIENTE A REINTER SAN PEDRO SULA', 'AGENCIA LA MUNDIAL- SAN PEDRO SULA', 10, 'ASTER', 'TCKU6859782', '2 EJES 40 SEAC423527', 29, 'JOSE LUIS HERNANDEZ ZUNIGA', 'TCA8426', 1810.00, 'facturado', 63, NULL, 6, '2026-09-17 07:44:20'),
(135, 'MAERSK', '2026-09-12', '11:00:00', 'SEP-11-SEP-17', 'RECOGER VACIO DEL CLIENTE Y ENTREGARLO EN REINTER SAN PEDRO SULA', 'MOVESA-SAN PERO SULA', 10, 'ASTER', 'MRSU5045447', '2 EJES 40 MAEC531049', 30, 'BIENVENIDO MONCADA', 'JDM6604', 1810.00, 'facturado', 63, NULL, 6, '2026-09-17 07:45:26'),
(136, 'MAERSK', '2026-09-12', '12:00:00', 'SEP-11-SEP-17', 'RECOGER VACIO DEL CLIENTE Y ENTREGARLO EN REINTER SAN PEDRO SULA', 'DIUNSA-SAN PEDRO SULA', 10, 'ASTER', 'SELU4067873', '2 EJES 40 MAEC7630055', 29, 'JOSE LUIS HERNANDEZ ZUNIGA', 'TCA8426', 1810.00, 'facturado', 63, NULL, 6, '2026-09-17 07:46:28'),
(137, 'MAERSK', '2026-09-16', NULL, 'SEP-11-SEP-17', 'RECOLECTA DE VACIO DE SICARGA DEL CLIENTE A REINTER SPS', 'DIUNSA-SAN PEDRO SULA', 10, 'ASTER', 'MRSU7480269', '2 EJES 40 SEAC465729', 30, 'BIENVENIDO MONCADA', 'JDM6604', 1810.00, 'facturado', 63, 'SE ENTERGO ENVASTAGO', 6, '2026-09-17 07:48:10'),
(138, 'MAERSK', '2026-09-16', '10:00:00', 'SEP-11-SEP-17', 'BOLETEAR CHASIS DE 40 DE 2 EJES EN REINTER SAN PEDRO SULA', 'GILDAN // CARBEX WORLDWIDE HONDURAS-SAN PEDRO SULA', 10, NULL, 'MRSU2810347', '2 EJES 40', 29, 'JOSE LUIS HERNANDEZ ZUNIGA', 'TCB1850', 1810.00, 'facturado', 63, NULL, 6, '2026-09-21 10:17:34'),
(139, 'MAERSK', '2026-09-16', NULL, 'SEP-11-SEP-17', 'RECOGER VACIO EN CENTRAL DE ABASTOS DIRECTO A S&T#1', 'IMPORTADORA DE FRUTAS DE HONDURAS-SAN PEDRO SULA', 10, 'ASTER', 'MNBU4281548', '2 EJES 40', 28, 'MANUEL ANTONIO AGUILAR DIAZ', 'JDK8613', 3000.00, 'facturado', 63, NULL, 6, '2026-09-21 10:18:39'),
(140, 'MAERSK', '2026-09-17', NULL, 'SEP-11-SEP-17', 'RECOGER EQUIPO VACIO EN PLANTA DEL CLIENTE HACIA REINTER SAP', 'HANES CHOLOMA ZIP VILLANUEVA', 10, NULL, 'CAAU8140733', '2 EJES 40 SEAC425299', 28, 'MANUEL ANTONIO AGUILAR DIAZ', 'JDK8613', 3000.00, 'facturado', 63, 'DE ZIP VILLANUEVA A REINTER', 6, '2026-09-21 10:20:19'),
(141, 'MAERSK', '2026-09-17', NULL, 'SEP-11-SEP-17', 'TRASLADO DE EQUIPO CARGADO DE SICARGA AL CLIENTE VACIO REINTER', 'INMOBILIARIA LA MUNDIAL-SAN PEDRO SULA', 10, 'ASTER', 'MRSU6191050', '2 EJES 40 SEAC463761', 30, 'BIENVENIDO MONCADA', 'JDM6604', 1810.00, 'facturado', 63, NULL, 6, '2026-09-21 10:21:23'),
(142, 'MAERSK', '2026-09-18', NULL, 'SEP-18-SEP-24', 'TRASLADO DE EQUIPO CARGADO DE SICARGA DIRECTO AL CLIENTE DESCARGAR', 'ALMACEN PAJARO AZUL-SAN PEDRO SULA', 10, 'ASTER', 'GCXU6239422', '2 EJES 40 SEAC461973', 28, 'MANUEL ANTONIO AGUILAR DIAZ', 'JDK8613', 1810.00, 'facturado', 63, 'NO SE MOVIO EL CONTENEDOR POR PROBLEMAS DE DOCUMENTACION ADUANA', 6, '2026-09-21 10:22:24'),
(143, 'MAERSK', '2026-09-19', '08:00:00', 'SEP-18-SEP-24', 'RECOLECTA DE VACIO DE SICARGA A REINTER', 'DIUNSA-SAN PEDRO SULA', 10, 'ASTER', 'MRSU5457824', '2 EJES 40 NOLZ410341', 30, 'BIENVENIDO MONCADA', 'JDM6604', 1810.00, 'facturado', 63, 'SE FINALIZO EL DIA 21/9/26', 6, '2026-09-21 10:25:59'),
(144, 'MAERSK', '2026-09-21', '08:00:00', 'SEP-18-SEP-24', 'BOLETEAR CHASIS DE 40 DE 2 EJES Y SUBIR VACIO EN REINTER DIRECTO A CARGAR', 'GILDAN MAYAN TEXTILES-RIO NANCE', 10, NULL, 'MRSU7382278', '2 EJES 40', 28, 'MANUEL ANTONIO AGUILAR DIAZ', 'JDK8613', 3000.00, 'facturado', 63, NULL, 6, '2026-09-21 17:44:47'),
(145, 'MAERSK', '2026-09-23', NULL, 'SEP-18-SEP-24', 'TRASLADO DE EQUIPO CARGADO DE SICARGA DIRECTO AL CLIENTE DESCARGAR', 'INVERSIONES MULTIPLES-SAN PEDRO SULA', 10, 'ASTER', 'MRSU3644702', '2 EJES 40 SEAC410047', 28, 'MANUEL ANTONIO AGUILAR DIAZ', 'JDK8613', 1810.00, 'facturado', 63, NULL, 6, '2026-09-23 15:13:34'),
(146, 'MAERSK', '2026-09-22', '08:00:00', 'SEP-18-SEP-24', 'TRASLADO DE EQUIPO CARGADO DIRECTO AL CLIENTE A DESCARGAR', 'ALMACEN PAJARO AZUL-SAN PEDRO SULA', 10, 'ASTER', 'GCXU6239422', '2 EJES 40 SEAC461973', 30, 'BIENVENIDO MONCADA', 'JDM6604', 1810.00, 'facturado', 63, NULL, 6, '2026-09-23 15:15:38'),
(147, 'MAERSK', '2026-09-23', NULL, 'SEP-18-SEP-24', 'BOLETEAR CHASIS DE 40 DE 2 EJES EN RINTER Y SUBIR VACIO A CARGAR', 'GILDAN MAYA TEXTILES- RIO NANCE', 10, NULL, 'MIEU3908227', '2 EJES 40', 30, 'BIENVENIDO MONCADA', 'JDM6604', 3000.00, 'facturado', 63, NULL, 8, '2026-09-24 15:37:52'),
(148, 'MAERSK', '2026-09-24', '08:00:00', 'SEP-18-SEP-24', 'BOLETEAR CHASIS DE 40 DE 2 EJES EN PUCAB Y SUBIR VACIO A POSICIONAR', 'GILDAN MAYAN TEXTILES-RIO NANCE', 10, NULL, 'MIEU3201595', '2 EJES 40', 28, 'MANUEL ANTONIO AGUILAR DIAZ', 'JDK8613', 3000.00, 'facturado', 63, NULL, 8, '2026-09-25 09:17:36'),
(149, 'MAERSK', '2026-09-24', NULL, 'SEP-18-SEP-24', 'BOLETEAR CHASIS DE 40 DE 2 EJES EN REINTER Y SUBIR VACIO A POSICIONAR', 'GILDAN / CARIBEX WORLDWIDE HONDURAS', 10, NULL, 'MRSU8987160', '2 EJES 40', 30, 'BIENVENIDO MONCADA', 'JDM6604', 1810.00, 'facturado', 63, NULL, 8, '2026-09-25 09:25:12'),
(150, 'MAERSK', '2026-09-23', '08:00:00', 'SEP-18-SEP-24', 'TRASLADO DE EQUIPO CARGADO DE SICARGA DIRECTO AL CLIENTE A DESCARGAR', 'INVERSIONES MULTIPLES SAN PEDRO SULA', 10, 'ASTER', 'MRKU4734768', '2 EJES 40 TCFHRC4643', 30, 'BIENVENIDO MONCADA', 'JDM6604', 1810.00, 'facturado', 63, NULL, 8, '2026-09-25 09:33:59'),
(151, 'MAERSK', '2026-09-23', '08:00:00', 'SEP-18-SEP-24', 'VACIO A PUCAB#2 PUERTO CORTES', 'INVERSIONES MULTIPLES SAN PEDRO SULA', 10, 'ASTER', 'TCFHRC4643', '2 EJES 40', 30, 'BIENVENIDO MONCADA', 'JDM6604', 3000.00, 'facturado', 63, NULL, 8, '2026-09-25 09:36:44'),
(152, 'MAERSK', '2026-10-05', '12:00:00', 'OCT-02-OCT-08', 'RECOGER EQUIPO VACIO DE PLANTA DE CLIENTE Y ENTREGAR VACIO EN PUCAB CONCORDIA CHASIS A PUCAB', 'MOVESA- SAN PEDRO SULA', 10, 'ASTER', 'MRKU4979288', '2 EJES 40 SEAC454413', 30, 'BIENVENIDO MONCADA', 'TCB5555', 3000.00, 'pendiente', NULL, NULL, 8, '2026-09-25 09:41:06'),
(153, 'MAERSK', '2026-09-22', '08:00:00', 'SEP-18-SEP-24', 'TRASLADO DE EQUIPO CARGADO DIRECTO AL CLIENTE A DESCARGAR', 'AGENCIA LA MUNDIAL SAN PEDRO SULA', 10, 'ASTER', 'SEAC467450', '2 EJES 40', 28, 'MANUEL ANTONIO AGUILAR DIAZ', 'JDK8613', 3000.00, 'facturado', 63, NULL, 8, '2026-09-25 09:46:43'),
(154, 'MAERSK', '2026-09-22', NULL, 'SEP-18-SEP-24', 'TRASLADO DE EQUIPO CARGADO DIRECTO AL CLIENTE A DESCARGAR', 'AGENCIA LA MUNDIAL SAN PEDRO SULA', 10, 'ASTER', 'MRKU3818550', '2 EJES 40 SEAC467450', 28, 'MANUEL ANTONIO AGUILAR DIAZ', 'JDK8613', 1810.00, 'facturado', 63, NULL, 8, '2026-09-25 09:54:37'),
(155, 'MAERSK', '2026-09-25', '13:00:00', 'SEP-25-OCT-01', 'BOLETEAR CHASIS DE 40 E 2 EJES EN PUCAB Y SUBIR VACIO A POSICIONAR', 'GILDAN//CARIBEX WORLDWIDE HONDURAS', 10, '67012057031', 'CAAU769050', '2 EJES 40 SEAC049493', 30, 'BIENVENIDO MONCADA', 'JDK8613', 1810.00, 'facturado', 63, NULL, 8, '2026-09-25 16:09:37'),
(156, 'MAERSK', '2026-09-25', '08:00:00', 'SEP-25-OCT-01', 'TRASLADO DE SICARGA DIRECTO AL CLIENTE A DESCARGAR', 'AGENCIA LA MUNDIAL SA DE CV', 10, 'ASTER', 'MRKU3566947', '2 EJES 40 SEAC049493', 30, 'BIENVENIDO MONCADA', 'JDM6604', 1810.00, 'facturado', 63, NULL, 8, '2026-09-28 09:15:16'),
(157, 'MAERSK', '2026-09-25', '08:00:00', 'SEP-25-OCT-01', 'TRASLADO DE SICARGA DIRECTO AL CLIENTE DECARRGAR', 'AGENCIA LA MUNDIAL SA DE CV', 10, 'ASTER', 'SEAC049493', '2 EJES 40 SEAC049493', 30, 'BIENVENIDO MONCADA', 'JDM6604', 3000.00, 'facturado', 63, 'VACIO A  S&T#2 TRAMADE', 8, '2026-09-28 09:28:20'),
(158, 'MAERSK', '2026-09-26', '08:00:00', 'SEP-25-OCT-01', 'BOLETEAR CHASIS DE 40 DE 2 EJES EN PUCAB Y SUBIR VACIO PARA POSICIONAR', 'GILDAN HONDURAS DISTRIBUTION CENTER (HDC)', 10, NULL, 'MRSU8866908', '2 EJES 40', 28, 'MANUEL ANTONIO AGUILAR DIAZ', 'JDK8613', 3000.00, 'facturado', 63, 'VACIO S&T#2 TRAMADE', 8, '2026-09-28 09:40:42'),
(159, 'MAERSK', '2026-09-29', '10:00:00', 'SEP-25-OCT-01', 'BOLETEAR CHASIS DE 40 DE 2 EJES EN REINTER Y SUBIR VACIO PARA POSICIONAR', 'GILDAN//CARIBEX WORLDWIDE HONDURAS', 10, '67012130987', 'MRSU7274015', '2 EJES 40', 30, 'BIENVENIDO MONCADA', 'JDM6604', 1810.00, 'facturado', 63, NULL, 8, '2026-09-30 08:19:40'),
(160, 'MAERSK', '2026-09-30', '08:00:00', 'SEP-25-OCT-01', 'TRASLADO DE EQUIPO CARGADO DE SICARGA AL CLIENTE', 'AGENCIA LA MUNDIAL S.A DE C.V', 10, 'ASTER', 'MRSU6548683', '2 EJES 40', 30, 'BIENVENIDO MONCADA', 'TCA5555', 1810.00, 'facturado', 63, NULL, 8, '2026-10-02 09:25:28'),
(161, 'MAERSK', '2026-10-01', '08:00:00', 'SEP-25-OCT-01', 'RECOGER VACIO EN AGENCIA LA MUNDAL', 'AGENCIA LA MUNDIAL S.A DE C.V', 10, 'ASTER', 'MRSU6011987', '2 EJES 40 MAEC 505897', 30, 'BIENVENIDO MONCADA', 'TCA5555', 1810.00, 'pendiente', NULL, NULL, 8, '2026-10-02 09:27:44'),
(162, 'MAERSK', '2026-10-01', '09:30:00', 'SEP-25-OCT-01', 'TRASLADO DE EQUIPO CARGADO DE SICARGA DIRECTO AL CLIENTE VACIO SE ENTREGA EN REINTER SAN PEDRO SULA', 'INDUSTRIAS IMET S DE R.L DE C.V', 10, 'ASTER', 'GAOU7194038', '2 EJES 40 SEAC047480', 30, 'BIENVENIDO MONCADA', 'TCB5555', 1810.00, 'pendiente', NULL, NULL, 8, '2026-10-03 08:23:02'),
(163, 'MAERSK', '2026-10-02', '08:00:00', 'OCT-02-OCT-08', 'BOLETEAR CHASIS DE 40 DE 2 EJES Y SUBIR VACIO EN REINTER Y SUBIR VACIO POSICIONAR EN RIO NANCE', 'GILDAN CHOLTEX - RIO NANCE', 10, '67012207540', 'CAAU8200154', '2 EJES 20', 30, 'BIENVENIDO MONCADA', 'TCB5555', 3000.00, 'pendiente', NULL, NULL, 8, '2026-10-03 08:28:34'),
(164, 'MAERSK', '2026-10-02', '03:00:00', 'OCT-02-OCT-08', 'RECOGER EQUIPO VACIO HACIA REINTER', 'INDUSTRIAS TIARA', 10, 'ASTER', 'MRSU8819681', '2 EJES 40 TCFH450021', 30, 'BIENVENIDO MONCADA', 'TCB5555', 1810.00, 'pendiente', NULL, NULL, 8, '2026-10-05 09:58:03'),
(165, 'MAERSK', '2026-10-05', '08:00:00', 'OCT-02-OCT-08', 'BOLETAER CHASIS DE 40 DE 2 EJES Y SUBIR VACIO EN REINTER', 'ZIP VILLANUEVA', 10, '67012184990', 'MRSU7394514', '2 EJES 20', 30, 'BIENVENIDO MONCADA', 'TCB5555', 3000.00, 'pendiente', NULL, NULL, 8, '2026-10-05 11:59:23'),
(166, 'MAERSK', '2026-10-05', '12:00:00', 'OCT-02-OCT-08', 'RECOGER EQUIPO VACIO EN PLANTA DEL CLIENTE Y ENTREGAR VACIO EN PUCAB CONCORDIA CHASIS A PUCAB', 'MOVESA', 10, 'ASTER', 'MRKU4979288', '2 EJES 40 SEAC454413', 30, 'BIENVENIDO MONCADA', 'TCB5555', 3000.00, 'pendiente', NULL, NULL, 8, '2026-10-07 08:56:53'),
(167, 'MAERSK', '2026-09-04', NULL, 'AGO-28-SEP-03', 'BOLETEAR CHASIS DE 40 DE 2 EJES Y SUBIR VACIO EN REINTER Y POSICIONAR EN GILDAN RIO NANCE', 'GILDAN MAYAN TEXTILES RIO NANCE', 10, NULL, 'MRSU6975469', NULL, 27, 'ORLANDO GUEVARA CHAVEZ', 'TCA8426', 3000.00, 'facturado', 63, NULL, 8, '2026-10-07 10:44:10'),
(168, 'MAERSK', '2026-10-06', '08:00:00', 'OCT-02-OCT-08', 'TRASLADO DE EQUIPO CARGADO DE SICARGA DIRECTO A DESCARGAR AL CLIENTE LUEGO VACIO  REINTER', 'AGENCIA LA MUNDIAL S.A DE C.V', 10, 'ASTER', 'TCKU6520865', 'APLZ133061', 30, 'BIENVENIDO MONCADA', 'TCB5555', 1810.00, 'pendiente', NULL, NULL, 8, '2026-10-13 10:25:03'),
(169, 'MAERSK', '2026-10-13', NULL, 'OCT-09-OCT-15', 'BOLETEAR CHASIS DE 40 DE 2 EJES EN REINTER Y SUBIR VACIO LUEGO POSICIONAR EN RIO NANCE', 'GILDAN HONDURAS DISTRIBUTION CENTER (HDC) RIO NANCE', 10, '67012438630', 'CAJU5233968', '2 EJES 40', 28, 'MANUEL ANTONIO AGUILAR DIAZ', 'JDK8613', 3000.00, 'pendiente', NULL, NULL, 8, '2026-10-14 08:39:52'),
(170, 'MAERSK', '2026-10-14', '12:00:00', 'OCT-09-OCT-15', 'BOLETEAR CHASIS DE 40 DE 2 EJES Y SUBIR VACIO EN REINTER Y POSICIONR EN GILDAN VILLANUEVA', 'ZIP VILLANUEVA', 10, NULL, 'GAOU7779207', '2 EJES 40', 19, 'WILLIAM NORTIE ARDON CRUZ', 'TCB1850', 3000.00, 'pendiente', NULL, NULL, 8, '2026-10-14 16:59:02'),
(171, 'MAERSK', '2026-10-17', '12:00:00', 'OCT-16-OCT-22', 'BOLETEAR CHASIS DE 40 DE 2 EJES EN REINTER Y SUBIR VACIO PARA POSICIONAR EN RIO NANCE', 'GILDAN MAYAN TEXTILES - RIO NANCE', 10, NULL, 'MRSU7938557', '2 EJES 40', 19, 'WILLIAM NORTIE ARDON CRUZ', 'TCB1850', 3000.00, 'pendiente', NULL, NULL, 8, '2026-10-17 11:58:10'),
(172, 'MAERSK', '2026-10-16', '08:00:00', 'OCT-16-OCT-22', 'TRASLADO DE EQUIPO CARGADO DE PREDIO FISCAL DE GRUPO LOGISTICO DIRECTO A DESCARGAR  AL CLIENTE  VACIO S&T PUERTO CORTES', 'DAYIN MARTINEZ', 10, 'ASTER', 'MSKU4654767', '2 EJES 40', 30, 'BIENVENIDO MONCADA', 'TCB5555', 4810.00, 'pendiente', NULL, NULL, 8, '2026-10-19 14:16:39'),
(173, 'MAERSK', '2026-10-20', '08:00:00', '19-OCT / 24-OCT', 'TRASLADO DE EQUIPO CARGADO DE SICARGA DIRECTO AL CLIENTE A DESCARGA VACIO A REINTER', 'AGENCIA LA MUNDIAL SA DE CV-SAN PEDRO SULA', 10, 'ASTER', 'MRKU3430863', '2 EJES 40 / TRB1878', 19, 'WILLIAM NORTIE ARDON CRUZ', 'TCB1850', 4810.00, 'pendiente', NULL, 'SE REALIZO MOVIMIENTO 1 EN SPS Y MOVIMIENTO 2 IR A PUCAB PUERTO CORTES DE DEJAR CONTENEDOR Y CHASIS', 9, '2026-10-23 16:37:17'),
(174, 'MAERSK', '2026-10-23', '18:00:00', '19-OCT / 24-OCT', 'TRASLADO DE EQUIPO CARGADO DEL PREDIO FISCAL GRUPO LOGISITICO ANTIGUO PREDIO DE BTD. DIRECTO AL CLIENTE A DESCARGAR VACIO REINTER', 'ASOCIACION LA PERLA-EL PROGRESO', 10, 'ASTER', 'TCKU7625520', '2 EJES / TRA9735', 35, 'JUAN RENEE CASTILLO FERNANDEZ', 'JDK8613', 3000.00, 'pendiente', NULL, NULL, 9, '2026-10-23 16:44:08');
INSERT INTO `movimientos` (`id_movimiento`, `tipo`, `fecha`, `hora`, `periodo`, `flete`, `destino`, `cliente_id`, `ot`, `contenedor`, `chasis`, `motorista_id`, `motorista`, `placa`, `tarifa`, `estado`, `factura_id`, `observacion`, `usuario_id`, `fecha_creacion`) VALUES
(175, 'MAERSK', '2026-10-23', '08:00:00', '19-OCT / 24-OCT', 'TRASLADO DE EQUIPO CARGADO DE PREDIO FISCAL ZOFRACO, DIRECTO AL CLIENTE A DESCARGAR VACIO A PUCAB CONCORDIA CHASIS A PUCAB 1', 'IMPORTACIONES EL MUNDO NUEVO-CHOLOMA', 10, 'ASTER', 'MRSU8140617', '2 EJES / TRC7407', 35, 'JUAN RENEE CASTILLO FERNANDEZ', 'JDK8613', 4810.00, 'pendiente', NULL, 'MOVIMIENTO 1 DE ZOFRACO SPS A IMPORTACIONES EL MUNDO NUEVO CHOLOMA , MOVIMIENTO 2 DE CHOLOMA A PUCAB PUERTO CORTES ENTREGAR CONTENEDOR Y CHASIS', 9, '2026-10-23 17:06:01'),
(176, 'MAERSK', '2026-10-23', '07:00:00', '19-OCT / 24-OCT', 'TRASLADO DE EQUIPO CARGADO DE SICARGO DIRECTO AL CLIENTE A DESCARGAR, LUEGO VACIO A REINTER', 'AGENCIA LA MUNDIAL SA DE CV-SAN PEDRO SULA', 10, 'ASTER', 'MIEU3540006', '2 EJES / TRA8212', 35, 'JUAN RENEE CASTILLO FERNANDEZ', 'TCB1850', 1810.00, 'pendiente', NULL, 'SE TRASLADO EQUIPO CARGADO DE SICARGO DIRECTO AL CLIENTE PERO SE DEJO COLOCADO EN ANDEN YA QUE NO LO DESCARGARON SE NOTIFICO AL VASTAGO Y DIJERON SE DEJARA EN EL CLIENTE FINALIZANDO EL VIAJE.', 9, '2026-10-24 08:22:06'),
(177, 'MAERSK', '2026-10-22', '16:00:00', '19-OCT / 24-OCT', 'RECOGER EQUIPO VACIO DE LA PLANTA DEL CLIENTE Y ENTREGAR EN REINTER SAN PEDRO SULA', 'AGENCIA LA MUNDIAL - SAN PEDRO SULA', 10, 'ASTER', 'MRSU3150839', '2 EJES / TRC4014', 30, 'BIENVENIDO MONCADA', 'TCA8426', 4810.00, 'pendiente', NULL, 'MOVIMIENTO 1 SE RECOGIO UNIDAD VACIA EN CLIENTE PARA REINTER QUE NO LO ACEPTO POR MAL ESTADO FISICO, MOVIMIENTO 2 DE REINTER A PUCAB CONCORDIA Y PUCAB 1.', 9, '2026-10-24 10:12:09'),
(178, 'MAERSK', '2026-10-23', '11:00:00', '19-OCT / 24-OCT', 'TRASLADO DE EQUIPO CARGADO DE ZOFRACO DIRECTO AL CLIENTE A DESCARGAR, LUEGO VACIO A PUCAB CONCORDIA CHASIS PUCAB 1', 'AMERICAN INTERNACIONAL TRADING S.A', 10, 'ASTER', 'MRSU5859628', '2 EJES / TRA7985', 19, 'WILLIAM NORTIE ARDON CRUZ', 'TCA8426', 4810.00, 'pendiente', NULL, 'MOVIMIENTO 1 TRASLADO DE EQUIPO CARGADO DE ZOFRACO DIRECTO AL CLIENTE, MOVIMIENTO 2 LUEGO VACIO A PUERTO CORTES ENTREGAR CONTENER Y CHASIS A PUCAB CONCORDIA Y PUCAB 1.', 9, '2026-10-24 10:24:59'),
(179, 'MAERSK', '2026-10-22', '08:00:00', '19-OCT/ 24-OCT', 'TRASLADO DE EQUIPO CARGADO DE SICARGO DIRECTO AL CLIENTE A DESCARGAR LUEGO VACIO REINTE', 'AGENCIA LA MUNDIAL-SAN PEDRO SULA', 10, 'ASTER', 'MRSU3150839', '2 EJES / TRC4014', 19, 'WILLIAM NORTIE ARDON CRUZ', 'TCB1850', 1810.00, 'pendiente', NULL, NULL, 9, '2026-10-24 11:58:07'),
(180, 'MAERSK', '2026-10-20', '08:00:00', 'OCT-16-OCT-22', 'TRASLADO DE EQUIPO CARGADO DE SICARGA DIRECTO AL CLIENTE A DESCARGAR VACIO A REINTER', 'AGENCIAL LA MUNDIAL S.A DE C.V', 10, 'ASTER', 'GAOU7481064', '2 EJES 40 TCFHRC4657', 30, 'BIENVENIDO MONCADA', 'TCA8426', 1810.00, 'pendiente', NULL, NULL, 8, '2026-10-24 12:05:23'),
(181, 'MAERSK', '2026-10-21', '08:00:00', 'OCT-16-OCT-22', 'BOLETEAR CHASIS DE 40 DE 2 EJES EN REINTER Y SUBIR VACIO Y POSICIONAR EN ZIP SAN JOSE GILDAN CARIBEX', 'GILDAN CARIBEX WORLDWIDE HONDURAS', 10, '67012590482', 'CAAU7592493', '2 EJES 40 TCFH400376', 30, 'BIENVENIDO MONCADA', 'TCA8426', 1810.00, 'pendiente', NULL, NULL, 8, '2026-10-24 12:09:31'),
(182, 'MAERSK', '2026-10-26', '10:00:00', '26 OCT- 31-OCT', 'BOLETEAR CHASIS DE 40 DE 3 EJES EN REINTER SAN PEDRO SULA Y SUBIR VACIO PARA POCISIONAR EN PLANTA DEL CLIENTE.', 'NEXT LEVEL/ EVERMORE MANUFACTURING SERVICES SA', 10, '67012642142', 'MRSU6299997', '3 EJES 40 / TRC7322', 19, 'WILLIAM NORTIE ARDON CRUZ', 'TCB1850', 3000.00, 'pendiente', NULL, 'EL DIA SABADO SE REALIZA EL RETIRO DEL CHASIS EN REINTER Y RETORNA AL PREDIO VAMER, LUNES 26-OCT SUBE EL CHASIS A MAQUILA EN ZOLI HONDURAS, CHOLOMA.', 9, '2026-10-26 09:59:45'),
(183, 'MAERSK', '2026-10-24', '10:00:00', '19-OCT 24-OCT', 'BOLETAER CHASIS DE 40 DE 3 EJES EN PUCAB PARA SUBIR EQUIPO CARGADO EN OPC A LAS 2:00PM DURECTO AL CLIENTE A DESCARGAR.', 'PRODUCTO IMPORTADOS AMERICANOS SA', 10, '67012595441', 'MRKU0946183', '3 EJES 40 TRC7868', 36, 'DONNY MARIANO HERNANDEZ GODOY', 'JAH9040', 3000.00, 'pendiente', NULL, 'BOLETEAR CHASIS DE 40 DE 3 EJES EN VASTAGO PARA PUCAB 1 Y CONTENEDOR EN PUCAB CONCORDIA.', 9, '2026-10-26 11:50:34');

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
  `tipo_referencia` enum('compra','orden_trabajo','cotizacion','ajuste_manual','requisicion') NOT NULL DEFAULT 'ajuste_manual',
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
-- Volcado de datos para la tabla `ordenes_trabajo`
--

INSERT INTO `ordenes_trabajo` (`id_orden`, `numero_orden`, `fecha_apertura`, `fecha_cierre`, `cliente_id`, `usuario_id`, `placa`, `marca`, `modelo`, `anio`, `color`, `kilometraje`, `numero_motor`, `numero_chasis`, `descripcion_trabajo`, `estado`, `cotizacion_origen_id`, `observaciones`, `fecha_creacion`, `cotizacion_id`) VALUES
(2, 'OT-2026-001', '2026-09-28', NULL, 2, 7, 'UNIDAD 366', '', '', NULL, '', NULL, 'CHURUMBULO', '', 'TRABAJO 1: BASES PARA LUZ CE CORTESIA ( 4 POR LADO)\nTRABAJO 2: COLGADOR PARA MANGUERAS FRONTALES\nTRABAJO 3: LINEA DE VIDA\nTRABAJO 4: REPARAR PARED FRONTAL, POR LA PARTE INTERNA\nTRABAJO 5: REVISION GENERAL', 'en_proceso', NULL, '', '2026-09-28 11:16:15', NULL),
(3, 'OT-2026-002', '2026-09-28', NULL, 2, 7, 'TROCO BOOSTER', '', '', NULL, '', NULL, '', '', 'TRABAJO 1: FABRICAR TROCO PARA BOOSTER Y PROBADOR DE LUCES', 'borrador', NULL, '', '2026-09-28 11:26:57', NULL),
(4, 'OT-2026-003', '2026-09-28', NULL, 7, 7, '', '', 'TANQUE', NULL, '', NULL, '', '', 'TRABAJO 1: SOLDADURA EXTERIOR\nTRABAJO 2:  SOLDADURA INTERIOR\nTRABAJO 3: MANTENIMIENTO DE LOS 4 SIN FINES Y SUSTITUIR SUS CHUMACERAS\nTRABAJO 4: INTADO DE LOS 2 BOOM\nTRABAJO 5: MANTENIMIENTO DE CANOA\nTRABAJO 6: REPARACION DE GUARDAFANGOS\nTRABAJO 7: ENGRASE DE SISETMA DE DESCARGA\nTRABAJO 8: REPARACION DE BOOM PLUMA\nTRABAJO 9: SUSTITUCION DE MANGUERAS DAÑADAS', 'borrador', NULL, '', '2026-09-28 11:31:09', NULL),
(5, 'OT-2026-004', '2026-09-28', NULL, 7, 7, 'TCH3196', '', '', NULL, '', NULL, 'CAMION GRANELERO', '', 'TRABAJO 1: REPARACION DE EJE DE TOMAFUERZA\nTRABAJO 2: REPARACION DE LINEAS DE AIRE DE SUSPENSION TRASERA Y TERCER EJE', 'en_proceso', NULL, '', '2026-09-28 11:37:34', NULL),
(6, 'OT-2026-005', '2026-09-28', NULL, 14, 7, 'TCH3196', 'FREIGHTLINER', 'CASCADIA', '2014', 'BLANCO', NULL, '', '1FUJGLBG9ELFP5694', 'TRABAJO 1: REPARACION DE BUMPER FRONTAL \nTRABAJO 2: INSTALACION DE PLACAS NUEVAS', 'en_proceso', NULL, '', '2026-09-28 11:41:11', NULL),
(7, 'OT-2026-006', '2026-10-08', NULL, 3, 7, 'CONT. 8253', 'FURGON SECO', '', NULL, '', NULL, '', '', 'TRABAJO 1: REPARACION DE COMPUERTA IZQ\nTRABAJO 2: BASES DE BUMPER TRASERO\nTRABAJO 3: REPARAR GOLPE LATERAL IZQUIERDA', 'en_proceso', NULL, '', '2026-09-28 11:43:43', NULL),
(8, 'OT-2026-007', '2026-09-29', NULL, 2, 7, '364', 'PIPA', '', NULL, '', NULL, '', '', 'TRABAJO 1: TODAS LAS BUCHACAS CUESTAN QUE ABRAN CUANDO ESTÁ CARGADO.\nTRABAJO 2: INSTALAR BASES PARA LUCES DE CORTESÍA.\nTRABAJO 3: FABRICAR COLGANTE DE MANBGUERAS Y SU BASE', 'en_proceso', NULL, '', '2026-09-29 09:38:44', NULL),
(9, 'OT-2026-008', '2026-09-29', NULL, 3, 7, 'V5103', 'FURGON SECO', '', NULL, '', NULL, '', '', 'TRABAJO 1: RECONSTRUCCIÓN DE PARED FRONTAL Y ESQUINERO\nMATERIALES:  2 PLYWOOD DE 1/4, 2 CAJAS DE REMACHES DE 1/4, 1 LAMINA PREPINTADA 10*4, 1 LAMINA DE ALUMINIO 10*4 , 2 SIKAFLEX', 'en_proceso', NULL, '', '2026-09-29 15:49:44', NULL),
(10, 'OT-2026-009', '2026-09-30', NULL, 2, 7, 'UNIDAD 486', '', '', NULL, '', NULL, '', '', 'TRABAJO 1: CAMBIAR PUENTE DE EJE MUERTO', 'en_proceso', NULL, '', '2026-09-30 13:13:49', NULL),
(11, 'OT-2026-010', '2026-10-01', NULL, 8, 7, '', '', '', NULL, '', NULL, 'OC0869', '', 'TRABAJO 1: FABRICAR E INSTALAR DOS TANQUES HIDRAULICOS PARA CABEZAL', 'borrador', NULL, '14,250 CANT 2 \nTOTAL 28500', '2026-10-03 09:35:37', NULL),
(12, 'OT-2026-011', '2026-10-16', NULL, 2, 7, '616', '', 'PIPA GRANELERA', NULL, '', NULL, '', '', 'TRABAJO 1: FABRICAR 10 BASES PARA LUCES DE CORTESÍAS', 'en_proceso', NULL, '', '2026-10-16 10:39:41', NULL),
(13, 'OT-2026-012', '2026-10-16', NULL, 2, 7, '366', '', 'PIPA GRANELERA', NULL, '', NULL, '', '', 'TRABAJO 1: FABRICAR BASES PARA LUCES DE CORTESÍAS, CUATRO BASES POR LADO.\nTRABAJO 2: FABRICAR BASES Y LINEA DE VIDA Y SUMINISTRO\nTRABAJO 3: FABRICAR COLGADOR DE MANGUERAS FRONTALES\nTRABAJO 4: REPARACION DE PARED FRONTAL PICADA \nTRABAJO 5: FABRICAR BASE  Y ESCUADRA DE PORTADOR DE MANGUERAS\nTRABAJO 6: SUMINISTRO DE RESORTE DE PORTA NANGUERAS', 'en_proceso', NULL, '', '2026-10-16 10:57:38', NULL),
(14, 'OT-2026-013', '2026-10-16', NULL, 2, 7, '603', '', 'PIPA GRANELERA', NULL, '', NULL, '', '', 'TRABAJO 1: FABRICAR BASES PARA LUCES DE CORTESÍAS, CUATRO BASES POR LADO.\nTRABAJO 2: FABRICAR BASES PARA LUZ DE TRABAJO EN BOOM', 'en_proceso', NULL, '', '2026-10-16 10:59:01', NULL),
(15, 'OT-2026-014', '2026-10-16', NULL, 2, 7, '617', '', 'PIPA GRANELERA', NULL, '', NULL, '', '', 'TRABAJO 1: FABRICAR BASES PARA LUCES DE CORTESÍAS, CUATRO BASES POR LADO.\nTRABAJO 2: REPARAR ESQUINAS DE GUARDAFANGOS FRONTALES \nTRABAJO 3: FABRICAR COLGADOR DE MANGUERAS FRONTALES\nTRABAJO 4: SUMINISTRO DE RESORTE DE PORTA NANGUERAS\nTRABAJO 5: FABRICAR BUMPER TRASERO\nTRABAJO 6: REPARACION DE BASE DE MANDOS HIDRAULICOS\nTRABAJO 7: REPARACION DE BASE DE HIDROMOTOR DEL BOOM VERTICAL\nTRABAJO 8: REPARACION DE ASPAS DE TORNILLO SIN FIN VERTICAL\nTRABAJO 9: REPARACION DE ESQUINA DE GUARDAFANGO TRASERO', 'borrador', NULL, '', '2026-10-16 11:00:27', NULL),
(16, 'OT-2026-015', '2026-10-16', NULL, 1, 7, 'PIPA 11', '', 'PIPA GRANELERA', NULL, '', NULL, '', '', 'TRABAJO 1: REPARACION DE BOOM HORIZONTAL', 'en_proceso', NULL, '', '2026-10-16 11:09:02', NULL),
(17, 'OT-2026-016', '2026-10-16', NULL, 2, 7, '612', '', 'PIPA GRANELERA', NULL, '', NULL, '', '', 'TRABAJO 1: FABRICAR BASES PARA LUCES DE CORTESÍAS, CUATRO BASES POR LADO.\nTRABAJO 2: REPARACION DE GUARDAFANGO DELANTERO IZQUIERDO\nTRABAJO 3: FABRICACION DE BUMPER TRASERO Y SUS BASES\nTRABAJO 4: FABRICAR BASE DE MANDOS HIDRAULICOS \nTRABAJO 5: REPARACION DE BASE DE BOOM VERTICAL\nTRABAJO 6: REPARACION DE CANOA\nTRABAJO 7: REPARACION DE ASPAS DE TORNILLO SIN FIN VERTICAL', 'borrador', NULL, '', '2026-10-16 11:10:54', NULL);

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
   WHERE numero_orden LIKE CONCAT('OT-', v_year, '-%') COLLATE utf8mb4_unicode_ci;
  SET NEW.numero_orden = CONCAT('OT-', v_year, '-', LPAD(v_seq, 3, '0'));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `orden_fotos`
--

CREATE TABLE `orden_fotos` (
  `id_foto` int(10) UNSIGNED NOT NULL,
  `orden_id` int(10) UNSIGNED NOT NULL,
  `ruta` varchar(255) NOT NULL,
  `nombre_original` varchar(255) DEFAULT NULL,
  `usuario_id` int(10) UNSIGNED DEFAULT NULL,
  `fecha_subida` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `orden_fotos`
--

INSERT INTO `orden_fotos` (`id_foto`, `orden_id`, `ruta`, `nombre_original`, `usuario_id`, `fecha_subida`) VALUES
(1, 8, 'assets/uploads/ordenes/8/ot_8_6abbdb84e4879.jpg', 'WhatsApp Image 2026-09-28 at 3.24.03 PM.jpeg', 7, '2026-09-29 09:38:44'),
(2, 8, 'assets/uploads/ordenes/8/ot_8_6abbdb851e0b8.jpg', 'WhatsApp Image 2026-09-28 at 3.15.50 PM.jpeg', 7, '2026-09-29 09:38:45'),
(3, 8, 'assets/uploads/ordenes/8/ot_8_6abbdb8535dcf.jpg', 'WhatsApp Image 2026-09-28 at 3.15.08 PM (2).jpeg', 7, '2026-09-29 09:38:45'),
(4, 8, 'assets/uploads/ordenes/8/ot_8_6abbdb855677d.jpg', 'WhatsApp Image 2026-09-28 at 3.15.08 PM (1).jpeg', 7, '2026-09-29 09:38:45'),
(5, 8, 'assets/uploads/ordenes/8/ot_8_6abbdb856c58b.jpg', 'WhatsApp Image 2026-09-28 at 3.15.08 PM.jpeg', 7, '2026-09-29 09:38:45');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `orden_tecnicos`
--

CREATE TABLE `orden_tecnicos` (
  `id` int(10) UNSIGNED NOT NULL,
  `orden_id` int(10) UNSIGNED NOT NULL,
  `empleado_id` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `orden_tecnicos`
--

INSERT INTO `orden_tecnicos` (`id`, `orden_id`, `empleado_id`) VALUES
(1, 6, 20),
(4, 7, 20),
(6, 8, 1),
(5, 9, 32),
(7, 10, 22),
(8, 14, 20),
(11, 15, 22),
(10, 16, 20);

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

--
-- Volcado de datos para la tabla `pagos_clientes`
--

INSERT INTO `pagos_clientes` (`id_pago`, `factura_id`, `cliente_id`, `usuario_id`, `fecha`, `monto`, `retencion_isr`, `retencion_isv`, `monto_neto`, `metodo_pago`, `referencia`, `concepto`, `estado`, `fecha_creacion`) VALUES
(1, 6, 9, 6, '2026-07-01', 154646.55, 1344.75, 0.00, 153301.80, 'transferencia', '126853', 'Pago de factura', 'anulado', '2026-07-01 10:09:33'),
(2, 6, 9, 6, '2026-07-06', 154646.55, 1344.75, 0.00, 153301.80, 'transferencia', '126958', 'Pago de factura', 'aplicado', '2026-07-06 10:28:57'),
(3, 4, 8, 6, '2026-07-06', 28405.00, 247.00, 0.00, 28158.00, 'transferencia', '123049', 'Pago de factura', 'aplicado', '2026-07-06 10:30:40'),
(4, 2, 8, 6, '2026-07-06', 8021.25, 69.75, 0.00, 7951.50, 'transferencia', '123049', 'Pago de factura', 'aplicado', '2026-07-06 10:31:03'),
(5, 10, 8, 6, '2026-07-08', 87419.01, 760.17, 9502.07, 77156.77, 'transferencia', '123184', 'Pago de factura', 'aplicado', '2026-07-08 09:46:56'),
(6, 9, 10, 6, '2026-07-17', 1493.85, 0.00, 0.00, 1493.85, 'transferencia', '534305986', 'Pago de factura', 'aplicado', '2026-07-17 10:51:25'),
(7, 11, 10, 6, '2026-07-17', 14683.20, 0.00, 0.00, 14683.20, 'transferencia', '534305986', 'Pago de factura', 'aplicado', '2026-07-17 10:51:30'),
(8, 12, 10, 6, '2026-07-17', 26910.00, 0.00, 0.00, 26910.00, 'transferencia', '534305986', 'Pago de factura', 'aplicado', '2026-07-17 10:51:35'),
(9, 15, 10, 6, '2026-07-28', 3450.00, 0.00, 0.00, 3450.00, 'transferencia', '412429360', 'Pago de factura', 'aplicado', '2026-07-28 11:32:29'),
(10, 13, 8, 6, '2026-07-28', 9409.24, 81.82, 1022.74, 8304.68, 'transferencia', '599501330', 'Pago de factura', 'aplicado', '2026-07-28 14:30:32'),
(11, 14, 8, 6, '2026-08-11', 15295.00, 133.00, 1662.50, 13499.50, 'transferencia', '599509568', 'Pago de factura', 'aplicado', '2026-08-11 14:17:23'),
(12, 17, 3, 6, '2026-08-20', 20067.50, 174.50, 0.00, 19893.00, 'transferencia', '1200', 'Pago de factura', 'aplicado', '2026-08-20 16:33:59'),
(13, 20, 3, 6, '2026-08-20', 9200.00, 80.00, 0.00, 9120.00, 'transferencia', '1200', 'Pago de factura', 'aplicado', '2026-08-20 16:34:43'),
(14, 18, 3, 6, '2026-08-20', 3220.00, 28.00, 0.00, 3192.00, 'transferencia', '1200', 'Pago de factura', 'aplicado', '2026-08-20 16:35:11'),
(15, 16, 3, 6, '2026-08-20', 17825.00, 155.00, 0.00, 17670.00, 'transferencia', '1200', 'Pago de factura', 'aplicado', '2026-08-20 16:35:36'),
(16, 21, 3, 6, '2026-08-20', 63250.00, 550.00, 0.00, 62700.00, 'transferencia', '1200', 'Pago de factura', 'aplicado', '2026-08-20 16:35:52'),
(17, 27, 3, 4, '2026-08-27', 341441.61, 2969.06, 0.00, 338472.55, 'transferencia', '7595333331', 'Pago de factura', 'aplicado', '2026-08-31 10:55:02'),
(18, 22, 10, 6, '2026-08-29', 43596.50, 0.00, 0.00, 43596.50, 'transferencia', '594100994', 'Pago de factura', 'aplicado', '2026-08-31 15:25:35'),
(19, 23, 10, 6, '2026-08-29', 7341.60, 0.00, 0.00, 7341.60, 'transferencia', '594100994', 'Pago de factura', 'aplicado', '2026-08-31 15:25:52'),
(20, 24, 3, 6, '2026-09-07', 38036.41, 330.75, 0.00, 37705.66, 'transferencia', '1215', 'Pago de factura', 'aplicado', '2026-09-08 10:11:53'),
(21, 34, 12, 6, '2026-09-11', 34589.13, 300.78, 3759.69, 30528.66, 'transferencia', '70108950', 'Pago de factura', 'aplicado', '2026-09-12 08:32:02'),
(22, 37, 3, 6, '2026-09-22', 63250.00, 0.00, 0.00, 63250.00, 'transferencia', '1233', 'Pago de factura', 'aplicado', '2026-09-23 09:49:00'),
(23, 26, 3, 6, '2026-09-25', 3640.54, 31.66, 0.00, 3608.88, 'transferencia', '759533331', 'Pago de factura', 'aplicado', '2026-09-25 14:55:55'),
(24, 39, 9, 8, '2026-09-28', 57784.05, 502.47, 6280.88, 51000.70, 'transferencia', '651807235', 'Pago de factura', 'aplicado', '2026-09-28 14:04:13'),
(25, 33, 3, 8, '2026-10-02', 16922.25, 0.00, 0.00, 16922.25, 'transferencia', '1242', 'Pago de factura', 'aplicado', '2026-10-02 11:55:34'),
(26, 29, 3, 8, '2026-10-02', 8050.00, 0.00, 0.00, 8050.00, 'transferencia', '1242', 'Pago de factura', 'aplicado', '2026-10-02 11:56:52'),
(27, 42, 3, 8, '2026-10-02', 3309.59, 0.00, 0.00, 3309.59, 'transferencia', '1242', 'Pago de factura', 'aplicado', '2026-10-02 11:57:03'),
(28, 41, 3, 8, '2026-10-02', 326999.75, 0.00, 0.00, 326999.75, 'transferencia', '1242', 'Pago de factura', 'aplicado', '2026-10-02 11:57:23'),
(29, 43, 3, 8, '2026-10-02', 38036.25, 0.00, 0.00, 38036.25, 'transferencia', '1242', 'Pago de factura', 'aplicado', '2026-10-02 11:57:53'),
(30, 32, 10, 8, '2026-10-06', 12236.00, 0.00, 0.00, 12236.00, 'transferencia', '759533331', 'Pago de factura', 'aplicado', '2026-10-06 17:06:05'),
(31, 31, 10, 8, '2026-10-07', 116932.00, 0.00, 0.00, 116932.00, 'transferencia', '594007729 / 594007731', 'Pago de factura', 'aplicado', '2026-10-07 10:12:19'),
(32, 36, 8, 8, '2026-10-13', 12000.25, 104.35, 1304.38, 10591.52, 'transferencia', '594107563', 'Pago de factura', 'aplicado', '2026-10-13 15:06:25'),
(33, 40, 8, 8, '2026-10-13', 56810.00, 494.00, 6175.00, 50141.00, 'transferencia', '594107562', 'Pago de factura', 'aplicado', '2026-10-13 15:08:29'),
(34, 38, 3, 8, '2026-10-14', 33350.00, 290.00, 0.00, 33060.00, 'transferencia', '1254', 'Pago de factura', 'aplicado', '2026-10-15 08:39:46'),
(35, 56, 15, 6, '2026-10-26', 5520.00, 0.00, 0.00, 0.00, 'efectivo', NULL, 'Pago factura 000-001-01-00000055', 'aplicado', '2026-10-26 10:41:15');

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
(15, 2, 'ordenes_trabajo', 1, 0, 0, 0),
(16, 2, 'reportes', 1, 0, 0, 0),
(17, 3, 'facturacion', 1, 1, 1, 1),
(18, 3, 'pagos', 1, 1, 1, 0),
(19, 3, 'planillas', 1, 1, 1, 1),
(20, 3, 'reportes', 1, 1, 1, 1),
(21, 3, 'clientes', 1, 1, 1, 0),
(22, 4, 'ordenes_trabajo', 1, 1, 1, 1),
(23, 4, 'inventario', 1, 1, 1, 1),
(24, 4, 'clientes', 1, 1, 1, 1),
(25, 2, 'usuarios', 0, 0, 0, 0),
(26, 2, 'roles', 0, 0, 0, 0),
(31, 2, 'inventario', 1, 0, 0, 0),
(32, 2, 'compras', 0, 0, 0, 0),
(33, 2, 'pagos', 0, 0, 0, 0),
(34, 2, 'planillas', 0, 0, 0, 0),
(146, 4, 'usuarios', 0, 0, 0, 0),
(147, 4, 'roles', 0, 0, 0, 0),
(150, 4, 'cotizaciones', 0, 0, 0, 0),
(151, 4, 'facturacion', 0, 0, 0, 0),
(153, 4, 'compras', 1, 1, 1, 1),
(154, 4, 'pagos', 0, 0, 0, 0),
(155, 4, 'planillas', 0, 0, 0, 0),
(156, 4, 'reportes', 1, 1, 1, 0),
(175, 3, 'usuarios', 0, 0, 0, 0),
(176, 3, 'roles', 0, 0, 0, 0),
(178, 3, 'ordenes_trabajo', 0, 0, 0, 0),
(179, 3, 'cotizaciones', 1, 1, 1, 0),
(181, 3, 'inventario', 0, 0, 0, 0),
(182, 3, 'compras', 0, 0, 0, 0),
(191, 1, 'gastos', 1, 1, 1, 1),
(192, 3, 'gastos', 1, 1, 1, 0),
(193, 4, 'gastos', 0, 0, 0, 0),
(194, 2, 'gastos', 1, 0, 0, 0),
(316, 1, 'movimientos', 1, 1, 1, 1),
(317, 2, 'movimientos', 1, 1, 1, 1),
(318, 3, 'movimientos', 1, 1, 1, 1),
(319, 4, 'movimientos', 1, 1, 1, 1),
(343, 1, 'vehiculos', 1, 1, 1, 1),
(344, 1, 'requisiciones', 1, 1, 1, 1),
(345, 1, 'proveedores', 1, 1, 1, 1),
(346, 1, 'catalogo', 1, 1, 1, 1),
(347, 1, 'cai', 1, 1, 1, 1),
(348, 1, 'libro_ventas', 1, 1, 1, 1),
(349, 1, 'vacaciones', 1, 1, 1, 1),
(350, 2, 'vehiculos', 1, 1, 1, 1),
(351, 2, 'requisiciones', 1, 1, 1, 1),
(352, 2, 'proveedores', 1, 1, 1, 1),
(353, 2, 'catalogo', 1, 1, 1, 1),
(354, 2, 'cai', 1, 1, 1, 1),
(355, 2, 'libro_ventas', 1, 1, 1, 1),
(356, 2, 'vacaciones', 1, 1, 1, 1),
(357, 3, 'vehiculos', 0, 0, 0, 0),
(358, 3, 'requisiciones', 0, 0, 0, 0),
(359, 3, 'proveedores', 1, 1, 1, 1),
(360, 3, 'catalogo', 0, 0, 0, 0),
(361, 3, 'cai', 1, 1, 1, 1),
(362, 3, 'libro_ventas', 1, 1, 1, 1),
(363, 3, 'vacaciones', 1, 1, 1, 1),
(364, 4, 'vehiculos', 1, 1, 1, 1),
(365, 4, 'requisiciones', 1, 1, 1, 1),
(366, 4, 'proveedores', 1, 1, 1, 1),
(367, 4, 'catalogo', 0, 0, 0, 0),
(368, 4, 'cai', 0, 0, 0, 0),
(369, 4, 'libro_ventas', 0, 0, 0, 0),
(370, 4, 'vacaciones', 0, 0, 0, 0),
(391, 1, 'reportes_ventas', 1, 1, 1, 1),
(392, 1, 'reportes_cxc', 1, 1, 1, 1),
(393, 1, 'reportes_retenciones', 1, 1, 1, 1),
(394, 1, 'reportes_rentabilidad', 1, 1, 1, 1),
(395, 1, 'reportes_inventario', 1, 1, 1, 1),
(396, 2, 'reportes_ventas', 1, 0, 0, 0),
(397, 2, 'reportes_cxc', 1, 0, 0, 0),
(398, 2, 'reportes_retenciones', 1, 0, 0, 0),
(399, 2, 'reportes_rentabilidad', 1, 0, 0, 0),
(400, 2, 'reportes_inventario', 1, 0, 0, 0),
(401, 3, 'reportes_ventas', 1, 1, 1, 1),
(402, 3, 'reportes_cxc', 1, 1, 1, 1),
(403, 3, 'reportes_retenciones', 1, 1, 1, 1),
(404, 3, 'reportes_rentabilidad', 1, 1, 1, 1),
(405, 3, 'reportes_inventario', 1, 1, 1, 1),
(406, 4, 'reportes_ventas', 0, 0, 0, 0),
(407, 4, 'reportes_cxc', 0, 0, 0, 0),
(408, 4, 'reportes_retenciones', 0, 0, 0, 0),
(409, 4, 'reportes_rentabilidad', 1, 1, 1, 0),
(410, 4, 'reportes_inventario', 1, 1, 1, 0),
(1411, 1, 'recibos', 1, 1, 1, 1),
(1412, 2, 'recibos', 0, 0, 0, 0),
(1413, 3, 'recibos', 1, 1, 1, 1),
(1414, 4, 'recibos', 0, 0, 0, 0),
(1418, 1, 'asistencia', 1, 1, 1, 1),
(1419, 2, 'asistencia', 0, 0, 0, 0),
(1420, 3, 'asistencia', 1, 1, 1, 1),
(1421, 4, 'asistencia', 0, 0, 0, 0),
(1503, 5, 'asistencia', 0, 0, 0, 0),
(1504, 5, 'cai', 0, 0, 0, 0),
(1505, 5, 'catalogo', 0, 0, 0, 0),
(1506, 5, 'clientes', 1, 1, 1, 1),
(1507, 5, 'compras', 0, 0, 0, 0),
(1508, 5, 'cotizaciones', 0, 0, 0, 0),
(1509, 5, 'facturacion', 0, 0, 0, 0),
(1510, 5, 'gastos', 0, 0, 0, 0),
(1511, 5, 'inventario', 0, 0, 0, 0),
(1512, 5, 'libro_ventas', 0, 0, 0, 0),
(1513, 5, 'movimientos', 1, 1, 1, 1),
(1514, 5, 'ordenes_trabajo', 1, 1, 1, 1),
(1515, 5, 'pagos', 0, 0, 0, 0),
(1516, 5, 'planillas', 0, 0, 0, 0),
(1517, 5, 'proveedores', 0, 0, 0, 0),
(1518, 5, 'recibos', 0, 0, 0, 0),
(1519, 5, 'reportes', 1, 1, 1, 1),
(1520, 5, 'reportes_cxc', 0, 0, 0, 0),
(1521, 5, 'reportes_inventario', 1, 1, 1, 1),
(1522, 5, 'reportes_rentabilidad', 0, 0, 0, 0),
(1523, 5, 'reportes_retenciones', 0, 0, 0, 0),
(1524, 5, 'reportes_ventas', 0, 0, 0, 0),
(1525, 5, 'requisiciones', 0, 0, 0, 0),
(1526, 5, 'roles', 0, 0, 0, 0),
(1527, 5, 'usuarios', 0, 0, 0, 0),
(1528, 5, 'vacaciones', 0, 0, 0, 0),
(1529, 5, 'vehiculos', 1, 1, 1, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `planillas`
--

CREATE TABLE `planillas` (
  `id_planilla` int(10) UNSIGNED NOT NULL,
  `periodo_mes` tinyint(2) NOT NULL COMMENT '1-12',
  `periodo_anio` year(4) NOT NULL,
  `quincena` enum('1ra','2da','catorceavo','aguinaldo') NOT NULL,
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
  `empresa_id` int(10) UNSIGNED DEFAULT NULL,
  `fecha_creacion` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `planillas`
--

INSERT INTO `planillas` (`id_planilla`, `periodo_mes`, `periodo_anio`, `quincena`, `fecha_pago`, `total_salarios`, `total_ihss_emp`, `total_ihss_pat`, `total_rap`, `total_isr`, `total_seguro`, `total_deducciones`, `total_neto`, `observaciones`, `estado`, `usuario_id`, `empresa_id`, `fecha_creacion`) VALUES
(9, 4, '2026', '1ra', '2026-04-15', 187500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 8071.81, 180898.19, '', 'cerrada', 1, 1, '2026-04-16 08:00:26'),
(35, 4, '2026', '2da', '2026-04-30', 187500.00, 0.00, 0.00, 0.00, 0.00, 4438.35, 11726.84, 188008.16, '', 'cerrada', 6, 1, '2026-04-30 09:00:06'),
(41, 5, '2026', '1ra', '2026-05-15', 185500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 9221.82, 177608.18, '', 'cerrada', 6, 1, '2026-05-12 16:01:46'),
(49, 5, '2026', '2da', '2026-05-30', 186500.00, 0.00, 0.00, 0.00, 0.00, 4172.94, 11878.09, 176066.91, '', 'cerrada', 6, 1, '2026-05-28 08:55:06'),
(62, 6, '2026', '1ra', '2026-06-15', 194500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 12644.12, 186972.88, '', 'cerrada', 6, 1, '2026-06-18 16:40:19'),
(96, 6, '2026', '2da', '2026-06-30', 21000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 42000.00, '', 'cerrada', 6, 2, '2026-07-13 13:36:30'),
(98, 6, '2026', '2da', '2026-06-30', 194500.00, 0.00, 0.00, 0.00, 0.00, 4892.42, 13869.87, 186155.13, '', 'cerrada', 6, 1, '2026-07-13 14:04:05'),
(99, 7, '2026', '1ra', '2026-07-14', 14000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 28000.00, '', 'cerrada', 6, 2, '2026-07-14 10:21:37'),
(124, 7, '2026', '1ra', '2026-07-20', 189500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 8377.45, 181122.55, '', 'cerrada', 6, 1, '2026-07-20 14:57:08'),
(138, 6, '2026', 'catorceavo', '2026-06-30', 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, '', 'cerrada', 6, 2, '2026-07-24 07:31:58'),
(141, 6, '2026', 'catorceavo', '2026-06-30', 226000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 203715.07, '', 'borrador', 6, 1, '2026-07-24 13:54:36'),
(142, 7, '2026', '2da', '2026-07-24', 7000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 14000.00, '', 'cerrada', 6, 2, '2026-07-28 15:28:32'),
(144, 7, '2026', '2da', '2026-07-31', 189500.00, 0.00, 0.00, 0.00, 0.00, 5252.16, 15418.82, 180881.18, '', 'cerrada', 6, 1, '2026-08-04 15:47:12'),
(189, 10, '2026', '1ra', '2026-10-15', 180000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 11300.00, 191566.90, '', 'borrador', 8, 2, '2026-10-14 16:24:38'),
(190, 10, '2026', '1ra', '2026-10-15', 43000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 1144.12, 41855.88, '', 'borrador', 8, 1, '2026-10-15 08:47:36'),
(191, 8, '2026', '1ra', '2026-08-15', 34000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 3644.12, 32595.88, '', 'borrador', 8, 1, '2026-10-19 15:28:42'),
(194, 8, '2026', '1ra', '2026-08-15', 183500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 16133.33, 195366.67, '', 'borrador', 8, 2, '2026-10-19 15:39:04'),
(195, 8, '2026', '2da', '2026-08-31', 34000.00, 0.00, 0.00, 0.00, 0.00, 1079.22, 4523.34, 29476.66, '', 'borrador', 8, 1, '2026-10-19 15:40:23'),
(200, 8, '2026', '2da', '2026-08-31', 183500.00, 0.00, 0.00, 0.00, 0.00, 3741.26, 26607.92, 186762.08, '', 'borrador', 8, 2, '2026-10-19 16:37:21'),
(201, 9, '2026', '1ra', '2026-09-15', 42000.00, 0.00, 0.00, 0.00, 0.00, 0.00, 7710.79, 35409.21, '', 'borrador', 8, 1, '2026-10-19 16:47:27'),
(202, 9, '2026', '1ra', '2026-09-15', 185500.00, 0.00, 0.00, 0.00, 0.00, 0.00, 7483.33, 207349.47, '', 'borrador', 8, 2, '2026-10-19 16:56:33'),
(204, 10, '2026', '2da', '2026-10-20', 185500.00, 0.00, 0.00, 0.00, 0.00, 4460.74, 4460.74, 181039.26, '', 'borrador', 8, 2, '2026-10-20 08:39:44'),
(205, 9, '2026', '2da', '2026-09-30', 43000.00, 0.00, 0.00, 0.00, 0.00, 1079.22, 4390.01, 39869.99, '', 'borrador', 8, 1, '2026-10-20 09:30:34'),
(209, 9, '2026', '2da', '2026-09-30', 188000.00, 0.00, 0.00, 0.00, 0.00, 3597.36, 17670.95, 193769.35, '', 'borrador', 8, 2, '2026-10-20 10:18:01');

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
(1, 'LUBRICANTES Y COMBUSTIBLES S.A DE C.V.', '', '', '', '', '', 'activo', '2026-04-01 12:22:18'),
(2, 'ULTRA REPUESTOS DE HONDURAS S.A. DE C.V.', '0501995149469', '', '', '', '', 'activo', '2026-04-01 12:22:28'),
(3, 'INSA TEXACO ARENALES', '', '', '', '', '', 'activo', '2026-04-01 12:22:36'),
(4, 'RECASER S. DE R.L.', '', '', '', '', '', 'activo', '2026-04-01 12:22:50'),
(5, 'TECNO FUEGO S. DE R.L. DE C.V', '', '', '', '', '', 'activo', '2026-04-01 12:23:00'),
(6, 'INEVERSIONES DEL ATLANTICO NORTE S. DE R.L. DE C.V', '', '', '', '', '', 'activo', '2026-05-07 10:41:06'),
(7, 'INVERSIONES M.C.R', '', '', '', '', '', 'activo', '2026-07-30 13:29:41'),
(8, 'SOLUCIONES INTEGRALES S. DE R.L DE C.V', '', '', '', '', '', 'activo', '2026-07-30 13:29:51'),
(9, 'COMERCIAL Y FERRETERIA EXPRESS HONDURAS  DE RL', '', '', '', '', '', 'activo', '2026-07-30 13:30:07'),
(10, 'CASA COMERCIAL MATHEWS S.A.', '', '', '', '', '', 'activo', '2026-07-30 13:30:14'),
(11, 'INVERSIONES PALCON S. DE R.L. DE C.V.', '', '', '', '', '', 'activo', '2026-07-30 13:30:46'),
(12, 'INVERSIONES EBEN EZER', '', '', '', '', '', 'activo', '2026-07-30 13:30:54'),
(13, 'GRUPO HMC S.A.', '', '', '', '', '', 'activo', '2026-07-30 13:30:59'),
(14, 'CEMCOL COMERCIAL, S.A DE C.V.', '', '', '', '', '', 'activo', '2026-07-30 13:31:07'),
(15, 'YC INDUSTRIAL S. DE R.L.', '', '', '', '', '', 'activo', '2026-07-30 13:31:14'),
(16, 'ABOGADA DENIA MAYTE VILLANUEVA RIVERA', '', '', '', '', '', 'activo', '2026-07-30 13:31:21'),
(17, 'UNO HONDURAS S.A DE C.V', '08029995457769', '', '', '', '', 'activo', '2026-09-12 11:47:10'),
(18, 'PURIFICADORA DE AGUA EL PROGRESO S. DE R.L. DE C.V.', '', '', '', '', '', 'activo', '2026-09-12 11:49:15'),
(19, 'OPERADORA DE ESTACIONES DE SERVICIO S.A DE C.V.', '', '', '', '', '', 'activo', '2026-09-12 11:49:56'),
(20, 'FERRETERIA ZUMMAR S.A. DE C.V.', '', '', '', '', '', 'activo', '2026-09-12 11:50:15'),
(21, 'REPUESTOS PARA CAMIONES , S.A DE C.V.', '', '', '', '', '', 'activo', '2026-09-12 11:50:39'),
(22, 'AGENCIA LA MUNDIAL, S.A DE C.V', '05019026315890', '', '', '', '', 'activo', '2026-09-17 12:54:19'),
(23, 'FERRETERIA CALPULES S. DE R.L', '05019998173837', '', '', '', '', 'activo', '2026-10-06 11:53:25');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `recibos`
--

CREATE TABLE `recibos` (
  `id_recibo` int(10) UNSIGNED NOT NULL,
  `numero` varchar(30) NOT NULL,
  `correlativo` int(10) UNSIGNED NOT NULL,
  `fecha` date NOT NULL,
  `semana` tinyint(3) UNSIGNED DEFAULT NULL COMMENT 'Semana de planilla (1-4) para viáticos',
  `empleado_id` int(10) UNSIGNED NOT NULL,
  `empleado_nombre` varchar(200) NOT NULL,
  `rtn` varchar(30) DEFAULT NULL,
  `direccion` varchar(255) DEFAULT NULL,
  `subtotal` decimal(12,2) NOT NULL DEFAULT 0.00,
  `retenciones` decimal(12,2) NOT NULL DEFAULT 0.00,
  `total` decimal(12,2) NOT NULL DEFAULT 0.00,
  `fecha_limite_emision` date DEFAULT NULL,
  `rango_autorizado` varchar(80) DEFAULT NULL,
  `observaciones` varchar(255) DEFAULT NULL,
  `estado` enum('emitido','anulado') NOT NULL DEFAULT 'emitido',
  `planilla_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'Planilla donde se aplicó (NULL = pendiente)',
  `usuario_id` int(10) UNSIGNED DEFAULT NULL,
  `fecha_creacion` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `recibos`
--

INSERT INTO `recibos` (`id_recibo`, `numero`, `correlativo`, `fecha`, `semana`, `empleado_id`, `empleado_nombre`, `rtn`, `direccion`, `subtotal`, `retenciones`, `total`, `fecha_limite_emision`, `rango_autorizado`, `observaciones`, `estado`, `planilla_id`, `usuario_id`, `fecha_creacion`) VALUES
(1, '000-001-01-00000001', 1, '2026-10-19', 3, 19, 'WILLIAM NORTIE ARDON CRUZ', '0703198105217', NULL, 2500.00, 0.00, 2500.00, '2030-06-16', '000-001-01-00000001 AL 000-001-01-00100000', NULL, 'emitido', NULL, 6, '2026-10-20 07:34:54'),
(2, '000-001-01-00000002', 2, '2026-10-19', 3, 25, 'RUBEN DARIO RODRIGUEZ AMAYA', '0509196700116', NULL, 2500.00, 0.00, 2500.00, '2030-06-16', '000-001-01-00000001 AL 000-001-01-00100000', NULL, 'emitido', NULL, 8, '2026-10-20 08:32:55'),
(3, '000-001-01-00000003', 3, '2026-10-19', 3, 30, 'BIENVENIDO MONCADA', '0801197917520', NULL, 2500.00, 0.00, 2500.00, '2030-06-16', '000-001-01-00000001 AL 000-001-01-00100000', NULL, 'emitido', NULL, 8, '2026-10-20 08:34:56'),
(4, '000-001-01-00000004', 4, '2026-10-31', NULL, 16, 'MELVIN DANILSON GOMEZ AGUILAR', '', NULL, 2000.00, 0.00, 2000.00, '2030-06-16', '000-001-01-00000001 AL 000-001-01-00100000', NULL, 'emitido', NULL, 6, '2026-10-20 13:05:58'),
(5, '000-001-01-00000005', 5, '2026-10-22', 3, 25, 'RUBEN DARIO RODRIGUEZ AMAYA', '0509196700116', NULL, 1000.00, 0.00, 1000.00, '2030-06-16', '000-001-01-00000001 AL 000-001-01-00100000', NULL, 'emitido', NULL, 6, '2026-10-22 08:34:53'),
(6, '000-001-01-00000006', 6, '2026-10-21', 3, 30, 'BIENVENIDO MONCADA', '0801197917520', NULL, 1000.00, 0.00, 1000.00, '2030-06-16', '000-001-01-00000001 AL 000-001-01-00100000', NULL, 'emitido', NULL, 8, '2026-10-22 09:48:52'),
(7, '000-001-01-00000007', 7, '2026-10-21', 3, 19, 'WILLIAM NORTIE ARDON CRUZ', '', NULL, 1000.00, 0.00, 1000.00, '2030-06-16', '000-001-01-00000001 AL 000-001-01-00100000', NULL, 'emitido', NULL, 8, '2026-10-22 09:49:51'),
(8, '000-001-01-00000008', 8, '2026-10-21', 3, 35, 'JUAN RENEE CASTILLO FERNANDEZ', '0511198000218', NULL, 1600.00, 0.00, 1600.00, '2030-06-16', '000-001-01-00000001 AL 000-001-01-00100000', NULL, 'emitido', NULL, 8, '2026-10-22 09:50:52'),
(9, '000-001-01-00000009', 9, '2026-10-26', 4, 19, 'WILLIAM NORTIE ARDON CRUZ', '0703-1981-05217', NULL, 3500.00, 0.00, 3500.00, '2030-06-16', '000-001-01-00000001 AL 000-001-01-00100000', NULL, 'emitido', NULL, 8, '2026-10-26 09:10:25'),
(10, '000-001-01-00000010', 10, '2026-10-26', 4, 25, 'RUBEN DARIO RODRIGUEZ AMAYA', '0509-1967-00116', NULL, 3500.00, 0.00, 3500.00, '2030-06-16', '000-001-01-00000001 AL 000-001-01-00100000', NULL, 'emitido', NULL, 8, '2026-10-26 09:12:04'),
(11, '000-001-01-00000011', 11, '2026-10-26', 4, 36, 'DONNY MARIANO HERNANDEZ GODOY', '1503-1978-01296', NULL, 3500.00, 0.00, 3500.00, '2030-06-16', '000-001-01-00000001 AL 000-001-01-00100000', NULL, 'emitido', NULL, 8, '2026-10-26 09:24:07');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `recibos_detalle`
--

CREATE TABLE `recibos_detalle` (
  `id_detalle` int(10) UNSIGNED NOT NULL,
  `recibo_id` int(10) UNSIGNED NOT NULL,
  `concepto_tipo` enum('viaticos','adelanto_salario','abono_prestamo','otro') NOT NULL DEFAULT 'viaticos',
  `descripcion` varchar(255) NOT NULL DEFAULT '',
  `monto` decimal(12,2) NOT NULL DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `recibos_detalle`
--

INSERT INTO `recibos_detalle` (`id_detalle`, `recibo_id`, `concepto_tipo`, `descripcion`, `monto`) VALUES
(2, 1, 'viaticos', 'VIATICOS DE LA SEMANA DEL 19/10/26 AL 25/10/26 DE AOCTUBRE', 2500.00),
(3, 2, 'viaticos', 'SEMANA DEL 19/10/2026 AL 25/10/2026', 2500.00),
(6, 3, 'viaticos', 'SEMANA DEL 19/10/2026 AL 25/10/2026', 2500.00),
(8, 4, 'abono_prestamo', 'PAGO DE CUTA NO.16', 2000.00),
(9, 5, 'viaticos', 'SEMANA DEL 19/10/2026 AL 25/10/2026', 1000.00),
(10, 6, 'viaticos', 'SEMANA DEL 19/10/2026 AL 25/10/2026', 1000.00),
(11, 7, 'viaticos', 'SEMANA DEL 19/10/2026 AL 25/10/2026', 1000.00),
(12, 8, 'viaticos', 'SEMANA DEL 19/10/2026 AL 25/10/2026', 1600.00),
(13, 9, 'viaticos', 'SEMANA DEL 26/10 AL 01/11', 3500.00),
(14, 10, 'viaticos', 'SEMANA DEL 26/10 AL 01/11', 3500.00),
(15, 11, 'viaticos', 'SEMANA DEL 26/10 AL 01/11', 3500.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `recibos_serie`
--

CREATE TABLE `recibos_serie` (
  `id_serie` int(10) UNSIGNED NOT NULL,
  `prefijo` varchar(20) NOT NULL DEFAULT '000-001-01' COMMENT 'Ej: 000-001-01',
  `rango_inicio` int(10) UNSIGNED NOT NULL DEFAULT 1,
  `rango_fin` int(10) UNSIGNED NOT NULL DEFAULT 100000,
  `correlativo_actual` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Último correlativo emitido',
  `fecha_limite_emision` date NOT NULL,
  `estado` enum('activo','inactivo') NOT NULL DEFAULT 'activo',
  `fecha_registro` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `recibos_serie`
--

INSERT INTO `recibos_serie` (`id_serie`, `prefijo`, `rango_inicio`, `rango_fin`, `correlativo_actual`, `fecha_limite_emision`, `estado`, `fecha_registro`) VALUES
(1, '000-001-01', 1, 100000, 11, '2030-06-16', 'activo', '2026-10-19 15:59:51');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `requisiciones_materiales`
--

CREATE TABLE `requisiciones_materiales` (
  `id_requisicion` int(10) UNSIGNED NOT NULL,
  `numero` varchar(20) NOT NULL COMMENT 'REQ-2026-001',
  `fecha_solicitud` date NOT NULL,
  `empleado_id` int(10) UNSIGNED NOT NULL,
  `departamento` varchar(100) NOT NULL,
  `numero_ot` varchar(20) DEFAULT NULL,
  `unidad` varchar(50) DEFAULT NULL COMMENT 'Placa / unidad',
  `cliente_id` int(10) UNSIGNED DEFAULT NULL,
  `estado` enum('pendiente','aprobada','despachada','anulada') NOT NULL DEFAULT 'pendiente',
  `observaciones` text DEFAULT NULL,
  `usuario_id` int(10) UNSIGNED NOT NULL,
  `fecha_creacion` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `requisicion_detalle`
--

CREATE TABLE `requisicion_detalle` (
  `id_detalle` int(10) UNSIGNED NOT NULL,
  `requisicion_id` int(10) UNSIGNED NOT NULL,
  `material_id` int(10) UNSIGNED DEFAULT NULL COMMENT 'NULL si no está en inventario',
  `descripcion` varchar(255) NOT NULL,
  `unidad_medida` varchar(30) NOT NULL DEFAULT 'unidad',
  `cantidad` decimal(10,2) NOT NULL,
  `observacion` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
(5, 'LOGISTICA'),
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
(94, 1, '0a17738adb1d5351a3d30067f3ddef2328342d04ecfe51eeede069e893b83d95', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-23 11:27:10', '2026-04-23 15:22:54', '2026-04-24 03:27:10', 'activa'),
(95, 1, '14b89bb3f528019aa11803689548c38dbd12d624caf9e03fe24d0aea3cb17352', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-24 07:34:28', '2026-04-24 10:24:06', '2026-04-24 23:34:28', 'activa'),
(96, 1, 'b37c47cfb6080c7d881829b27944fafa28bd9586a23e080ea42824fce17d1b2d', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-24 10:24:26', '2026-04-24 10:24:34', '2026-04-25 02:24:26', 'activa'),
(97, 1, 'f56c86923ac391dfe47386102458f0f59cf3dde671db595911d1569d3fe68d7e', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-24 11:04:57', '2026-04-24 14:35:46', '2026-04-25 03:04:57', 'activa'),
(98, 6, '181dd62532e7d0b8bccac05e43e1e759a27d30417b741d1c0081bfdf1293c56e', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-25 07:49:27', '2026-04-25 12:12:01', '2026-04-25 23:49:27', 'activa'),
(99, 1, '767ef32d701e7be7c33adc3ce9b5dd11c8ee4ee3bd5c2947c2e9083f033e9049', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-27 07:57:49', '2026-04-27 09:31:31', '2026-04-27 23:57:49', 'cerrada'),
(100, 6, 'dd6ec4c71d284239d81d8bddbd8d92b29256a6b55c5e4280be80254eda2ae32f', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-27 09:31:44', '2026-04-27 09:36:49', '2026-04-28 01:31:44', 'activa'),
(101, 6, '3f091a8c3836f8876b33a856a02d1e97167373631c6b18f565b0bdef25a11857', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-27 15:05:10', '2026-04-27 17:32:41', '2026-04-28 07:05:10', 'activa'),
(102, 6, '4f38d66a880e4750f978204aaa2f0184403c0d129781314577226662570eb7cd', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-28 08:38:18', '2026-04-28 08:39:55', '2026-04-29 00:38:18', 'activa'),
(103, 1, 'dd620b87038fe613e7a13899b0453ff8d4a4e5fccb3ba50726cc06f26e5574bb', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-28 13:25:14', '2026-04-28 16:49:24', '2026-04-29 05:25:14', 'activa'),
(104, 6, '64a21004a7569e4a102e9cb46dff010d0c30a4547d0e67c4b5b78df15b1f7194', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-28 16:55:25', '2026-04-28 16:55:25', '2026-04-29 08:55:25', 'activa'),
(105, 6, 'd60313c7476efb8c37437ae54423839e3dd101e8c6014fa0c3cd5ffd31ddeeb0', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-29 07:45:18', '2026-04-29 12:51:59', '2026-04-29 23:45:18', 'cerrada'),
(106, 6, '633648be4e4bd9014c20309897110f9f846b31017559c8fd97f283438b080c94', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-29 12:52:12', '2026-04-29 16:07:03', '2026-04-30 04:52:12', 'activa'),
(107, 6, '61695ffd964a8ae4c439451821f4cd2d769c5a6f14ee77f490d163609c22ed9e', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-29 16:07:35', '2026-04-29 17:08:45', '2026-04-30 08:07:35', 'activa'),
(108, 6, '2cd701cd81969f836bb78f46b3fb250efef224426f382187be1a0ef91124795d', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-30 07:29:04', '2026-04-30 14:50:48', '2026-04-30 23:29:04', 'activa'),
(109, 6, 'bbecfe65c96b2addd3e758ff78feaf17481df8af1ef9f5a14fa2052ac0be7d3c', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-04-30 16:26:19', '2026-04-30 16:27:00', '2026-05-01 08:26:19', 'activa'),
(110, 6, '1a8d46f046f617f5f79d447713df2c83ab60c2cd3a7c80e6a52881cb041b1c1a', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-01 08:02:10', '2026-05-01 15:03:41', '2026-05-02 00:02:10', 'activa'),
(111, 6, 'cff562f57837111b44098496625476028bd4f913846bd47a0671ac1c763c657f', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-01 16:19:51', '2026-05-01 16:21:59', '2026-05-02 08:19:51', 'activa'),
(112, 6, '7b3068b8c819e2a5156756e740a0f734bc8be6d95accdc1e2f594431fb8b7db3', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-04 09:11:35', '2026-05-04 09:17:30', '2026-05-05 01:11:35', 'activa'),
(113, 6, 'fb07b384a6b99698da6f82e3afe36878df650cfe306811eb2576b35febeb75ee', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-04 14:13:10', '2026-05-04 14:40:11', '2026-05-05 06:13:10', 'activa'),
(114, 6, '3fdd58da2df991f2ab001d16f2163556f7b925cff5209f846111369f0bc4ac53', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-05 09:28:39', '2026-05-05 16:27:01', '2026-05-06 01:28:39', 'activa'),
(115, 6, '00d042be41e4a966c6f62ce4a60667b51de4c07c47366bf940360b324d305b35', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-06 08:40:54', '2026-05-06 15:51:57', '2026-05-07 00:40:54', 'activa'),
(116, 6, '891e872ca57dbcda34af8c63ee949a64216256d4579929deabc99888579370cc', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-07 10:31:36', '2026-05-07 16:33:52', '2026-05-08 02:31:36', 'activa'),
(117, 6, '28906261446862263432856fb45c4bd5232edfaa2b66c9788bf0716155b87388', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-08 15:26:26', '2026-05-08 16:27:06', '2026-05-09 07:26:26', 'activa'),
(118, 6, '6cff6edcd4368779def58c41e4aeddf82580c35954fb42a2221d3abaaeabeed7', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-08 16:27:20', '2026-05-08 17:02:52', '2026-05-09 08:27:20', 'cerrada'),
(119, 6, 'd2217f095bfaa24732ed223803b51d3efbe5d0ae5ed824c0ca4eb05176fce380', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-08 17:13:36', '2026-05-08 17:14:06', '2026-05-09 09:13:36', 'activa'),
(120, 6, 'e1456e0e104d5d07f09a4cbd180ef85fdd47a8dfa796355bfb847def3b57f5a1', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-09 09:50:00', '2026-05-09 11:48:24', '2026-05-10 01:50:00', 'activa'),
(121, 6, 'e91465e4c0531b3f24f313e9cf1a6926eda0f732fdefce84bd05202579baee45', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-11 13:12:48', '2026-05-11 17:22:31', '2026-05-12 05:12:48', 'activa'),
(122, 6, '9c75016b2250a2a840c7fa60700072ae8022b9af10c56cb3dde0a67505ef66a4', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-11 17:23:46', '2026-05-11 17:29:29', '2026-05-12 09:23:46', 'activa'),
(123, 6, '73b036271af5f1cea2dadb4adb2f4a4854d5f874f1bd30a86f2cce0a39a26485', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-12 08:08:36', '2026-05-12 15:11:21', '2026-05-13 00:08:36', 'activa'),
(124, 6, 'd26f1d1ef96f3848e5d3140ce8ba770efa699b236fdfbcb6c501cab2d3d396c1', '10.130.144.46', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36', '2026-05-12 11:27:31', '2026-05-12 11:31:03', '2026-05-13 03:27:31', 'activa'),
(125, 6, '4a72d3a8ea9cfc1af79acf03e595dc19b39a50b30dd330257ff0b955260d53d8', '10.130.144.82', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-05-12 11:29:44', '2026-05-12 11:30:42', '2026-05-13 03:29:44', 'activa'),
(126, 6, '66b243460557e8ad4fbd5f9f93d515e64c9e99070f737c09591646b2bbaff6d0', '192.168.40.61', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', '2026-05-12 11:32:01', '2026-05-12 11:34:04', '2026-05-13 03:32:01', 'activa'),
(127, 6, '232885ece675ed871522496891c22d23a73abb7dabca0944936645c53f767c53', '192.168.40.66', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', '2026-05-12 14:55:46', '2026-05-12 14:56:01', '2026-05-13 06:55:46', 'activa'),
(128, 6, 'ea148337c93ea2eb93ddacf3f860f431b60c2202b6dfdb2d3770f6dbd74788c2', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-12 15:13:00', '2026-05-12 15:13:00', '2026-05-13 07:13:00', 'activa'),
(129, 6, 'b83d9a0576538b3d1481b490dc1fb6aa46f09ba6574f86e9d35c9904c2c3369d', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-12 15:13:14', '2026-05-12 15:13:14', '2026-05-13 07:13:14', 'activa'),
(130, 6, '27dfdb654cd65b5190e9644e4c6d59bef0e9830490c9fc3d827de89896267d0a', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-12 15:13:40', '2026-05-12 15:13:40', '2026-05-13 07:13:40', 'activa'),
(131, 6, 'b65e264619ae27d7637a71ecc1699df61843600de77c1df21436ad61f002242e', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-12 15:14:31', '2026-05-12 17:17:37', '2026-05-13 07:14:31', 'activa'),
(132, 6, 'd1dc2fdba3fdea4e306f34d8788c5d63204aee5fea9783c365d3dbe282d306c3', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-13 08:01:34', '2026-05-13 11:16:13', '2026-05-14 00:01:34', 'activa'),
(133, 6, '2406dfcb00438f7bf47161d34203fcaff21e9d94228b8f2aba74173ef6740fc4', '::1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) SamsungBrowser/29.0 Chrome/136.0.0.0 Mobile Safari/537.36', '2026-05-13 16:42:24', '2026-05-13 16:44:06', '2026-05-14 08:42:24', 'activa'),
(134, 6, '25ab1cdde696993e0e43a87dfd47529e95281f371a39e8a38f96c1437ebeb5c5', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-13 16:43:11', '2026-05-13 16:43:16', '2026-05-14 08:43:11', 'activa'),
(135, 6, '786bb87e7e72ca292ba84d202f9427131910285e74b6e7905cb3468358e28252', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-14 08:04:57', '2026-05-14 10:41:20', '2026-05-15 00:04:57', 'activa'),
(136, 6, 'b4e207876e2f08bebf7d2ae59532bc02dd791e71377c739ac5710cae975bc7b2', '10.130.144.82', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-05-14 09:00:59', '2026-05-14 09:06:57', '2026-05-15 01:00:59', 'activa'),
(137, 6, '839e460dfe7178554cef08bc2a74db39e03a7bd5cd9bf6467b2af1c18ab75251', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-14 11:31:28', '2026-05-14 16:13:15', '2026-05-15 03:31:28', 'activa'),
(138, 6, '4251e95f70c3c46842e0b58f387839c2993f5ae1caa8610dda237df3a726051e', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-05-15 08:51:20', '2026-05-15 15:06:44', '2026-05-16 00:51:20', 'activa'),
(139, 6, 'ca89e1bf1177751d23655826d51781d0efa90436970e688bbcc98d7b38074e08', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-15 14:24:01', '2026-05-15 15:55:21', '2026-05-16 06:24:01', 'activa'),
(140, 6, '6dd69235072b3f45c1f239ac80dedbb3b22d617d40ebd06e628fa30941a60a40', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-16 07:47:17', '2026-05-16 13:02:00', '2026-05-16 23:47:17', 'activa'),
(141, 6, '9e4fc09dd4f3debc5ef527944104e295659caf1720b849a0bfe1977e54c30674', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-18 07:36:43', '2026-05-18 12:58:10', '2026-05-18 23:36:43', 'activa'),
(142, 6, 'ba6ad84585ec37d0b6308a426246c07648e3c9f95749c462c3ad2d13de8c686f', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-19 16:58:42', '2026-05-19 17:20:54', '2026-05-20 08:58:42', 'activa'),
(143, 6, 'b5e72bfc0efbbe3e3ae725c27a9a03b8eca201f4f342bff96a3b4d86ecc1200e', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-20 07:46:00', '2026-05-20 07:46:00', '2026-05-20 23:46:00', 'activa'),
(144, 6, 'efd1c98f7b964c98dd6f29f5307e037086b9edc8925e8eb450c13b9d5eb54a03', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-20 09:11:58', '2026-05-20 09:54:33', '2026-05-21 01:11:58', 'activa'),
(145, 6, '03b58cf05165bd3db2ca6bf18d4c159a4edb44d692946d34564895cdbc6e9589', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-20 11:07:31', '2026-05-20 11:07:49', '2026-05-21 03:07:31', 'activa'),
(146, 6, '47d1f8f8c2f6a15a0b99e6ceff3e1475c72b0cf598e33e263c868f22c65cac05', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-20 12:50:14', '2026-05-20 12:50:17', '2026-05-21 04:50:14', 'activa'),
(147, 6, '6ff1c52ca9bd487b32ae38565f703868c9b9a487e80c84bcd308739d907f689a', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-20 14:18:01', '2026-05-20 17:04:07', '2026-05-21 06:18:01', 'activa'),
(148, 6, '67bdd6aa9f430b6996acb2850b73821ba782a243a659dc24ff9f12ed057058d3', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-21 10:15:47', '2026-05-21 16:19:54', '2026-05-22 02:15:47', 'activa'),
(149, 6, 'd0d53a14fd5744bb648a690bf56cade07af759ee3ea03c4f716aaf59125af047', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-22 11:03:33', '2026-05-22 11:03:59', '2026-05-23 03:03:33', 'activa'),
(150, 6, 'b81e4459eb63914786fb011dc8edd3742c7e3786034600622bb052912d53be12', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-22 11:04:45', '2026-05-22 11:09:11', '2026-05-23 03:04:45', 'activa'),
(151, 6, '0197b8b854ea1366812711864dea4fadd4eef8edaf1b1ba133ad2914c484b2a7', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-22 11:51:07', '2026-05-22 11:51:36', '2026-05-23 03:51:07', 'activa'),
(152, 6, 'bc5aadeaddb49e1ae4fce9a8244e32705c3069ec9f4480f6d34a27771e821b16', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-22 13:16:30', '2026-05-22 13:16:30', '2026-05-23 05:16:30', 'activa'),
(153, 6, 'ccab9c49d8859df847ab735466a5ee3c0d943d380873ccd03992d439df84975d', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-22 13:19:03', '2026-05-22 14:54:31', '2026-05-23 05:19:03', 'cerrada'),
(154, 6, 'c4defad27272a90705f566ba61759dacf52be3b4155fe4dbdf5663e488d6f8d4', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-22 14:54:37', '2026-05-22 17:00:16', '2026-05-23 06:54:37', 'cerrada'),
(155, 6, '5f6a6530664434b7dc982bf2bcdfcd138e8260ef5ca31a68ec3c606b7171d751', '192.168.40.95', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36', '2026-05-22 16:56:21', '2026-05-22 16:56:22', '2026-05-23 08:56:21', 'activa'),
(156, 6, 'c2acec7ef2f7f0f6ecbf4f3147ec974055ce7eb9e4eb6bd871b2738b375e022c', '192.168.40.95', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36', '2026-05-22 16:57:36', '2026-05-22 16:57:36', '2026-05-23 08:57:36', 'activa'),
(157, 2, '17b5978f9938593aac5ab3a0c73cb6e2f9b08f0e104f5de3fd9d197def38ae88', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-22 17:00:23', '2026-05-22 17:02:44', '2026-05-23 09:00:23', 'activa'),
(158, 6, '47aa0161937338c59ea565cc9e6c9ef32f588298210ce1af9b5a0d0fe2339184', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-23 09:24:56', '2026-05-23 09:55:26', '2026-05-24 01:24:56', 'cerrada'),
(159, 2, '8bd94989574a6174b2c155ab3146c64da6deb36be23a88850504e0cafb9a0b98', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-23 09:55:32', '2026-05-23 11:57:33', '2026-05-24 01:55:32', 'cerrada'),
(160, 6, 'a11f484a69e1ed713658606b66b2af8bb9c541b5001e72256fffa966f8085ad4', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-23 11:57:38', '2026-05-23 12:03:58', '2026-05-24 03:57:38', 'activa'),
(161, 6, '4d57e4bc5f4abd09c90e8f4e582ed3481ff8c077c632567dd177a7a5a93d1ebe', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-23 12:04:12', '2026-05-23 12:05:46', '2026-05-24 04:04:12', 'activa'),
(162, 6, 'd34cc6d4c3fb7326ab338bbcc9b88d3fedda802d5ff18f639366a78a4ccc26d8', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-25 07:47:04', '2026-05-25 15:39:30', '2026-05-25 23:47:04', 'activa'),
(163, 6, 'bdead0377bf51322ce624d5302ee0534d627d45dbee1167544c37d0257d40b3a', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-25 17:10:39', '2026-05-25 17:10:46', '2026-05-26 09:10:39', 'activa'),
(164, 6, '8ffd34ffaa6736e0859ab66c7384cf0a93cf868f2bc25adddbcd121b93bd1320', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-26 07:49:15', '2026-05-26 14:46:03', '2026-05-26 23:49:15', 'activa'),
(165, 6, 'a28a09993676eea75565da79604e6aee071ee1cefcf5a5105f165a311ed169cb', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-05-27 07:39:59', '2026-05-27 07:42:04', '2026-05-27 23:39:59', 'activa'),
(166, 6, 'f50436f0f3708db0f84fd45e87a9b6a16c6e0df668c822953e917915ba679354', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-27 07:54:39', '2026-05-27 10:14:22', '2026-05-27 23:54:39', 'activa'),
(167, 6, '1aecec0632f22bcf595862108403ca09c402d6b23d36587b43db380e6c738685', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-27 16:30:56', '2026-05-27 16:30:57', '2026-05-28 08:30:56', 'activa'),
(168, 6, '2b54fb880874080983eb085ee01585e6c3f55f4fe14c0ec8f692083c43d6cd4a', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-28 08:54:01', '2026-05-28 13:32:34', '2026-05-29 00:54:01', 'activa'),
(169, 6, '0c495525f53e2a4fa5da4b6b55afe1b761f3cf92ae44b40c77108b5cc7236441', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-29 07:42:47', '2026-05-29 13:22:35', '2026-05-29 23:42:47', 'activa'),
(170, 6, 'a8d1142efc9bb4dc0422a0f806a928e69d7b096f9bf0b6233e9cad621c04631f', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-29 15:53:43', '2026-05-29 16:54:10', '2026-05-30 07:53:43', 'activa'),
(171, 6, '3455e5ccaac499ca489b87036e4bf7e321e160215974b0f1ac7c3d45a23aa41b', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-05-30 08:58:49', '2026-05-30 12:15:14', '2026-05-31 00:58:49', 'activa');
INSERT INTO `sesiones_admin` (`id_sesion`, `usuario_id`, `token`, `ip_address`, `user_agent`, `fecha_creacion`, `fecha_ultimo_acceso`, `fecha_expiracion`, `estado`) VALUES
(172, 6, 'b305b3efb1dbb72605233d94714be880426c5d1befa328a6fcc6a0b76ae9bf2c', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-06-01 13:58:53', '2026-06-01 14:40:39', '2026-06-02 05:58:53', 'cerrada'),
(173, 4, 'ce4fa0643f7476582bdcc8026f499ed3a10b9d5b4e10d8a91b989627ef8529c8', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-06-01 14:40:50', '2026-06-01 14:40:50', '2026-06-02 06:40:50', 'activa'),
(174, 6, 'dc0564fad1d66db8eb4bc8981ebdf3175b32757901fcc17a679ff9353f1ceba4', '192.168.40.58', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36', '2026-06-01 14:56:16', '2026-06-01 14:58:14', '2026-06-02 06:56:16', 'activa'),
(175, 6, '28903bb98637828fe0a34f8942787b272eeda74b404ea6e14ca58b09bc05fb67', '192.168.40.54', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-06-01 16:07:18', '2026-06-01 16:56:52', '2026-06-02 08:07:18', 'activa'),
(176, 4, '658c05378850a5b24286400d31134494eca51e3f40a88ef5c300d707eed553c5', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-06-02 14:19:32', '2026-06-02 14:39:28', '2026-06-03 06:19:32', 'activa'),
(177, 4, 'b609eb35b6ea226044837a6e9b2c53431a79d5b76964bdd9d49dedae510469b9', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-06-02 14:44:20', '2026-06-02 14:45:05', '2026-06-03 06:44:20', 'activa'),
(178, 4, '35bb88ac3b7aa81d3efb496115074f153869aa3c2520c68e2b93cffce86c64e6', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-06-02 14:47:31', '2026-06-02 14:58:48', '2026-06-03 06:47:31', 'activa'),
(179, 6, 'ca09a04c8c382f99718c2a9d592b4220456074d5b4dfe356f0e3ba850193f685', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-06-03 10:05:34', '2026-06-03 16:47:58', '2026-06-04 02:05:34', 'activa'),
(180, 4, '00ff5e45509b4c853a0f059764a0c23b95cbc6e75f7ff87a6523b4a3705bfb5c', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-06-04 10:04:36', '2026-06-04 10:14:58', '2026-06-05 02:04:36', 'activa'),
(181, 6, '7d384c62cfe31193227e58d80ddc5692c97dc6a5079f6f7694ef2964cd445c93', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-06-04 11:42:31', '2026-06-04 14:00:43', '2026-06-05 03:42:31', 'activa'),
(182, 4, '6f7a771405fa4067a3dffbab28be4e4a1dc1e5584006a286521d94100370fd7b', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-06-04 11:48:59', '2026-06-04 11:59:11', '2026-06-05 03:48:59', 'activa'),
(183, 6, '41389c1623be2a1e5e07875515e2e706f93fc0322152ae6b7449b91f6c3fe994', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-06-04 14:01:32', '2026-06-04 17:15:51', '2026-06-05 06:01:32', 'activa'),
(184, 4, 'af25db20f36296c8b3d41e68c1b5848357a49c8a261b57e91ce2a630e672a4dd', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-06-04 14:53:21', '2026-06-04 14:53:26', '2026-06-05 06:53:21', 'activa'),
(185, 4, 'ae44d2bc0a90b04059632323516dd35c0423dc1f3a5ae259baa0f672003b1c04', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-06-04 14:55:09', '2026-06-04 16:02:17', '2026-06-05 06:55:09', 'cerrada'),
(186, 4, 'f50fcb69879c7af526a95f626e613adf4dfdda546557484abf4b23ad93daf646', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-06-05 09:09:30', '2026-06-05 09:15:36', '2026-06-06 01:09:30', 'activa'),
(187, 4, '48aab0e71e0186eaa281caa067355b4ea3e18a0f3502218308a9d4775d2e8125', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-06-05 09:56:40', '2026-06-05 09:56:40', '2026-06-06 01:56:40', 'activa'),
(188, 4, '98dd9f9d76b51be436868466567df70caf405847afe38c6a5bc5872121927585', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-06-05 09:57:24', '2026-06-05 09:57:29', '2026-06-06 01:57:24', 'activa'),
(189, 6, 'c964b5c6e3aadb20d94561f5386bca1f126407522a8c9316b9a560b5c4d55c87', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-06-05 10:06:19', '2026-06-05 16:57:02', '2026-06-06 02:06:19', 'activa'),
(190, 4, 'ab3444c6245f170689dc5b795094347e2ce20ea8a162f67ca05911c569ff93a0', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', '2026-06-05 10:10:16', '2026-06-05 10:10:23', '2026-06-06 02:10:16', 'activa'),
(191, 4, 'cb5cf10f29bf47129b9c4006a91f31fca19f90e370c15c2ebdbd190fefcceaec', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-05 13:36:08', '2026-06-05 13:38:34', '2026-06-06 05:36:08', 'activa'),
(192, 4, '8e5bb4a184e44216f294c762de68932911ccd10d03640193905cc1aef924501d', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-05 13:50:13', '2026-06-05 13:59:30', '2026-06-06 05:50:13', 'activa'),
(193, 4, '96a81da5eb71a5f7745683e3157f6942a8fb0591b70c39189cb2e0a7514d4af9', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-05 14:03:22', '2026-06-05 14:11:13', '2026-06-06 06:03:22', 'activa'),
(194, 4, '812e02bb8243153ce5a3503248e5f55952340b180d744614d37892483317282f', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-05 14:26:17', '2026-06-05 14:32:08', '2026-06-06 06:26:17', 'activa'),
(195, 4, 'e86373a1f9452a60aee5db556aee5c58474cb5131067576fd319c37a5a2d70cb', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-05 14:32:46', '2026-06-05 14:33:36', '2026-06-06 06:32:46', 'activa'),
(196, 4, 'cd50f2b8daf32c7585b918e327a09e0e2f1e194fc65581fa5e2fa1dcdd9d7cd1', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-05 14:41:33', '2026-06-05 14:42:22', '2026-06-06 06:41:33', 'activa'),
(197, 4, '4603c260c230a01ec1af9f31e6727b37e0f666961809691f2d55b4cdb2f0c42e', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-05 14:43:27', '2026-06-05 15:53:25', '2026-06-06 06:43:27', 'cerrada'),
(198, 6, '25321c1b76c463349ba9e48b9b995bd535e98f177490e123b4ead2af9d0a35ef', '192.168.40.90', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36', '2026-06-05 15:18:20', '2026-06-05 15:18:21', '2026-06-06 07:18:20', 'activa'),
(199, 6, '4c29489718d7b0a63b6222959c19784fd9f51f84956570ce77635deb4c57a6dd', '192.168.40.90', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36', '2026-06-05 15:18:36', '2026-06-05 15:23:25', '2026-06-06 07:18:36', 'activa'),
(200, 4, '8604e85d579fb2afc01983f601e6a88bb0274770d23525a6cccd9777fe792f02', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-05 15:59:04', '2026-06-05 16:23:39', '2026-06-06 07:59:04', 'activa'),
(201, 4, '5f84d56f8a5e0704d96c66f1e500ed377752c863718aaedc2f691c4f105e5b12', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-05 16:58:47', '2026-06-05 17:05:41', '2026-06-06 08:58:47', 'activa'),
(202, 4, 'f1151cedd7b7c040281f9a00670a8daee5074564576ee519c5bccbf487cc518e', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-06 08:33:19', '2026-06-06 08:33:20', '2026-06-07 00:33:19', 'activa'),
(203, 4, '3e03ee38b106f2e1110d0febf00805f35bfe03140f8ca427bd645a37ce0b404b', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-06 08:33:57', '2026-06-06 08:35:07', '2026-06-07 00:33:57', 'cerrada'),
(204, 4, '11f21bc0a00d5042b0400478b70e04823d2a58961c0917c5a56068d12953c44a', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-06 09:06:37', '2026-06-06 09:09:53', '2026-06-07 01:06:37', 'activa'),
(205, 4, '5cf16b60d42bd71bc5b30a4c6d4bdc9f5bb27246a829029a3fecba09221b78f0', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-06 09:10:22', '2026-06-06 09:11:25', '2026-06-07 01:10:22', 'cerrada'),
(206, 4, 'b6662446e4f77d06279d9e59b99a7db0d233a20c1445b95eaab5cc972a440dbf', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-06 09:11:34', '2026-06-06 09:32:07', '2026-06-07 01:11:34', 'activa'),
(207, 6, 'e1d0826b54e7889331a2c70e50cec77552fb5f8b76d486e0706d4b5ef7b50ced', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-06-06 09:29:47', '2026-06-06 09:42:25', '2026-06-07 01:29:47', 'activa'),
(208, 4, '77a5cf9941696ceddffa3988429d3b645a5acbf4f6762b159d540b68db0475ff', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-06 09:32:21', '2026-06-06 09:44:49', '2026-06-07 01:32:21', 'activa'),
(209, 4, 'c9a7d90fb8859f1e043ecbd1a7c42669e0f4165028290c12cda25703418484a8', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-06 09:46:57', '2026-06-06 09:47:23', '2026-06-07 01:46:57', 'cerrada'),
(210, 6, 'be9c377af624865e85e1479bf9282c5b42484cbab98b5fc6287e03e0b03a3d5d', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-06-06 09:47:29', '2026-06-06 12:12:45', '2026-06-07 01:47:29', 'activa'),
(211, 4, 'fa8e297e87a0e0c129356f2afd68b99b3a84d23623aa758b899fbe78cd5afa9e', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-06 10:04:44', '2026-06-06 10:05:45', '2026-06-07 02:04:44', 'activa'),
(212, 4, '257ec42546c82dd0a6425c12145e3ab23acc3582fefa0e9f3ffd5c0075f63626', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-06 10:11:49', '2026-06-06 10:13:47', '2026-06-07 02:11:49', 'cerrada'),
(213, 4, '20023632e5fec19ba0bec866ed2c4ae11e3dd7d26012a47884c4e441bd053fc8', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-06 10:16:19', '2026-06-06 10:16:48', '2026-06-07 02:16:19', 'activa'),
(214, 6, 'f78bb63af194152ffb862bb7e04a2a21b541da1cf8f643b5e4172ec50eb70123', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-06-08 07:44:37', '2026-06-08 14:34:29', '2026-06-08 23:44:37', 'activa'),
(215, 4, '234fbf4d012aa7a4471998f63d4c4dae08879f557cc3d059fe67811c2e02ac9f', '192.168.40.86', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-08 10:43:02', '2026-06-08 10:51:01', '2026-06-09 02:43:02', 'cerrada'),
(216, 4, 'af516028b6687431b7505c00c4b0a0af153554cad4eb7179277e4f881d4fe78a', '192.168.40.86', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-08 10:51:11', '2026-06-08 10:51:11', '2026-06-09 02:51:11', 'activa'),
(217, 4, 'fc4ebcbad468e1c9b4fcf43a7048e508df64e4bb841ec7e39417977e3e759807', '192.168.40.86', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-08 13:39:50', '2026-06-08 13:41:59', '2026-06-09 05:39:50', 'cerrada'),
(218, 4, '68dc65fdb11ca6fc0280042aa4588d04ee490904364150374418b6c0fbcd5d66', '192.168.40.86', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-08 13:42:08', '2026-06-08 13:42:16', '2026-06-09 05:42:08', 'activa'),
(219, 4, '8d566e92a52b093646322495ddf1c12e5f516ea00ff77b03115e7554befdd0cd', '192.168.40.86', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-08 13:43:07', '2026-06-08 16:28:05', '2026-06-09 05:43:07', 'cerrada'),
(220, 6, 'c47d84cfd3d77dbb055be60606caa014e3798bf19191997bf953316bf5652f1f', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-06-08 16:14:58', '2026-06-08 16:27:36', '2026-06-09 08:14:58', 'activa'),
(221, 4, '5065398c48153a34efa75e6cb29429a49eb7a904c21cbbb530dd274f26ff0c8c', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-08 16:34:50', '2026-06-08 16:39:05', '2026-06-09 08:34:50', 'activa'),
(222, 4, '14c910145d612ecaad92ca0654f299fc091c23197db6c00e36e17d60f0f48d75', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-08 16:39:52', '2026-06-08 16:59:29', '2026-06-09 08:39:52', 'cerrada'),
(223, 6, '2eb4b3405f0f9f501f9b963b827a437d2c2b8a0e7d90ef1dc74c1f11bbb7a19b', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-06-09 07:40:40', '2026-06-09 13:21:49', '2026-06-09 23:40:40', 'activa'),
(224, 4, 'a9a37bfc03c7ef529911899c9dd3998dc66c068f585cbbf302fe48d1faf689b1', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-09 09:20:23', '2026-06-09 09:23:57', '2026-06-10 01:20:23', 'activa'),
(225, 4, '86c64677392ab55fe27af9db9f1f3dfcfe963e063bf3184ad100b3d4fe10030c', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-09 09:39:06', '2026-06-09 09:40:10', '2026-06-10 01:39:06', 'activa'),
(226, 4, '54b3f00db297ac7196d1678ba857a384f78c21e4bb401419412bc3e497098b8f', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-09 11:19:12', '2026-06-09 11:30:02', '2026-06-10 03:19:12', 'cerrada'),
(227, 4, 'b80ae117c62fb0eab99440907ad88239f03ee27a1e1f8e085d7e3e2a2d7b82d8', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-09 11:30:12', '2026-06-09 11:30:16', '2026-06-10 03:30:12', 'activa'),
(228, 4, 'fbe344bbaa912972f29f27adf9b1f9e5969490d6c3cef4f52073147b89adee2b', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-09 15:40:25', '2026-06-09 16:27:23', '2026-06-10 07:40:25', 'cerrada'),
(229, 6, '97883ecef1118807e8dc70f64262075d60e55302d2aa2087a5c60a2ace9bcd64', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-06-09 15:42:10', '2026-06-09 17:35:04', '2026-06-10 07:42:10', 'activa'),
(230, 4, 'f519683d1e5cc2fd22b8683179ade7a6dfbe88dc8a73309fb3dcd6e9b6679db7', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-09 16:35:37', '2026-06-09 16:39:51', '2026-06-10 08:35:37', 'cerrada'),
(231, 4, '91012e15333d8034e87ac8b155c2400f62d44c17b06ea38c40afe6fd823d6e7b', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-09 16:40:26', '2026-06-09 16:44:44', '2026-06-10 08:40:26', 'cerrada'),
(232, 4, '87885b06f7ae363463f0c51827853afcf23ba023b33a1c0e515b81ca31dea532', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-09 16:53:40', '2026-06-09 17:08:20', '2026-06-10 08:53:40', 'cerrada'),
(233, 6, '70c4ac8c430ceb0d8bc240bcb5b0db85e2f89b951534514e809583ef8ae1d89a', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-06-10 07:36:38', '2026-06-10 15:24:48', '2026-06-10 23:36:38', 'activa'),
(234, 4, '0206d7d516c7ee170755a77ead9c0228ebcd16e3a513414001065d284b3bb59f', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-10 08:54:56', '2026-06-10 09:11:47', '2026-06-11 00:54:56', 'activa'),
(235, 6, '1947b50b84112a9135af9c15958bd218308adb5ba723f3cd4d05b52450a1d98b', '192.168.40.86', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-10 08:59:11', '2026-06-10 09:00:31', '2026-06-11 00:59:11', 'activa'),
(236, 4, '84fbb3b031653ef70f63cbf198ff4403136a82d1b34c157e880fa59c232fb6af', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-10 09:57:17', '2026-06-10 10:14:51', '2026-06-11 01:57:17', 'cerrada'),
(237, 4, '2d9abea36fccaf81bfc8e8ea773e991b6edd9bee435d508409ff707b851365c2', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-10 10:15:33', '2026-06-10 10:15:33', '2026-06-11 02:15:33', 'activa'),
(238, 4, '461da524b36480236d2a47839011d8b6e7bdf68b370cc9f50f93d0562de84e51', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-10 10:45:04', '2026-06-10 10:53:27', '2026-06-11 02:45:04', 'activa'),
(239, 4, 'a25fa469b27b2eb7806ef2c9d98956aba905939fbb866d0b9f349c43ec79d66e', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-10 10:57:22', '2026-06-10 11:12:53', '2026-06-11 02:57:22', 'activa'),
(240, 4, '89c21bcdba0d392e8c2cf47c26ea5bfb6fe4d6bd2f4f81d1395754404eacad50', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-10 11:13:08', '2026-06-10 11:15:32', '2026-06-11 03:13:08', 'activa'),
(241, 4, '1433a11653b357fefe7e9a6387d4ae821915ec419498df6bfc1d08b8bf1a4ea0', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-10 13:19:18', '2026-06-10 13:21:28', '2026-06-11 05:19:18', 'activa'),
(242, 4, 'cb5a4cd76bdcc4ad40b0a6fade5826b75aedc10c310689580b1e1b6a0341fb16', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-10 13:23:28', '2026-06-10 13:35:36', '2026-06-11 05:23:28', 'activa'),
(243, 4, '79ef4b2aea346cdca73c8cac84c8d914bc44c88735928eef72a0fb7b20a855c9', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-10 13:49:43', '2026-06-10 14:14:30', '2026-06-11 05:49:43', 'activa'),
(244, 4, 'f8ffe3fa40a898dd47c579ca58cd97df60bdd75a8acc9f032979994c565e1460', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-10 14:45:02', '2026-06-10 14:56:27', '2026-06-11 06:45:02', 'cerrada'),
(245, 4, 'bddbf9ac49cbfe0ecb4b704ea278a710aaefb1518a1d85450fe736f4a5943648', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-10 14:56:38', '2026-06-10 16:31:22', '2026-06-11 06:56:38', 'cerrada'),
(246, 6, 'c8fb0563adbbd886904349f36d47bde38f46416ad60709de5100a15dc0962687', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-06-10 16:16:03', '2026-06-10 16:16:07', '2026-06-11 08:16:03', 'activa'),
(247, 6, '40141643dfa65829849512d22876f30999f616d4a07d6eeefc19ce41690b0bae', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-06-11 07:56:58', '2026-06-11 15:53:05', '2026-06-11 23:56:58', 'activa'),
(248, 4, '9ed1dc7aaf9be38ab2bf6fee26775483856e6c162f3c970468b266ac68353fcc', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-11 09:24:28', '2026-06-11 09:30:52', '2026-06-12 01:24:28', 'activa'),
(249, 4, '26e4dcff635c46bbadc3c63e015765363ebea324e9049934ca3328494d34f15c', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-11 09:31:31', '2026-06-11 09:37:20', '2026-06-12 01:31:31', 'activa'),
(250, 4, 'd407fb08d3a281037644809b9eaec8315d55fdc52f2c595d17763df3d179d2dc', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-11 09:38:11', '2026-06-11 09:41:53', '2026-06-12 01:38:11', 'activa'),
(251, 4, '3de64e11be48bd22f559c1f40d16cd75bd9e95af28d9231a5e85a0cbbb545f15', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-11 09:42:50', '2026-06-11 09:43:34', '2026-06-12 01:42:50', 'activa'),
(252, 4, '2da977c4541b6844ace54ab6149e2ee4c7a21a580d93ff6cb92ccaa9a11c8041', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-11 09:44:19', '2026-06-11 09:49:56', '2026-06-12 01:44:19', 'cerrada'),
(253, 4, '734f5524bf1d6b717ebc5d629f97afbb7e7d6471e33453595dc9e89ca488ff4c', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-11 09:50:09', '2026-06-11 10:02:02', '2026-06-12 01:50:09', 'activa'),
(254, 4, '4ef2f9992aff74fa29c220c46016e0ade95be630dc524928755fd0d7d0556a10', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-11 10:02:33', '2026-06-11 10:04:06', '2026-06-12 02:02:33', 'activa'),
(255, 4, '7c5f102531b78569177a2c5c25dcab941908b6321070756fdc60b0a7bcf95dde', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-11 10:05:31', '2026-06-11 10:29:03', '2026-06-12 02:05:31', 'activa'),
(256, 4, '0a2f5a3fb67a0ad37bc4c1c6e5e902c18ac973d13fbc3a6a010206a5a2f28261', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-11 10:29:20', '2026-06-11 10:48:36', '2026-06-12 02:29:20', 'activa'),
(257, 4, 'b14dd853a1ef499777ff6210ad9dfeda39ec51c2c3a62678b1c65fb546bdc5ad', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-11 10:49:13', '2026-06-11 10:53:05', '2026-06-12 02:49:13', 'activa'),
(258, 4, '211224952046c77458f89f2d94e90a347b69712da6f2b8adfb8f3dacdd854fe9', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-11 10:53:34', '2026-06-11 10:57:57', '2026-06-12 02:53:34', 'activa'),
(259, 4, 'cbd46ef5bbdb7a513425d1dd3628bbbb441348361dfebaa5475f0a6c5c3daf67', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-11 11:37:29', '2026-06-11 11:37:29', '2026-06-12 03:37:29', 'activa'),
(260, 4, '06d63d2bbd3a5891fc0f75657996b02c9addf099a0379cb7cf35d4dba33a138d', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-11 13:32:24', '2026-06-11 13:32:24', '2026-06-12 05:32:24', 'activa'),
(261, 4, '3409f3906bb9f5ce328c8347b8977c4cadbd5697669089382908fbe5d74d65dd', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-11 13:40:12', '2026-06-11 13:40:23', '2026-06-12 05:40:12', 'activa'),
(262, 4, 'ab103a49a365ed96e18cf23da83572314c15353c8844605b953035c18da5d079', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-11 13:46:10', '2026-06-11 13:50:37', '2026-06-12 05:46:10', 'activa'),
(263, 4, '432d66292117e1eaff789ac8cb68cd4627958bf0ae4123ab6b8e972a97c4cc60', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-11 14:11:50', '2026-06-11 14:26:00', '2026-06-12 06:11:50', 'cerrada'),
(264, 4, 'dd5e28cee3ecd3a30b62deafe15533917d2d03b2963be04718ee073d6f97249d', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-11 16:07:12', '2026-06-11 16:27:07', '2026-06-12 08:07:12', 'activa'),
(265, 4, '3a906bc002d9f82ddd492199ed092e8767fc265794680d19db424c34ae8b45fe', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-11 16:27:28', '2026-06-11 16:56:09', '2026-06-12 08:27:28', 'activa'),
(266, 6, '2548c484bcdd28b05a0df70208a4544020a9df075a09391f9b54629f82eff993', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-06-11 16:36:13', '2026-06-11 16:41:34', '2026-06-12 08:36:13', 'activa'),
(267, 4, '428ccf7a2588581ba308dcca3947aaa19669c6cb0169ce983e00bef79059721d', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-11 16:57:10', '2026-06-11 16:57:50', '2026-06-12 08:57:10', 'activa'),
(268, 4, '5e65a747b05ddfccde6ca8087e256fe92c296e702da08fc0871a2f9ea2476b84', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-11 16:58:19', '2026-06-11 17:12:13', '2026-06-12 08:58:19', 'activa'),
(269, 4, 'b9229da54ff0cd4900e6f7bae30bf92055cf5159715f3934d42ef271e3e49984', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-11 17:12:57', '2026-06-11 17:14:37', '2026-06-12 09:12:57', 'cerrada'),
(270, 4, '18a1ca8ec82f72ac7c65cf12d1d96fc3cde9fb26e5b59f6c36286860032c94ba', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-12 08:24:04', '2026-06-12 08:27:39', '2026-06-13 00:24:04', 'cerrada'),
(271, 4, 'db8937983650c50a53ad8febfc5061d7d298154ce49067a14b1a278697ed7900', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-12 08:27:54', '2026-06-12 08:27:54', '2026-06-13 00:27:54', 'activa'),
(272, 4, '62aeddbfa095c1575e7e1960ec8e9c377abbadee3449386621b998c9b94ba04c', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-12 10:43:41', '2026-06-12 10:50:05', '2026-06-13 02:43:41', 'activa'),
(273, 6, '1f15eab54db47568655dbe0e350873e2bc420ea534fd5f5a3235dacc56b642b0', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-06-12 12:36:56', '2026-06-12 15:14:11', '2026-06-13 04:36:56', 'activa'),
(274, 4, '2a9a207104a92730d7ee1d8cf64086413b4e970d7d73f818c51a5907a26c0b28', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-12 13:21:52', '2026-06-12 13:35:43', '2026-06-13 05:21:52', 'activa'),
(275, 4, '8a239930b0586b6bf1bd78f9f3d372295fa8a308908830a786f1a2b20ce2b278', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-12 14:36:14', '2026-06-12 15:07:35', '2026-06-13 06:36:14', 'activa'),
(276, 4, '79ff390cc4d0f56adfe6f0fb43793829aa45c9b0ed5ed4a8020d7b9f60fd4253', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-12 15:13:28', '2026-06-12 15:13:28', '2026-06-13 07:13:28', 'activa'),
(277, 4, '19775d253856d98534ffab2771832913f7e766a4ce712be3758f84e81e1ded6f', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-12 16:32:26', '2026-06-12 16:32:45', '2026-06-13 08:32:26', 'activa'),
(278, 4, '4fb63f6e1e884b6fb6435176ba7e48956e45b12048e340e7446e30265d1bb7c7', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-12 16:33:17', '2026-06-12 16:41:34', '2026-06-13 08:33:17', 'activa'),
(279, 4, '76a38f4c872181c33aa92415fe86f1648b3f6a1293bef5da4b0d3b48a2fc25c1', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-12 16:42:27', '2026-06-12 16:42:35', '2026-06-13 08:42:27', 'activa'),
(280, 6, '08867246dbdb290e746d1f11e390e23b118711b0cb6dc58d05e6e97d3addf43e', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-06-13 07:32:11', '2026-06-13 11:26:15', '2026-06-13 23:32:11', 'activa'),
(281, 4, '6b9dc8ac15841f33926bc40f7f27cd3cc799138a3c33d39efcef97992c428844', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-13 08:48:13', '2026-06-13 09:14:21', '2026-06-14 00:48:13', 'activa'),
(282, 4, 'b2705b309046ecf7d86051303d37e632423b28632442af0b56ba49169be3823e', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-13 09:15:14', '2026-06-13 09:15:19', '2026-06-14 01:15:14', 'activa'),
(283, 4, 'd0a1303c55985e9f09318e4317fbe6d6dea8e8f12b640966a37145d62fb66b2f', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-13 09:28:19', '2026-06-13 09:43:26', '2026-06-14 01:28:19', 'cerrada'),
(284, 4, 'd6865c5918791c4d3be05740d9f7751da31c5609a766b957d8f8039c2ba02de2', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-13 09:45:51', '2026-06-13 10:08:47', '2026-06-14 01:45:51', 'activa'),
(285, 4, 'ee0f0a5d1b3c0af3b80b8e5b54fb0b238007427e35c7ab56a0af1a71923d26ef', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-13 10:09:24', '2026-06-13 10:09:58', '2026-06-14 02:09:24', 'activa'),
(286, 4, '8c053212d0ba8427ce37174be167a544911b9abadc422c7108cd4cd6deb6f496', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-13 10:10:32', '2026-06-13 10:10:44', '2026-06-14 02:10:32', 'activa'),
(287, 4, 'df0043014ee710ae45df82648d3b821c1b3773cd53c8d2627740e80cc81153cd', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-13 10:23:29', '2026-06-13 10:31:20', '2026-06-14 02:23:29', 'activa'),
(288, 4, '507a09e86306ff7f576f95a9bd0666f699f52783f8320f59c392c225be145047', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-13 10:32:09', '2026-06-13 10:32:44', '2026-06-14 02:32:09', 'activa'),
(289, 4, '18962163e3c6680bb8d79dd3fa68cf9d0cc025eb469b24db1649f02682e95db1', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-13 10:33:56', '2026-06-13 10:44:04', '2026-06-14 02:33:56', 'activa'),
(290, 4, 'f69a74b7fb043fa0be6a27064f4d0d0337ca9b26c29bdd93e53e27fa95886292', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-13 11:16:26', '2026-06-13 11:43:49', '2026-06-14 03:16:26', 'activa'),
(291, 6, 'd8537f3cc9500638373f1be32d425e0b4d521ba2046ac8e5590d6cefb260ba7f', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-06-15 16:24:53', '2026-06-15 17:15:36', '2026-06-16 08:24:53', 'activa'),
(292, 6, '35460fc0e6fb1855513df0b555a997c9a8890570476e310fba0b11909399ad27', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-06-16 08:27:50', '2026-06-16 08:35:06', '2026-06-17 00:27:50', 'activa'),
(293, 6, 'dcc8fb2c01457c094c135e3e5663a846f9a3e7fbc14bbe77eca07a58e5f936e7', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-06-17 08:48:40', '2026-06-17 16:22:29', '2026-06-18 00:48:40', 'activa'),
(294, 6, '09845c99565b6dbf0c8f7d13bd1887a3d810ebdd203978994c04b2426eb158af', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-06-17 17:06:54', '2026-06-17 17:06:54', '2026-06-18 09:06:54', 'activa'),
(295, 6, '8102f50588ea592d35983f59584493ea0fe347920446a789089a182919f8517d', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-06-18 09:57:26', '2026-06-18 17:37:03', '2026-06-19 01:57:26', 'cerrada'),
(296, 4, '656f484baf8eb267020418d82b0f7aa92aae55c3c96a9435ee1c3f2b99bcde63', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-18 10:50:06', '2026-06-18 13:57:44', '2026-06-19 02:50:06', 'cerrada'),
(297, 4, '6acf407271f1d57eb23b94f8f9684b5a1e8b541a7aa0767a1591600770f2570d', '192.168.40.84', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-18 13:58:09', '2026-06-18 14:00:47', '2026-06-19 05:58:09', 'activa'),
(298, 6, '876335ce06084306cd0350324295fc29027686fbe4b595c833f0ca2fc863286f', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-06-18 17:37:11', '2026-06-18 17:51:24', '2026-06-19 09:37:11', 'activa'),
(299, 6, 'ad78bf37485d3b12a10a4a1ebe74c0d80fa8940056c39f0c334b2dd0ade13cbd', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-06-19 07:31:42', '2026-06-19 07:42:30', '2026-06-19 23:31:42', 'activa'),
(300, 6, '4a257bbb967a542fcd3b630b0c16c61ed2b40584933b0c83f37a7240504fe780', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-06-19 10:49:04', '2026-06-19 13:36:40', '2026-06-20 02:49:04', 'activa'),
(301, 6, '692fd1cf4e646f7cdfc72ab9f6e23c1dcf9706ec06f14e5cd2500005bbd3b99d', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-06-19 13:45:00', '2026-06-19 17:05:15', '2026-06-20 05:45:00', 'activa'),
(302, 6, 'eac3bf175a82ab596396700452e5f9a8d9870f8fb93a2b388f5a7f78db4e0417', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-06-20 07:43:26', '2026-06-20 13:02:20', '2026-06-20 23:43:26', 'activa'),
(303, 6, 'c131e98fa8a868f482d722ed4c988f7ef715d2141beae4197f647c13487ca19e', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-06-20 13:14:26', '2026-06-20 13:37:59', '2026-06-21 05:14:26', 'activa'),
(304, 6, '693d3a3be533cbb6c186457798819b1f399c3fab1096a9b25d4df5a6ef32fc2a', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-06-22 13:03:42', '2026-06-22 15:54:01', '2026-06-23 05:03:42', 'activa'),
(305, 6, '38daa08e1709177a4096622018adc479c2709e12988d362532743411c66dfd3c', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-06-22 16:12:00', '2026-06-22 16:14:02', '2026-06-23 08:12:00', 'activa'),
(306, 6, '083a9bd7b11371a91ee2fc02646c5436f23daf726e33e8e6008970929802ca10', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-06-23 08:24:51', '2026-06-23 08:31:10', '2026-06-24 00:24:50', 'activa'),
(307, 6, 'a08254c18512597e37b81bf0aac7bb666cbc4b299c33af645548c7e941125ef1', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-06-23 10:28:55', '2026-06-23 10:29:49', '2026-06-24 02:28:55', 'activa'),
(308, 6, 'e2a5c4ecf990baa8cc0932821e2330c389c547952c5e40f977f0d9705681fda0', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-06-25 07:39:48', '2026-06-25 07:39:51', '2026-06-25 23:39:48', 'activa'),
(309, 6, 'c1c3be48f4138667b1b3a15e20e7cc4fabd5bca949f906adfafb7d15c9ab0a09', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-06-27 08:16:21', '2026-06-27 11:41:33', '2026-06-28 00:16:21', 'activa'),
(310, 6, 'ef7021e6afb24d1f4cdb8fcbb3e82b0da84827000c8b0bbb0ffbdbec7ee0e6c3', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-06-30 10:58:13', '2026-06-30 15:48:01', '2026-07-01 02:58:13', 'activa'),
(311, 6, '49e616a2a16e684ac8068b1afd1ee80e19c3e0d25f4f875386d9c991775de5a2', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-07-01 09:54:12', '2026-07-01 13:36:50', '2026-07-02 01:54:12', 'activa'),
(312, 6, '608cc1a79beb0c34112601ac44dd24c865ca00b25f08a41584b9d904359e8b99', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-07-02 13:15:40', '2026-07-02 17:24:10', '2026-07-03 05:15:40', 'activa'),
(313, 6, '316998aee18c098107ed715bee948e2c7b903d6c4907785eecff310214247025', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-07-03 07:58:15', '2026-07-03 12:51:29', '2026-07-03 23:58:15', 'activa'),
(314, 6, 'e0c8227df855be20692ef114d3cfc4714f51dee9811e35879ddb68086674695c', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-07-03 16:24:27', '2026-07-03 16:48:48', '2026-07-04 08:24:27', 'activa'),
(315, 6, '2dddadf734d0a3391293d271ef0d3ce637216806b8a00a5ab8c6b5a368df293c', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-07-04 07:55:37', '2026-07-04 12:58:10', '2026-07-04 23:55:37', 'activa'),
(316, 6, '19c5a112eee0f1005e62070563e78d0a4385b69c4614bfdf0d81e85de41fee23', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-07-06 07:19:20', '2026-07-06 08:12:42', '2026-07-06 23:19:20', 'activa'),
(317, 6, '80033aef7d9603c662eb1dca8100bf02fb89e0788df990bdbac0c89b9f08035e', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-07-06 09:21:39', '2026-07-06 14:57:47', '2026-07-07 01:21:39', 'cerrada'),
(318, 6, 'c8e873f982030c0f82f8a40ea42bb5de4e6c827fd6cde1b93dbe667a20725b7d', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-07-06 14:57:53', '2026-07-06 15:10:26', '2026-07-07 06:57:53', 'activa'),
(319, 6, 'e9ab1423a5b6bfd06dacd1a00b28cf68a4cd189e57a336177c3f8274697caf5e', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-07-07 11:18:29', '2026-07-07 15:50:38', '2026-07-08 03:18:29', 'activa'),
(320, 6, '4b8f983e9d21cf63320d3cb7da32bddeee032f6548bfb5a8dbb1020e612a5837', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-07-07 15:50:57', '2026-07-07 16:05:33', '2026-07-08 07:50:57', 'activa'),
(321, 6, '4c6db9b719c517a79b085083ecb05ed70aa3d2826c7977441bb856586c3232a9', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-07-08 08:47:23', '2026-07-08 14:08:07', '2026-07-09 00:47:23', 'activa'),
(322, 6, 'e9159d728e090ab666e1f64c373208477e292333e1baeb2fd935e6f27e08985f', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-07-08 16:48:25', '2026-07-08 16:49:58', '2026-07-09 08:48:25', 'activa'),
(323, 6, '68f663acde7adbeb05ae25f96d2babccc781b53d192b71993119b510f9d64ba8', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-07-09 07:56:35', '2026-07-09 08:49:44', '2026-07-09 23:56:35', 'activa'),
(324, 6, 'b23df753a21937ffa1cd38fd602d30dc45a4552fa005f3354a445d67a545d665', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-07-09 13:29:39', '2026-07-09 14:28:23', '2026-07-10 05:29:39', 'activa'),
(325, 6, 'ce7844e353451725c2ac49a7f97839cb6eae934e1aadda85fea479385dc695c1', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-07-10 08:03:09', '2026-07-10 15:34:27', '2026-07-11 00:03:09', 'activa'),
(326, 6, '0525a7af5377475da14d2ea4398a5992c4326d8c04f68f27bfab33f6000cf932', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-07-10 16:49:18', '2026-07-10 17:07:09', '2026-07-11 08:49:18', 'activa'),
(327, 6, '59ac54e175cb1647a65ca941aca63863a0e4b5c916fd26799f5ba12f8bbeec3c', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-07-11 07:51:15', '2026-07-11 07:54:24', '2026-07-11 23:51:15', 'cerrada'),
(328, 6, 'd709314d71c36dd8bfbceb42625e505ad2bc28b814bcc80027b1ccb468191db4', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-07-11 07:54:30', '2026-07-11 09:25:18', '2026-07-11 23:54:30', 'activa'),
(329, 6, '36bed2768a9b2d0394f479f220ba4a11cdae25091d66aec3c1e879511f6c8664', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-07-13 08:48:12', '2026-07-13 10:43:11', '2026-07-14 00:48:12', 'activa'),
(330, 6, 'de7fed92557869df378bf855457e77e51e3fe203e45122b3a6892ef0f3abc1b7', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-07-13 13:23:18', '2026-07-13 15:56:26', '2026-07-14 05:23:18', 'activa'),
(331, 6, 'fbca41154d218ebd429d6711a5a23026570dfc0eb243bba1b2a21d678a13b23e', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-07-14 10:12:57', '2026-07-14 16:03:40', '2026-07-15 02:12:57', 'activa'),
(332, 6, '3b8299ce911c587be5a1d44fec6c996e3b68651af3ed286ab218689ab5a59501', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-07-15 10:11:45', '2026-07-15 14:18:17', '2026-07-16 02:11:45', 'activa'),
(333, 6, '3fa281c0cd230fa0a9789affc5c1edc49710cd8761a51e457144d24623d676fb', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-07-16 13:31:53', '2026-07-16 13:33:08', '2026-07-17 05:31:53', 'activa'),
(334, 6, '85661a2cbaa4b23355b904030c12de7fa751077efa09ecacce3af34ad3bd57e3', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-07-17 08:36:05', '2026-07-17 11:48:21', '2026-07-18 00:36:05', 'activa'),
(335, 6, 'f1cea9ddf04f20ed2cf5afe4f8b055a5319aed7e17b65a821b56f9eab9ec8539', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-07-18 08:04:12', '2026-07-18 08:22:19', '2026-07-19 00:04:12', 'activa'),
(336, 6, '09b929300ff98aeb92aaf1b2b09eb15753e8ac5bb7d904d3fc516c83a98ad2b0', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-07-20 09:12:54', '2026-07-20 15:29:40', '2026-07-21 01:12:54', 'activa'),
(337, 6, '453fb1191b27abd4f61b714f03068a3c80e54f79c5c3b4bc97def1d790efc2bc', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-07-21 09:01:37', '2026-07-21 13:52:19', '2026-07-22 01:01:37', 'activa'),
(338, 6, '71f13f7d0b207e60ce7c1875bad40769748c185ca2fa84ea15c79a509d75f10e', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-07-22 07:49:43', '2026-07-22 13:23:50', '2026-07-22 23:49:43', 'activa'),
(339, 6, '70b4fb03589b2d9679f8c84d588a4597c6ca14ff4a215f99c61bda3b34126c98', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-07-22 16:20:19', '2026-07-22 16:41:09', '2026-07-23 08:20:19', 'activa'),
(340, 6, '7acfd1d2f9b116f76cd51db61158faf814873518948878a62856c4ef577a1088', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-07-23 10:34:31', '2026-07-23 11:11:00', '2026-07-24 02:34:31', 'activa'),
(341, 6, 'b415bad478216fbe41fd42b11642c38a82fb8d53bc68caca48cf0536697addef', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-07-24 07:31:41', '2026-07-24 13:45:22', '2026-07-24 23:31:41', 'cerrada'),
(342, 6, 'b25e7fa4977c92412e80472766eaa4f7a5c4ab0da5bb66ae9616180c73bdacb6', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-07-24 13:45:28', '2026-07-24 16:31:38', '2026-07-25 05:45:28', 'activa'),
(343, 6, 'ed4a608180ca8e6806d11b9d88866865fd081336d65b346ebfecad63fdf6c699', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-07-25 07:46:50', '2026-07-25 11:01:19', '2026-07-25 23:46:50', 'activa');
INSERT INTO `sesiones_admin` (`id_sesion`, `usuario_id`, `token`, `ip_address`, `user_agent`, `fecha_creacion`, `fecha_ultimo_acceso`, `fecha_expiracion`, `estado`) VALUES
(344, 6, '03a6ffb6ab463737612a8e9e2e9600081edf64609b4ed32e47d94a9207daafcc', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-07-27 09:15:10', '2026-07-27 17:09:59', '2026-07-28 01:15:10', 'activa'),
(345, 6, '29b270e63ed23cadcd7981b4dc0eb6a7138b53d04c2963572d330ac6500f5f70', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-07-28 07:52:54', '2026-07-28 08:37:46', '2026-07-28 23:52:54', 'activa'),
(346, 6, 'e93537b5f8d1a0e33578094bd8283c892ded8fee7b5f474137671ee2b81fa77e', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-07-28 11:07:24', '2026-07-28 16:29:28', '2026-07-29 03:07:24', 'activa'),
(347, 6, '93e161b21b42c518bef7935e2cd5523235b681db53abffe535acb9365be2bd12', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-07-29 10:20:37', '2026-07-29 16:49:33', '2026-07-30 02:20:37', 'activa'),
(348, 4, '0531ccfe3e3803356b93a73f6a64cb68d63c4467b4c5b3cd37f75729b055d9d9', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36', '2026-07-29 15:45:18', '2026-07-29 16:24:00', '2026-07-30 07:45:18', 'activa'),
(349, 4, '3269e26ea23e599175e7cae9466c825c99436bac7ea64ce7b6fc0179ff87311e', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36', '2026-07-29 16:39:31', '2026-07-29 16:47:32', '2026-07-30 08:39:31', 'activa'),
(350, 6, '47d07e8ab1e60b7ffaf978648bb3c283734db01aa023d3cd535b0fa8eb117b88', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-07-30 07:33:20', '2026-07-30 13:52:44', '2026-07-30 23:33:20', 'activa'),
(351, 4, 'ef4e2f1b284d3966777c0e4947d1a086b58b53de8e8963b3c83edbd3765c4a3a', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36', '2026-07-30 09:29:54', '2026-07-30 13:26:38', '2026-07-31 01:29:54', 'activa'),
(352, 4, '0fff9fcd8863dcfe328e6cb08680532111526e4fd6cdcb12ed1b1094d84ce304', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-07-30 13:41:41', '2026-07-30 16:57:32', '2026-07-31 05:41:41', 'activa'),
(353, 6, 'dec89e81e15cb19766dd1f514fd95b228aa6c147624a0fb31a2c5f0249957902', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-07-31 07:59:40', '2026-07-31 13:08:17', '2026-07-31 23:59:40', 'activa'),
(354, 4, '70891255c734744ddf16a72a2b4eff7b29df41d117894049957b6b53f23cc30e', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-07-31 10:02:02', '2026-07-31 14:29:34', '2026-08-01 02:02:02', 'activa'),
(355, 4, '55c3299f2a272916a89d1124c96749d11e78e8d61d4d74555c82e8ba83f73235', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-07-31 14:33:40', '2026-07-31 14:33:40', '2026-08-01 06:33:40', 'activa'),
(356, 6, '7209c7bc89b2de4a6c79619eb716f9a4d69ff4918204ee97d3a9df232d8e958d', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-08-01 07:48:32', '2026-08-01 08:37:48', '2026-08-01 23:48:32', 'activa'),
(357, 6, '469c9dac5886bf88d07a7a9a89fae05341443b65e23f4a2418ba8cebe541ac70', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-08-01 09:17:49', '2026-08-01 09:55:18', '2026-08-02 01:17:49', 'activa'),
(358, 6, 'b27cd61dc58a21fad2151dcb2eecef8e66559def1f56a974ada5aa60591e8efa', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-08-03 08:42:56', '2026-08-03 16:41:26', '2026-08-04 00:42:56', 'activa'),
(359, 4, '03221f2cc28be12f7723dc4522128a4c95a2ab4da4aecc0d3a88b7e535be69c9', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-03 10:42:07', '2026-08-03 11:41:33', '2026-08-04 02:42:07', 'cerrada'),
(360, 4, '7fef779b2b9639e59d9e6c1f0be8327dbd335e96868c999f433d426451eece41', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-03 16:26:28', '2026-08-03 16:27:06', '2026-08-04 08:26:28', 'activa'),
(361, 6, 'c8fe1ccf790d5ecb3f50c3c9afe7feec9c50c7da5bdd25fe4b9d758111c5b59c', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-08-03 16:44:51', '2026-08-03 17:05:56', '2026-08-04 08:44:51', 'activa'),
(362, 6, 'c7e02e531d1fa9b52344c4c30fdcbca35844cdd89846eaae24696123e85e5f8a', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-08-04 07:26:22', '2026-08-04 15:24:48', '2026-08-04 23:26:22', 'activa'),
(363, 6, '305c262b2fc28fb2e54c952f5ca65ae3b271e490cb871fcda26c121d95bce986', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-08-04 15:30:05', '2026-08-04 16:41:54', '2026-08-05 07:30:05', 'activa'),
(364, 6, '29c59eac9b4ac42bc51d3c0eb282d3d2a69ea895851d463b3adbeaa01196d379', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-08-05 07:48:37', '2026-08-05 14:37:36', '2026-08-05 23:48:37', 'activa'),
(365, 6, 'c43e844758e4809c218e05cffb89f4115ebfba3a0f0220dfeb638e41fb91d3e7', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-08-06 08:55:59', '2026-08-06 15:26:10', '2026-08-07 00:55:59', 'activa'),
(366, 6, '6e9809df0010a64883dfa87743b4ab2328ef3a05f6ddb87f567a9179efc28081', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-08-06 17:48:00', '2026-08-06 17:48:05', '2026-08-07 09:48:00', 'activa'),
(367, 6, '32cc824fd38b00cc341b692eeb9a889eebc99f3058cfcfa9fa5e0e3f0d8f0d25', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-08-07 08:28:04', '2026-08-07 15:13:25', '2026-08-08 00:28:04', 'activa'),
(368, 4, '3fcf577d9b300b0c5e1a643d8b9183b4caa2a7509216eb77b1edf567be8d4304', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-08 09:02:40', '2026-08-08 09:06:59', '2026-08-09 01:02:40', 'activa'),
(369, 6, '8b5af0328619c532863e2f569ff27cb68f046ddb610d6a03823c623fff8a7f07', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-08-08 11:15:38', '2026-08-08 11:18:33', '2026-08-09 03:15:38', 'activa'),
(370, 6, '85628cd5d316d9d1255f251e447c8c9a7661e5f0d15917ee7e7f808da01358e4', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-08-10 11:26:15', '2026-08-10 15:24:04', '2026-08-11 03:26:15', 'activa'),
(371, 4, '55ab9fe988d14a7fb53c809acb69b6586ed2bf6ae6f62899bb4726f859491da4', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-10 13:30:01', '2026-08-10 13:36:22', '2026-08-11 05:30:01', 'cerrada'),
(372, 6, '3db6d4617e094c5b2a9332994319cfaab49d6e10415ab9a6ed84154c808be469', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-08-11 07:38:42', '2026-08-11 15:19:20', '2026-08-11 23:38:42', 'activa'),
(373, 4, '2b9bb356ba42519b6242e52bc9a0f48891372d43fdd4b92eb4b636c176df6954', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-11 10:59:25', '2026-08-11 11:59:30', '2026-08-12 02:59:25', 'cerrada'),
(374, 4, '6c212b06cb29cbd538b9a29d8941118fcc97b20dbde9731c7d7284515b17d451', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-11 14:00:27', '2026-08-11 14:42:34', '2026-08-12 06:00:27', 'cerrada'),
(375, 6, 'c9a92d53e65785bb3868cb0df3e4ae6618b97e0d3b009bd6a40b2e9abcfef352', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-08-12 09:08:20', '2026-08-12 16:08:25', '2026-08-13 01:08:20', 'activa'),
(376, 6, '5a541103b272913dd27c74a82c4b6a0687666a9ea798a2cd478157feb5602318', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-08-12 13:22:02', '2026-08-12 13:22:10', '2026-08-13 05:22:02', 'activa'),
(377, 4, '2384e766c16edb3959a9422f20b4a75bf2893cec2c0285784d75521bb593fcdd', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-12 14:34:38', '2026-08-12 16:56:12', '2026-08-13 06:34:38', 'activa'),
(378, 6, 'c3d95a087b8e62b3f976211cc2957c33ce3c1fda675e27200570b801bff5a764', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-08-13 07:27:14', '2026-08-13 13:09:29', '2026-08-13 23:27:14', 'activa'),
(379, 6, '3ddf9696fde950bd408981d4893177eb43e9bffd9fd6bb7e386b3eecc30f5740', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-08-13 15:54:49', '2026-08-13 17:37:54', '2026-08-14 07:54:49', 'activa'),
(380, 6, '0f49f1d94f52c8ad7db8f83a43beb4d946887657e837f670ec7d9b5b01af3ccd', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-08-14 13:23:31', '2026-08-14 13:35:57', '2026-08-15 05:23:31', 'activa'),
(381, 6, '79348ad81126a008e2e7b79c0b61fbfa8ef8680afea373c6cd4a98073d67442a', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-08-14 14:03:21', '2026-08-14 14:41:18', '2026-08-15 06:03:21', 'activa'),
(382, 6, 'ec6c12484f2ce4ef73dccaf9d8f3ec76a707eb395299d1288adf8ebd72729c47', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-08-14 14:48:29', '2026-08-14 17:23:24', '2026-08-15 06:48:29', 'activa'),
(383, 6, 'f517be0b99ce83d7b790f0656c060a277f5e64e4dfbaf02daf22b4ea96ce156a', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-08-15 08:09:04', '2026-08-15 08:54:31', '2026-08-16 00:09:04', 'activa'),
(384, 6, '932c4e082827d989eb6f34be5be92e2a93fdf93b265f57ef7ee7536d0a6e33cf', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-08-17 07:43:56', '2026-08-17 15:26:26', '2026-08-17 23:43:56', 'activa'),
(385, 6, '7dee03ae7a1299ef7acb274c3ec472b247faaed560238dcb3af173a043acbf16', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-08-17 15:48:11', '2026-08-17 18:11:13', '2026-08-18 07:48:11', 'cerrada'),
(386, 6, 'f3e770b832a08481d873bbfba22385da13987d77fa7d0631823b185c974e6ef1', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-08-18 09:27:44', '2026-08-18 17:25:57', '2026-08-19 01:27:44', 'activa'),
(387, 6, '4587a7bbc534a544413a54fbc805125ebe11b2b74f0ce239e4dc1d3ac2e7ee8f', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-08-18 17:29:27', '2026-08-18 17:35:59', '2026-08-19 09:29:27', 'activa'),
(388, 6, 'a8a0954d79da6b109bd9f9241859de59737aee70d1b11b792d073c47d23b0113', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-08-19 07:23:11', '2026-08-19 14:06:18', '2026-08-19 23:23:11', 'activa'),
(389, 6, '896a5d6e9295afe1767b380e29a41bbdb565dabb20745cd4e502e4fe36703fef', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-08-19 16:13:49', '2026-08-19 17:45:29', '2026-08-20 08:13:49', 'activa'),
(390, 6, 'e6abf0fdffc2e658ab7a71cd10dfeb63bfe4fce064340ad35f9e80ab1d416398', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-08-20 07:40:50', '2026-08-20 07:40:50', '2026-08-20 23:40:50', 'activa'),
(391, 6, 'ab73bf2fb9a33b728cc4c42c41a5e0183457f759de2cbaf093f410f81bff1339', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-08-20 09:23:30', '2026-08-20 16:36:09', '2026-08-21 01:23:30', 'activa'),
(392, 4, '7e62ed7527f9509ea5e99b4fa751d3d5c7f0643248f2965ae243a7a050d90724', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-20 16:21:56', '2026-08-20 16:22:46', '2026-08-21 08:21:56', 'activa'),
(393, 6, '83fc3fc710ce445c0366c4d2b0341ff2e58c3179c7b4166be43b9057e8163f59', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-08-21 13:28:27', '2026-08-21 17:26:37', '2026-08-22 05:28:27', 'activa'),
(394, 6, '0457ebe69d127dee782b565e4d55ea9bf41510de7dd7cbe291b65e9e975903f8', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-08-22 07:42:05', '2026-08-22 12:47:52', '2026-08-22 23:42:05', 'activa'),
(395, 6, '0f332d53ea0c75bcdb6492d6b8ef5a03d98e8349f0d5d8f26ce746de6f8ca5dd', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-08-24 07:35:09', '2026-08-24 14:48:41', '2026-08-24 23:35:09', 'activa'),
(396, 6, 'eccae8576b48f8e55a19b98578ede8a2b1e6ab64e030017d8f7b9ebddd50c571', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-08-24 15:49:51', '2026-08-24 17:11:54', '2026-08-25 07:49:51', 'activa'),
(397, 6, '72fbdebd115b74bdd767e75524d5e9b60b94a5a75c53b44bf219327b7ad79439', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-08-25 07:53:54', '2026-08-25 08:28:26', '2026-08-25 23:53:54', 'activa'),
(398, 6, '1decb4bc144e3a199c01a352078962c1a7a9ac02373d3fea39ec6cb24514e2e8', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-08-25 16:25:06', '2026-08-25 16:31:17', '2026-08-26 08:25:06', 'cerrada'),
(399, 6, '123c9ac80d6424363bf001014bf6816d773edd40a4dd871759709f06a3915114', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-08-25 16:31:23', '2026-08-25 16:38:34', '2026-08-26 08:31:23', 'activa'),
(400, 6, '36aa6291da888936f5a6de07692d0b0a89079a2f31ab7ad542560e13a9665d62', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-08-26 07:51:54', '2026-08-26 14:14:20', '2026-08-26 23:51:54', 'activa'),
(401, 6, '113216416a0fa61c28f8c0f52509a2334c66af3a44d2ac5aa958ca7d384c9b51', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-08-27 09:25:59', '2026-08-27 15:58:03', '2026-08-28 01:25:59', 'activa'),
(402, 6, 'dfd930ec0ec7a0944443dfd903f95e9588d9b5f82e60263d5e2c18475e68fd9a', '192.168.40.94', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Mobile Safari/537.36', '2026-08-27 11:25:27', '2026-08-27 11:45:58', '2026-08-28 03:25:27', 'activa'),
(403, 6, '4a289b2bf1396ad7d9bc318f2e5841a079d4eaea4d8a8282566b9fee607b5591', '192.168.40.94', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Mobile Safari/537.36', '2026-08-27 11:46:07', '2026-08-27 11:46:24', '2026-08-28 03:46:07', 'activa'),
(404, 6, '4bdcecb1499faa4bad02060fcb64c258ff69a406acdf6e3454e972a9ff95eae2', '192.168.40.94', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Mobile Safari/537.36', '2026-08-27 11:46:52', '2026-08-27 12:02:31', '2026-08-28 03:46:52', 'activa'),
(405, 4, '0e6a1090b6780eb0fe31a942b1894fff93eb3bc631fb88244ee90f3644198ca4', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36', '2026-08-27 11:53:36', '2026-08-27 14:49:52', '2026-08-28 03:53:36', 'activa'),
(406, 6, '90346ba218d73a70ae415fd5121c06428e97fe25465ff09e0da75cdfc810eb5a', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-08-28 11:39:11', '2026-08-28 14:50:45', '2026-08-29 03:39:11', 'activa'),
(407, 4, 'f21f7209aecb2a04803b72f7833186d924925a9f518264f74d35c7fca5a423d6', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36', '2026-08-28 13:06:42', '2026-08-28 15:01:46', '2026-08-29 05:06:42', 'activa'),
(408, 4, 'c907533957d590cbe419d491c18cf8855fc5ec604205bd382b44d3b0e08d0649', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36', '2026-08-28 15:02:49', '2026-08-28 15:05:44', '2026-08-29 07:02:49', 'activa'),
(409, 6, 'd2d884156a4146f004a6c7c3cd5429ca6e6cde86ba6c50aad72de15c1e70a895', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-08-29 08:34:36', '2026-08-29 11:02:04', '2026-08-30 00:34:36', 'activa'),
(410, 6, '4984b7df76cf4efacdcb38c381afef5cca6e789df735ceb617ee4348190c6997', '::1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Mobile Safari/537.36', '2026-08-29 09:36:10', '2026-08-29 09:37:42', '2026-08-30 01:36:10', 'activa'),
(411, 4, '8f51477d5de26ab12580a0272fe6363e490e53b4ad3deda689f2f747b64281d0', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36', '2026-08-29 09:45:06', '2026-08-29 09:45:16', '2026-08-30 01:45:06', 'activa'),
(412, 6, 'c5230e7fe89cf6ff84e9e95fec08738b034c7cce0952058b8406130d2bab2bdb', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-08-31 08:14:14', '2026-08-31 10:26:56', '2026-09-01 00:14:14', 'activa'),
(413, 4, '5007be41201068592c2d12290b64112bb2e1f5baca82bf2c385084de12cc25a8', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36', '2026-08-31 08:44:05', '2026-08-31 10:55:20', '2026-09-01 00:44:05', 'activa'),
(414, 6, 'c943212f8876e062ea2ad7d8c4a3cea15fba89cc5b125d8194a18908f13d2e95', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-08-31 11:29:18', '2026-08-31 15:50:56', '2026-09-01 03:29:18', 'activa'),
(415, 6, '52eb54de04a1daf87440e3028e48393c231203f2817fdaba97ed9eb20de44618', '::1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Mobile Safari/537.36', '2026-08-31 12:30:53', '2026-08-31 12:31:58', '2026-09-01 04:30:53', 'cerrada'),
(416, 6, '719fa0a1f07e3455b8f1a94dd299459d7efd8bbc49c54499753410f3457c3e0e', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36 Edg/124.0.0.0', '2026-08-31 12:37:23', '2026-08-31 12:38:30', '2026-09-01 04:37:23', 'activa'),
(417, 6, 'fc54bbae98f1adc3ac1342235660da3d673d8755faae0b7955866835c907729b', '::1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Mobile Safari/537.36', '2026-08-31 13:00:23', '2026-08-31 13:08:38', '2026-09-01 05:00:23', 'activa'),
(418, 6, '514e49c877a456631a74eb4d630ba1883f34ed14482fa3080a8d4220622232d7', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36 Edg/152.0.0.0', '2026-09-01 09:05:40', '2026-09-01 16:57:13', '2026-09-02 01:05:40', 'activa'),
(419, 6, '7ea096438490bb95ab1331ca7ade6ce46b8cfda4e437a1fc76bcf0d4e080ce54', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36 Edg/152.0.0.0', '2026-09-01 10:21:14', '2026-09-01 10:21:40', '2026-09-02 02:21:14', 'activa'),
(420, 6, 'a9967382820ea489ea036fc800a64f2042f87e6975cf73c46f8fa21ed3bd0d4e', '192.168.40.119', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36 Edg/152.0.0.0', '2026-09-01 12:11:55', '2026-09-01 12:15:15', '2026-09-02 04:11:55', 'activa'),
(421, 6, '01c4241c26009ea91517ce903db53e0e9016181060c0c024aac5477d7a0446e2', '::1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Mobile Safari/537.36', '2026-09-01 14:08:02', '2026-09-01 14:08:21', '2026-09-02 06:08:02', 'activa'),
(422, 6, '2e03ec739b0f6380243574db6a8b2de8f9a2c0860988b7af896791486c210bd0', '::1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Mobile Safari/537.36', '2026-09-02 07:37:53', '2026-09-02 07:37:56', '2026-09-02 23:37:53', 'activa'),
(423, 6, '34970b37e62c91755994ff4e4d106378d0879d46dbbd214ef7abb9b5c2e65b76', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36 Edg/152.0.0.0', '2026-09-02 08:01:52', '2026-09-02 15:06:46', '2026-09-03 00:01:52', 'activa'),
(424, 6, '8de25deb3cb4aaf3a940077f2e76723cc37ddfd0cb5e6f59eaa9e8ba81cae625', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36 Edg/152.0.0.0', '2026-09-02 16:39:10', '2026-09-02 16:39:21', '2026-09-03 08:39:10', 'cerrada'),
(425, 6, '91089806279eb23e21020ff185bdbd5606b8ce0e2aee03bff91fca8691402fbb', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36 Edg/152.0.0.0', '2026-09-02 16:39:27', '2026-09-02 16:43:38', '2026-09-03 08:39:27', 'activa'),
(426, 6, '7826bc8ad8e47dc7cf6397e8f8ce788f28e603302c65ffaa9001361b8858b95a', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36 Edg/152.0.0.0', '2026-09-02 16:44:59', '2026-09-02 16:44:59', '2026-09-03 08:44:59', 'activa'),
(427, 6, 'eb42a8bb0d64b7ec0a494415a30577ef68e2e023dc2e880f44ed5bcccf00137b', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36 Edg/152.0.0.0', '2026-09-02 16:45:06', '2026-09-02 16:45:06', '2026-09-03 08:45:06', 'activa'),
(428, 6, '08c82e55b33bf8ccc148bc30c8c7b863e46b1d3aaa1afa0104387fde833f65b3', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36 Edg/152.0.0.0', '2026-09-02 16:45:16', '2026-09-02 16:45:16', '2026-09-03 08:45:16', 'activa'),
(429, 6, '593a8519c39a2d4e1839c22b97a7e2318926918bb4fc9252cff3063d86b0f4ee', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36 Edg/152.0.0.0', '2026-09-02 16:45:46', '2026-09-02 16:45:46', '2026-09-03 08:45:46', 'activa'),
(430, 6, 'b0c7dbd8ce64b84dc0c777df314a3ed3d5fea1922c04f3d70c68fab3f177fa30', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36 Edg/152.0.0.0', '2026-09-02 16:47:13', '2026-09-02 16:47:21', '2026-09-03 08:47:13', 'activa'),
(431, 6, 'de377047e156730d7133dab94fe03578a92af951ca55a1ecf2b8974da3ad6e51', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36 Edg/152.0.0.0', '2026-09-03 11:27:38', '2026-09-03 15:52:43', '2026-09-04 03:27:38', 'activa'),
(432, 6, '356e07685011662e09907ddb97a460ca40b3b99f9a6b48b508d8e908db46d316', '::1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Mobile Safari/537.36', '2026-09-03 15:19:42', '2026-09-03 15:23:12', '2026-09-04 07:19:42', 'activa'),
(433, 6, 'a880278a449182cff2676adb7cc77fdd6d22a9955816bc761d6b52a8cee46c65', '::1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Mobile Safari/537.36', '2026-09-03 15:23:32', '2026-09-03 15:25:23', '2026-09-04 07:23:32', 'activa'),
(434, 4, '1ad5d509cfeab8335369cb8f0425dd01b0b134212d769f8a1c37f08825062b42', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36', '2026-09-03 15:41:28', '2026-09-03 15:46:04', '2026-09-04 07:41:28', 'activa'),
(435, 4, '33d443f3e269a2d653fc39319a3a5ecb83a8e46d029449f1e33de4b99cf4e6cb', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36', '2026-09-03 15:46:22', '2026-09-03 15:52:09', '2026-09-04 07:46:22', 'cerrada'),
(436, 6, '636dac7a3b897a1db3398081a9f3fb0292380839fae026dbdcc524c4d3f8541e', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36 Edg/152.0.0.0', '2026-09-03 15:54:55', '2026-09-03 15:57:55', '2026-09-04 07:54:55', 'activa'),
(437, 6, '24a7041bd458b823bfc4c2fdbb90d27628d9b8c80ee53bfb385637cee36e30a0', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36 Edg/152.0.0.0', '2026-09-04 10:04:02', '2026-09-04 17:19:05', '2026-09-05 02:04:02', 'activa'),
(438, 4, '4f9677cfdd2f0127a4d330c411b36a3d55d56a1316331f8713bb3ba5e3f3ec5c', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36', '2026-09-04 14:38:59', '2026-09-04 14:39:07', '2026-09-05 06:38:59', 'activa'),
(439, 4, 'd10c2a001ba8aaf70db8c99f9428e7cb1fef54f7d116dc163d65b8fac39071be', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36', '2026-09-04 14:41:23', '2026-09-04 14:41:23', '2026-09-05 06:41:23', 'activa'),
(440, 6, 'f8e2d50ffd7bf7736a1e98f64451be058f68db304462e0e454e9e5756835146f', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36 Edg/152.0.0.0', '2026-09-05 07:12:05', '2026-09-05 11:31:24', '2026-09-05 23:12:05', 'activa'),
(441, 4, '2cb8db624f5a4aa74727db47032e54d412c8c5fecfc0470a2aa72833648c166b', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36', '2026-09-05 08:42:04', '2026-09-05 08:45:19', '2026-09-06 00:42:04', 'cerrada'),
(442, 6, 'f7312677e617d7f7198620b4d1cb3b2eaa1ef05aa0d76960d04477fd1144576c', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36 Edg/152.0.0.0', '2026-09-07 08:33:53', '2026-09-07 15:05:06', '2026-09-08 00:33:53', 'activa'),
(443, 6, '28efd749e150caa64a4bbce0a91f8227918f4fe2590aa6b0ecd44955ed484f11', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36 Edg/152.0.0.0', '2026-09-08 08:49:17', '2026-09-08 14:26:06', '2026-09-09 00:49:17', 'activa'),
(444, 4, 'ebea9a8b5fb1c3547f35d4d49f778450d0aaddb8af900445c256ad625f834e81', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36', '2026-09-08 09:14:30', '2026-09-08 09:33:47', '2026-09-09 01:14:30', 'cerrada'),
(445, 4, 'ffa596a06206377d8607599a631bc1ed6f0bfb665df000db9cc30f79c8bbe505', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36', '2026-09-08 10:04:00', '2026-09-08 10:09:52', '2026-09-09 02:04:00', 'cerrada'),
(446, 6, 'fc9508a3b8e9048af54a11788593c76150b257619b1cca85051ea8fb68f6b3ab', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36 Edg/152.0.0.0', '2026-09-08 16:49:10', '2026-09-08 17:52:09', '2026-09-09 08:49:10', 'activa'),
(447, 6, '14d4b31669715d1614a4850adc601b3028fc2f540f0a437e276a6507e740fd91', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36 Edg/152.0.0.0', '2026-09-09 09:18:00', '2026-09-09 17:17:30', '2026-09-10 01:18:00', 'activa'),
(448, 7, '792ec9db59fd31fddc96f884137564c2da7cdbd89ae5b809f493ff4801ba2b05', '192.168.40.118', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36 Edg/152.0.0.0', '2026-09-09 15:42:30', '2026-09-09 15:44:01', '2026-09-10 07:42:30', 'cerrada'),
(449, 7, '4304d30693700cebf839abb7ef3fecddfe5e4175bbde717d5482370467f73ce1', '192.168.40.118', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36 Edg/152.0.0.0', '2026-09-09 15:44:08', '2026-09-09 15:45:37', '2026-09-10 07:44:08', 'activa'),
(450, 7, '789fa5fce853276f22bf1a8313af04f88b03e5018a0b794d4ebe54166f37235a', '192.168.40.118', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36 Edg/152.0.0.0', '2026-09-09 15:57:27', '2026-09-09 15:58:04', '2026-09-10 07:57:27', 'activa'),
(451, 7, '036940cc240e8a0ca3eed623b971cdf2329b4ea96ee9aeb59700e7ade8db338f', '192.168.40.118', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36 Edg/152.0.0.0', '2026-09-09 16:01:04', '2026-09-09 16:03:43', '2026-09-10 08:01:04', 'activa'),
(452, 7, '768cef7e7e1d5d311c88a3101a28840ca190b4e4457895db10c8b397d53c332b', '192.168.40.118', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36 Edg/152.0.0.0', '2026-09-09 16:12:46', '2026-09-09 16:51:39', '2026-09-10 08:12:46', 'activa'),
(453, 4, '22af0b20ac991f9ccc000c80815a5a28d32a252b9f3f455ce02fd3dc706849fe', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36', '2026-09-09 16:32:27', '2026-09-09 16:34:00', '2026-09-10 08:32:27', 'cerrada'),
(454, 6, '92676e60173a96a316b94aa94bf112bf701f6acbf60d7e04f82cdb822b725dcd', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36 Edg/152.0.0.0', '2026-09-09 17:19:48', '2026-09-09 17:21:08', '2026-09-10 09:19:48', 'activa'),
(455, 6, 'e66a116ec3a1ab0320a4955a5f9c67728d555c95e042d6ebcd238f94bfeea130', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36 Edg/152.0.0.0', '2026-09-10 07:31:26', '2026-09-10 15:21:37', '2026-09-10 23:31:26', 'activa'),
(456, 4, 'c8338c5b662d349e334b7a727f17bead209bedbe7d5b0162d607eb019a117687', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36', '2026-09-10 10:13:32', '2026-09-10 10:26:43', '2026-09-11 02:13:32', 'cerrada'),
(457, 4, '6f10c100602e14d050c49893e3da07fe707ca2358c9e857b300f9a7715d11d8b', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36', '2026-09-10 13:41:18', '2026-09-10 16:33:40', '2026-09-11 05:41:18', 'cerrada'),
(458, 6, '324a064acb728854f562ed132d7107093ead2ce005b32be7ce78d72adc1fbd99', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36 Edg/152.0.0.0', '2026-09-10 15:33:22', '2026-09-10 16:37:26', '2026-09-11 07:33:22', 'activa'),
(459, 4, '74fa6b50756fe6f0dc0131a3aaeb44507c68562038346931c4b8adb078040ba5', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36', '2026-09-10 16:33:50', '2026-09-10 16:36:53', '2026-09-11 08:33:50', 'activa'),
(460, 4, 'f27458fc36529336bd295b27300194350e6754bdaa92eeabd93f74040e465d79', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36', '2026-09-10 16:55:17', '2026-09-10 17:13:50', '2026-09-11 08:55:17', 'cerrada'),
(461, 4, 'f3a41e217a7281cf9dddd9d3a91275a9e96ed08f2366328e150e9d6e3a3ab69b', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36', '2026-09-11 08:22:54', '2026-09-11 08:23:54', '2026-09-12 00:22:54', 'cerrada'),
(462, 4, '06f37134811e4884677fd88b6093d6aee2cc08313ea7e3e1f0ee505bf159059a', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36', '2026-09-11 08:28:58', '2026-09-11 08:30:16', '2026-09-12 00:28:58', 'cerrada'),
(463, 7, 'ce1be7f4843b3c7009ccbfdc9978f97e6a668b3d266b6b476404383ba0058def', '192.168.40.115', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-11 10:20:07', '2026-09-11 10:29:16', '2026-09-12 02:20:07', 'activa'),
(464, 6, 'da5bbe2505d3a16b265f18b60086aea9e134b2fd4645d3a77dc3d9b178a731ca', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36 Edg/152.0.0.0', '2026-09-11 10:20:52', '2026-09-11 17:00:59', '2026-09-12 02:20:52', 'activa'),
(465, 6, '09ae83724b53085601bf5e8ccae3d9f8e4cef81fef5890463e3294446b44e77a', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36', '2026-09-11 10:29:29', '2026-09-11 10:29:44', '2026-09-12 02:29:29', 'cerrada'),
(466, 6, 'bb42cf2ef0408ee54782ba3584db54416a3710032f073fd5631e021da7253196', '::1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Mobile Safari/537.36', '2026-09-11 10:30:54', '2026-09-11 12:04:48', '2026-09-12 02:30:54', 'activa'),
(467, 6, '4c46b8139876de7e07ba7d3707d2d691b1489b9f5f8b141f576518567b302177', '::1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Mobile Safari/537.36', '2026-09-11 12:04:56', '2026-09-11 12:05:27', '2026-09-12 04:04:56', 'activa'),
(468, 6, 'f99c03984232fbebf43d00c11ca04d35192cd0fabbbcc21150c8a91fdaf88c6f', '::1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Mobile Safari/537.36', '2026-09-11 12:32:55', '2026-09-11 12:35:46', '2026-09-12 04:32:55', 'activa'),
(469, 6, 'b3cc32eebf6379d842565285c00777dc23ea53226e176f1b92b48ac9d22a6fae', '::1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Mobile Safari/537.36', '2026-09-11 12:36:09', '2026-09-11 12:36:34', '2026-09-12 04:36:09', 'activa'),
(470, 6, 'e355f11c619661a4fedddee6492ab9f34ee01460e854fa3061b488570775f5e7', '::1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Mobile Safari/537.36', '2026-09-11 12:37:39', '2026-09-11 12:37:44', '2026-09-12 04:37:39', 'activa'),
(471, 7, '3a20094c3f2c6a18f6b17de6b79ad98d0017e19ccbfdcd9aaba09b6c5dce841b', '::1', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Mobile Safari/537.36', '2026-09-11 12:38:40', '2026-09-11 12:40:30', '2026-09-12 04:38:40', 'activa'),
(472, 4, 'b944e22b9d884187d59480b1d95b6873df50509b948e1fcf393c571bbf6e6b45', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-11 13:41:42', '2026-09-11 13:42:43', '2026-09-12 05:41:42', 'cerrada'),
(473, 4, '2ddacc3a4820a8f836c170177f8a2a6cdf8bde3247969102e18dcd1a713e6398', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-11 13:48:39', '2026-09-11 13:54:02', '2026-09-12 05:48:39', 'cerrada'),
(474, 4, '6187a80b909237726e896267dc2e1c2d1c40019d36c21be5c9e2536a00013a07', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-11 13:54:58', '2026-09-11 13:55:03', '2026-09-12 05:54:58', 'cerrada'),
(475, 7, '1b30910b8bef925a74d4c7c9ae9095f6038d6195784f856de3057e95962d8a7a', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36 Edg/152.0.0.0', '2026-09-11 14:07:25', '2026-09-11 14:12:06', '2026-09-12 06:07:25', 'activa'),
(476, 7, '2e3a7d3510730bf9e1bbe16046b7b3f61af9d16cab925fd5a20f2eb43b180692', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36 Edg/152.0.0.0', '2026-09-11 14:21:36', '2026-09-11 14:24:21', '2026-09-12 06:21:36', 'cerrada'),
(477, 6, 'cfa5658fcb642b069f78bf55426dfe1ca304d465ace0a052754d6d76b70cfd89', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-12 08:21:42', '2026-09-12 11:52:53', '2026-09-13 00:21:42', 'activa'),
(478, 6, 'b083e6c783a7b9ad70d06dbdbba8511d3af37cd1414b4f086a38321aeb474c8a', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-14 08:48:21', '2026-09-14 16:31:48', '2026-09-15 00:48:21', 'activa'),
(479, 4, 'c3d2d4024b868e14961d5ea6c8e13ccf42f2c024b8772397bb481eeb150dc55f', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-16 07:53:43', '2026-09-16 07:54:05', '2026-09-16 23:53:43', 'activa'),
(480, 6, '2d8c311b49755003b12f73b3bf46b1c11068fcb9aa05687ac8b6a89bc7a1e970', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-16 08:19:22', '2026-09-16 14:15:44', '2026-09-17 00:19:22', 'activa'),
(481, 6, 'd0862e7abfd7bfbdf2832eb0332b91067f419f841d494919846ba78fbd830e6a', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-16 16:46:02', '2026-09-16 17:17:54', '2026-09-17 08:46:02', 'activa'),
(482, 6, 'e3bb1423dd8b69fceead61f895c8b90bce69840e2afc29353d3c167520fbbf1f', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-17 07:42:36', '2026-09-17 13:14:13', '2026-09-17 23:42:36', 'activa'),
(483, 6, '0ab0d6130d6cd3665375186c9a4da03c666c4ccd39337e0d5ae51b1f8ad16297', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-18 11:29:40', '2026-09-18 16:41:42', '2026-09-19 03:29:40', 'activa'),
(484, 6, '6fbec92ba1ef713b5a1dfde8bd3f6a5c1044f665d5917c02b5933c1e7bf31ed0', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-19 07:29:26', '2026-09-19 08:09:43', '2026-09-19 23:29:26', 'cerrada'),
(485, 6, 'ccd059861337a80eb3a12690efb4a6e99c2c0a774435cd4199232677a869f15b', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-19 08:09:49', '2026-09-19 10:56:53', '2026-09-20 00:09:49', 'activa'),
(486, 6, '52dd37ba57f3b933c6fa070794f429ab1f0f54b3f40c4eae6181c1e41193ff5a', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-21 09:25:44', '2026-09-21 17:23:54', '2026-09-22 01:25:44', 'activa'),
(487, 4, 'fb725817a87ff1d535cdf50f2fbda243d8d60dfaff295295acc0bccd90505e86', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-21 11:35:28', '2026-09-21 11:43:55', '2026-09-22 03:35:28', 'cerrada'),
(488, 4, '4ca0a416ad2bc439e76bb514263571fde9316d027dbd47a2ab654da74e8a714e', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-21 11:44:04', '2026-09-21 11:56:42', '2026-09-22 03:44:04', 'cerrada'),
(489, 4, 'ecc4effaa2f4ec694a5aa7531820ea712eea653c5bd87ac0f39f3db6b4d9ed0d', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-21 13:19:27', '2026-09-21 14:37:27', '2026-09-22 05:19:27', 'activa'),
(490, 6, '51a2bbcf7a2c6356cd37ce14ac66be98edfe0b86334c8c5fdb4cbd14e68a54be', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-21 17:30:02', '2026-09-21 17:44:54', '2026-09-22 09:30:02', 'activa'),
(491, 6, 'f54ca7312443a970b449241616ebb76ac8c5e34a67ef8dba437e08fd58b26fff', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-22 08:40:44', '2026-09-22 16:19:52', '2026-09-23 00:40:44', 'activa'),
(492, 4, '9fd08b01ed2b782cc29f52b521292406cfa93296759bd9a212f91abc2f657eac', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-22 11:07:10', '2026-09-22 11:09:05', '2026-09-23 03:07:10', 'activa'),
(493, 6, 'a60845719759a23345148e762bfb0f902a2440ab3d8ef0793475937edcee8545', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-22 16:49:02', '2026-09-22 17:32:45', '2026-09-23 08:49:02', 'activa'),
(494, 6, '86e7b2c3e30a6a14d004e4fa49f8a860afacd1f589419caff6845009a23e03d2', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 08:09:49', '2026-09-23 16:09:02', '2026-09-24 00:09:49', 'activa'),
(495, 8, 'a1e5476747abcf4e7df193db168e616c015487f9c5f32b481bfe55c187e0dd2c', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 10:01:45', '2026-09-23 10:05:07', '2026-09-24 02:01:45', 'cerrada'),
(496, 8, '7c3ca9d9b81b1fea0770c5dfd5c33e71dac011bdf2264fe9d6e378b2d2713cb9', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 10:05:19', '2026-09-23 10:10:56', '2026-09-24 02:05:19', 'cerrada'),
(497, 4, '9359e1194da3a7e5f94cd0edaa89834e69a44395700c26a49fc54d217d39082f', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-23 10:11:24', '2026-09-23 13:26:30', '2026-09-24 02:11:24', 'cerrada'),
(498, 8, '376405f7ed9ffd8bcbe258c2158d3e28f6373a8e3f25b8f375c8fbb322d33714', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-23 13:26:50', '2026-09-23 16:22:20', '2026-09-24 05:26:50', 'activa'),
(499, 6, '5d912f86bc563810f35f0c00d10b19c332f19d943ed4ae3b43f9278bdcf398fc', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-23 16:10:29', '2026-09-23 16:27:10', '2026-09-24 08:10:29', 'activa'),
(500, 8, 'c46da23cc37491d103e1e24444fd453cd5f4415c40828f0fa70df42ef8f9c14d', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-23 16:22:41', '2026-09-23 17:08:22', '2026-09-24 08:22:41', 'activa'),
(501, 8, 'a99f6aed1be76c47c05ba823ddf9938f7706142868e2245091219f67aa34b216', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-24 08:11:09', '2026-09-24 09:14:57', '2026-09-25 00:11:09', 'activa'),
(502, 6, 'c152f0ba63c08ea15647dd99da51d1908a2cdbe513d6c289ad045e109a4c9e08', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-24 08:16:45', '2026-09-24 15:52:17', '2026-09-25 00:16:45', 'activa'),
(503, 8, '65921978e2729e52f0239350d1da4e6634d30fabde1126c711893271c2e94122', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-24 09:29:20', '2026-09-24 15:37:52', '2026-09-25 01:29:20', 'activa'),
(504, 6, '0f602667303e97f391564c5ce1ea16329a66db897635cc5f4eee53263f6c517b', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-25 08:54:36', '2026-09-25 14:24:53', '2026-09-26 00:54:36', 'cerrada'),
(505, 8, 'e99497aa10c18b30ae899df868bf2c965052107465e119d07ca46911334d9956', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-25 08:59:12', '2026-09-25 14:30:22', '2026-09-26 00:59:12', 'activa'),
(506, 6, '4bc46637b47979a310b0adf98862268d646bb20ef5c03b81bcbe9badc1116e47', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-25 14:25:00', '2026-09-25 14:54:15', '2026-09-26 06:25:00', 'activa'),
(507, 8, 'a273d2afd4ec83e5bfdae4813edf16774872ff0b09ae2b3d031cb35fef9b1aa4', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-25 14:52:24', '2026-09-25 15:25:53', '2026-09-26 06:52:24', 'activa'),
(508, 6, '3dcc2cee54d515eb3ff4f5aaad46b170df9568c7d41a19c600be93b2ba03140b', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-25 14:54:27', '2026-09-25 18:09:06', '2026-09-26 06:54:27', 'activa'),
(509, 8, '1767fcd3063553bb13dda00b27e2e3f8173add0c506afde1a01bbe2d9a867b26', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-25 15:26:10', '2026-09-25 16:19:01', '2026-09-26 07:26:10', 'activa'),
(510, 8, '7a5b6e132d9cc2758345603edb1a1fa8a41280d1c93164532104c8b6e0ff0a35', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-26 08:09:53', '2026-09-26 11:44:28', '2026-09-27 00:09:53', 'activa'),
(511, 6, 'd98c28e115334411ec3746d4e508f87a3609dc0dc5ea9364edfa45d4a14e99a7', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 Edg/153.0.0.0', '2026-09-26 09:28:00', '2026-09-26 11:04:03', '2026-09-27 01:28:00', 'activa'),
(512, 6, '53c2f8a6bc938eb64705487fdb91d0737da2c4b2af31d78284d2bbf48fd44f03', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-09-28 07:29:16', '2026-09-28 14:02:26', '2026-09-28 23:29:16', 'activa'),
(513, 8, '937f383d42a6d5c4148dd3ed15a2b3296c99be7c3e1090b8e19ae5a612010149', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-28 07:59:40', '2026-09-28 13:16:42', '2026-09-28 23:59:40', 'cerrada'),
(514, 7, '6e6a24e4a86872883667343030184fb10ef560978844cfddf6f6154b516626e7', '192.168.40.152', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-28 09:56:48', '2026-09-28 11:45:43', '2026-09-29 01:56:48', 'activa'),
(515, 8, '726f3b886fd2658c36c9d41a9b28059cf7fb4afed5c0c6639bd70955cb02b7da', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-28 13:16:49', '2026-09-28 13:20:00', '2026-09-29 05:16:49', 'activa');
INSERT INTO `sesiones_admin` (`id_sesion`, `usuario_id`, `token`, `ip_address`, `user_agent`, `fecha_creacion`, `fecha_ultimo_acceso`, `fecha_expiracion`, `estado`) VALUES
(516, 8, 'f2591859b180073b717da92d8a8100ba7ea64182383c109ef0de959fb8d509ac', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-09-28 13:20:42', '2026-09-28 13:20:57', '2026-09-29 05:20:42', 'activa'),
(517, 8, '231c4bb98cffb18395e13aa98bc17d8a1c571a389fe778c60d7d74544e925a0c', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-28 13:29:28', '2026-09-28 16:10:11', '2026-09-29 05:29:28', 'activa'),
(518, 6, '50d77c780382afe9196c3d442e078b47a9072c7b10e2dfeb6d251d92dee7a413', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-09-28 13:59:22', '2026-09-28 13:59:38', '2026-09-29 05:59:22', 'cerrada'),
(519, 8, '5e94c96467f80b243ec70e0fc43f31dca39c1bef9d8c24befb61e4eb866a059c', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-09-28 13:59:44', '2026-09-28 14:26:51', '2026-09-29 05:59:44', 'activa'),
(520, 6, '629693c58c4369630a3323163a90ecb42ab662134a4c961702fba5ac50f5c2ea', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-09-28 15:28:25', '2026-09-28 17:37:38', '2026-09-29 07:28:25', 'activa'),
(521, 8, '06d281a8e8ee4e8112bfe9575d46f50e6681c06a8bbf81dc77885bf3db697381', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-29 09:11:16', '2026-09-29 11:21:45', '2026-09-30 01:11:16', 'cerrada'),
(522, 6, 'a07f96dbc7319a717576dbad8e15986594d947c58f4285ae39f8398e98312ec5', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-09-29 09:15:30', '2026-09-29 17:14:27', '2026-09-30 01:15:30', 'activa'),
(523, 7, 'b32b4faafde59faa94e5d238f8697851778e692fb86252426a56dbbcd531c179', '192.168.40.152', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-29 09:20:15', '2026-09-29 15:52:33', '2026-09-30 01:20:15', 'activa'),
(524, 8, 'e1b821f1b978af4e9040cfd148dcb5b2aebdf9085178f50b7b13edb01a6179ed', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-29 11:21:50', '2026-09-29 11:23:49', '2026-09-30 03:21:50', 'activa'),
(525, 8, 'd42c1168208f9d7dc179d352ed0a7c122d50c9cf10774ae79e7d3e7247d498b2', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-29 11:25:14', '2026-09-29 13:39:37', '2026-09-30 03:25:14', 'activa'),
(526, 8, 'ddbea2a9e088c1eabc4fe59fa65e3b7485c1e303bd39456f1feb6009f84e683b', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-29 13:39:45', '2026-09-29 14:45:10', '2026-09-30 05:39:45', 'activa'),
(527, 8, '2e2cfb56c535eb7badecacd747e6757bbebccb140d06daec3e8d909115c31308', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-29 14:55:47', '2026-09-29 16:47:09', '2026-09-30 06:55:47', 'activa'),
(528, 6, 'e6e8bcf20a032cae0f28c71856c85d1b3ca70d536ef7bf46cb60dc8e96ec7816', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-09-30 07:31:01', '2026-09-30 14:17:15', '2026-09-30 23:31:01', 'activa'),
(529, 8, 'c3af3ad6beb7c15ebb586dd4910bf6d38688620dc99880e5d51d7831e39a25f7', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-30 08:03:05', '2026-09-30 10:11:09', '2026-10-01 00:03:05', 'activa'),
(530, 8, '2483a4f65df604426a4653d9c16500af79949609a257fa3612324d0cb2dba7a2', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-09-30 10:11:19', '2026-09-30 15:25:24', '2026-10-01 02:11:19', 'activa'),
(531, 7, 'e191793a6d1009d38ac1d89357d3442e864e5486f871674cb2bcde71c4970574', '192.168.40.152', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36', '2026-09-30 13:10:50', '2026-09-30 14:24:48', '2026-10-01 05:10:50', 'activa'),
(532, 6, 'b3830be514623ad6bd800a5cb459e4dbe146bcb4282c34578e8edbd35468ea6e', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-01 07:37:46', '2026-10-01 14:33:48', '2026-10-01 23:37:46', 'activa'),
(533, 8, 'c7b499d88686610688d4ad6c3f638183be19ab0529c703236dfa7c17e81d588c', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-01 08:02:16', '2026-10-01 09:09:01', '2026-10-02 00:02:16', 'activa'),
(534, 8, '32db2cb9dac797fae8820ca8ee09f3fb84b11ffa5d02c5b01db4b865ca4db02e', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-01 11:13:36', '2026-10-01 13:46:54', '2026-10-02 03:13:36', 'activa'),
(535, 7, '99f0d870002f7df04df141cdba9bd6651d2dfd7fd847ce55d20b226b8f0b9ea8', '192.168.40.152', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-01 15:16:53', '2026-10-01 15:17:08', '2026-10-02 07:16:53', 'activa'),
(536, 6, 'bb0b871c5e9995367bf4b1f14fbc5ecf5580b70b1e52fe586ef1b1bb09e7836f', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-01 15:40:13', '2026-10-01 18:08:13', '2026-10-02 07:40:13', 'activa'),
(537, 6, '080884a2b658edfecdad6c43dc77bf1f00f72f579ce1600c73c9b48eb286e305', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-02 07:19:53', '2026-10-02 14:33:58', '2026-10-02 23:19:53', 'activa'),
(538, 8, 'ac89df93cd50a93e70f1a0272c61ab623696c0e35c0b85c63ad0abb8146c3b85', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-02 08:26:44', '2026-10-02 16:19:07', '2026-10-03 00:26:44', 'activa'),
(539, 7, 'f8a7f1b24b674d9f626eebdce4686d0353dd7fced39528d9b704b374578f6257', '192.168.40.152', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-02 08:29:55', '2026-10-02 13:51:11', '2026-10-03 00:29:55', 'activa'),
(540, 6, '23b01a5a8d1d7743b7a7f36c9f0e7eb99699bc003f8a880a9f062f750ee98b05', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-02 15:29:17', '2026-10-02 17:37:26', '2026-10-03 07:29:17', 'activa'),
(541, 8, 'a0354c89492eb7d164ec412965f9ab1315d0e6aa1801a5ae314492a4078c5bf2', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-02 16:45:07', '2026-10-02 16:45:43', '2026-10-03 08:45:07', 'activa'),
(542, 6, 'be5ab826b144038d807982d060747d01462e67fd484da2e8b9c6b0861706c015', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-03 07:23:13', '2026-10-03 11:38:12', '2026-10-03 23:23:13', 'activa'),
(543, 8, '9aaacdb89b3c70926f8d9116f9f9d2f0d04a4482f97601f953582e6fad5bc677', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-03 08:02:56', '2026-10-03 11:41:35', '2026-10-04 00:02:56', 'activa'),
(544, 7, '7da24b98910f9ce554a96dafbe64759e104729b7fa9208bc725b04b1848ecb3e', '192.168.40.152', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-03 09:32:59', '2026-10-03 09:35:37', '2026-10-04 01:32:59', 'activa'),
(545, 6, 'ec64cc7fff976a40d569c72d5341c87aa8fb53d03bf364366e1719c251b43cee', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-05 07:05:48', '2026-10-05 07:12:05', '2026-10-05 23:05:48', 'activa'),
(546, 6, '4fedd83a50f2cf44a9637f706d3cce4538c989304b5724a61be9de5b4c2dcd8c', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-05 07:55:53', '2026-10-05 14:30:51', '2026-10-05 23:55:53', 'activa'),
(547, 8, '058ea7720c430b7da302ceb291fb74fc88f07f610a2570ea34028ca214d8708d', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-05 08:32:27', '2026-10-05 14:46:18', '2026-10-06 00:32:27', 'activa'),
(548, 7, '4a9038d235396381a6c7a55fd3f98bd47912b458fd9aaa8a1427db0d17f81bdd', '192.168.40.133', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-05 10:33:51', '2026-10-05 17:13:28', '2026-10-06 02:33:51', 'activa'),
(549, 8, 'cc15ed25ebb4759623676ebb98844034643873c26657ba83260f91d14e6aa792', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-05 14:46:32', '2026-10-05 14:46:41', '2026-10-06 06:46:32', 'activa'),
(550, 8, 'fbed32028003c36e5f99eb97f23066be95f4104c4517022ea0a24e86c041dba7', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-05 14:47:07', '2026-10-05 16:02:19', '2026-10-06 06:47:07', 'activa'),
(551, 6, 'a39d122aadbfc79e491c7d753d8219d977d87e2516afe3887ad3a180cbb5cc02', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-05 15:58:19', '2026-10-05 17:13:26', '2026-10-06 07:58:19', 'activa'),
(552, 8, '90fa39a4616f657ab1254d9d55b6336eb73bb3742e6e2e81ce32aa5c79cfcf90', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-05 16:10:52', '2026-10-05 17:04:48', '2026-10-06 08:10:52', 'cerrada'),
(553, 6, 'd02b3a034d10763754d223ffac0063c36797bb14177a7a97ea18c7689bf28c62', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-06 07:31:34', '2026-10-06 13:21:09', '2026-10-06 23:31:34', 'activa'),
(554, 8, '09fc9354105493c49a5757c6b67db041f29ee5195ae95b147eaa30913baabef9', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-06 08:10:14', '2026-10-06 11:52:18', '2026-10-07 00:10:14', 'activa'),
(555, 8, '55f7b7051c6dafa4c23c761a164729766d75fbed4acd322c5213f7a4f7a57b97', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-06 11:52:24', '2026-10-06 17:07:59', '2026-10-07 03:52:24', 'cerrada'),
(556, 6, '80527c01889664b64ed75c5a4e3534469d0db737c8825a7c516390523650ef97', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-06 17:52:25', '2026-10-06 17:53:09', '2026-10-07 09:52:25', 'activa'),
(557, 6, '3cd7f5b9345f8adaeb3485ac82d1b89df2de4d11cffd4e3567515a0a3495ff59', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-07 07:23:21', '2026-10-07 07:29:43', '2026-10-07 23:23:21', 'cerrada'),
(558, 6, '29d3355264f9bc646c6c81187b1a4fb5ce9eb2ef2be6d113833a6cfa18be4b8e', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36 Edg/154.0.0.0', '2026-10-07 07:30:51', '2026-10-07 11:35:33', '2026-10-07 23:30:51', 'activa'),
(559, 8, '4e3898ff21ef74a3d25d55598e9e0ba9b1867dfddaba958e5a8ffa0a74eb0130', '192.168.40.104', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-07 08:09:32', '2026-10-07 10:37:11', '2026-10-08 00:09:32', 'activa'),
(560, 8, '2e5b4b859f24a18984a4008f2a4dba2e8696cc83c864a884d045ef93e31d34f2', '10.29.179.82', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-07 10:40:32', '2026-10-07 11:38:56', '2026-10-08 02:40:32', 'activa'),
(561, 8, '591258cd588cf2bde238565b07235cf12f5d4640e48a95f8c25a8d5e7c054a2a', '192.168.40.135', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-12 08:21:50', '2026-10-12 10:41:56', '2026-10-13 00:21:50', 'activa'),
(562, 6, '27345906576d8b7138c81031be4bb584e9fbc8e091e4e1c9658b76cb8a587928', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-12 09:56:07', '2026-10-12 16:29:54', '2026-10-13 01:56:07', 'activa'),
(563, 8, 'ec22c535df4705044fb55879bd10b0117e01f5cfc3836bfd562d625c85c2f652', '10.206.17.82', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-12 11:04:39', '2026-10-12 13:59:47', '2026-10-13 03:04:39', 'activa'),
(564, 8, '4da246e0a24f5592031fb79f3b86769a0631dbdc6d05df589d1b69cfe5cace93', '192.168.40.135', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36', '2026-10-12 14:00:08', '2026-10-12 16:46:55', '2026-10-13 06:00:08', 'activa'),
(565, 6, '6c804426cf1c52d08e831bea329102497e5ac7fdac88ddd3a92e22a33ffabd2f', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-13 07:55:30', '2026-10-13 15:09:06', '2026-10-13 23:55:30', 'activa'),
(566, 8, '29a69c61ee68f7b236c98ae26d87dc957167cfcd75d0e407d83a6362fa19335d', '192.168.40.135', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-13 08:32:27', '2026-10-13 16:26:39', '2026-10-14 00:32:27', 'activa'),
(567, 6, '38420ea766fcb5e682ac6922b3b70508da2a3148d385965c7527231eeef01d82', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-13 16:01:09', '2026-10-13 17:07:51', '2026-10-14 08:01:09', 'cerrada'),
(568, 6, '133b40f697fb8878243fe680877b64d65110a08f530fc049b4421926967f0c2f', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-13 17:10:22', '2026-10-13 17:10:22', '2026-10-14 09:10:22', 'activa'),
(569, 6, '48ee587554346120b3a0da349ecea3cd2e312f7f81dd7bc9da5476bab6d99ea1', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-13 17:26:36', '2026-10-13 17:34:10', '2026-10-14 09:26:36', 'activa'),
(570, 6, '465978d737a93d31a5578418faaa4fbfd4deaec840f14e19994b004a3e9f03a4', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-14 08:06:10', '2026-10-14 15:56:12', '2026-10-15 00:06:10', 'activa'),
(571, 8, 'a8753ec9f4b42913e1aba0679044f1bd4c366641f2d8f5e77234f32d49aa566c', '192.168.40.135', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-14 08:18:26', '2026-10-14 08:21:03', '2026-10-15 00:18:26', 'activa'),
(572, 8, '73c5ef6c10ea3d94ac3b8a8d83a4eb8c58b348dfcdf3fed3501af37909455b4b', '192.168.40.135', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-14 08:22:12', '2026-10-14 16:16:37', '2026-10-15 00:22:12', 'activa'),
(573, 8, '2730cffcc5b4346883da84dbd68f228339bce5078a23e2d6664511e0c4afbf4c', '192.168.40.135', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-14 16:16:48', '2026-10-14 16:59:02', '2026-10-15 08:16:48', 'activa'),
(574, 6, '3723ca529d208fb29e6d3f77b5acc7df02fb71c3da3f848b930976b889d712af', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-14 17:03:30', '2026-10-14 17:35:41', '2026-10-15 09:03:30', 'activa'),
(575, 6, '8b82340852f0a12ad90742a9769c22a8730333dedf7a57c3cc3b13f0f273f2ff', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-15 07:26:33', '2026-10-15 14:42:22', '2026-10-15 23:26:33', 'activa'),
(576, 8, 'f6d4f692a4c2ffa9c3b3ca05f52db955419ba56d5de3197194d61434a77a9331', '192.168.40.135', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-15 08:37:30', '2026-10-15 09:06:30', '2026-10-16 00:37:30', 'activa'),
(577, 8, '14e0f0fe6d3e8ba453278ac9f77e0e3c1b0ea13b06ed235c17239281ea24fb3e', '192.168.40.135', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-15 09:49:46', '2026-10-15 16:25:49', '2026-10-16 01:49:46', 'activa'),
(578, 6, '98edb7c9335d2774d3ec31b63ef0d3ec08902979a56967ed535d09d5d439f281', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-15 15:48:58', '2026-10-15 17:37:05', '2026-10-16 07:48:58', 'activa'),
(579, 8, '1a1ea7d588bb6d60fefbfdb0d857118f02a9a4b1f63ff1d0a247294d36a45e27', '192.168.40.135', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-15 16:26:14', '2026-10-15 17:00:36', '2026-10-16 08:26:14', 'activa'),
(580, 6, '9ec6b0a95589c88cc36a9454c6c9c769d3f80b81ff05edf2ff4fc5e87537fcfe', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-16 07:47:15', '2026-10-16 13:17:40', '2026-10-16 23:47:15', 'cerrada'),
(581, 8, '1ef5df48d0a85510d5af9e90e262a84bd768fe73e554d83bb56c0e38ef65ca15', '192.168.40.135', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-16 08:11:24', '2026-10-16 11:40:35', '2026-10-17 00:11:24', 'activa'),
(582, 7, 'c6b783f22477aa3ddc54860709759b5ab083c675631161c53299858681f962d2', '192.168.40.152', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-16 10:32:06', '2026-10-16 11:15:00', '2026-10-17 02:32:06', 'activa'),
(583, 6, '1ff40d27321789f391300bbc32de9ad40c1c7c95ec0f69286900496f662d3f7e', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-16 13:17:48', '2026-10-16 15:53:15', '2026-10-17 05:17:48', 'activa'),
(584, 8, 'dce7306fc539a22f04b465c4e743c12e53b4bca7b2d00a4053714ff2de732ba3', '192.168.40.135', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-16 16:19:06', '2026-10-16 16:20:09', '2026-10-17 08:19:06', 'activa'),
(585, 6, 'f0faab723984a3c29b024ad28e19cc4dbd4ae7ad17b9025ce8a1cd1cbc257431', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-17 07:55:25', '2026-10-17 10:09:38', '2026-10-17 23:55:25', 'activa'),
(586, 8, '52744849adfaddc7635574bc432209956e86c34cff9b8810c13545c53e6bc5d8', '192.168.40.135', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-17 07:56:35', '2026-10-17 11:05:56', '2026-10-17 23:56:35', 'activa'),
(587, 8, 'e86ba53428233f90732b519e2ed0f50be333d7d9e4663270f89fb194c1d2ab06', '192.168.40.135', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-17 11:06:13', '2026-10-17 11:58:10', '2026-10-18 03:06:13', 'activa'),
(588, 7, 'fff999d0a576c31024a01e2b1bd6eddb99338d5265478fee36af5ec89eda457e', '192.168.40.152', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-17 11:23:22', '2026-10-17 11:29:47', '2026-10-18 03:23:22', 'activa'),
(589, 6, 'd0a98e2c9490af0d57200cc64490581362dbda57aaab9b68ec465149d0f27612', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-19 07:43:29', '2026-10-19 12:50:11', '2026-10-19 23:43:29', 'activa'),
(590, 8, '64f12c4c429f302b6480b80b51bad6edf6fa7e09e5e465923b835ecfff541811', '192.168.40.135', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-19 07:59:49', '2026-10-19 15:37:53', '2026-10-19 23:59:49', 'activa'),
(591, 6, '3238097605019cf77b3c3672c88098c8cca3191f92362c823fdedc0cd5f0628b', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-19 12:50:19', '2026-10-19 16:07:11', '2026-10-20 04:50:19', 'cerrada'),
(592, 8, '770ca6a010ec6a34cb4ac3dc64a3fc2bdd5494a1a754dfc3ec63ab55b597986f', '192.168.40.135', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-19 15:38:45', '2026-10-19 15:50:29', '2026-10-20 07:38:45', 'activa'),
(593, 8, '67943bf0d6e8ec83c82db1223e3a98169aa971bf4dbd4d5f6f506b908f0edbcd', '192.168.40.135', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-19 15:56:20', '2026-10-19 15:56:22', '2026-10-20 07:56:20', 'cerrada'),
(594, 6, '1fa56d1ffd8fb92d3aa8f3463907b48a8db125eab68e8e0dbb46b650b1370f55', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-19 16:07:17', '2026-10-19 17:12:03', '2026-10-20 08:07:17', 'activa'),
(595, 8, '2f47ea9756047364d39806647ef7a9f3a3775c9f7f50520da681c5f6c8d9948d', '192.168.40.135', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-19 16:16:30', '2026-10-19 16:24:12', '2026-10-20 08:16:30', 'activa'),
(596, 8, '5b05b83978461b1b884ec66ed59d17c887eb4943d2a85e38c1eecec4277a7e00', '192.168.40.135', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-19 16:24:28', '2026-10-19 16:24:52', '2026-10-20 08:24:28', 'activa'),
(597, 8, '10800b315862f41744360be0e0da95f742b28ed896244257d26150ba67b07c74', '192.168.40.135', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-19 16:25:13', '2026-10-19 17:00:04', '2026-10-20 08:25:13', 'cerrada'),
(598, 8, '4929b2ffd31f34ee77c7801336fc7937cd97580242a402b986dd9b68bab35154', '192.168.40.135', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-19 17:01:28', '2026-10-19 17:01:53', '2026-10-20 09:01:28', 'activa'),
(599, 6, 'c14c045a6b90c233a65cebfc8c949af3849d0f999d76c08fe0ab700c57db645a', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-20 07:33:29', '2026-10-20 14:28:17', '2026-10-20 23:33:29', 'activa'),
(600, 8, '18e447a1e2c9c7b98aad0e2d713cf9f12c2d19bfc18df10d83f9ee0fa3fd9ac0', '192.168.40.135', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-20 08:02:45', '2026-10-20 08:35:11', '2026-10-21 00:02:45', 'activa'),
(601, 8, 'e995da48a53ac8a5fdfbed0037f1ec9e61f476152b64c73869286959db9bbdb7', '192.168.40.135', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-20 08:35:19', '2026-10-20 08:35:56', '2026-10-21 00:35:19', 'activa'),
(602, 8, '198a703ac2fd0183b9eb6c4d4e4efdd1a70d692503cc3f6b6d00705bc7f58248', '192.168.40.135', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-20 08:36:17', '2026-10-20 09:22:51', '2026-10-21 00:36:17', 'activa'),
(603, 8, 'ea87802de398d44221a3c0ee9a54d07cbfd76073ee5e02e1e91b3e70b56f77be', '192.168.40.135', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-20 09:25:40', '2026-10-20 15:16:30', '2026-10-21 01:25:40', 'activa'),
(604, 6, '25519a3bc1acc4597af241ebf1754e67373ba6bb789d818644c6f4147462034a', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-20 15:33:46', '2026-10-20 16:34:15', '2026-10-21 07:33:46', 'activa'),
(605, 6, '514d0be76268d8c4966ab9792f7c6ea7d03ded267800e1f5174989f71e05f932', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-21 07:27:25', '2026-10-21 13:59:15', '2026-10-21 23:27:25', 'activa'),
(606, 8, '281502dcebe2e247c9bff12622d04f1a9024de28a04718cc9158924634ccb608', '192.168.40.135', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36', '2026-10-21 08:03:32', '2026-10-21 15:27:03', '2026-10-22 00:03:32', 'activa'),
(607, 6, 'd68cfbdcc70bd72a87f2511d9e3b64fae1e697361f4bfa90b20dd64b630b437a', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-21 18:27:58', '2026-10-21 18:34:47', '2026-10-22 10:27:58', 'cerrada'),
(608, 9, '42ce8ade24397f38f16deb8f5a73628b000f84b32e9b172bec46e0d47e1feec6', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-21 18:34:53', '2026-10-21 18:35:20', '2026-10-22 10:34:53', 'cerrada'),
(609, 9, 'f232fe02c20332cd75e3d277aea0495f80bdd7ca5f7a1574e22bb587b209ca57', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-21 18:35:26', '2026-10-21 18:35:59', '2026-10-22 10:35:26', 'cerrada'),
(610, 6, '9fa75aa4903458eacd640ec2ddc483dc16e145430670dce1d88fca1e9513a1ba', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-21 18:36:04', '2026-10-21 18:36:38', '2026-10-22 10:36:04', 'cerrada'),
(611, 9, '519446b6b69924357f80e62fd3e4b8883e5396a0df6ca3284ee8fb590186a2e8', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-21 18:36:45', '2026-10-21 18:36:48', '2026-10-22 10:36:45', 'activa'),
(612, 8, 'd44f0e79144df3b462f11d61f4d8178d6ec067824f88d4f00a9473ddc21fd312', '192.168.40.135', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36', '2026-10-22 08:15:09', '2026-10-22 09:34:18', '2026-10-23 00:15:09', 'activa'),
(613, 6, '249b9b60c38c5820a21484c8b39126517a98328f4f85b20308175f27e4a690cf', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-22 08:33:55', '2026-10-22 13:51:51', '2026-10-23 00:33:55', 'activa'),
(614, 8, '51cfd85aa3cd2fd724f757a73983460adbc2ad92a98ba9c541b759662fe90101', '192.168.40.135', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36', '2026-10-22 09:34:25', '2026-10-22 09:41:39', '2026-10-23 01:34:25', 'activa'),
(615, 8, '7ac2e683946d8dbdc5c44a82d057fda11b7deb0ef293f419e908cba8c599bddd', '192.168.40.135', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36', '2026-10-22 09:42:15', '2026-10-22 14:12:05', '2026-10-23 01:42:15', 'activa'),
(616, 8, 'f594c4c811a54765dcc63cb8086a350a34e2083af46abbd0a3875739c82590fe', '192.168.40.135', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36', '2026-10-22 14:42:23', '2026-10-22 16:39:13', '2026-10-23 06:42:23', 'activa'),
(617, 6, '5f39a6cf0da7cc68725faac0e595c79caaf12c0aebb48f46b529d764ddd30ecb', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-23 08:00:04', '2026-10-23 13:22:26', '2026-10-24 00:00:04', 'cerrada'),
(618, 8, 'd980f9e79065547a3932847c31cd7f3b852efb382cfcb63f7d411e90f9f5d2b4', '192.168.40.135', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36', '2026-10-23 13:05:52', '2026-10-23 16:52:06', '2026-10-24 05:05:52', 'activa'),
(619, 9, 'b61236bc96243e9ffd5506525ffbdf1150698de825b49ca0c568a2fe82c5985a', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-23 13:22:32', '2026-10-23 13:23:14', '2026-10-24 05:22:32', 'cerrada'),
(620, 6, 'af29226bc4687a3cd80cfd26cfde684095a1aa4e209d3e0ef4a1606ee91b24ab', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-23 13:23:33', '2026-10-23 17:18:47', '2026-10-24 05:23:33', 'activa'),
(621, 9, '004caded2d5fac807cec90c40b1d69c37e33ed19d280ca54f21ce1255a6b5907', '192.168.40.152', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-23 16:22:31', '2026-10-23 17:06:47', '2026-10-24 08:22:31', 'cerrada'),
(622, 8, '6048e39cd8fb7b6c31099f099cad835938046533a932a5cd4b8db050aa57f8a6', '192.168.40.135', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36', '2026-10-24 08:05:38', '2026-10-24 12:09:31', '2026-10-25 00:05:38', 'activa'),
(623, 9, '301e665b8607efa3aa4ad676c70e13c395ef0597be1d668ba1b31421ba650f93', '192.168.40.152', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-24 08:18:06', '2026-10-24 11:45:34', '2026-10-25 00:18:06', 'cerrada'),
(624, 6, '09646be9451be88ba218e732e27cb6213d49143b0a2413b9bb4fc22e7681bb51', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', '2026-10-24 09:24:18', '2026-10-24 12:05:41', '2026-10-25 01:24:18', 'activa'),
(625, 9, 'c07612e3f0aeca34a6e350b89b20b61dd742df6a420fbbb1c5363ddc3b5949b7', '192.168.40.152', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0', '2026-10-24 11:46:17', '2026-10-24 11:58:07', '2026-10-25 02:46:17', 'activa'),
(626, 8, '49494def9f84f77e7959c94a12b2815c23ed774f433ca6758b4133a4899d2786', '192.168.40.135', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36', '2026-10-26 08:16:07', '2026-10-26 08:55:06', '2026-10-26 23:16:07', 'cerrada'),
(627, 6, 'b3c8cbfff14c17567b62b9bdf863fbd990602b647c2ef0bf09736265f4140b83', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', '2026-10-26 08:49:15', '2026-10-26 14:41:50', '2026-10-26 23:49:15', 'activa'),
(628, 6, 'baba4f953d817f60c3eda350c70bffc349dc806607207e8e2df498d8788903ec', '192.168.40.135', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36', '2026-10-26 08:55:11', '2026-10-26 08:55:23', '2026-10-26 23:55:11', 'cerrada'),
(629, 8, 'd3435fd29dfb9d5983f1122afc961c6507823ea80c900a2458137558f749d176', '192.168.40.135', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36', '2026-10-26 09:05:11', '2026-10-26 14:47:47', '2026-10-27 00:05:11', 'activa'),
(630, 9, 'ca643e9acdce2cdecb6d07ea3757b77654ceb5a4cce42bb0d74e3c05873882d9', '192.168.40.156', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0', '2026-10-26 09:51:48', '2026-10-26 11:50:34', '2026-10-27 00:51:48', 'activa');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipos_vehiculo`
--

CREATE TABLE `tipos_vehiculo` (
  `id_tipo` int(10) UNSIGNED NOT NULL,
  `nombre` varchar(60) NOT NULL,
  `estado` enum('activo','inactivo') NOT NULL DEFAULT 'activo',
  `fecha_creacion` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `tipos_vehiculo`
--

INSERT INTO `tipos_vehiculo` (`id_tipo`, `nombre`, `estado`, `fecha_creacion`) VALUES
(1, 'PIPA GRANELERA', 'activo', '2026-10-01 17:51:19'),
(2, 'CAMION GRANELERO', 'activo', '2026-10-01 17:51:19'),
(3, 'FURGON SECO', 'activo', '2026-10-01 17:51:19'),
(4, 'FURGON REFFER', 'activo', '2026-10-01 17:51:19'),
(5, 'PLATAFORMA', 'activo', '2026-10-01 17:51:19'),
(6, 'LOWBOY', 'activo', '2026-10-01 17:51:19'),
(7, 'PLATAFORMA GRUA', 'activo', '2026-10-01 17:51:19'),
(8, 'MAQUINARIA AMARILLA', 'activo', '2026-10-01 17:51:19'),
(9, 'TANQUE', 'activo', '2026-10-01 17:51:19'),
(10, 'MULITA', 'activo', '2026-10-01 17:51:19'),
(11, 'CABEZAL', 'activo', '2026-10-01 17:51:19'),
(12, 'CAMION', 'activo', '2026-10-01 17:51:19'),
(13, 'OTROS', 'activo', '2026-10-01 17:51:19');

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
  `empleado_id` int(10) UNSIGNED DEFAULT NULL,
  `estado` enum('activo','inactivo') NOT NULL DEFAULT 'activo',
  `fecha_creacion` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id_usuario`, `nombre`, `usuario`, `contrasena`, `rol_id`, `empleado_id`, `estado`, `fecha_creacion`) VALUES
(1, 'Administrador', 'admin', '$2y$12$awWsiiGw2sYpKHL8WVVl3en0dRoB/z5Jt.p3ip1qTQezhh4eGqHJW', 1, NULL, 'activo', '2026-03-18 13:21:58'),
(2, 'ventas soldymeg', 'ventas', '$2y$10$HXqnzkwgJJ6Z4d8WwA9fLOPyUG3imDvJ/Wv.fMkUjMnmOXa5VBZSe', 2, NULL, 'inactivo', '2026-03-18 14:05:43'),
(3, 'soldymeg', 'soldymeg', '$2y$10$zvDmsXDSIxSOduMDh5ObHO/hbBfJo6dXsk93dOass654QZO2OKeKO', 1, NULL, 'inactivo', '2026-03-27 08:40:31'),
(4, 'SANTOS ARITA', 'sbelloza', '$2y$10$TPUWIp5T6BkWQZQrjB3Xa..3iuPQYnjxFMvjz0Y41HhcINoODix1O', 3, 23, 'inactivo', '2026-03-27 08:43:27'),
(5, 'Soldymeg Operarador', 'operador', '$2y$10$whPPDyIlpt1VRPxozEmcou0TMNzcVMa1TX8x4tiC6clDhx1h5vIYy', 4, NULL, 'inactivo', '2026-03-27 08:43:48'),
(6, 'ELBIN MAURICIO ARITA ARITA', 'EARITA', '$2y$10$AkCBbzjXc5umb9dIdwFh1upImrHrMzJWam886iGyUaIDhDJmlxPyC', 1, 6, 'activo', '2026-04-23 15:19:34'),
(7, 'OSMAR ANTONIO JOVEL GUEVARA', 'OJOVEL', '$2y$10$92dE4mprv21W0H9KozUU9eDrRkNudA5CUu4c/pr3k5MPq1hBsxXT2', 4, 31, 'activo', '2026-09-09 15:40:31'),
(8, 'JEIMY SCARLETH LOPEZ BU', 'JLOPEZ', '$2y$10$GIEWRs40w08Z5dAcCS8KSu6L1zqMu2aWCcX/qDAYo5NiX2Ff/Or56', 3, 33, 'activo', '2026-09-23 09:56:58'),
(9, 'EDUARDO FALCONERY POLANCO PERELLO', 'EPOLANCO', '$2y$10$X94eAQy0Q8vAqAGU0hxTZ.HDUok.LZ5DBNS/sqlyWIc.BvKB3tfci', 5, 34, 'activo', '2026-10-21 18:34:34');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `vacaciones`
--

CREATE TABLE `vacaciones` (
  `id_vacacion` int(10) UNSIGNED NOT NULL,
  `empleado_id` int(10) UNSIGNED NOT NULL,
  `fecha_inicio` date NOT NULL COMMENT 'Inicio del período laboral para cálculo',
  `fecha_fin` date NOT NULL COMMENT 'Fin del período laboral (aniversario)',
  `anios_laborados` decimal(4,2) NOT NULL DEFAULT 0.00,
  `dias_correspondientes` tinyint(3) UNSIGNED NOT NULL DEFAULT 10 COMMENT 'Días según tabla Honduras',
  `salario_diario` decimal(12,4) NOT NULL DEFAULT 0.0000,
  `monto_vacaciones` decimal(12,2) NOT NULL DEFAULT 0.00 COMMENT 'Pago si se pagaron en efectivo',
  `tipo` enum('descanso','pago') NOT NULL DEFAULT 'descanso' COMMENT 'descanso=días libres, pago=pago en efectivo',
  `fecha_registro` date NOT NULL COMMENT 'Fecha en que se registró/tomó',
  `observaciones` varchar(300) DEFAULT NULL,
  `estado` enum('pendiente','tomada','pagada','anulada') NOT NULL DEFAULT 'pendiente',
  `usuario_id` int(10) UNSIGNED NOT NULL COMMENT 'Quien registró',
  `fecha_creacion` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `vacaciones`
--

INSERT INTO `vacaciones` (`id_vacacion`, `empleado_id`, `fecha_inicio`, `fecha_fin`, `anios_laborados`, `dias_correspondientes`, `salario_diario`, `monto_vacaciones`, `tipo`, `fecha_registro`, `observaciones`, `estado`, `usuario_id`, `fecha_creacion`) VALUES
(1, 9, '2025-01-02', '2026-01-02', 1.00, 6, 600.0000, 0.00, 'descanso', '2026-07-06', 'TOMO DEL 06-07-2026-11-07-2026 (PENDIENTE 4 DIAS)', 'tomada', 8, '2026-09-25 11:20:53'),
(2, 12, '2025-01-16', '2026-01-16', 1.00, 10, 616.6667, 0.00, 'descanso', '2026-09-23', 'GOCE DE VAC DEL 23-09-2026 AL 03-10-2026', 'tomada', 8, '2026-09-25 11:33:16'),
(3, 18, '2025-01-02', '2026-01-02', 1.00, 1, 533.3333, 0.00, 'descanso', '2026-05-11', 'PENDIENTES 9 DIAS', 'tomada', 8, '2026-09-25 11:35:36'),
(4, 19, '2025-02-16', '2026-10-01', 1.58, 10, 700.0000, 7000.00, 'pago', '2026-10-01', 'PAGO DE 10 DIASDE VACACIONES (0 PENDIENTES)', 'pagada', 8, '2026-10-01 09:07:15'),
(5, 4, '2025-02-01', '2026-10-15', 1.67, 10, 500.0000, 0.00, 'descanso', '2026-10-15', 'GOCE DE VACACIONES (10) DIAS DEL 12/10/2026 AL 22/10/2026', 'tomada', 8, '2026-10-15 14:28:52'),
(6, 8, '2026-10-12', '2026-10-22', 1.67, 10, 500.0000, 0.00, 'descanso', '2026-10-22', 'GOCE DE (10) DIAS DE VAC DEL 12/10/2026 AL 22/10/2026', 'tomada', 8, '2026-10-22 10:46:12');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `vehiculos`
--

CREATE TABLE `vehiculos` (
  `id_vehiculo` int(10) UNSIGNED NOT NULL,
  `cliente_id` int(10) UNSIGNED NOT NULL,
  `placa` varchar(20) NOT NULL,
  `marca` varchar(80) DEFAULT NULL,
  `modelo` varchar(80) DEFAULT NULL,
  `anio` year(4) DEFAULT NULL,
  `color` varchar(50) DEFAULT NULL,
  `numero_motor` varchar(50) DEFAULT NULL,
  `numero_chasis` varchar(50) DEFAULT NULL,
  `observaciones` varchar(255) DEFAULT NULL,
  `estado` enum('activo','inactivo') NOT NULL DEFAULT 'activo',
  `fecha_creacion` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `vehiculos`
--

INSERT INTO `vehiculos` (`id_vehiculo`, `cliente_id`, `placa`, `marca`, `modelo`, `anio`, `color`, `numero_motor`, `numero_chasis`, `observaciones`, `estado`, `fecha_creacion`) VALUES
(1, 1, 'PIPA 01', '', '', NULL, '', '', '', '', 'activo', '2026-04-24 07:39:06'),
(2, 1, 'PIPA 02', '', '', NULL, '', '', '', '', 'activo', '2026-04-24 07:39:19'),
(3, 1, 'PIPA 03', '', '', NULL, '', '', '', '', 'activo', '2026-04-24 07:41:01'),
(4, 1, 'PIPA 04', '', '', NULL, '', '', '', '', 'activo', '2026-04-24 07:41:18'),
(5, 1, 'PIPA 05', '', '', NULL, '', '', '', '', 'activo', '2026-04-24 07:41:29'),
(6, 1, 'PIPA 06', '', '', NULL, '', '', '', '', 'activo', '2026-04-24 07:41:38'),
(7, 1, 'PIPA 07', '', '', NULL, '', '', '', '', 'activo', '2026-04-24 07:42:02'),
(8, 1, 'PIPA 08', '', '', NULL, '', '', '', '', 'activo', '2026-04-24 07:42:12'),
(9, 1, 'PIPA 09', '', '', NULL, '', '', '', '', 'activo', '2026-04-24 07:42:22'),
(10, 1, 'PIPA 10', '', '', NULL, '', '', '', '', 'activo', '2026-04-24 07:42:34'),
(11, 1, 'PIPA 11', '', '', NULL, '', '', '', '', 'activo', '2026-04-24 07:42:44'),
(12, 1, 'PIPA 12', '', '', NULL, '', '', '', '', 'activo', '2026-04-24 07:42:53'),
(13, 1, 'PIPA 13', '', '', NULL, '', '', '', '', 'activo', '2026-04-24 07:43:20'),
(14, 1, 'PIPA 14', '', '', NULL, '', '', '', '', 'activo', '2026-04-24 07:43:32'),
(15, 1, 'PIPA 15', '', '', NULL, '', '', '', '', 'activo', '2026-04-24 07:43:41'),
(16, 1, 'PIPA 16', '', '', NULL, '', '', '', '', 'activo', '2026-04-24 07:43:51'),
(17, 2, 'CABEZAL 605', '', '', NULL, '', '', '', '', 'activo', '2026-04-24 07:45:28'),
(18, 2, 'CABEZAL 606', '', '', NULL, '', '', '', '', 'activo', '2026-04-24 07:45:44'),
(19, 2, 'UNIDAD 287', '', '', NULL, '', '', '', '', 'activo', '2026-04-24 07:45:59'),
(20, 2, 'UNIDAD 365', '', '', NULL, '', '', '', '', 'activo', '2026-04-24 07:46:29'),
(21, 2, 'UNIDAD 486', '', '', NULL, '', '', '', '', 'activo', '2026-04-24 07:47:34'),
(22, 2, 'UNIDAD 487', '', '', NULL, '', '', '', '', 'activo', '2026-04-24 07:47:48'),
(23, 2, 'UNIDAD 609', '', '', NULL, '', '', '', '', 'activo', '2026-04-24 07:48:05'),
(24, 2, 'UNIDAD 610', '', '', NULL, '', '', '', '', 'activo', '2026-04-24 07:48:20'),
(25, 2, 'UNIDAD 845', '', '', NULL, '', '', '', '', 'activo', '2026-04-24 07:48:34'),
(26, 2, 'UNIDAD 863', '', '', NULL, '', '', '', '', 'activo', '2026-04-24 07:48:47'),
(27, 8, 'TEA3565', '', '', NULL, '', '', '', 'C-21', 'activo', '2026-04-24 07:57:09'),
(28, 8, 'HAE7990', '', '', NULL, '', '', '', 'F-1912', 'activo', '2026-04-24 07:57:51'),
(29, 8, 'F-329', '', '', NULL, '', '', '', '', 'activo', '2026-04-24 07:58:09'),
(30, 8, 'TRC8861', '', '', NULL, '', '', '', 'PLATAFORMA LONVOY', 'activo', '2026-04-24 07:58:34'),
(31, 1, 'TEA2104', '', '', NULL, '', '', '', '', 'activo', '2026-04-27 17:31:51'),
(32, 1, 'TEA9764', '', '', NULL, '', '', '', '', 'activo', '2026-04-27 17:32:08'),
(33, 8, 'D-54', '', '', NULL, '', '', '', '', 'activo', '2026-06-17 15:54:16'),
(34, 9, '320DL', '', '', NULL, '', '', '', '', 'activo', '2026-06-19 15:58:53'),
(35, 8, 'VW', '', '', NULL, '', '', '', '', 'activo', '2026-07-02 15:16:47'),
(36, 8, 'IH', '', '', NULL, '', '', '', '', 'activo', '2026-07-02 15:19:05'),
(37, 8, 'F-1907', '', '', NULL, '', '', '', '', 'activo', '2026-07-02 15:21:21'),
(38, 8, 'TEA3899', '', '', NULL, '', '', '', '', 'activo', '2026-07-07 15:51:36'),
(39, 12, 'TRC4601', '', '', NULL, '', '', '', '', 'activo', '2026-07-29 16:31:30'),
(40, 3, 'CONT.6464', '', '', NULL, '', '', '', '', 'activo', '2026-07-29 16:46:46'),
(41, 3, 'CONT.2377', '', '', NULL, '', '', '', '', 'activo', '2026-07-30 07:38:15'),
(42, 3, 'CONT.8259', '', '', NULL, '', '', '', '', 'activo', '2026-07-30 07:41:24'),
(43, 3, 'TRA0811', '', '', NULL, '', '', '', '', 'activo', '2026-07-30 07:44:42'),
(44, 4, 'N/A', '', '', NULL, '', '', '', '', 'activo', '2026-07-30 07:46:50'),
(45, 3, 'TRB3713', '', '', NULL, '', '', '', '', 'activo', '2026-08-03 10:27:26'),
(46, 3, '2795', '', '', NULL, '', '', '', '', 'activo', '2026-08-03 10:28:32'),
(47, 3, '2718', '', '', NULL, '', '', '', '', 'activo', '2026-08-03 10:28:45'),
(48, 3, '0966', '', '', NULL, '', '', '', '', 'activo', '2026-08-03 10:28:59'),
(49, 8, '320GC', '', '', NULL, '', '', '', '', 'activo', '2026-08-20 10:48:35'),
(50, 3, 'CONT. 8253', '', '', NULL, '', '', '', '', 'activo', '2026-08-20 10:55:44'),
(51, 3, 'CONT. 2823', '', '', NULL, '', '', '', '', 'activo', '2026-08-20 10:56:02'),
(52, 3, 'CONT. 9927', '', '', NULL, '', '', '', '', 'activo', '2026-08-20 10:56:16'),
(53, 13, 'TRB6281', '', '', NULL, '', '', '', '', 'activo', '2026-08-20 10:56:51'),
(54, 8, 'R23', '', '', NULL, '', '', '', '', 'activo', '2026-09-01 09:24:21'),
(55, 8, 'R19', '', '', NULL, '', '', '', '', 'activo', '2026-09-01 09:25:35'),
(56, 3, 'CONT.8621', '', '', NULL, '', '', '', '', 'activo', '2026-09-01 09:26:40'),
(57, 8, 'RETRO.349', '', '', NULL, '', '', '', '', 'activo', '2026-09-01 09:27:53'),
(58, 2, '364', 'PIPA', '', NULL, '', '', '', '', 'activo', '2026-09-29 09:37:15'),
(59, 3, 'V5103', 'FURGON SECO', '', NULL, '', '', '', '', 'activo', '2026-09-29 15:45:41'),
(60, 3, 'CONT.5103', '', '', NULL, '', '', '', '', 'activo', '2026-09-29 17:09:16'),
(61, 2, '616', '', 'PIPA GRANELERA', NULL, '', '', '', '', 'activo', '2026-10-16 10:38:47'),
(62, 2, '366', '', 'PIPA GRANELERA', NULL, '', '', '', '', 'activo', '2026-10-16 10:40:21'),
(63, 2, '603', '', 'PIPA GRANELERA', NULL, '', '', '', '', 'activo', '2026-10-16 10:58:27'),
(64, 2, '617', '', 'PIPA GRANELERA', NULL, '', '', '', '', 'activo', '2026-10-16 10:59:47'),
(65, 2, '612', '', 'PIPA GRANELERA', NULL, '', '', '', '', 'activo', '2026-10-16 11:10:02');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `asistencia_registros`
--
ALTER TABLE `asistencia_registros`
  ADD PRIMARY KEY (`id_registro`),
  ADD KEY `idx_asist_empleado` (`empleado_id`),
  ADD KEY `idx_asist_fecha` (`fecha`),
  ADD KEY `idx_asist_planilla` (`planilla_id`);

--
-- Indices de la tabla `cai_facturacion`
--
ALTER TABLE `cai_facturacion`
  ADD PRIMARY KEY (`id_cai`),
  ADD UNIQUE KEY `uk_cai_codigo` (`cai`),
  ADD KEY `fk_cai_usuario` (`usuario_id`);

--
-- Indices de la tabla `catalogo_precios`
--
ALTER TABLE `catalogo_precios`
  ADD PRIMARY KEY (`id_catalogo`),
  ADD UNIQUE KEY `uk_codigo` (`codigo`),
  ADD KEY `idx_estado` (`estado`),
  ADD KEY `idx_categoria` (`categoria`);

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
-- Indices de la tabla `departamentos`
--
ALTER TABLE `departamentos`
  ADD PRIMARY KEY (`id_departamento`),
  ADD UNIQUE KEY `uk_nombre` (`nombre`);

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
  ADD KEY `fk_emp_empresa` (`empresa_id`);

--
-- Indices de la tabla `empresas`
--
ALTER TABLE `empresas`
  ADD PRIMARY KEY (`id_empresa`);

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
-- Indices de la tabla `gastos_dmc`
--
ALTER TABLE `gastos_dmc`
  ADD PRIMARY KEY (`id_gasto`),
  ADD KEY `idx_periodo` (`anio_declaracion`,`mes_declaracion`),
  ADD KEY `idx_estado` (`estado`),
  ADD KEY `idx_rtn` (`rtn_proveedor`);

--
-- Indices de la tabla `gastos_dmc_items`
--
ALTER TABLE `gastos_dmc_items`
  ADD PRIMARY KEY (`id_item`),
  ADD KEY `fk_gdi_gasto` (`gasto_id`);

--
-- Indices de la tabla `materiales`
--
ALTER TABLE `materiales`
  ADD PRIMARY KEY (`id_material`),
  ADD UNIQUE KEY `uk_material_codigo` (`codigo`),
  ADD KEY `idx_material_nombre` (`nombre`),
  ADD KEY `idx_material_categoria` (`categoria_id`);

--
-- Indices de la tabla `movimientos`
--
ALTER TABLE `movimientos`
  ADD PRIMARY KEY (`id_movimiento`),
  ADD KEY `idx_mov_tipo` (`tipo`),
  ADD KEY `idx_mov_estado` (`estado`),
  ADD KEY `idx_mov_cliente` (`cliente_id`),
  ADD KEY `idx_mov_factura` (`factura_id`),
  ADD KEY `idx_mov_fecha` (`fecha`),
  ADD KEY `fk_movtrans_usuario` (`usuario_id`),
  ADD KEY `fk_movimientos_motorista` (`motorista_id`);

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
-- Indices de la tabla `orden_fotos`
--
ALTER TABLE `orden_fotos`
  ADD PRIMARY KEY (`id_foto`),
  ADD KEY `idx_orden_fotos_orden` (`orden_id`);

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
  ADD UNIQUE KEY `uk_planilla_periodo_empresa` (`periodo_mes`,`periodo_anio`,`quincena`,`empresa_id`),
  ADD KEY `idx_planilla_estado` (`estado`),
  ADD KEY `fk_planilla_usuario` (`usuario_id`),
  ADD KEY `fk_plan_empresa` (`empresa_id`);

--
-- Indices de la tabla `proveedores`
--
ALTER TABLE `proveedores`
  ADD PRIMARY KEY (`id_proveedor`),
  ADD KEY `idx_prov_nombre` (`nombre`);

--
-- Indices de la tabla `recibos`
--
ALTER TABLE `recibos`
  ADD PRIMARY KEY (`id_recibo`),
  ADD UNIQUE KEY `uq_recibo_numero` (`numero`),
  ADD KEY `idx_recibo_empleado` (`empleado_id`),
  ADD KEY `idx_recibo_fecha` (`fecha`),
  ADD KEY `idx_recibo_planilla` (`planilla_id`);

--
-- Indices de la tabla `recibos_detalle`
--
ALTER TABLE `recibos_detalle`
  ADD PRIMARY KEY (`id_detalle`),
  ADD KEY `idx_recdet_recibo` (`recibo_id`);

--
-- Indices de la tabla `recibos_serie`
--
ALTER TABLE `recibos_serie`
  ADD PRIMARY KEY (`id_serie`);

--
-- Indices de la tabla `requisiciones_materiales`
--
ALTER TABLE `requisiciones_materiales`
  ADD PRIMARY KEY (`id_requisicion`),
  ADD UNIQUE KEY `uk_numero` (`numero`),
  ADD KEY `fk_req_empleado` (`empleado_id`),
  ADD KEY `fk_req_usuario` (`usuario_id`),
  ADD KEY `fk_req_cliente` (`cliente_id`);

--
-- Indices de la tabla `requisicion_detalle`
--
ALTER TABLE `requisicion_detalle`
  ADD PRIMARY KEY (`id_detalle`),
  ADD KEY `fk_det_req` (`requisicion_id`);

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
-- Indices de la tabla `tipos_vehiculo`
--
ALTER TABLE `tipos_vehiculo`
  ADD PRIMARY KEY (`id_tipo`),
  ADD UNIQUE KEY `uk_tipo_nombre` (`nombre`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id_usuario`),
  ADD UNIQUE KEY `uk_usuarios_usuario` (`usuario`),
  ADD KEY `fk_usuarios_rol` (`rol_id`),
  ADD KEY `fk_usr_empleado` (`empleado_id`);

--
-- Indices de la tabla `vacaciones`
--
ALTER TABLE `vacaciones`
  ADD PRIMARY KEY (`id_vacacion`),
  ADD KEY `fk_vac_empleado` (`empleado_id`),
  ADD KEY `fk_vac_usuario` (`usuario_id`);

--
-- Indices de la tabla `vehiculos`
--
ALTER TABLE `vehiculos`
  ADD PRIMARY KEY (`id_vehiculo`),
  ADD UNIQUE KEY `uq_placa` (`placa`),
  ADD KEY `fk_veh_cliente` (`cliente_id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `asistencia_registros`
--
ALTER TABLE `asistencia_registros`
  MODIFY `id_registro` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `cai_facturacion`
--
ALTER TABLE `cai_facturacion`
  MODIFY `id_cai` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `catalogo_precios`
--
ALTER TABLE `catalogo_precios`
  MODIFY `id_catalogo` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `categorias_material`
--
ALTER TABLE `categorias_material`
  MODIFY `id_categoria` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de la tabla `clientes`
--
ALTER TABLE `clientes`
  MODIFY `id_cliente` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT de la tabla `compras`
--
ALTER TABLE `compras`
  MODIFY `id_compra` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `cotizaciones`
--
ALTER TABLE `cotizaciones`
  MODIFY `id_cotizacion` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=60;

--
-- AUTO_INCREMENT de la tabla `departamentos`
--
ALTER TABLE `departamentos`
  MODIFY `id_departamento` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de la tabla `detalle_compras`
--
ALTER TABLE `detalle_compras`
  MODIFY `id_detalle_compra` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `detalle_cotizacion`
--
ALTER TABLE `detalle_cotizacion`
  MODIFY `id_detalle_cot` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=227;

--
-- AUTO_INCREMENT de la tabla `detalle_factura`
--
ALTER TABLE `detalle_factura`
  MODIFY `id_detalle_fac` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=206;

--
-- AUTO_INCREMENT de la tabla `detalle_orden_mano_obra`
--
ALTER TABLE `detalle_orden_mano_obra`
  MODIFY `id_mano_obra` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT de la tabla `detalle_orden_materiales`
--
ALTER TABLE `detalle_orden_materiales`
  MODIFY `id_detalle_om` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `detalle_planilla`
--
ALTER TABLE `detalle_planilla`
  MODIFY `id_detalle` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3105;

--
-- AUTO_INCREMENT de la tabla `empleados`
--
ALTER TABLE `empleados`
  MODIFY `id_empleado` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;

--
-- AUTO_INCREMENT de la tabla `empresas`
--
ALTER TABLE `empresas`
  MODIFY `id_empresa` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `facturas`
--
ALTER TABLE `facturas`
  MODIFY `id_factura` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=64;

--
-- AUTO_INCREMENT de la tabla `factura_cotizaciones`
--
ALTER TABLE `factura_cotizaciones`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `gastos_dmc`
--
ALTER TABLE `gastos_dmc`
  MODIFY `id_gasto` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=193;

--
-- AUTO_INCREMENT de la tabla `gastos_dmc_items`
--
ALTER TABLE `gastos_dmc_items`
  MODIFY `id_item` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=417;

--
-- AUTO_INCREMENT de la tabla `materiales`
--
ALTER TABLE `materiales`
  MODIFY `id_material` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=44;

--
-- AUTO_INCREMENT de la tabla `movimientos`
--
ALTER TABLE `movimientos`
  MODIFY `id_movimiento` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=184;

--
-- AUTO_INCREMENT de la tabla `movimientos_inventario`
--
ALTER TABLE `movimientos_inventario`
  MODIFY `id_movimiento` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `ordenes_trabajo`
--
ALTER TABLE `ordenes_trabajo`
  MODIFY `id_orden` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT de la tabla `orden_fotos`
--
ALTER TABLE `orden_fotos`
  MODIFY `id_foto` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `orden_tecnicos`
--
ALTER TABLE `orden_tecnicos`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT de la tabla `pagos_clientes`
--
ALTER TABLE `pagos_clientes`
  MODIFY `id_pago` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=36;

--
-- AUTO_INCREMENT de la tabla `permisos`
--
ALTER TABLE `permisos`
  MODIFY `id_permiso` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1561;

--
-- AUTO_INCREMENT de la tabla `planillas`
--
ALTER TABLE `planillas`
  MODIFY `id_planilla` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=210;

--
-- AUTO_INCREMENT de la tabla `proveedores`
--
ALTER TABLE `proveedores`
  MODIFY `id_proveedor` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT de la tabla `recibos`
--
ALTER TABLE `recibos`
  MODIFY `id_recibo` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT de la tabla `recibos_detalle`
--
ALTER TABLE `recibos_detalle`
  MODIFY `id_detalle` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT de la tabla `recibos_serie`
--
ALTER TABLE `recibos_serie`
  MODIFY `id_serie` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `requisiciones_materiales`
--
ALTER TABLE `requisiciones_materiales`
  MODIFY `id_requisicion` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `requisicion_detalle`
--
ALTER TABLE `requisicion_detalle`
  MODIFY `id_detalle` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `roles`
--
ALTER TABLE `roles`
  MODIFY `id_rol` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `sesiones_admin`
--
ALTER TABLE `sesiones_admin`
  MODIFY `id_sesion` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=631;

--
-- AUTO_INCREMENT de la tabla `tipos_vehiculo`
--
ALTER TABLE `tipos_vehiculo`
  MODIFY `id_tipo` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id_usuario` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de la tabla `vacaciones`
--
ALTER TABLE `vacaciones`
  MODIFY `id_vacacion` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `vehiculos`
--
ALTER TABLE `vehiculos`
  MODIFY `id_vehiculo` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=66;

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
-- Filtros para la tabla `empleados`
--
ALTER TABLE `empleados`
  ADD CONSTRAINT `fk_emp_empresa` FOREIGN KEY (`empresa_id`) REFERENCES `empresas` (`id_empresa`) ON DELETE SET NULL;

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
-- Filtros para la tabla `gastos_dmc_items`
--
ALTER TABLE `gastos_dmc_items`
  ADD CONSTRAINT `fk_gdi_gasto` FOREIGN KEY (`gasto_id`) REFERENCES `gastos_dmc` (`id_gasto`) ON DELETE CASCADE;

--
-- Filtros para la tabla `materiales`
--
ALTER TABLE `materiales`
  ADD CONSTRAINT `fk_material_categoria` FOREIGN KEY (`categoria_id`) REFERENCES `categorias_material` (`id_categoria`) ON DELETE SET NULL;

--
-- Filtros para la tabla `movimientos`
--
ALTER TABLE `movimientos`
  ADD CONSTRAINT `fk_movimientos_motorista` FOREIGN KEY (`motorista_id`) REFERENCES `empleados` (`id_empleado`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_movtrans_cliente` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id_cliente`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_movtrans_factura` FOREIGN KEY (`factura_id`) REFERENCES `facturas` (`id_factura`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_movtrans_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id_usuario`);

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
  ADD CONSTRAINT `fk_plan_empresa` FOREIGN KEY (`empresa_id`) REFERENCES `empresas` (`id_empresa`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_planilla_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id_usuario`);

--
-- Filtros para la tabla `recibos_detalle`
--
ALTER TABLE `recibos_detalle`
  ADD CONSTRAINT `fk_recdet_recibo` FOREIGN KEY (`recibo_id`) REFERENCES `recibos` (`id_recibo`) ON DELETE CASCADE;

--
-- Filtros para la tabla `requisiciones_materiales`
--
ALTER TABLE `requisiciones_materiales`
  ADD CONSTRAINT `fk_req_cliente` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id_cliente`) ON DELETE SET NULL;

--
-- Filtros para la tabla `sesiones_admin`
--
ALTER TABLE `sesiones_admin`
  ADD CONSTRAINT `fk_sesiones_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id_usuario`);

--
-- Filtros para la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD CONSTRAINT `fk_usr_empleado` FOREIGN KEY (`empleado_id`) REFERENCES `empleados` (`id_empleado`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_usuarios_rol` FOREIGN KEY (`rol_id`) REFERENCES `roles` (`id_rol`);

--
-- Filtros para la tabla `vacaciones`
--
ALTER TABLE `vacaciones`
  ADD CONSTRAINT `fk_vac_empleado` FOREIGN KEY (`empleado_id`) REFERENCES `empleados` (`id_empleado`),
  ADD CONSTRAINT `fk_vac_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id_usuario`);

--
-- Filtros para la tabla `vehiculos`
--
ALTER TABLE `vehiculos`
  ADD CONSTRAINT `fk_veh_cliente` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`id_cliente`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
