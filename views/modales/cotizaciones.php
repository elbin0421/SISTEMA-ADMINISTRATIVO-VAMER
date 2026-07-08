<!-- MODAL COTIZACIÓN DIRECTA -->
<div class="modal-bg" id="modalCotizacionDirecta">
  <div class="modal modal-lg">
    <h4>📑 Nueva Cotización Directa</h4>
    <div class="alert alert-error" id="errCotDir"></div>
    <div class="form-row">
      <div class="form-group">
        <label>Cliente *</label>
        <input type="text" id="cotDirClienteBuscar" placeholder="Buscar cliente..." oninput="buscarClienteCotDir()">
        <input type="hidden" id="cotDirClienteId">
      </div>
      <div class="form-group">
        <label>Vigencia (días)</label>
        <input type="number" id="cotDirVigencia" value="15" min="1" max="90">
      </div>
    </div>
    <div id="sugerenciasClienteCotDir" style="display:none;background:var(--bg);border:1px solid var(--border);border-radius:6px;margin-bottom:8px;max-height:140px;overflow-y:auto"></div>
    <div class="form-row">
      <div class="form-group">
        <label>Unidad / Placa del vehículo</label>
        <select id="cotDirVehiculoSelect" onchange="autoLlenarPlacaCotDir()" style="width:100%;padding:8px 12px;background:var(--bg);border:1px solid var(--border);border-radius:7px;color:var(--text);font-size:13px">
          <option value="">— Sin vehículo / No aplica —</option>
        </select>
      </div>
      <div class="form-group">
        <label>Placa (manual)</label>
        <input type="text" id="cotDirPlaca" placeholder="AAA-0000 o descripción unidad">
      </div>
    </div>
    <div class="form-row">
      <div class="form-group">
        <label>OT Cliente <span style="color:var(--muted);font-size:11px">(ej: 4007731855)</span></label>
        <input type="text" id="cotDirOtCliente" placeholder="Número de OT del cliente">
      </div>
      <div class="form-group">
        <label>Orden de Compra <span style="color:var(--muted);font-size:11px">(ej: 5503905114)</span></label>
        <input type="text" id="cotDirOrdenCompra" placeholder="Número de OC">
      </div>
    </div>
    <div class="form-group"><label>Observaciones</label><input type="text" id="cotDirObs" placeholder="Notas para el cliente..."></div>
    <div class="section-title">📋 Ítems de la cotización</div>
    <div style="background:var(--bg);border:1px solid var(--border);border-radius:9px;padding:12px 14px;margin-bottom:8px">
      <div style="display:grid;grid-template-columns:2fr 1fr 1fr 100px auto;gap:8px;align-items:flex-end">
        <div>
          <label style="display:block;font-size:11px;color:var(--muted);margin-bottom:4px">Descripción</label>
          <input type="text" id="cotDirDesc" placeholder="Descripción del servicio o material" style="width:100%;padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px;outline:none">
        </div>
        <div>
          <label style="display:block;font-size:11px;color:var(--muted);margin-bottom:4px">Tipo</label>
          <select id="cotDirTipo" style="width:100%;padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
            <option value="material">Material</option>
            <option value="mano_obra">Mano de obra</option>
            <option value="otro">Otro</option>
          </select>
        </div>
        <div>
          <label style="display:block;font-size:11px;color:var(--muted);margin-bottom:4px">Cantidad</label>
          <input type="number" id="cotDirCant" value="1" min="0.01" step="0.01" style="width:100%;padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px;outline:none">
        </div>
        <div>
          <label style="display:block;font-size:11px;color:var(--muted);margin-bottom:4px">Precio unit. (L.)</label>
          <input type="number" id="cotDirPrecio" min="0" step="0.01" placeholder="0.00" style="width:100%;padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px;outline:none">
        </div>
        <div style="padding-bottom:1px;display:flex;gap:6px">
          <button class="btn btn-primary" onclick="agregarItemCotDir()">+ Agregar</button>
          <button class="btn btn-secondary" onclick="abrirBuscarCatalogo()" title="Seleccionar del catálogo de precios">📂 Catálogo</button>
        </div>
      </div>
    </div>
    <div class="table-wrap">
      <table id="tablaItemsCotDir">
        <thead><tr><th>Tipo</th><th>Descripción</th><th>Cant.</th><th>Precio unit.</th><th>Subtotal</th><th>Desc.%</th><th>Rebaja</th><th>Neto</th><th></th></tr></thead>
        <tbody id="itemsCotDirBody"><tr><td colspan="9" class="empty-state">Sin ítems</td></tr></tbody>
      </table>
    </div>

    <!-- Totales + Descuento global -->
    <div style="display:flex;justify-content:flex-end;margin-top:12px">
      <div style="width:320px;font-size:13px;background:var(--sidebar);border:1px solid var(--border);border-radius:8px;padding:12px 16px">
        <div style="display:flex;justify-content:space-between;margin-bottom:6px">
          <span style="color:var(--muted)">Subtotal:</span>
          <strong id="cotDirSubtotalMostrar">L. 0.00</strong>
        </div>
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:6px;gap:8px">
          <span style="color:var(--muted);white-space:nowrap">Desc. global (%):</span>
          <input type="number" id="cotDirDescPct" min="0" max="100" step="0.01" value="0"
            style="width:70px;padding:4px 6px;background:var(--bg);border:1px solid var(--border);border-radius:5px;color:var(--text);font-size:12px;text-align:right"
            oninput="recalcCotDir()">
        </div>
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:6px;gap:8px">
          <span style="color:var(--muted);white-space:nowrap">Rebaja global (L.):</span>
          <input type="number" id="cotDirDescMto" min="0" step="0.01" value="0"
            style="width:90px;padding:4px 6px;background:var(--bg);border:1px solid var(--border);border-radius:5px;color:var(--text);font-size:12px;text-align:right"
            oninput="recalcCotDir()">
        </div>
        <div style="display:flex;justify-content:space-between;margin-bottom:6px">
          <span style="color:var(--muted)">ISV 15%:</span>
          <strong id="cotDirISVMostrar">L. 0.00</strong>
        </div>
        <div style="display:flex;justify-content:space-between;border-top:1px solid var(--border);padding-top:8px;margin-top:4px">
          <span style="color:var(--muted)">Total c/ desc.:</span>
          <strong id="cotDirTotalMostrar" style="color:var(--accent);font-size:15px">L. 0.00</strong>
        </div>
      </div>
    </div>
    <div class="modal-footer">
      <button class="btn btn-secondary" onclick="cerrarModal('modalCotizacionDirecta')">Cancelar</button>
      <button class="btn btn-primary" onclick="guardarCotizacionDirecta()">💾 Generar Cotización</button>
    </div>
  </div>
</div>

<!-- MODAL DETALLE COTIZACIÓN -->
<div class="modal-bg" id="modalDetalleCot">
  <div class="modal modal-lg">
    <div id="contenidoDetalleCot"><p class="loading">Cargando...</p></div>
    <div class="modal-footer" id="footerDetalleCot">
      <button class="btn btn-secondary" onclick="cerrarModal('modalDetalleCot')">Cerrar</button>
    </div>
  </div>
</div>
