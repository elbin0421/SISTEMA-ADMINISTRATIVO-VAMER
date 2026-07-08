<div class="module" id="mod-ordenes">
  <div class="card">
    <div class="card-header">
      <h4>🔧 Órdenes de Trabajo</h4>
      <div class="btn-group">
        <input type="text" id="buscarOrden" placeholder="🔍 Buscar OT, cliente, placa..." oninput="filtrarOrdenes()" style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px;outline:none;width:200px">
        <select id="filtroEstadoOT" onchange="cargarOrdenes()" style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
          <option value="">Todas</option>
          <option value="borrador">Borrador</option>
          <option value="en_proceso">En Proceso</option>
          <option value="finalizada">Finalizada</option>
          <option value="facturada">Facturada</option>
        </select>
        <button class="btn btn-primary" onclick="abrirModalOT()">+ Nueva OT</button>
      </div>
    </div>
    <div class="table-wrap" id="tablaOrdenes"><p class="loading">Cargando...</p></div>
    <div id="paginaOrdenes"></div>
  </div>
</div>
