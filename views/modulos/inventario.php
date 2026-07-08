<div class="module" id="mod-inventario">
  <div class="card">
    <div class="card-header">
      <h4>📦 Materiales / Inventario</h4>
      <div class="btn-group">
        <input type="text" id="buscarInventario" placeholder="🔍 Buscar nombre, código..." oninput="filtrarInventario()"
          style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px;outline:none;width:200px">
        <a href="controllers/ReportesController.php?action=inventario_stock&format=excel"
           class="btn btn-secondary" title="Descargar Excel">⬇️ Excel</a>
        <a href="controllers/ReportesController.php?action=inventario_stock&format=pdf"
           target="_blank" class="btn btn-secondary" title="Ver PDF">📄 PDF</a>
        <button class="btn btn-primary" onclick="abrirModalMaterial()">+ Nuevo Material</button>
      </div>
    </div>
    <div class="table-wrap" id="tablaInventario"><p class="loading">Cargando...</p></div>
    <div id="paginaInventario"></div>
  </div>
</div>
