<!-- MODAL SOLICITUD -->
<div class="modal-bg" id="modalSolicitud">
  <div class="modal modal-lg">
    <h4 id="tituloSolicitud">Nueva Solicitud</h4>
    <div class="alert alert-error" id="errSolicitud"></div>
    <input type="hidden" id="solId">
    <div class="form-row">
      <div class="form-group" style="grid-column:1/-1;position:relative">
        <label>Cliente *</label>
        <input type="text" id="solClienteBuscar" placeholder="Buscar cliente por nombre o RTN..." oninput="buscarClienteSol()" autocomplete="off">
        <input type="hidden" id="solClienteId">
        <div id="solSugerencias" style="display:none;position:absolute;left:0;right:0;top:100%;z-index:20;background:var(--surface);border:1px solid var(--border);border-radius:7px;max-height:200px;overflow:auto"></div>
      </div>
    </div>
    <div class="form-row">
      <div class="form-group"><label>Solicitante</label><input type="text" id="solSolicitante" readonly></div>
      <div class="form-group"><label>Prioridad</label>
        <select id="solPrioridad"><option value="normal">Normal</option><option value="urgente">Urgente</option></select>
      </div>
    </div>
    <div class="section-title">🚗 Unidad / Vehículo</div>
    <div class="form-group">
      <select id="solVehiculoSel"><option value="">— Seleccione un cliente —</option></select>
    </div>

    <div class="section-title">❓ ¿Qué se solicita?</div>
    <input type="hidden" id="solTipo" value="ot">
    <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;margin-bottom:12px">
      <button type="button" class="btn btn-secondary" id="solBtnOT" onclick="solSetTipo('ot')">🔩 Orden de Trabajo (O.T.)</button>
      <button type="button" class="btn btn-secondary" id="solBtnCOT" onclick="solSetTipo('cotizacion')">📑 Cotización</button>
    </div>

    <!-- O.T. -->
    <div id="solSecOT">
      <div class="section-title">🔧 Trabajo</div>
      <div class="form-group">
        <label>Descripción de la solicitud *</label>
        <div id="solDescWrap" style="background:var(--bg);border:1px solid var(--border);border-radius:7px;padding:10px;min-height:80px;max-height:200px;overflow-y:auto"></div>
        <button type="button" onclick="solAgregarLinea()" class="btn btn-sm btn-secondary" style="margin-top:8px">+ Trabajo</button>
      </div>
    </div>

    <!-- COTIZACIÓN -->
    <div id="solSecCOT" style="display:none">
      <div class="section-title">📋 Ítems de la solicitud</div>
      <div style="background:var(--bg);border:1px solid var(--border);border-radius:9px;padding:12px 14px;margin-bottom:8px">
        <div style="display:grid;grid-template-columns:2fr 1fr 1fr 110px auto;gap:8px;align-items:flex-end">
          <div><label style="display:block;font-size:11px;color:var(--muted);margin-bottom:4px">Descripción</label>
            <input type="text" id="solItDesc" placeholder="Descripción del servicio o material" style="width:100%;padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px;outline:none"></div>
          <div><label style="display:block;font-size:11px;color:var(--muted);margin-bottom:4px">Tipo</label>
            <select id="solItTipo" style="width:100%;padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
              <option value="material">Material</option><option value="mano_obra">Mano de obra</option><option value="otro">Otro</option></select></div>
          <div><label style="display:block;font-size:11px;color:var(--muted);margin-bottom:4px">Cantidad</label>
            <input type="number" id="solItCant" value="1" min="0.01" step="0.01" style="width:100%;padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px;outline:none"></div>
          <div><label style="display:block;font-size:11px;color:var(--muted);margin-bottom:4px">Precio unit. (L.)</label>
            <input type="number" id="solItPrecio" min="0" step="0.01" placeholder="0.00" style="width:100%;padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px;outline:none"></div>
          <div><button type="button" class="btn btn-primary" onclick="solAgregarItem()">+ Agregar</button></div>
        </div>
      </div>
      <div class="table-wrap">
        <table>
          <thead><tr><th>Tipo</th><th>Descripción</th><th>Cant.</th><th>Precio unit.</th><th>Subtotal</th><th></th></tr></thead>
          <tbody id="solItemsBody"><tr><td colspan="6" class="empty-state">Sin ítems</td></tr></tbody>
        </table>
      </div>
    </div>

    <div class="modal-actions">
      <button class="btn btn-secondary" onclick="cerrarModal('modalSolicitud')">Cancelar</button>
      <button class="btn btn-primary" onclick="guardarSolicitud()">Guardar</button>
    </div>
  </div>
</div>
