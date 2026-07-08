<div class="module" id="mod-catalogo">
  <div class="card">
    <div class="card-header" style="flex-wrap:wrap;gap:8px">
      <h4>📂 Catálogo de Precios</h4>
      <div class="btn-group" style="flex-wrap:wrap;gap:6px">
        <input type="text" id="filtroCatQ" placeholder="Buscar descripción, código..." oninput="filtrarCatalogo()"
               style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px;width:210px">
        <select id="filtroCatTipo" onchange="filtrarCatalogo()"
                style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
          <option value="">Todos los tipos</option>
          <option value="material">Material</option>
          <option value="mano_obra">Mano de obra</option>
          <option value="otro">Otro</option>
        </select>
        <select id="filtroCatEstado" onchange="cargarCatalogo()"
                style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
          <option value="activo">Activos</option>
          <option value="inactivo">Inactivos</option>
          <option value="todos">Todos</option>
        </select>
        <button class="btn btn-primary"    onclick="abrirModalCatalogo()">+ Nuevo</button>
        <button class="btn btn-secondary"  onclick="exportarCatalogoExcel()">⬇️ Excel</button>
        <button class="btn btn-secondary"  onclick="exportarCatalogoPDF()">📄 PDF</button>
      </div>
    </div>
    <div class="table-wrap">
      <table>
        <thead>
          <tr>
            <th>Código</th>
            <th>Descripción</th>
            <th>Tipo</th>
            <th>Categoría</th>
            <th>Precio</th>
            <th>Estado</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody id="tablaCatalogoBody">
          <tr><td colspan="7" class="empty-state">Cargando...</td></tr>
        </tbody>
      </table>
    </div>
  </div>
</div>
