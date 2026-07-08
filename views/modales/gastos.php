<div class="modal-bg" id="modalGasto">
  <div class="modal" style="max-width:680px">
    <div class="modal-header">
      <h3 id="modalGastoTitulo">🧾 Nuevo Gasto</h3>
      <button class="modal-close" onclick="cerrarModal('modalGasto')">✕</button>
    </div>
    <div class="modal-body">
      <div id="errGasto" class="error-msg" style="display:none"></div>
      <input type="hidden" id="gastoId">

      <!-- Fila 1: Fecha + Tipo doc -->
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-bottom:12px">
        <div><label class="form-label">Fecha *</label><input type="date" id="gastoFecha" class="form-control"></div>
        <div><label class="form-label">Tipo de documento *</label>
          <select id="gastoTipoDoc" class="form-control">
            <option value="factura">Factura</option><option value="recibo">Recibo</option>
            <option value="ticket">Ticket</option><option value="otro">Otro</option>
          </select>
        </div>
      </div>

      <!-- Fila 2: N° Doc + Categoría -->
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-bottom:12px">
        <div><label class="form-label">N° Factura / Documento</label>
          <input type="text" id="gastoNumDoc" class="form-control" placeholder="001-001-01-00000123" style="text-transform:uppercase">
        </div>
        <div><label class="form-label">Categoría *</label>
          <select id="gastoCategoria" class="form-control">
            <option value="materiales">Materiales</option><option value="servicios">Servicios</option>
            <option value="alquiler">Alquiler</option><option value="combustible">Combustible</option>
            <option value="publicidad">Publicidad</option><option value="mantenimiento">Mantenimiento</option>
            <option value="sueldos">Sueldos</option><option value="honorarios">Honorarios</option>
            <option value="utilities">Utilities</option><option value="otros">Otros</option>
          </select>
        </div>
      </div>

      <!-- Fila 3: RTN + Proveedor -->
      <div style="display:grid;grid-template-columns:1fr 2fr;gap:12px;margin-bottom:12px">
        <div>
          <label class="form-label">RTN Proveedor</label>
          <input type="text" id="gastoRTN" class="form-control" placeholder="0801199012345" maxlength="14"
            oninput="this.value=this.value.replace(/\D/g,'');validarRTN()">
          <div id="rtnMsg" style="font-size:11px;margin-top:3px;color:var(--muted)"></div>
        </div>
        <div><label class="form-label">Nombre del Proveedor *</label>
          <input type="text" id="gastoProveedor" class="form-control" placeholder="Razón social" style="text-transform:uppercase">
        </div>
      </div>

      <!-- ── ÍTEMS DE LA FACTURA ── -->
      <div style="margin-bottom:10px">
        <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px">
          <label class="form-label" style="margin:0">Ítems del documento *</label>
          <button class="btn btn-secondary btn-sm" type="button" onclick="agregarItemGasto()">+ Agregar ítem</button>
        </div>
        <div style="border:1px solid var(--border);border-radius:8px;overflow:hidden">
          <table style="width:100%;border-collapse:collapse;font-size:13px">
            <thead>
              <tr style="background:var(--sidebar)">
                <th style="padding:7px 10px;text-align:left;font-weight:600;color:var(--muted);font-size:11px">DESCRIPCIÓN</th>
                <th style="padding:7px 10px;text-align:right;font-weight:600;color:var(--muted);font-size:11px;width:80px">CANT.</th>
                <th style="padding:7px 10px;text-align:right;font-weight:600;color:var(--muted);font-size:11px;width:120px">P. UNIT. (sin ISV)</th>
                <th style="padding:7px 10px;text-align:right;font-weight:600;color:var(--muted);font-size:11px;width:120px">TOTAL ÍTEM</th>
                <th style="width:36px"></th>
              </tr>
            </thead>
            <tbody id="gastoItemsBody"></tbody>
          </table>
        </div>
      </div>

      <!-- Tasa ISV + Totales -->
      <div style="display:flex;justify-content:flex-end;margin-bottom:14px">
        <div style="width:300px;background:var(--bg);border:1px solid var(--border);border-radius:8px;padding:12px 16px;font-size:13px">
          <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:8px;gap:10px">
            <span style="color:var(--muted)">Tasa ISV</span>
            <select id="gastoTasaISV" onchange="calcularGastoISV()"
              style="padding:4px 8px;background:var(--surface);border:1px solid var(--border);border-radius:5px;color:var(--text);font-size:12px">
              <option value="0">0% — Exento</option>
              <option value="15" selected>15% — Estándar</option>
              <option value="18">18% — Especial</option>
            </select>
          </div>
          <div style="display:flex;justify-content:space-between;padding:3px 0;color:var(--muted)">
            <span>Subtotal (sin ISV):</span><strong id="gastoSubtotalMostrar">L. 0.00</strong>
          </div>
          <div style="display:flex;justify-content:space-between;padding:3px 0;color:var(--muted)">
            <span>ISV:</span><strong id="gastoISVMostrar">L. 0.00</strong>
          </div>
          <div style="display:flex;justify-content:space-between;padding:6px 0;border-top:1px solid var(--border);margin-top:4px">
            <strong>TOTAL:</strong><strong id="gastoTotalMostrar" style="color:var(--accent);font-size:15px">L. 0.00</strong>
          </div>
        </div>
      </div>

      <!-- Mes/Año + Estado + Deducible -->
      <div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:12px;margin-bottom:12px">
        <div><label class="form-label">Mes declaración *</label>
          <select id="gastoMes" class="form-control">
            <option value="1">Enero</option><option value="2">Febrero</option><option value="3">Marzo</option>
            <option value="4">Abril</option><option value="5">Mayo</option><option value="6">Junio</option>
            <option value="7">Julio</option><option value="8">Agosto</option><option value="9">Septiembre</option>
            <option value="10">Octubre</option><option value="11">Noviembre</option><option value="12">Diciembre</option>
          </select>
        </div>
        <div><label class="form-label">Año declaración *</label><select id="gastoAnio" class="form-control"></select></div>
        <div><label class="form-label">Estado</label>
          <select id="gastoEstado" class="form-control">
            <option value="pendiente">Pendiente</option><option value="declarado">Declarado</option>
          </select>
        </div>
      </div>
      <div style="display:grid;grid-template-columns:auto 1fr;gap:12px;align-items:center;margin-bottom:12px">
        <div style="display:flex;align-items:center;gap:8px">
          <input type="checkbox" id="gastoDeducible" checked style="width:16px;height:16px;accent-color:var(--accent)">
          <label for="gastoDeducible" style="font-size:13px;cursor:pointer">Gasto deducible ISR</label>
        </div>
        <div><label class="form-label">Observaciones</label>
          <input type="text" id="gastoObs" class="form-control" placeholder="Opcional">
        </div>
      </div>
    </div>
    <div class="modal-footer">
      <button class="btn btn-secondary" onclick="cerrarModal('modalGasto')">Cancelar</button>
      <button class="btn btn-primary" id="btnGuardarGasto" onclick="guardarGasto()">Guardar Gasto</button>
    </div>
  </div>
</div>
