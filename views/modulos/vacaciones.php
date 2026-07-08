<div class="module" id="mod-vacaciones">

  <!-- TABS -->
  <div style="display:flex;gap:8px;margin-bottom:16px;border-bottom:1px solid var(--border);padding-bottom:0">
    <button class="tab-vac active" id="tabVacResumen"   onclick="tabVacaciones('resumen')">📊 Resumen por Empleado</button>
    <button class="tab-vac"        id="tabVacHistorial" onclick="tabVacaciones('historial')">📋 Historial de Registros</button>
  </div>

  <!-- PANEL RESUMEN -->
  <div id="panelVacResumen">
    <div class="card">
      <div class="card-header">
        <h4>🏖️ Vacaciones — Resumen Empleados</h4>
        <div class="btn-group">
          <button class="btn btn-primary" onclick="abrirModalVacacion()">+ Registrar Vacaciones</button>
        </div>
      </div>
      <div style="background:var(--bg);border:1px solid var(--border);border-radius:8px;padding:12px 16px;margin-bottom:14px;font-size:12px;color:var(--muted);line-height:1.8">
        <strong style="color:var(--accent)">⚖️ Ley Honduras — Art. 346 Código del Trabajo:</strong>
        &nbsp; 1 año exacto → <strong>10 días</strong> &nbsp;|&nbsp;
        2 años exactos → <strong>12 días</strong> &nbsp;|&nbsp;
        3 años exactos → <strong>15 días</strong> &nbsp;|&nbsp;
        4+ años → <strong>20 días</strong>
      </div>
      <div class="table-wrap" id="tablaVacResumenWrap"><p class="loading">Cargando...</p></div>
    </div>
  </div>

  <!-- PANEL HISTORIAL -->
  <div id="panelVacHistorial" style="display:none">
    <div class="card">
      <div class="card-header">
        <h4>📋 Historial de Vacaciones</h4>
        <div class="btn-group">
          <select id="filtroVacEmpleado" onchange="cargarHistorialVacaciones()"
            style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
            <option value="">Todos los empleados</option>
          </select>
          <select id="filtroVacEstado" onchange="cargarHistorialVacaciones()"
            style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
            <option value="todos">Todos los estados</option>
            <option value="tomada">Descanso tomado</option>
            <option value="pagada">Pagadas</option>
            <option value="anulada">Anuladas</option>
          </select>
          <button class="btn btn-primary" onclick="abrirModalVacacion()">+ Registrar</button>
        </div>
      </div>
      <div class="table-wrap" id="tablaVacHistorialWrap"><p class="loading">Cargando...</p></div>
      <div id="paginaVacHistorial"></div>
    </div>
  </div>

</div>
