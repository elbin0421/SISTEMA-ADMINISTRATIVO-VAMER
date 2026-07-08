<!-- MODAL NUEVA / EDITAR REQUISICIÓN -->
<div class="modal-bg" id="modalRequisicion">
  <div class="modal" style="max-width:780px;width:95%">
    <h4 id="tituloRequisicion">Nueva Requisición de Materiales</h4>
    <div class="alert alert-error" id="errRequisicion" style="display:none"></div>
    <input type="hidden" id="reqId">

    <!-- Número + Fecha -->
    <div class="form-row">
      <div class="form-group">
        <label>N° Requisición</label>
        <input type="text" id="reqNumero" readonly
               style="background:var(--bg-alt,#1e1e2e);color:var(--accent);cursor:not-allowed;font-family:monospace;font-weight:700;font-size:14px;text-align:center">
      </div>
      <div class="form-group">
        <label>Fecha de Solicitud *</label>
        <input type="date" id="reqFecha">
      </div>
    </div>

    <!-- Empleado + Departamento -->
    <div class="form-row">
      <div class="form-group">
        <label>Empleado que Solicita *</label>
        <select id="reqEmpleado">
          <option value="">— Seleccionar —</option>
        </select>
      </div>
      <div class="form-group">
        <label>Departamento *</label>
        <input type="text" id="reqDepartamento" placeholder="Se llena desde el empleado"
               style="width:100%;padding:8px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
      </div>
    </div>

    <!-- Cliente -->
    <div class="form-row">
      <div class="form-group">
        <label>Cliente *</label>
        <select id="reqClienteId" onchange="cargarUnidadesPorCliente()">
          <option value="">— Seleccionar cliente —</option>
        </select>
      </div>
      <div class="form-group">
        <label>N° OT <span style="color:var(--muted);font-size:11px">(opcional)</span></label>
        <input type="text" id="reqOT" placeholder="OT-2026-001">
      </div>
    </div>

    <!-- Unidad/Placa (carga según cliente) -->
    <div class="form-row">
      <div class="form-group">
        <label>Unidad / Placa *</label>
        <select id="reqUnidadSelect">
          <option value="">— Selecciona primero un cliente —</option>
        </select>
        <input type="text" id="reqUnidad" placeholder="O escribe manualmente si no está en lista..."
               style="margin-top:6px;text-transform:uppercase;width:100%;padding:8px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
        <div style="font-size:11px;color:var(--muted);margin-top:3px">Selecciona de la lista o escribe manualmente.</div>
      </div>
    </div>

    <!-- Tabla de materiales -->
    <div style="margin:12px 0 6px;display:flex;justify-content:space-between;align-items:center">
      <strong style="font-size:13px">Materiales Solicitados</strong>
      <button class="btn btn-primary btn-sm" onclick="agregarFilaReq()">+ Agregar Material</button>
    </div>
    <div class="table-wrap" style="max-height:260px;overflow-y:auto">
      <table>
        <thead>
          <tr>
            <th style="width:35px">#</th>
            <th>Descripción / Material *</th>
            <th style="width:100px">Unidad Med.</th>
            <th style="width:80px">Cantidad *</th>
            <th style="width:140px">Observación</th>
            <th style="width:36px"></th>
          </tr>
        </thead>
        <tbody id="reqDetalleBody">
          <tr id="reqFilaVacia"><td colspan="6" style="text-align:center;color:var(--muted);padding:12px">Sin materiales. Haga clic en "+ Agregar Material".</td></tr>
        </tbody>
      </table>
    </div>

    <!-- Observaciones generales -->
    <div class="form-group" style="margin-top:10px">
      <label>Observaciones Generales</label>
      <textarea id="reqObs" rows="2" placeholder="Notas adicionales..." style="width:100%;padding:8px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px;resize:vertical"></textarea>
    </div>

    <div class="modal-footer">
      <button class="btn btn-secondary" onclick="cerrarModal('modalRequisicion')">Cancelar</button>
      <button class="btn btn-primary" onclick="guardarRequisicion()">💾 Guardar Requisición</button>
    </div>
  </div>
</div>

<!-- MODAL VER DETALLE REQUISICIÓN -->
<div class="modal-bg" id="modalVerRequisicion">
  <div class="modal" style="max-width:780px;width:95%">
    <div id="contenidoVerReq">Cargando...</div>
    <div class="modal-footer">
      <button class="btn btn-secondary" onclick="cerrarModal('modalVerRequisicion')">Cerrar</button>
      <button class="btn btn-secondary" onclick="imprimirRequisicion()">🖨️ Imprimir</button>
    </div>
  </div>
</div>
