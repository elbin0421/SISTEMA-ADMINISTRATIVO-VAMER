<div class="module" id="mod-planillas">

  <!-- Tabs principales -->
  <div style="display:flex;gap:4px;margin-bottom:16px;border-bottom:2px solid var(--border)">
    <button id="tabEmpleados"  class="tab-btn active" onclick="switchTabPlanilla('empleados')">👷 Empleados</button>
    <button id="tabPlanillas"  class="tab-btn"        onclick="switchTabPlanilla('planillas')">📋 Planillas</button>
    <button id="tabEspeciales" class="tab-btn"        onclick="switchTabPlanilla('especiales')">1️⃣4️⃣&nbsp;/&nbsp;🎄 14vo &amp; Aguinaldo</button>
  </div>

  <!-- ── Panel Empleados ── -->
  <div id="panelEmpleados">
    <div class="card">
      <div class="card-header">
        <h4>👷 Empleados</h4>
        <div class="btn-group">
          <input type="text" id="buscarEmpleado" placeholder="🔍 Buscar nombre, puesto..." oninput="filtrarEmpleados()"
            style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px;outline:none;width:220px">
          <select id="filtroEstadoEmp" onchange="cargarEmpleados()" style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
            <option value="activo">Activos</option>
            <option value="inactivo">Inactivos</option>
            <option value="">Todos</option>
          </select>
          <button class="btn btn-primary" onclick="abrirModalEmpleado()">+ Nuevo Empleado</button>
        </div>
      </div>
      <div class="table-wrap" id="tablaEmpleados"><p class="loading">Cargando...</p></div>
      <div id="paginaEmpleados"></div>
    </div>
  </div>

  <!-- ── Panel Planillas ── -->
  <div id="panelPlanillas" style="display:none">
    <div class="card">
      <div class="card-header">
        <h4>📋 Planillas Generadas</h4>
        <button class="btn btn-primary" onclick="abrirModalGenerarPlanilla()">+ Generar Planilla</button>
      </div>
      <div class="kpi-grid" style="margin-bottom:16px">
        <div class="kpi-card"><div class="kpi-label">Total salarios (último)</div><div class="kpi-val" id="kpiPlanSalarios">—</div></div>
        <div class="kpi-card"><div class="kpi-label">Total neto (último)</div><div class="kpi-val" id="kpiPlanNeto">—</div></div>
        <div class="kpi-card"><div class="kpi-label">Empleados en planilla</div><div class="kpi-val" id="kpiPlanEmpleados">—</div></div>
      </div>
      <div class="table-wrap" id="tablaPlanillas"><p class="loading">Cargando...</p></div>
      <div id="paginaPlanillas"></div>
    </div>
  </div>

  <!-- ── Panel Planillas Especiales ── -->
  <div id="panelEspeciales" style="display:none">
    <div class="card">
      <div class="card-header">
        <h4>1️⃣4️⃣ / 🎄 Planillas Especiales</h4>
        <button class="btn btn-primary" onclick="abrirModalGenerarEspecial()">+ Generar 14vo / Aguinaldo</button>
      </div>
      <div class="kpi-grid" style="margin-bottom:16px">
        <div class="kpi-card"><div class="kpi-label">Último 14vo — Neto</div><div class="kpi-val" id="kpiEspCatorceavo">—</div></div>
        <div class="kpi-card"><div class="kpi-label">Último Aguinaldo — Neto</div><div class="kpi-val" id="kpiEspAguinaldo">—</div></div>
      </div>
      <div class="table-wrap" id="tablaEspeciales"><p class="loading">Cargando...</p></div>
      <div id="paginaEspeciales"></div>
    </div>
  </div>

</div>
