<div class="module" id="mod-recibos">
  <div class="card">
    <div class="card-header">
      <h4>🧾 Recibos</h4>
      <div class="btn-group">
        <input type="text" id="recBuscar" placeholder="🔍 Buscar número o empleado..." oninput="filtrarRecibos()"
          style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px;outline:none;width:210px">
        <input type="date" id="recDesde" onchange="cargarRecibos()" title="Desde"
          style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
        <input type="date" id="recHasta" onchange="cargarRecibos()" title="Hasta"
          style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
        <select id="recEstado" onchange="cargarRecibos()"
          style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
          <option value="">Todos</option>
          <option value="emitido">Emitidos</option>
          <option value="anulado">Anulados</option>
        </select>
        <button class="btn btn-secondary" onclick="abrirModalSerieRecibos()">⚙️ Serie</button>
        <button class="btn btn-primary" onclick="abrirModalRecibo()">+ Nuevo Recibo</button>
      </div>
    </div>
    <div class="table-wrap" id="tablaRecibosWrap"><p class="loading">Cargando...</p></div>
    <div id="paginaRecibos"></div>
  </div>
</div>
