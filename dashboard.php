<?php
require_once __DIR__ . '/config/auth.php';
$sesion = requireAuth();
?>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>VAMER — Dashboard</title>
  <link rel="stylesheet" href="assets/css/dashboard.css">
  <script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
</head>
<body>
<div id="overlay"></div>

<!-- SIDEBAR -->
<nav id="sidebar">

  <!-- Cabecera: logo + botón hamburguesa -->
  <div class="sidebar-logo">
    <div style="display:flex;align-items:center;gap:10px">
      <div class="vamer-hex">V</div>
      <div class="sb-logo-text"><h2>VAMER</h2><p>Ventas America S. de R.L</p></div>
    </div>
    <button id="btnMenuToggle" title="Colapsar menú">
      <div class="hbr"><span></span><span></span><span></span></div>
    </button>
  </div>

  <div class="sidebar-nav">

    <!-- Inicio -->
    <a class="nav-item" data-module="inicio" title="Inicio">
      <span class="nav-icon">🏠</span><span class="nav-text">Inicio</span>
    </a>

    <!-- ── 1. ADMINISTRACIÓN ── -->
    <div class="nav-group" id="grp-admin">
      <div class="nav-group-header" onclick="toggleGrupo('admin')" title="Administración">
        <span class="nav-icon">⚙️</span>
        <span class="nav-text"><span class="grp-dot"></span>Administración</span>
        <svg class="nav-arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="6 9 12 15 18 9"/></svg>
      </div>
      <div class="nav-group-body">
        <a class="nav-item" data-module="usuarios" title="Usuarios"><span class="nav-icon">👥</span><span class="nav-text">Usuarios</span></a>
        <a class="nav-item" data-module="roles" title="Roles y Permisos"><span class="nav-icon">🔑</span><span class="nav-text">Roles y Permisos</span></a>
      </div>
    </div>

    <!-- ── 2. OPERACIONES ── -->
    <div class="nav-group" id="grp-operaciones">
      <div class="nav-group-header" onclick="toggleGrupo('operaciones')" title="Operaciones">
        <span class="nav-icon">🔧</span>
        <span class="nav-text"><span class="grp-dot"></span>Operaciones</span>
        <svg class="nav-arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="6 9 12 15 18 9"/></svg>
      </div>
      <div class="nav-group-body">
        <a class="nav-item" data-module="clientes"    title="Clientes"><span class="nav-icon">🧾</span><span class="nav-text">Clientes</span></a>
        <a class="nav-item" data-module="vehiculos"   title="Vehículos"><span class="nav-icon">🚗</span><span class="nav-text">Vehículos</span></a>
        <a class="nav-item" data-module="inventario"    title="Inventario"><span class="nav-icon">📦</span><span class="nav-text">Inventario</span></a>
        <a class="nav-item" data-module="requisiciones" title="Requisiciones de Materiales"><span class="nav-icon">📋</span><span class="nav-text">Requisiciones</span></a>
        <a class="nav-item" data-module="compras"     title="Compras"><span class="nav-icon">🛒</span><span class="nav-text">Compras</span></a>
        <a class="nav-item" data-module="proveedores" title="Proveedores"><span class="nav-icon">🏭</span><span class="nav-text">Proveedores</span></a>
        <a class="nav-item" data-module="ordenes"     title="Órdenes de Trabajo"><span class="nav-icon">🔩</span><span class="nav-text">Órdenes de Trabajo</span></a>
      </div>
    </div>

    <!-- ── 3. COMERCIAL ── -->
    <div class="nav-group" id="grp-comercial">
      <div class="nav-group-header" onclick="toggleGrupo('comercial')" title="Comercial">
        <span class="nav-icon">💰</span>
        <span class="nav-text"><span class="grp-dot"></span>Comercial</span>
        <svg class="nav-arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="6 9 12 15 18 9"/></svg>
      </div>
      <div class="nav-group-body">
        <a class="nav-item" data-module="cotizaciones"  title="Cotizaciones"><span class="nav-icon">📑</span><span class="nav-text">Cotizaciones</span></a>
        <a class="nav-item" data-module="catalogo"      title="Catálogo de Precios"><span class="nav-icon">📂</span><span class="nav-text">Catálogo de Precios</span></a>
        <a class="nav-item" data-module="facturacion"   title="Facturación"><span class="nav-icon">💳</span><span class="nav-text">Facturación</span></a>
        <a class="nav-item" data-module="cai"           title="CAI"><span class="nav-icon">🏷️</span><span class="nav-text">CAI</span></a>
        <a class="nav-item" data-module="libro_ventas"  title="Libro de Ventas"><span class="nav-icon">📒</span><span class="nav-text">Libro de Ventas</span></a>
        <a class="nav-item" data-module="pagos"         title="Pagos"><span class="nav-icon">💵</span><span class="nav-text">Pagos</span></a>
        <a class="nav-item" data-module="gastos"        title="Gastos DMC"><span class="nav-icon">🧾</span><span class="nav-text">Gastos DMC</span></a>
      </div>
    </div>

    <!-- ── 4. RRHH ── -->
    <div class="nav-group" id="grp-rrhh">
      <div class="nav-group-header" onclick="toggleGrupo('rrhh')" title="RRHH">
        <span class="nav-icon">👷</span>
        <span class="nav-text"><span class="grp-dot"></span>RRHH</span>
        <svg class="nav-arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="6 9 12 15 18 9"/></svg>
      </div>
      <div class="nav-group-body">
        <a class="nav-item" data-module="planillas" title="Planilla"><span class="nav-icon">📋</span><span class="nav-text">Planilla</span></a>
        <a class="nav-item" data-module="vacaciones" title="Vacaciones"><span class="nav-icon">🏖️</span><span class="nav-text">Vacaciones</span></a>
      </div>
    </div>

    <!-- ── 5. ANÁLISIS ── -->
    <div class="nav-group" id="grp-analisis">
      <div class="nav-group-header" onclick="toggleGrupo('analisis')" title="Análisis">
        <span class="nav-icon">📊</span>
        <span class="nav-text"><span class="grp-dot"></span>Análisis</span>
        <svg class="nav-arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="6 9 12 15 18 9"/></svg>
      </div>
      <div class="nav-group-body">
        <a class="nav-item" data-module="reportes" title="Reportes"><span class="nav-icon">📈</span><span class="nav-text">Reportes</span></a>
      </div>
    </div>

  </div><!-- /sidebar-nav -->

  <div class="sidebar-footer">
    <div class="user-info sb-logo-text">
      <p id="sidebarNombre"><?= htmlspecialchars($sesion['nombre'] ?? '—') ?></p>
      <span id="sidebarRol"><?= htmlspecialchars($sesion['rol'] ?? '—') ?></span>
    </div>
    <button id="btnLogout"><span class="nav-icon">🚪</span><span class="nav-text">Cerrar sesión</span></button>
  </div>

</nav>



<!-- MAIN -->
<div id="main">
  <div class="topbar">
    <div class="topbar-left">
      <h3 id="topbarTitle">Inicio</h3>
    </div>
    <span class="clock" id="clock"></span>
  </div>
  <div class="content">
    <?php
    $modulos = [
      'inicio','clientes','vehiculos','inventario','requisiciones','compras','proveedores',
      'ordenes','cotizaciones','catalogo','facturacion','cai','libro_ventas',
      'pagos','planillas','vacaciones','gastos','reportes','usuarios_roles',
    ];
    foreach ($modulos as $mod) {
      $f = __DIR__ . "/views/modulos/{$mod}.php";
      if (file_exists($f)) include $f;
    }

    $modales = [
      'clientes','vehiculos','inventario','compras_proveedores',
      'ordenes','cotizaciones','catalogo_precios','facturacion',
      'pagos','planillas','planillas_especiales','vacaciones','gastos','usuarios','requisicion',
    ];
    foreach ($modales as $modal) {
      $f = __DIR__ . "/views/modales/{$modal}.php";
      if (file_exists($f)) include $f;
    }
    ?>
  </div>
</div>

<div id="toast-container"></div>
<div id="confirmBg">
  <div id="confirmBox">
    <p id="confirmMsg">¿Estás seguro?</p>
    <div class="confirm-btns">
      <button class="btn btn-secondary" id="confirmCancel">Cancelar</button>
      <button class="btn btn-danger" id="confirmOk">Confirmar</button>
    </div>
  </div>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.min.js"></script>
<script src="assets/js/dashboard.js"></script>
</body>
</html>
