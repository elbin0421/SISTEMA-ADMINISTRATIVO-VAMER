<!-- MODAL REGISTRAR / CORREGIR MARCA -->
<div class="modal-bg" id="modalMarca">
  <div class="modal" style="max-width:480px">
    <h4 id="mcMarcaTitulo">Registrar marca</h4>
    <div class="alert alert-error" id="mcMarcaErr"></div>
    <div class="form-group">
      <label>Empleado *</label>
      <input type="text" id="mcMarcaBuscar" placeholder="🔍 Buscar empleado..." autocomplete="off" oninput="mcBuscarEmp()" onfocus="mcBuscarEmp()"
        onblur="setTimeout(()=>{document.getElementById('mcMarcaSug').style.display='none'},180)">
      <input type="hidden" id="mcMarcaEmp">
      <div id="mcMarcaSug" style="display:none;background:var(--surface,var(--bg));border:1px solid var(--border);border-radius:6px;margin-top:2px;max-height:180px;overflow-y:auto"></div>
      <div id="mcMarcaMulti">
        <div style="display:flex;gap:6px;flex-wrap:wrap;margin-top:8px;align-items:center">
          <select id="mcMarcaEmpresa" style="flex:1;min-width:130px" onchange="mcFiltroEmpresa()"><option value="">Empresa: Todas</option><option value="1">SOLDYMEG</option><option value="2">VAMER</option></select>
          <select id="mcMarcaDepto" style="flex:1;min-width:140px" onchange="mcAgregarDepto()"><option value="">+ Agregar departamento…</option></select>
          <button type="button" class="btn btn-sm btn-secondary" onclick="mcAgregarTodos()">+ Todos</button>
          <button type="button" class="btn btn-sm btn-secondary" onclick="mcLimpiarSel()">Limpiar</button>
        </div>
        <div id="mcMarcaChips" style="display:flex;flex-wrap:wrap;gap:5px;margin-top:8px;max-height:110px;overflow-y:auto"></div>
        <div id="mcMarcaCont" style="font-size:12px;color:var(--muted);margin-top:4px"></div>
        <label style="display:flex;gap:6px;align-items:center;font-size:12px;margin-top:6px;font-weight:400"><input type="checkbox" id="mcMarcaSobre"> Sobrescribir a quienes ya tienen marca ese día</label>
      </div>
    </div>
    <div class="form-row">
      <div class="form-group"><label>Fecha *</label><input type="date" id="mcMarcaFecha"></div>
      <div class="form-group"><label>Origen</label>
        <select id="mcMarcaOrigen">
          <option value="manual">Manual</option><option value="app_movil">App móvil</option>
          <option value="biometrico">Biométrico</option><option value="importado">Importado</option>
        </select>
      </div>
    </div>
    <div class="form-row">
      <div class="form-group"><label>Hora de entrada</label><input type="time" id="mcMarcaEntrada"></div>
      <div class="form-group"><label>Hora de salida</label><input type="time" id="mcMarcaSalida"></div>
    </div>
    <div class="form-group"><label>Observación</label><input type="text" id="mcMarcaObs" maxlength="255" placeholder="Ej: Tráfico en carretera, avisó a su jefe."></div>
    <div class="modal-footer">
      <button class="btn btn-secondary" onclick="cerrarModal('modalMarca')">Cancelar</button>
      <button class="btn btn-secondary" id="mcBtnAhora" onclick="mcMarcarAhora()">⏱️ Marcar ahora</button>
      <button class="btn btn-primary" onclick="mcGuardarMarca()">Guardar</button>
    </div>
  </div>
</div>

<!-- MODAL JUSTIFICAR -->
<div class="modal-bg" id="modalJustificar">
  <div class="modal" style="max-width:440px">
    <h4>Justificar</h4>
    <div class="alert alert-error" id="mcJustErr"></div>
    <div id="mcJustInfo" style="font-size:13px;color:var(--muted);margin-bottom:10px"></div>
    <div class="form-group"><label>Motivo de la justificación *</label><textarea id="mcJustMotivo" rows="3" maxlength="255" placeholder="Ej: Cita médica con constancia"></textarea></div>
    <div class="modal-footer">
      <button class="btn btn-secondary" onclick="cerrarModal('modalJustificar')">Cancelar</button>
      <button class="btn btn-danger" id="mcJustQuitar" style="display:none" onclick="mcQuitarJust()">Quitar justificación</button>
      <button class="btn btn-primary" onclick="mcGuardarJust()">Guardar</button>
    </div>
  </div>
</div>

<!-- MODAL HORARIO -->
<div class="modal-bg" id="modalMcConfig">
  <div class="modal" style="max-width:480px">
    <h4>⚙️ Horario y reglas</h4>
    <div class="alert alert-error" id="mcCfgErr"></div>
    <div class="section-title">Lunes a viernes</div>
    <div class="form-row-3">
      <div class="form-group"><label>Entrada</label><input type="time" id="mcCfgEntrada"></div>
      <div class="form-group"><label>Salida</label><input type="time" id="mcCfgSalida"></div>
      <div class="form-group"><label>Almuerzo (min)</label><input type="number" id="mcCfgAlmuerzo" min="0" max="240"></div>
    </div>
    <div class="section-title">Sábado</div>
    <div class="form-row-3">
      <div class="form-group"><label>¿Se trabaja?</label><select id="mcCfgSabado"><option value="1">Sí</option><option value="0">No</option></select></div>
      <div class="form-group"><label>Entrada</label><input type="time" id="mcCfgSabEntrada"></div>
      <div class="form-group"><label>Salida</label><input type="time" id="mcCfgSabSalida"></div>
    </div>
    <div class="form-group"><label>Tolerancia de tardanza (min)</label><input type="number" id="mcCfgTol" min="0" max="60">
      <div style="font-size:11px;color:var(--muted);margin-top:4px">Hasta estos minutos después de la hora de entrada se considera puntual. El domingo es día inhábil.</div></div>
    <div class="modal-footer">
      <button class="btn btn-secondary" onclick="cerrarModal('modalMcConfig')">Cancelar</button>
      <button class="btn btn-primary" onclick="mcGuardarConfig()">Guardar</button>
    </div>
  </div>
</div>

<!-- MODAL ENVIAR A TIEMPO EXTRA Y FALTAS -->
<div class="modal-bg" id="modalMcSync">
  <div class="modal" style="max-width:640px">
    <h4>Enviar a Tiempo Extra y Faltas</h4>
    <div id="mcSyncInfo" style="font-size:13px;color:var(--muted);margin-bottom:10px"></div>
    <div class="alert alert-error" id="mcSyncErr"></div>
    <div style="display:flex;gap:16px;flex-wrap:wrap;align-items:center;margin-bottom:10px;font-size:13px">
      <label style="display:flex;gap:6px;align-items:center;font-weight:400"><input type="checkbox" id="mcSyncExtra" checked onchange="mcPrevSync()"> Horas extra</label>
      <label style="display:flex;gap:6px;align-items:center;font-weight:400">desde <input type="number" id="mcSyncMin" value="30" min="1" max="600" style="width:64px" onchange="mcPrevSync()"> min</label>
      <label style="display:flex;gap:6px;align-items:center;font-weight:400"><input type="checkbox" id="mcSyncFaltas" checked onchange="mcPrevSync()"> Días faltados (ausentes sin justificar)</label>
    </div>
    <div id="mcSyncPrev" style="max-height:300px;overflow:auto;border:1px solid var(--border);border-radius:8px"></div>
    <div id="mcSyncRes" style="font-size:12px;color:var(--muted);margin-top:8px"></div>
    <div class="modal-footer">
      <button class="btn btn-secondary" onclick="cerrarModal('modalMcSync')">Cancelar</button>
      <button class="btn btn-primary" id="mcSyncBtn" onclick="mcEnviarSync()">Enviar</button>
    </div>
  </div>
</div>
