<div class="module" id="mod-reportes">
  <div class="card">
    <div class="card-header">
      <h4>📊 Reportes</h4>
    </div>

    <!-- Selector de reporte -->
    <div style="display:flex;gap:8px;flex-wrap:wrap;margin-bottom:20px">
      <button class="tab-btn active" id="rptabVentas"       onclick="switchReporte('ventas')">📈 Ventas</button>
      <button class="tab-btn"        id="rptabCxC"          onclick="switchReporte('cxc')">🕐 Cuentas x Cobrar</button>
      <button class="tab-btn"        id="rptabRetenciones"  onclick="switchReporte('retenciones')">📋 Retenciones</button>
      <button class="tab-btn"        id="rptabRentabilidad" onclick="switchReporte('rentabilidad')">💹 Rentabilidad OT</button>
      <button class="tab-btn"        id="rptabInventario"   onclick="switchReporte('inventario')">📦 Inventario</button>
    </div>

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
  </div>
</div>
