<!-- MODAL NUEVO / EDITAR ITEM CATÁLOGO -->
<div class="modal-bg" id="modalCatalogo">
  <div class="modal">
    <h4 id="tituloCatalogo">Nuevo Ítem</h4>
    <div class="alert alert-error" id="errCatalogo" style="display:none"></div>
    <input type="hidden" id="catId">
    <div class="form-row">
      <div class="form-group">
        <label>Código <span style="color:var(--muted);font-size:11px">(automático)</span></label>
        <input type="text" id="catCodigo" readonly
               style="background:var(--bg-alt,#1e1e2e);color:var(--muted);cursor:not-allowed;font-family:monospace;font-weight:700;font-size:15px;text-align:center">
      </div>
      <div class="form-group">
        <label>Tipo *</label>
        <select id="catTipo">
          <option value="material">Material</option>
          <option value="mano_obra">Mano de obra</option>
          <option value="otro">Otro</option>
        </select>
      </div>
    </div>
    <div class="form-group">
      <label>Descripción *</label>
      <input type="text" id="catDescripcion" placeholder="Descripción del servicio o producto">
    </div>
    <div class="form-row">
      <div class="form-group">
        <label>Categoría *</label>
        <select id="catCategoria">
          <option value="">— Seleccionar —</option>
          <option value="Soldadura">Soldadura</option>
          <option value="Mecánica">Mecánica</option>
          <option value="Eléctrico">Eléctrico</option>
          <option value="Pintura">Pintura</option>
          <option value="Materiales">Materiales</option>
          <option value="Mano de Obra">Mano de Obra</option>
          <option value="Servicios Generales">Servicios Generales</option>
          <option value="Lubricantes">Lubricantes</option>
          <option value="Frenos">Frenos</option>
          <option value="Suspensión">Suspensión</option>
          <option value="Otros">Otros</option>
        </select>
      </div>
      <div class="form-group">
        <label>Precio (L.) *</label>
        <input type="number" id="catPrecio" min="0" step="0.01" placeholder="0.00">
      </div>
    </div>
    <div class="modal-footer">
      <button class="btn btn-secondary" onclick="cerrarModal('modalCatalogo')">Cancelar</button>
      <button class="btn btn-primary" onclick="guardarCatalogo()">💾 Guardar</button>
    </div>
  </div>
</div>

<!-- MODAL BUSCAR EN CATÁLOGO (para cotización directa) -->
<div class="modal-bg" id="modalBuscarCatalogo">
  <div class="modal modal-lg">
    <h4>📂 Seleccionar del Catálogo de Precios</h4>
    <div style="display:flex;gap:8px;margin-bottom:12px">
      <input type="text" id="buscarCatQ" placeholder="Buscar por descripción, código o categoría..."
             style="flex:1;padding:8px 12px;background:var(--bg);border:1px solid var(--border);border-radius:7px;color:var(--text);font-size:13px"
             oninput="filtrarCatalogoModal()">
      <select id="buscarCatTipo" onchange="filtrarCatalogoModal()"
              style="padding:8px 12px;background:var(--bg);border:1px solid var(--border);border-radius:7px;color:var(--text);font-size:13px">
        <option value="">Todos los tipos</option>
        <option value="material">Material</option>
        <option value="mano_obra">Mano de obra</option>
        <option value="otro">Otro</option>
      </select>
    </div>
    <div class="table-wrap" style="max-height:380px;overflow-y:auto">
      <table>
        <thead>
          <tr><th>Cód.</th><th>Descripción</th><th>Tipo</th><th>Categoría</th><th>Precio</th><th></th></tr>
        </thead>
        <tbody id="catalogoModalBody">
          <tr><td colspan="6" class="empty-state">Cargando...</td></tr>
        </tbody>
      </table>
    </div>
    <div class="modal-footer">
      <button class="btn btn-secondary" onclick="cerrarModal('modalBuscarCatalogo')">Cerrar</button>
    </div>
  </div>
</div>
