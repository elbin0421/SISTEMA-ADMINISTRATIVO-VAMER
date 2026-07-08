<!-- MODAL OT -->
<div class="modal-bg" id="modalOT">
  <div class="modal modal-lg">
    <h4 id="tituloOT">Nueva Orden de Trabajo</h4>
    <div class="alert alert-error" id="errOT"></div>
    <input type="hidden" id="otId">
    <div class="section-title">👤 Cliente y Técnico</div>
    <div class="form-row">
      <div class="form-group"><label>Cliente *</label><input type="text" id="otClienteBuscar" placeholder="Buscar cliente..." oninput="buscarClienteOT()"><input type="hidden" id="otClienteId"></div>
      <div class="form-group">
        <label>Técnicos asignados <span style="color:var(--muted);font-size:11px">(puedes seleccionar varios)</span></label>
        <div id="otTecnicosWrap" style="background:var(--bg);border:1px solid var(--border);border-radius:7px;padding:10px 14px;max-height:160px;overflow-y:auto">
          <p style="color:var(--muted);font-size:13px">Cargando...</p>
        </div>
      </div>
    </div>
    <div id="sugerenciasClienteOT" style="display:none;background:var(--bg);border:1px solid var(--border);border-radius:6px;margin-bottom:8px;max-height:140px;overflow-y:auto"></div>
    <div class="form-row">
      <div class="form-group"><label>Fecha apertura</label><input type="date" id="otFecha"></div>
    </div>
    <div class="section-title">🚗 Datos del Vehículo</div>
    <div class="form-row">
      <div class="form-group">
        <label>Vehículo registrado <span style="color:var(--muted);font-size:11px">(selecciona o llena manualmente)</span></label>
        <select id="otVehiculoSelect" onchange="autoLlenarVehiculoOT()" style="width:100%;padding:8px 12px;background:var(--bg);border:1px solid var(--border);border-radius:7px;color:var(--text);font-size:13px">
          <option value="">— Seleccionar vehículo del cliente —</option>
        </select>
      </div>
    </div>
    <div class="form-row-3">
      <div class="form-group"><label>Placa</label><input type="text" id="otPlaca" placeholder="AAA-0000"></div>
      <div class="form-group"><label>Marca</label><input type="text" id="otMarca" placeholder="Toyota, Ford..."></div>
      <div class="form-group"><label>Modelo</label><input type="text" id="otModelo" placeholder="Hilux, F-150..."></div>
    </div>
    <div class="form-row-3">
      <div class="form-group"><label>Año</label><input type="number" id="otAnio" placeholder="2020" min="1900" max="2099"></div>
      <div class="form-group"><label>Color</label><input type="text" id="otColor" placeholder="Blanco"></div>
      <div class="form-group"><label>Kilometraje</label><input type="number" id="otKm" placeholder="0" min="0"></div>
    </div>
    <div class="form-row">
      <div class="form-group"><label>No. Motor</label><input type="text" id="otMotor"></div>
      <div class="form-group"><label>No. Chasis</label><input type="text" id="otChasis"></div>
    </div>
    <div class="section-title">🔧 Trabajo</div>
    <div class="form-group">
      <label>Descripción del trabajo *</label>
      <div id="otDescWrap" style="background:var(--bg);border:1px solid var(--border);border-radius:7px;padding:10px;min-height:80px;max-height:200px;overflow-y:auto"></div>
      <button type="button" onclick="agregarLineaTrabajo()" class="btn btn-sm btn-secondary" style="margin-top:8px">+ Trabajo</button>
      <input type="hidden" id="otDesc">
    </div>
    <div class="form-group"><label>Observaciones</label><textarea id="otObs" placeholder="Notas adicionales..."></textarea></div>
    <div class="modal-footer">
      <button class="btn btn-secondary" onclick="cerrarModal('modalOT')">Cancelar</button>
      <button class="btn btn-primary" onclick="guardarOT()">Guardar OT</button>
    </div>
  </div>
</div>

<!-- MODAL DETALLE OT -->
<div class="modal-bg" id="modalDetalleOT">
  <div class="modal modal-lg">
    <div id="contenidoDetalleOT"><p class="loading">Cargando...</p></div>
    <div class="modal-footer"><button class="btn btn-secondary" onclick="cerrarModal('modalDetalleOT')">Cerrar</button></div>
  </div>
</div>
