<div class="module" id="mod-pagos">
  <div class="card">
    <div class="card-header">
      <h4>💳 Pagos de Clientes</h4>
      <div class="btn-group">
        <select id="pagosFiltroMes" style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
          <option value="">Todos los meses</option>
          <option value="01">Enero</option><option value="02">Febrero</option>
          <option value="03">Marzo</option><option value="04">Abril</option>
          <option value="05">Mayo</option><option value="06">Junio</option>
          <option value="07">Julio</option><option value="08">Agosto</option>
          <option value="09">Septiembre</option><option value="10">Octubre</option>
          <option value="11">Noviembre</option><option value="12">Diciembre</option>
        </select>
        <select id="pagosFiltroAnio" style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
          <option value="">Todos los años</option>
          <option value="2025">2025</option><option value="2026">2026</option><option value="2027">2027</option>
        </select>
        <select id="pagosFiltroMetodo" onchange="cargarPagos()" style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
          <option value="">Todos los métodos</option>
          <option value="efectivo">Efectivo</option>
          <option value="tarjeta">Tarjeta</option>
          <option value="transferencia">Transferencia</option>
        </select>
        <button class="btn btn-primary" onclick="cargarPagos()">🔍 Filtrar</button>
      </div>
    </div>

    <!-- KPIs -->
    <div class="kpi-grid" id="pagosKpiGrid" style="margin-bottom:16px">
      <div class="kpi-card"><div class="kpi-label">Pagos este mes</div><div class="kpi-val" id="kpiPagosTotal">—</div></div>
      <div class="kpi-card"><div class="kpi-label">Total cobrado</div><div class="kpi-val" id="kpiPagosCobrado">—</div></div>
      <div class="kpi-card"><div class="kpi-label">Neto recibido</div><div class="kpi-val" id="kpiPagosNeto">—</div></div>
      <div class="kpi-card"><div class="kpi-label">Retenciones</div><div class="kpi-val stock-bajo" id="kpiPagosRetenciones">—</div></div>
    </div>

    <!-- Tabs -->
    <div style="display:flex;gap:4px;margin-bottom:16px;border-bottom:2px solid var(--border);padding-bottom:0">
      <button id="tabPagos" class="tab-btn active" onclick="switchTabPagos('pagos')">📋 Historial de Pagos</button>
      <button id="tabCxC" class="tab-btn" onclick="switchTabPagos('cxc')">🕐 Cuentas por Cobrar</button>
    </div>

    <!-- Panel: Historial -->
    <div id="panelHistorialPagos">
      <div style="display:flex;gap:8px;margin-bottom:12px;align-items:center">
        <input type="text" id="buscarPago" placeholder="🔍 Buscar cliente, factura..." oninput="filtrarPagos()"
          style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px;outline:none;flex:1;max-width:280px">
      </div>
      <div class="table-wrap" id="tablaPagos"><p class="loading">Cargando...</p></div>
      <div id="paginaPagos"></div>
    </div>

    <!-- Panel: Cuentas por Cobrar -->
    <div id="panelCxC" style="display:none">
      <div style="display:flex;gap:8px;margin-bottom:12px;align-items:center">
        <input type="text" id="buscarCxC" placeholder="🔍 Buscar cliente, factura..." oninput="filtrarCxC()"
          style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px;outline:none;flex:1;max-width:280px">
        <select id="cxcFiltroCliente" onchange="cargarCxC()"
          style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px;min-width:180px">
          <option value="">Todos los clientes</option>
        </select>
        <div style="font-size:13px;color:var(--muted)">Total pendiente:
          <strong id="cxcTotalPendiente" style="color:var(--danger)">L. 0.00</strong>
        </div>
      </div>
      <div class="table-wrap" id="tablaCxC"><p class="loading">Cargando...</p></div>
      <div id="paginaCxC"></div>
    </div>

  </div>
</div>
