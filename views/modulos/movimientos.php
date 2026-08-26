<div class="module" id="mod-movimientos">
  <div class="card">
    <div class="card-header">
      <h4>🚛 Movimientos — MAERSK / ALPLA</h4>
      <div class="btn-group">
        <button class="btn btn-secondary" onclick="abrirModalFacturarMovimientos()">📑 Facturar Movimientos</button>
        <button class="btn btn-secondary" onclick="exportarMovimientosListadoExcel()">⬇️ Descargar Excel</button>
        <button class="btn btn-primary" onclick="abrirModalMovimiento()">+ Registrar Movimiento</button>
      </div>
    </div>

    <!-- Filtros -->
    <div style="display:flex;gap:8px;flex-wrap:wrap;margin-bottom:14px">
      <select id="filtroMovTipo" onchange="cargarMovimientos()"
        style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
        <option value="todos">Todos los tipos</option>
        <option value="MAERSK">MAERSK</option>
        <option value="ALPLA">ALPLA</option>
      </select>
      <select id="filtroMovEstado" onchange="cargarMovimientos()"
        style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
        <option value="todos">Todos los estados</option>
        <option value="pendiente">Pendiente</option>
        <option value="facturado">Facturado</option>
        <option value="anulado">Anulado</option>
      </select>
      <input type="date" id="filtroMovFechaDesde" onchange="cargarMovimientos()" title="Fecha desde"
        style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
      <input type="date" id="filtroMovFechaHasta" onchange="cargarMovimientos()" title="Fecha hasta"
        style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
      <input type="text" id="filtroMovPeriodo" placeholder="Periodo (ej. 1ra Quincena Agosto)"
        oninput="cargarMovimientos()"
        style="width:200px;padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
      <input type="text" id="filtroMovBuscar" placeholder="🔍 OT, contenedor, chasis, motorista, placa, cliente..."
        oninput="cargarMovimientos()"
        style="flex:1;min-width:220px;padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
      <button class="btn btn-secondary" onclick="limpiarFiltrosMovimientos()" title="Limpiar filtros">✕ Limpiar</button>
    </div>

    <div class="table-wrap" id="tablaMovimientosWrap"><p class="loading">Cargando...</p></div>
    <div id="paginaMovimientos"></div>
  </div>
</div>
