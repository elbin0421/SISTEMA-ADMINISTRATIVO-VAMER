<div class="module" id="mod-compras">
  <div class="card">
    <div class="card-header">
      <h4>🛒 Compras</h4>
      <div class="btn-group">
        <input type="text" id="buscarCompra" placeholder="🔍 Buscar proveedor, doc..." oninput="filtrarCompras()" style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px;outline:none;width:200px">
        <button class="btn btn-primary" onclick="abrirModalCompra()">+ Nueva</button>
      </div>
    </div>
    <div class="table-wrap" id="tablaCompras"><p class="loading">Cargando...</p></div>
    <div id="paginaCompras"></div>
  </div>
</div>
