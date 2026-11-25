<div class="module" id="mod-solicitudes">
  <div class="card">
    <div class="card-header">
      <h4>📝 Solicitudes</h4>
      <div class="btn-group">
        <input type="text" id="buscarSol" placeholder="🔍 Buscar solicitud, cliente, placa..." oninput="filtrarSolicitudes()" style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px;outline:none;width:220px">
        <select id="filtroEstadoSol" onchange="cargarSolicitudes()" style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
          <option value="">Todas</option>
          <option value="pendiente">Pendientes</option>
          <option value="en_ot">En O.T.</option>
          <option value="en_cotizacion">En Cotización</option>
          <option value="anulada">Anuladas</option>
        </select>
        <button class="btn btn-primary" onclick="abrirModalSolicitud()">+ Nueva Solicitud</button>
      </div>
    </div>
    <div class="table-wrap" id="tablaSolicitudes"><p class="loading">Cargando...</p></div>
    <div id="paginaSolicitudes"></div>
  </div>
</div>
