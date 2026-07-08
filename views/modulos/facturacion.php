<div class="module" id="mod-facturacion">
  <div class="card">
    <div class="card-header">
      <h4>💰 Facturación</h4>
      <div class="btn-group">
        <input type="text" id="buscarFactura" placeholder="🔍 Buscar número, cliente..." oninput="filtrarFacturas()"
          style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px;outline:none;width:220px">
        <select id="filtroEstadoFac" onchange="cargarFacturas()" style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
          <option value="">Todas</option>
          <option value="emitida">Emitida</option>
          <option value="pagada">Pagada</option>
          <option value="pendiente">Pendiente</option>
          <option value="anulada">Anulada</option>
        </select>
        <button class="btn btn-primary" onclick="abrirModalFacturaDirecta()">+ Nueva Factura</button>
        <button class="btn btn-secondary" onclick="abrirModalFacturarMultiple()">📑 Multi Cotizaciones</button>
      </div>
    </div>
    <div class="kpi-grid" id="kpiFacGrid" style="margin-bottom:16px">
      <div class="kpi-card"><div class="kpi-label">Facturas este mes</div><div class="kpi-val" id="kpiFacTotal">—</div></div>
      <div class="kpi-card"><div class="kpi-label">Monto facturado</div><div class="kpi-val" id="kpiFacMonto">—</div></div>
      <div class="kpi-card"><div class="kpi-label">Pendientes de cobro</div><div class="kpi-val stock-bajo" id="kpiFacPendientes">—</div></div>
      <div class="kpi-card"><div class="kpi-label">Anuladas</div><div class="kpi-val" id="kpiFacAnuladas">—</div></div>
    </div>
    <div class="table-wrap" id="tablaFacturas"><p class="loading">Cargando...</p></div>
    <div id="paginaFacturas"></div>
  </div>
</div>
