<div class="module" id="mod-gastos">
  <div class="card" style="margin-bottom:14px">
    <div class="card-header" style="flex-wrap:wrap;gap:8px">
      <h4>🧾 Gastos DMC — SAR Honduras</h4>
      <div class="btn-group" style="flex-wrap:wrap;gap:6px">
        <select id="filtroGastoAnio" onchange="cargarGastos()" style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px"></select>
        <select id="filtroGastoMes" onchange="cargarGastos()" style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
          <option value="">Todos los meses</option>
          <option value="1">Enero</option><option value="2">Febrero</option><option value="3">Marzo</option><option value="4">Abril</option>
          <option value="5">Mayo</option><option value="6">Junio</option><option value="7">Julio</option><option value="8">Agosto</option>
          <option value="9">Septiembre</option><option value="10">Octubre</option><option value="11">Noviembre</option><option value="12">Diciembre</option>
        </select>
        <select id="filtroGastoEstado" onchange="cargarGastos()" style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
          <option value="">Todos</option><option value="pendiente">Pendientes</option><option value="declarado">Declarados</option>
        </select>
        <select id="filtroGastoCategoria" onchange="cargarGastos()" style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
          <option value="">Todas las categorías</option>
          <option value="materiales">Materiales</option><option value="servicios">Servicios</option><option value="alquiler">Alquiler</option>
          <option value="combustible">Combustible</option><option value="publicidad">Publicidad</option><option value="mantenimiento">Mantenimiento</option>
          <option value="sueldos">Sueldos</option><option value="honorarios">Honorarios</option><option value="utilities">Utilities</option><option value="otros">Otros</option>
        </select>
        <input type="text" id="buscarGasto" placeholder="Buscar proveedor…" oninput="filtrarGastosLocal()"
          style="padding:7px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px;min-width:180px">
        <button class="btn btn-primary" onclick="abrirModalGasto()">+ Nuevo Gasto</button>
        <button class="btn btn-secondary" onclick="exportarGastosExcel()">📊 Excel</button>
        <button class="btn btn-secondary" onclick="exportarGastosPDF()">📄 PDF</button>
      </div>
    </div>
  </div>
  <div id="gastosResumen" style="display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:12px;margin-bottom:14px"></div>
  <div class="card">
    <div id="tablaGastosWrap"><p class="loading">Cargando…</p></div>
    <div id="paginaGastos"></div>
  </div>
  <div id="gastosBtnDeclarar" style="display:none;margin-top:12px;text-align:right">
    <button class="btn btn-success" onclick="marcarPeriodoDeclarado()">✅ Marcar período como Declarado al SAR</button>
  </div>
</div>
