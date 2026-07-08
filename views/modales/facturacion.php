<!-- MODAL DETALLE FACTURA -->
<div class="modal-bg" id="modalDetalleFactura">
  <div class="modal modal-lg">
    <div id="contenidoDetalleFactura"><p class="loading">Cargando...</p></div>
    <div class="modal-footer" id="footerDetalleFactura">
      <button class="btn btn-secondary" onclick="cerrarModal('modalDetalleFactura')">Cerrar</button>
    </div>
  </div>
</div>

<!-- MODAL REGISTRAR PAGO -->
<div class="modal-bg" id="modalRegistrarPago">
  <div class="modal" style="max-width:460px">
    <h4>💳 Registrar Pago</h4>
    <div class="alert alert-error" id="errPago"></div>
    <input type="hidden" id="pagoFacturaId">
    <input type="hidden" id="pagoFacturaSubtotal">
    <div style="background:var(--bg);border:1px solid var(--border);border-radius:8px;padding:10px 14px;margin-bottom:14px;font-size:13px">
      <div id="pagoFacturaInfo" style="color:var(--muted);margin-bottom:6px"></div>
      <div style="display:flex;justify-content:space-between;align-items:center">
        <span style="color:var(--muted);font-size:12px">Saldo pendiente:</span>
        <strong id="pagoSaldoPendiente" style="font-size:15px;color:var(--accent)">L. 0.00</strong>
      </div>
    </div>
    <div class="form-row">
      <div class="form-group">
        <label>Monto a cobrar (L.) *</label>
        <input type="number" id="pagoMonto" min="0.01" step="0.01" placeholder="0.00" oninput="pagoRecalcular()">
      </div>
      <div class="form-group">
        <label>Fecha</label>
        <input type="date" id="pagoFecha">
      </div>
    </div>
    <div style="background:var(--bg);border:1px solid var(--border);border-radius:8px;padding:12px 14px;margin-bottom:14px">
      <div style="font-size:11px;text-transform:uppercase;letter-spacing:.6px;color:var(--muted);font-weight:600;margin-bottom:10px">📋 Retenciones (opcional)</div>
      <div class="form-row" style="margin-bottom:8px">
        <div class="form-group" style="margin-bottom:0">
          <label style="font-size:12px">
            <input type="checkbox" id="chkRetencionISR" onchange="pagoToggleRetencion('isr')" style="margin-right:6px">
            Retención ISR 1% sobre subtotal
          </label>
          <div id="retencionISRGrupo" style="display:none;margin-top:6px">
            <input type="number" id="pagoRetencionISR" min="0" step="0.01" placeholder="0.00" readonly
              style="width:100%;padding:6px 10px;background:var(--surface);border:1px solid var(--border);border-radius:6px;color:var(--accent);font-size:13px;font-family:monospace;font-weight:600">
          </div>
        </div>
        <div class="form-group" style="margin-bottom:0">
          <label style="font-size:12px">
            <input type="checkbox" id="chkRetencionISV" onchange="pagoToggleRetencion('isv')" style="margin-right:6px">
            Retención ISV 12.5% sobre subtotal
          </label>
          <div id="retencionISVGrupo" style="display:none;margin-top:6px">
            <input type="number" id="pagoRetencionISV" min="0" step="0.01" placeholder="0.00" readonly
              style="width:100%;padding:6px 10px;background:var(--surface);border:1px solid var(--border);border-radius:6px;color:var(--accent);font-size:13px;font-family:monospace;font-weight:600">
          </div>
        </div>
      </div>
      <div id="pagoResumenNeto" style="display:none;border-top:1px solid var(--border);padding-top:10px;margin-top:4px;font-size:13px;line-height:2">
        <div style="display:flex;justify-content:space-between"><span style="color:var(--muted)">Monto bruto:</span> <span id="resNBruto">L. 0.00</span></div>
        <div style="display:flex;justify-content:space-between"><span style="color:var(--muted)">− Ret. ISR 1%:</span> <span id="resNISR" style="color:var(--danger)">L. 0.00</span></div>
        <div style="display:flex;justify-content:space-between"><span style="color:var(--muted)">− Ret. ISV 12.5%:</span> <span id="resNISV" style="color:var(--danger)">L. 0.00</span></div>
        <div style="display:flex;justify-content:space-between;border-top:1px solid var(--border);padding-top:4px;margin-top:4px">
          <span style="font-weight:600">Neto a recibir:</span>
          <strong id="resNNeto" style="color:var(--success);font-size:14px">L. 0.00</strong>
        </div>
      </div>
    </div>
    <div class="form-group">
      <label>Método de pago *</label>
      <div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:8px;margin-top:4px">
        <div class="metodo-pago-btn" onclick="selMetodoPagoFac('efectivo')" data-mfac="efectivo"
          style="border:2px solid var(--border);border-radius:8px;padding:10px 6px;text-align:center;cursor:pointer">
          <div style="font-size:20px">💵</div><div style="font-size:11px;font-weight:600">Efectivo</div>
        </div>
        <div class="metodo-pago-btn" onclick="selMetodoPagoFac('tarjeta')" data-mfac="tarjeta"
          style="border:2px solid var(--border);border-radius:8px;padding:10px 6px;text-align:center;cursor:pointer">
          <div style="font-size:20px">💳</div><div style="font-size:11px;font-weight:600">Tarjeta</div>
        </div>
        <div class="metodo-pago-btn" onclick="selMetodoPagoFac('transferencia')" data-mfac="transferencia"
          style="border:2px solid var(--border);border-radius:8px;padding:10px 6px;text-align:center;cursor:pointer">
          <div style="font-size:20px">🏦</div><div style="font-size:11px;font-weight:600">Transferencia</div>
        </div>
      </div>
    </div>
    <div class="form-group" id="pagoRefGrupoFac" style="display:none">
      <label>Referencia <span style="color:var(--muted);font-size:11px">(No. tarjeta / transferencia)</span></label>
      <input type="text" id="pagoRefFac" placeholder="Número de referencia">
    </div>
    <div class="modal-footer">
      <button class="btn btn-secondary" onclick="cerrarModal('modalRegistrarPago')">Cancelar</button>
      <button class="btn btn-primary" onclick="confirmarPago()">✓ Registrar Pago</button>
    </div>
  </div>
</div>

<!-- MODAL FACTURAR DESDE COTIZACIÓN -->
<div class="modal-bg" id="modalFacturarCotizacion">
  <div class="modal" style="max-width:440px">
    <h4>🧾 Generar Factura desde Cotización</h4>
    <div class="alert alert-error" id="errFacturarCot"></div>

    <!-- Resumen de la cotización -->
    <div id="facturarCotResumen" style="background:var(--bg);border:1px solid var(--border);border-radius:8px;padding:12px 16px;font-size:13px;margin-bottom:14px">
      <p style="color:var(--muted);font-size:12px">Cargando resumen...</p>
    </div>

    <div class="form-group">
      <label>Método de pago *</label>
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-top:4px">
        <div class="metodo-cot-btn" onclick="facturarCotSelMetodo('efectivo')" data-mcot="efectivo"
          style="border:2px solid var(--border);border-radius:8px;padding:12px 6px;text-align:center;cursor:pointer">
          <div style="font-size:22px">💵</div><div style="font-size:12px;font-weight:600">Contado</div>
          <div style="font-size:10px;color:var(--muted);margin-top:2px">Efectivo / Tarjeta / Transferencia</div>
        </div>
        <div class="metodo-cot-btn" onclick="facturarCotSelMetodo('credito')" data-mcot="credito"
          style="border:2px solid var(--border);border-radius:8px;padding:12px 6px;text-align:center;cursor:pointer">
          <div style="font-size:22px">📋</div><div style="font-size:12px;font-weight:600">Crédito</div>
          <div style="font-size:10px;color:var(--muted);margin-top:2px">Pago posterior</div>
        </div>
      </div>
      <div id="facturarCotNotaMetodo" style="font-size:11px;color:var(--muted);margin-top:6px;display:none"></div>
    </div>
    <div class="form-group" id="facturarCotRefGrupo" style="display:none">
      <label>Referencia <span style="color:var(--muted);font-size:11px">(No. tarjeta / transferencia)</span></label>
      <input type="text" id="facturarCotRef" placeholder="Número de referencia">
    </div>
    <div class="modal-footer">
      <button class="btn btn-secondary" onclick="cerrarModal('modalFacturarCotizacion')">Cancelar</button>
      <button class="btn btn-primary" onclick="confirmarFacturarCotizacion()">🧾 Emitir Factura</button>
    </div>
  </div>
</div>

<!-- MODAL FACTURA DIRECTA -->
<div class="modal-bg" id="modalFacturaDirecta">
  <div class="modal modal-lg" style="max-width:680px">
    <h4>🧾 Nueva Factura Directa</h4>
    <div class="alert alert-error" id="errFacturaDirecta"></div>
    <div class="form-row">
      <div class="form-group" style="flex:2">
        <label>Cliente *</label>
        <select id="fdClienteId" style="width:100%;padding:8px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
          <option value="">— Seleccionar cliente —</option>
        </select>
      </div>
      <div class="form-group" style="flex:1">
        <label>Fecha</label>
        <input type="date" id="fdFecha">
      </div>
    </div>
    <div class="form-group">
      <label>Observaciones</label>
      <input type="text" id="fdObservaciones" placeholder="Opcional...">
    </div>
    <div class="section-title" style="margin-top:8px">📋 Ítems de factura</div>
    <div id="fdItemsWrap" style="display:flex;flex-direction:column;gap:8px;margin-bottom:10px"></div>
    <button class="btn btn-secondary btn-sm" onclick="fdAgregarItem()" style="margin-bottom:12px">+ Agregar ítem</button>
    <div style="background:var(--bg);border:1px solid var(--border);border-radius:8px;padding:12px 16px;text-align:right;font-size:13px;line-height:2.2;margin-bottom:14px">
      <div style="display:flex;justify-content:space-between;align-items:center">
        <span style="color:var(--muted)">Subtotal (sin ISV):</span>
        <strong id="fdSubtotal">L. 0.00</strong>
      </div>
      <div style="display:flex;justify-content:space-between;align-items:center;gap:8px">
        <span style="color:var(--muted);white-space:nowrap">Desc. (%):</span>
        <input type="number" id="fdDescPct" min="0" max="100" step="0.01" value="0"
          style="width:70px;padding:3px 6px;background:var(--surface);border:1px solid var(--border);border-radius:5px;color:var(--text);font-size:12px;text-align:right"
          oninput="fdRecalcular()">
      </div>
      <div style="display:flex;justify-content:space-between;align-items:center;gap:8px">
        <span style="color:var(--muted);white-space:nowrap">Rebaja (L.):</span>
        <input type="number" id="fdDescMto" min="0" step="0.01" value="0"
          style="width:90px;padding:3px 6px;background:var(--surface);border:1px solid var(--border);border-radius:5px;color:var(--text);font-size:12px;text-align:right"
          oninput="fdRecalcular()">
      </div>
      <div style="display:flex;justify-content:space-between;align-items:center">
        <span style="color:var(--muted)">ISV 15%:</span>
        <strong id="fdISV">L. 0.00</strong>
      </div>
      <div style="display:flex;justify-content:space-between;align-items:center;border-top:1px solid var(--border);padding-top:6px;margin-top:4px">
        <span style="font-size:15px;font-weight:600">TOTAL:</span>
        <strong id="fdTotal" style="font-size:16px;color:var(--accent)">L. 0.00</strong>
      </div>
    </div>
    <div class="form-group">
      <label>Método de pago *</label>
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-top:4px">
        <div class="fd-metodo-btn" onclick="fdSelMetodo('efectivo')" data-mfd="efectivo"
          style="border:2px solid var(--border);border-radius:8px;padding:12px 6px;text-align:center;cursor:pointer">
          <div style="font-size:22px">💵</div><div style="font-size:12px;font-weight:600">Contado</div>
          <div style="font-size:10px;color:var(--muted);margin-top:2px">Efectivo / Tarjeta / Transferencia</div>
        </div>
        <div class="fd-metodo-btn" onclick="fdSelMetodo('credito')" data-mfd="credito"
          style="border:2px solid var(--border);border-radius:8px;padding:12px 6px;text-align:center;cursor:pointer">
          <div style="font-size:22px">📋</div><div style="font-size:12px;font-weight:600">Crédito</div>
          <div style="font-size:10px;color:var(--muted);margin-top:2px">Pago posterior</div>
        </div>
      </div>
      <div id="fdNotaMetodo" style="font-size:11px;color:var(--muted);margin-top:6px;display:none"></div>
    </div>
    <div class="form-group" id="fdRefGrupo" style="display:none">
      <label>Referencia <span style="color:var(--muted);font-size:11px">(No. tarjeta / transferencia)</span></label>
      <input type="text" id="fdReferencia" placeholder="Número de referencia">
    </div>
    <div class="modal-footer">
      <button class="btn btn-secondary" onclick="cerrarModal('modalFacturaDirecta')">Cancelar</button>
      <button class="btn btn-primary" onclick="confirmarFacturaDirecta()">🧾 Emitir Factura</button>
    </div>
  </div>
</div>

<!-- MODAL CAI -->
<div class="modal-bg" id="modalCAI">
  <div class="modal">
    <h4>⚙️ Configurar CAI</h4>
    <div class="alert alert-error" id="errCAI"></div>
    <div id="caiActualInfo" style="background:var(--bg);border:1px solid var(--border);border-radius:8px;padding:12px;margin-bottom:16px;font-size:13px"></div>
    <div class="section-title">Registrar nuevo CAI</div>
    <div class="form-group"><label>Código CAI *</label><input type="text" id="caiCodigo" placeholder="XXXXXX-XXXXXX-XXXXXX-XXXXXX-XXXXXX-XX" style="font-family:monospace"></div>
    <div class="form-row">
      <div class="form-group"><label>Rango inicio *</label><input type="text" id="caiInicio" placeholder="001-001-01-00000001" style="font-family:monospace"></div>
      <div class="form-group"><label>Rango fin *</label><input type="text" id="caiFin" placeholder="001-001-01-00099999" style="font-family:monospace"></div>
    </div>
    <div class="form-row">
      <div class="form-group"><label>Fecha límite emisión *</label><input type="date" id="caiFechaLimite"></div>
      <div class="form-group"><label>Establecimiento</label><input type="text" id="caiEstablecimiento" value="001" maxlength="3"></div>
    </div>
    <div class="modal-footer">
      <button class="btn btn-secondary" onclick="cerrarModal('modalCAI')">Cancelar</button>
      <button class="btn btn-primary" onclick="guardarCAI()">💾 Guardar CAI</button>
    </div>
  </div>
</div>

<!-- MODAL ANULAR FACTURA -->
<div class="modal-bg" id="modalAnularFactura">
  <div class="modal" style="max-width:400px">
    <h4>🚫 Anular Factura</h4>
    <div class="alert alert-error" id="errAnular"></div>
    <input type="hidden" id="anularFacturaId">
    <p id="anularFacturaInfo" style="font-size:13px;color:var(--muted);margin-bottom:12px"></p>
    <div class="form-group"><label>Motivo de anulación *</label><textarea id="anularMotivo" placeholder="Describa el motivo..." rows="3"></textarea></div>
    <div class="modal-footer">
      <button class="btn btn-secondary" onclick="cerrarModal('modalAnularFactura')">Cancelar</button>
      <button class="btn btn-danger" onclick="confirmarAnulacion()">🚫 Anular</button>
    </div>
  </div>
</div>

<!-- MODAL FACTURAR MÚLTIPLES COTIZACIONES -->
<div class="modal-bg" id="modalFacturarMultiple">
  <div class="modal" style="max-width:640px">
    <h4>📑 Facturar varias cotizaciones</h4>
    <div class="alert alert-error" id="errFacturarMulti"></div>

    <!-- Buscar cliente -->
    <div class="form-group" style="margin-bottom:10px">
      <label>Cliente *</label>
      <div style="position:relative">
        <input type="text" id="multiCotClienteBuscar" placeholder="🔍 Buscar cliente..."
          oninput="buscarClienteMultiCot()"
          style="width:100%;padding:8px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
        <div id="sugerenciasClienteMulti" style="display:none;position:absolute;left:0;right:0;top:calc(100% + 2px);background:var(--sidebar);border:1px solid var(--border);border-radius:8px;z-index:9999;max-height:180px;overflow-y:auto;box-shadow:0 4px 16px rgba(0,0,0,.2)"></div>
      </div>
      <input type="hidden" id="multiCotClienteId">
    </div>

    <!-- Lista de cotizaciones aprobadas del cliente -->
    <div id="multiCotListaWrap" style="display:none">
      <div style="font-size:12px;color:var(--muted);margin-bottom:8px">
        Selecciona las cotizaciones a incluir en la factura:
      </div>
      <div id="multiCotLista" style="max-height:260px;overflow-y:auto"></div>
      <div style="margin-top:10px;padding:10px 12px;background:var(--bg);border-radius:8px;font-size:13px;display:flex;justify-content:space-between">
        <span>Cotizaciones seleccionadas: <strong id="multiCotCount">0</strong></span>
        <span>Total: <strong id="multiCotTotal" style="color:var(--accent)">L. 0.00</strong></span>
      </div>
    </div>
    <div id="multiCotSinCots" style="display:none;color:var(--muted);font-size:13px;padding:16px 0;text-align:center">
      Sin cotizaciones aprobadas para este cliente.
    </div>

    <!-- Método de pago -->
    <div id="multiCotMetodoWrap" style="display:none;margin-top:14px">
      <div class="section-title">Método de pago</div>
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-bottom:10px">
        <div class="metodo-btn" data-mmulti="efectivo" onclick="selMetodoMulti('efectivo')"
          style="border:2px solid var(--border);border-radius:8px;padding:10px;text-align:center;cursor:pointer">
          <div style="font-size:20px">💵</div><div style="font-size:12px;font-weight:600">Efectivo</div>
        </div>
        <div class="metodo-btn" data-mmulti="credito" onclick="selMetodoMulti('credito')"
          style="border:2px solid var(--border);border-radius:8px;padding:10px;text-align:center;cursor:pointer">
          <div style="font-size:20px">📋</div><div style="font-size:12px;font-weight:600">Crédito</div>
        </div>
      </div>
      <div id="multiNotaMetodo" style="display:none;font-size:12px;color:var(--muted);margin-bottom:8px"></div>
      <div class="form-group"><label>Observaciones</label>
        <input type="text" id="multiCotObs" placeholder="Opcional...">
      </div>
    </div>

    <div class="modal-footer">
      <button class="btn btn-secondary" onclick="cerrarModal('modalFacturarMultiple')">Cancelar</button>
      <button class="btn btn-primary" id="btnConfirmarMulti" onclick="confirmarFacturarMultiple()" style="display:none">
        ✓ Emitir Factura
      </button>
    </div>
  </div>
</div>
