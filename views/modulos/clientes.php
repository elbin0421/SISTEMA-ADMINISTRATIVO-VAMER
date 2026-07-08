<div class="module" id="mod-clientes">
  <div class="card">
    <div class="card-header">
      <h4>🧾 Clientes</h4>
      <div class="btn-group">
        <input type="text" id="buscarCliente" placeholder="🔍 Buscar nombre, RTN..." oninput="filtrarClientes()"
          style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px;outline:none;width:200px">
        <select id="filtroEstadoCliente" onchange="cargarClientes()" style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
          <option value="activo">Activos</option>
          <option value="inactivo">Inactivos</option>
        </select>
        <button class="btn btn-primary" onclick="abrirModalCliente()">+ Nuevo</button>
      </div>
    </div>
    <div class="table-wrap" id="tablaClientes"><p class="loading">Cargando...</p></div>
    <div id="paginaClientes"></div>
  </div>
</div>
