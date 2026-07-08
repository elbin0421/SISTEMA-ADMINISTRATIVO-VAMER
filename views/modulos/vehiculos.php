<div class="module" id="mod-vehiculos">
  <div class="card">
    <div class="card-header">
      <h4>🚗 Vehículos</h4>
      <div class="btn-group">
        <input type="text" id="buscarVehiculo" placeholder="🔍 Buscar placa, marca, cliente..."
          oninput="filtrarVehiculos()"
          style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px;outline:none;width:220px">
        <select id="filtroEstadoVehiculo" onchange="cargarVehiculos()"
          style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
          <option value="activo">Activos</option>
          <option value="todos">Todos</option>
        </select>
        <button class="btn btn-primary" onclick="abrirModalVehiculo()">+ Nuevo</button>
      </div>
    </div>
    <div class="table-wrap" id="tablaVehiculosWrap"><p class="loading">Cargando...</p></div>
    <div id="paginaVehiculos"></div>
  </div>
</div>
