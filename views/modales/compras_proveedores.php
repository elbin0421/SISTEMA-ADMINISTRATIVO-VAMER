<!-- MODAL COMPRA -->
<div class="modal-bg" id="modalCompra">
  <div class="modal modal-lg">
    <h4>Nueva Compra</h4>
    <div class="alert alert-error" id="errCompra"></div>
    <div class="form-row">
      <div class="form-group"><label>Proveedor *</label><select id="compraProveedor"><option value="">Seleccionar...</option></select></div>
      <div class="form-group"><label>Fecha *</label><input type="date" id="compraFecha"></div>
    </div>
    <div class="form-row">
      <div class="form-group"><label>No. Factura proveedor</label><input type="text" id="compraNroDoc" placeholder="Número de documento"></div>
    </div>
    <div class="form-group"><label>Observaciones</label><input type="text" id="compraObs"></div>
    <div class="section-title">📦 Materiales de la compra</div>
    <div style="background:var(--bg);border:1px solid var(--border);border-radius:9px;padding:12px 14px;margin-bottom:8px">
      <div style="margin-bottom:10px">
        <label style="display:block;font-size:11px;color:var(--muted);margin-bottom:5px;font-weight:500">Material</label>
        <input type="text" id="compraMatBuscar" placeholder="Buscar material..." oninput="buscarMatCompra()" style="padding:8px 10px;background:var(--bg);border:1px solid var(--border);border-radius:7px;color:var(--text);font-size:13px;outline:none;width:100%">
      </div>
      <div style="display:grid;grid-template-columns:1fr 1fr 1fr auto;gap:8px;align-items:flex-end">
        <div>
          <label style="display:block;font-size:11px;color:var(--muted);margin-bottom:5px;font-weight:500">Cantidad</label>
          <input type="number" id="compraMatCant" min="0.01" step="0.01" placeholder="0" oninput="calcIsvItem()" style="padding:8px 10px;background:var(--bg);border:1px solid var(--border);border-radius:7px;color:var(--text);font-size:13px;outline:none;width:100%">
        </div>
        <div>
          <label style="display:block;font-size:11px;color:var(--muted);margin-bottom:5px;font-weight:500">Precio unit. (L.)</label>
          <input type="number" id="compraMatPrecio" min="0" step="0.01" placeholder="0.00" oninput="calcIsvItem()" style="padding:8px 10px;background:var(--bg);border:1px solid var(--border);border-radius:7px;color:var(--text);font-size:13px;outline:none;width:100%">
        </div>
        <div>
          <label style="display:block;font-size:11px;color:var(--muted);margin-bottom:5px;font-weight:500">ISV 15% (L.) <span style="color:var(--accent);font-size:10px">auto</span></label>
          <input type="number" id="compraImpuesto" value="0" readonly style="padding:8px 10px;background:var(--sidebar);border:1px solid var(--border);border-radius:7px;color:var(--muted);font-size:13px;width:100%">
        </div>
        <div style="padding-bottom:1px">
          <button class="btn btn-primary" onclick="agregarItemCompra()" style="white-space:nowrap;padding:8px 16px">+ Agregar</button>
        </div>
      </div>
    </div>
    <div id="sugerenciasMatCompra" style="display:none;background:var(--bg);border:1px solid var(--border);border-radius:6px;margin-bottom:8px;max-height:140px;overflow-y:auto"></div>
    <input type="hidden" id="compraMatId">
    <div class="table-wrap"><table id="tablaItemsCompra">
      <thead><tr><th>Material</th><th>Cantidad</th><th>Precio unit.</th><th>ISV</th><th>Subtotal</th><th></th></tr></thead>
      <tbody id="itemsCompraBody"><tr><td colspan="5" class="empty-state">Sin items</td></tr></tbody>
    </table></div>
    <div style="text-align:right;margin-top:10px;font-size:13px;color:var(--muted)">
      Subtotal: <strong id="compraSubtotalMostrar">L. 0.00</strong> &nbsp;|&nbsp;
      Total: <strong id="compraTotalMostrar" style="color:var(--accent)">L. 0.00</strong>
    </div>
    <div class="modal-footer">
      <button class="btn btn-secondary" onclick="cerrarModal('modalCompra')">Cancelar</button>
      <button class="btn btn-primary" onclick="guardarCompra()">Guardar Compra</button>
    </div>
  </div>
</div>

<!-- MODAL PAGO COMPRA -->
<div class="modal-bg" id="modalPagoCompra">
  <div class="modal" style="max-width:380px">
    <h4>💳 Registrar Pago</h4>
    <div class="alert alert-error" id="errPagoCompra"></div>
    <input type="hidden" id="pagoCompraId">
    <p id="pagoCompraInfo" style="font-size:13px;color:var(--muted);margin-bottom:16px"></p>
    <div class="form-group">
      <label>Método de pago *</label>
      <div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:8px;margin-top:4px" id="metodoPagoOpts">
        <div class="metodo-pago-btn" onclick="selMetodoPago('efectivo')" data-metodo="efectivo"
          style="border:2px solid var(--border);border-radius:8px;padding:12px 8px;text-align:center;cursor:pointer;transition:all .15s">
          <div style="font-size:22px">💵</div>
          <div style="font-size:12px;margin-top:4px;font-weight:600">Efectivo</div>
        </div>
        <div class="metodo-pago-btn" onclick="selMetodoPago('tarjeta')" data-metodo="tarjeta"
          style="border:2px solid var(--border);border-radius:8px;padding:12px 8px;text-align:center;cursor:pointer;transition:all .15s">
          <div style="font-size:22px">💳</div>
          <div style="font-size:12px;margin-top:4px;font-weight:600">Tarjeta</div>
        </div>
        <div class="metodo-pago-btn" onclick="selMetodoPago('credito')" data-metodo="credito"
          style="border:2px solid var(--border);border-radius:8px;padding:12px 8px;text-align:center;cursor:pointer;transition:all .15s">
          <div style="font-size:22px">🏦</div>
          <div style="font-size:12px;margin-top:4px;font-weight:600">Crédito</div>
        </div>
      </div>
    </div>
    <div class="form-group" id="pagoRefGrupo" style="display:none">
      <label>Referencia <span style="color:var(--muted);font-size:11px">(No. tarjeta / transferencia)</span></label>
      <input type="text" id="pagoCompraRef" placeholder="Número de referencia">
    </div>
    <div class="modal-footer">
      <button class="btn btn-secondary" onclick="cerrarModal('modalPagoCompra')">Cancelar</button>
      <button class="btn btn-primary" onclick="confirmarPagoCompra()">✓ Confirmar Pago</button>
    </div>
  </div>
</div>

<!-- MODAL PROVEEDOR -->
<div class="modal-bg" id="modalProveedor">
  <div class="modal">
    <h4 id="tituloProveedor">Nuevo Proveedor</h4>
    <div class="alert alert-error" id="errProveedor"></div>
    <input type="hidden" id="pId">
    <div class="form-group"><label>Nombre *</label><input type="text" id="pNombre" placeholder="Nombre o razón social"></div>
    <div class="form-row">
      <div class="form-group"><label>RTN</label><input type="text" id="pRtn"></div>
      <div class="form-group"><label>Teléfono</label><input type="text" id="pTel"></div>
    </div>
    <div class="form-row">
      <div class="form-group"><label>Correo</label><input type="email" id="pCorreo"></div>
      <div class="form-group"><label>Contacto</label><input type="text" id="pContacto"></div>
    </div>
    <div class="form-group"><label>Dirección</label><input type="text" id="pDir"></div>
    <div class="modal-footer">
      <button class="btn btn-secondary" onclick="cerrarModal('modalProveedor')">Cancelar</button>
      <button class="btn btn-primary" onclick="guardarProveedor()">Guardar</button>
    </div>
  </div>
</div>
