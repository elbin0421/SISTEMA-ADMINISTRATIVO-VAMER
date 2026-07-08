<div class="module" id="mod-cai">
  <div class="card">
    <div class="card-header">
      <h4>🏷️ CAI — Control Autorización de Impresión (SAR)</h4>
      <button class="btn btn-primary" onclick="mostrarFormCAI()">+ Registrar CAI</button>
    </div>

    <!-- CAI activo -->
    <div id="caiActivoWrap" style="margin-bottom:18px">
      <p class="loading">Cargando CAI activo...</p>
    </div>

    <!-- Formulario registrar CAI (oculto por defecto) -->
    <div id="formCAIWrap" style="display:none;background:var(--bg);border:1px solid var(--border);border-radius:10px;padding:18px;margin-bottom:18px">
      <div style="font-weight:600;margin-bottom:12px;font-size:14px">Registrar nuevo CAI</div>
      <div class="alert alert-error" id="errCAIModulo"></div>
      <div class="form-group">
        <label>Código CAI *</label>
        <input type="text" id="caiCodigoM" placeholder="XXXXXX-XXXXXX-XXXXXX-XXXXXX-XXXXXX-XX" style="font-family:monospace;letter-spacing:.5px">
      </div>
      <div class="form-row">
        <div class="form-group"><label>Correlativo inicio *</label><input type="text" id="caiInicioM" placeholder="001-001-01-00000001" style="font-family:monospace"></div>
        <div class="form-group"><label>Correlativo fin *</label><input type="text" id="caiFinalM" placeholder="001-001-01-00099999" style="font-family:monospace"></div>
      </div>
      <div class="form-row">
        <div class="form-group"><label>Fecha límite de emisión *</label><input type="date" id="caiFechaLimiteM"></div>
        <div class="form-group"><label>Establecimiento</label><input type="text" id="caiEstablecimientoM" value="001" maxlength="3"></div>
      </div>
      <div style="display:flex;gap:8px;margin-top:4px">
        <button class="btn btn-primary" onclick="guardarCAIModulo()">💾 Guardar CAI</button>
        <button class="btn btn-secondary" onclick="ocultarFormCAI()">Cancelar</button>
      </div>
    </div>

    <!-- Historial de CAIs -->
    <div class="section-title">Historial de CAI registrados</div>
    <div class="table-wrap" id="tablaCAILista"><p class="loading">Cargando...</p></div>
  </div>
</div>
