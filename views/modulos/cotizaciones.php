<div class="module" id="mod-cotizaciones">
  <div class="card">
    <div class="card-header">
      <h4>📑 Cotizaciones</h4>
      <div class="btn-group">
        <input type="text" id="buscarCotizacion" placeholder="🔍 Buscar número, cliente..." oninput="filtrarCotizaciones()"
          style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px;outline:none;width:220px">
        <select id="filtroEstadoCot" onchange="cargarCotizaciones()" style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
          <option value="">Todas</option>
          <option value="pendiente">Pendiente</option>
          <option value="enviada">Enviada</option>
          <option value="aprobada">Aprobada</option>
          <option value="rechazada">Rechazada</option>
        </select>
        <button class="btn btn-primary" onclick="abrirModalCotizacionDirecta()">+ Nueva directa</button>
      </div>
    </div>
    <div class="table-wrap" id="tablaCotizaciones"><p class="loading">Cargando...</p></div>
    <div id="paginaCotizaciones"></div>
  </div>
</div>
