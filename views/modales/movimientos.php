<!-- ══════════════════════════════════════════════
     MODAL MOVIMIENTO — Registrar/Editar movimiento
     ══════════════════════════════════════════════ -->
<div class="modal-bg" id="modalMovimiento">
  <div class="modal" style="max-width:640px">
    <h4 id="tituloModalMovimiento">🚛 Registrar Movimiento</h4>
    <div class="alert alert-error" id="errMovimiento"></div>
    <input type="hidden" id="movId">

    <div class="form-row">
      <div class="form-group">
        <label>Tipo *</label>
        <select id="movTipo">
          <option value="MAERSK">MAERSK</option>
          <option value="ALPLA">ALPLA</option>
        </select>
      </div>
      <div class="form-group">
        <label>Periodo</label>
        <input type="text" id="movPeriodo" placeholder="Ej: 2026-08">
      </div>
    </div>

    <div class="form-row">
      <div class="form-group">
        <label>Fecha *</label>
        <input type="date" id="movFecha">
      </div>
      <div class="form-group">
        <label>Hora</label>
        <input type="time" id="movHora">
      </div>
    </div>

    <!-- Cliente -->
    <div class="form-group" style="margin-bottom:10px">
      <label>Cliente</label>
      <div style="position:relative">
        <input type="text" id="movClienteBuscar" placeholder="🔍 Buscar cliente..."
          oninput="buscarClienteMov()"
          style="width:100%;padding:8px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
        <div id="sugerenciasClienteMov" style="display:none;position:absolute;left:0;right:0;top:calc(100% + 2px);background:var(--sidebar);border:1px solid var(--border);border-radius:8px;z-index:9999;max-height:180px;overflow-y:auto;box-shadow:0 4px 16px rgba(0,0,0,.2)"></div>
      </div>
      <input type="hidden" id="movClienteId">
    </div>

    <div class="form-group">
      <label>Flete</label>
      <input type="text" id="movFlete" placeholder="Ej: Puerto Cortés - San Pedro Sula">
    </div>

    <div class="form-group">
      <label>Cliente / Destino</label>
      <input type="text" id="movDestino" placeholder="Ej: Bodega ALPLA, Choloma">
    </div>

    <div class="form-row">
      <div class="form-group">
        <label>OT</label>
        <input type="text" id="movOt" placeholder="Orden de transporte">
      </div>
      <div class="form-group">
        <label>Contenedor</label>
        <input type="text" id="movContenedor">
      </div>
    </div>

    <div class="form-row">
      <div class="form-group">
        <label>Chasis</label>
        <input type="text" id="movChasis">
      </div>
      <div class="form-group">
        <label>Placa</label>
        <input type="text" id="movPlaca">
      </div>
    </div>

    <div class="form-row">
      <div class="form-group">
        <label>Motorista</label>
        <select id="movMotorista" style="width:100%;padding:8px 12px;background:var(--bg);border:1px solid var(--border);border-radius:7px;color:var(--text);font-size:13px">
          <option value="">— Seleccionar motorista —</option>
        </select>
      </div>
      <div class="form-group">
        <label>Tarifa (L.) *</label>
        <input type="number" id="movTarifa" min="0" step="0.01" placeholder="0.00">
      </div>
    </div>

    <div class="form-group">
      <label>Observación</label>
      <textarea id="movObservacion" rows="2" placeholder="Opcional..."></textarea>
    </div>

    <div class="modal-footer">
      <button class="btn btn-secondary" onclick="cerrarModal('modalMovimiento')">Cancelar</button>
      <button class="btn btn-primary" id="btnGuardarMovimiento" onclick="guardarMovimiento()">
        Registrar Movimiento
      </button>
    </div>
  </div>
</div>

<!-- ══════════════════════════════════════════════
     MODAL VER DETALLE MOVIMIENTO
     ══════════════════════════════════════════════ -->
<div class="modal-bg" id="modalVerMovimiento">
  <div class="modal" style="max-width:640px;width:95%">
    <div id="contenidoVerMov">Cargando...</div>
    <div class="modal-footer">
      <button class="btn btn-secondary" onclick="cerrarModal('modalVerMovimiento')">Cerrar</button>
      <button class="btn btn-primary" onclick="imprimirMovimiento()">🖨️ PDF / Imprimir</button>
    </div>
  </div>
</div>

<!-- ══════════════════════════════════════════════
     MODAL FACTURAR MOVIMIENTOS — selección múltiple
     ══════════════════════════════════════════════ -->
<div class="modal-bg" id="modalFacturarMovimientos">
  <div class="modal" style="max-width:640px">
    <h4>📑 Facturar Movimientos</h4>
    <div class="alert alert-error" id="errFacturarMov"></div>

    <!-- Buscar cliente -->
    <div class="form-group" style="margin-bottom:10px">
      <label>Cliente *</label>
      <div style="position:relative">
        <input type="text" id="multiMovClienteBuscar" placeholder="🔍 Buscar cliente..."
          oninput="buscarClienteMultiMov()"
          style="width:100%;padding:8px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
        <div id="sugerenciasClienteMultiMov" style="display:none;position:absolute;left:0;right:0;top:calc(100% + 2px);background:var(--sidebar);border:1px solid var(--border);border-radius:8px;z-index:9999;max-height:180px;overflow-y:auto;box-shadow:0 4px 16px rgba(0,0,0,.2)"></div>
      </div>
      <input type="hidden" id="multiMovClienteId">
    </div>

    <!-- Lista de movimientos pendientes del cliente -->
    <div id="multiMovListaWrap" style="display:none">
      <div style="font-size:12px;color:var(--muted);margin-bottom:8px">
        Selecciona los movimientos a incluir en la factura:
      </div>
      <div id="multiMovLista" style="max-height:260px;overflow-y:auto"></div>
      <div style="margin-top:10px;padding:10px 12px;background:var(--bg);border-radius:8px;font-size:13px;display:flex;justify-content:space-between">
        <span>Movimientos seleccionados: <strong id="multiMovCount">0</strong></span>
        <span>Total: <strong id="multiMovTotal" style="color:var(--accent)">L. 0.00</strong></span>
      </div>
    </div>
    <div id="multiMovSinMovs" style="display:none;color:var(--muted);font-size:13px;padding:16px 0;text-align:center">
      Sin movimientos pendientes para este cliente.
    </div>

    <!-- Método de pago -->
    <div id="multiMovMetodoWrap" style="display:none;margin-top:14px">
      <div class="section-title">Método de pago</div>
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-bottom:10px">
        <div class="metodo-btn" data-mmov="efectivo" onclick="selMetodoMultiMov('efectivo')"
          style="border:2px solid var(--border);border-radius:8px;padding:10px;text-align:center;cursor:pointer">
          <div style="font-size:20px">💵</div><div style="font-size:12px;font-weight:600">Efectivo</div>
        </div>
        <div class="metodo-btn" data-mmov="credito" onclick="selMetodoMultiMov('credito')"
          style="border:2px solid var(--border);border-radius:8px;padding:10px;text-align:center;cursor:pointer">
          <div style="font-size:20px">📋</div><div style="font-size:12px;font-weight:600">Crédito</div>
        </div>
      </div>
      <div id="multiMovNotaMetodo" style="display:none;font-size:12px;color:var(--muted);margin-bottom:8px"></div>
      <div class="form-group"><label>Observaciones</label>
        <input type="text" id="multiMovObs" placeholder="Opcional...">
      </div>
    </div>

    <div class="modal-footer">
      <button class="btn btn-secondary" onclick="cerrarModal('modalFacturarMovimientos')">Cancelar</button>
      <button class="btn btn-primary" id="btnConfirmarMultiMov" onclick="confirmarFacturarMovimientos()" style="display:none">
        ✓ Emitir Factura
      </button>
    </div>
  </div>
</div>
