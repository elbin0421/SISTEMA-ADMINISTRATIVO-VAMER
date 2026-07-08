<div class="module" id="mod-requisiciones">
  <div class="card">
    <div class="card-header" style="flex-wrap:wrap;gap:8px">
      <h4>📋 Requisiciones de Materiales</h4>
      <div class="btn-group" style="flex-wrap:wrap;gap:6px">
        <input type="text" id="filtroReqQ" placeholder="Buscar N°, empleado, OT..."
               oninput="filtrarRequisiciones()"
               style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px;width:210px">
        <select id="filtroReqEstado" onchange="cargarRequisiciones()"
                style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
          <option value="todos">Todos los estados</option>
          <option value="pendiente">Pendiente</option>
          <option value="aprobada">Aprobada</option>
          <option value="despachada">Despachada</option>
          <option value="anulada">Anulada</option>
        </select>
        <button class="btn btn-primary"   onclick="abrirModalRequisicion()">+ Nueva Requisición</button>
        <button class="btn btn-secondary" onclick="exportarRequisicionesExcel()">⬇️ Excel</button>
      </div>
    </div>
    <div class="table-wrap">
      <table>
        <thead>
          <tr>
            <th>N° Req.</th><th>Fecha</th><th>Empleado</th><th>Departamento</th>
            <th>N° OT</th><th>Unidad</th><th>Estado</th><th>Acciones</th>
          </tr>
        </thead>
        <tbody id="tablaReqBody">
          <tr><td colspan="8" class="empty-state">Cargando...</td></tr>
        </tbody>
      </table>
    </div>
  </div>
</div>
