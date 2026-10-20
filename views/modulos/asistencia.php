<div class="module" id="mod-asistencia">
  <div class="card">
    <div class="card-header">
      <h4>🕒 Tiempo Extra y Días Faltados</h4>
      <div class="btn-group">
        <select id="asisEmpleadoFiltro" onchange="cargarAsistencia()"
          style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px;max-width:200px">
          <option value="">Todos los empleados</option>
        </select>
        <input type="date" id="asisDesde" onchange="cargarAsistencia()" title="Desde"
          style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
        <input type="date" id="asisHasta" onchange="cargarAsistencia()" title="Hasta"
          style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
        <select id="asisTipoFiltro" onchange="cargarAsistencia()"
          style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
          <option value="">Todos los tipos</option>
          <option value="horas_extra">Horas extra</option>
          <option value="dia_faltado">Días faltados</option>
        </select>
        <select id="asisEstadoFiltro" onchange="cargarAsistencia()"
          style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
          <option value="">Todos</option>
          <option value="pendiente">Pendientes</option>
          <option value="aplicado">Aplicados</option>
        </select>
        <button class="btn btn-primary" onclick="abrirModalAsistencia()">+ Nuevo Registro</button>
      </div>
    </div>
    <div class="table-wrap" id="tablaAsistenciaWrap"><p class="loading">Cargando...</p></div>
    <div id="paginaAsistencia"></div>
  </div>
</div>
