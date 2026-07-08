<div class="module" id="mod-proveedores">
  <div class="card">
    <div class="card-header">
      <h4>🏭 Proveedores</h4>
      <div class="btn-group">
        <input type="text" id="buscarProveedor" placeholder="🔍 Buscar..." oninput="filtrarProveedores()"
          style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px;outline:none;width:180px">
        <select id="filtroEstadoProv" onchange="cargarProveedores()" style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
          <option value="activo">Activos</option>
          <option value="inactivo">Inactivos</option>
        </select>
        <button class="btn btn-primary" onclick="abrirModalProveedor()">+ Nuevo</button>
      </div>
    </div>
    <div class="table-wrap" id="tablaProveedores"><p class="loading">Cargando...</p></div>
    <div id="paginaProveedores"></div>
  </div>
</div>
