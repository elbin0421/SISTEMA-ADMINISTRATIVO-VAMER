<div class="module" id="mod-reportes">
  <div class="card">
    <div class="card-header">
      <h4>📊 Reportes</h4>
    </div>

    <?php
    $subReportes = [
      'ventas'       => ['id' => 'rptabVentas',       'icono' => '📈', 'label' => 'Ventas'],
      'cxc'          => ['id' => 'rptabCxC',           'icono' => '🕐', 'label' => 'Cuentas x Cobrar'],
      'retenciones'  => ['id' => 'rptabRetenciones',   'icono' => '📋', 'label' => 'Retenciones'],
      'rentabilidad' => ['id' => 'rptabRentabilidad',  'icono' => '💹', 'label' => 'Rentabilidad OT'],
      'inventario'   => ['id' => 'rptabInventario',    'icono' => '📦', 'label' => 'Inventario'],
      'movimientos'  => ['id' => 'rptabMovimientos',   'icono' => '🚛', 'label' => 'Movimientos MAERSK / ALPLA'],
    ];
    $reportesVisibles = [];
    foreach ($subReportes as $key => $info) {
      if (tienePermiso($sesion['rol_id'], "reportes_$key", 'puede_ver')) $reportesVisibles[$key] = $info;
    }
    $primerReporte = array_key_first($reportesVisibles);
    ?>

    <?php if ($primerReporte): ?>
    <!-- El reporte se elige desde el menú lateral (Análisis) -->
    <h5 id="rpTitulo" style="margin:0 0 14px;font-size:15px"></h5>
    <script>window.__reporteInicial = <?= json_encode($primerReporte) ?>;</script>

    <!-- Filtros comunes -->
    <div id="filtrosReporte" style="display:flex;gap:8px;align-items:center;margin-bottom:14px;flex-wrap:wrap">
      <select id="rpMes" style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
        <option value="">Todo el año</option>
        <option value="01">Enero</option><option value="02">Febrero</option>
        <option value="03">Marzo</option><option value="04">Abril</option>
        <option value="05">Mayo</option><option value="06">Junio</option>
        <option value="07">Julio</option><option value="08">Agosto</option>
        <option value="09">Septiembre</option><option value="10">Octubre</option>
        <option value="11">Noviembre</option><option value="12">Diciembre</option>
      </select>
      <select id="rpAnio" style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
        <option value="2025">2025</option><option value="2026" selected>2026</option><option value="2027">2027</option>
      </select>
      <select id="rpMovTipo" style="display:none;padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
        <option value="todos">Tipo: Todos</option><option value="MAERSK">MAERSK</option><option value="ALPLA">ALPLA</option>
      </select>
      <select id="rpMovEstado" style="display:none;padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
        <option value="todos">Estado: Todos (sin anulados)</option><option value="pendiente">Pendientes</option><option value="facturado">Facturados</option><option value="anulado">Anulados</option>
      </select>
      <button class="btn btn-primary" onclick="ejecutarReporte()">🔍 Consultar</button>
      <button class="btn btn-secondary" onclick="exportarReporteExcel()">⬇️ Excel</button>
    </div>

    <!-- KPIs reporte -->
    <div id="reporteKpis" style="display:none;margin-bottom:14px"></div>

    <!-- Tabla resultado -->
    <div class="table-wrap" id="tablaReporte">
      <p style="color:var(--muted);text-align:center;padding:40px">Selecciona un reporte y haz clic en Consultar.</p>
    </div>
    <div id="paginaReporte"></div>
    <?php else: ?>
      <p style="color:var(--muted);text-align:center;padding:40px">No tienes permiso para ver ningún reporte. Solicita acceso a un administrador.</p>
    <?php endif; ?>
  </div>
</div>
