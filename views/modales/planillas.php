<!-- MODAL EMPLEADO -->
<div class="modal-bg" id="modalEmpleado">
  <div class="modal modal-lg">
    <h4 id="tituloEmpleado">Nuevo Empleado</h4>
    <div class="alert alert-error" id="errEmpleado"></div>
    <input type="hidden" id="empId">

    <div class="section-title">👤 Datos personales</div>
    <div class="form-row">
      <div class="form-group"><label>Nombres *</label><input type="text" id="empNombres" placeholder="Ej: Melvin Danilson"></div>
      <div class="form-group"><label>Apellidos *</label><input type="text" id="empApellidos" placeholder="Ej: Gomez Aguilar"></div>
    </div>
    <div class="form-row">
      <div class="form-group">
        <label>Empresa *</label>
        <select id="empEmpresaId">
          <option value="1">SOLDYMEG</option>
          <option value="2">VAMER</option>
        </select>
      </div>
      <div class="form-group">
        <label>Ubicación *</label>
        <select id="empUbicacion" onchange="empAutoSeguro()">
          <option value="SOLDYMEG">SOLDYMEG</option>
          <option value="VESTA">VESTA</option>
        </select>
      </div>
      <div class="form-group"><label>Puesto</label><input type="text" id="empPuesto" placeholder="Soldador, Mecánico..."></div>
    </div>
    <div class="form-row">
      <div class="form-group">
        <label>Departamento</label>
        <select id="empDepartamento">
          <option value="">— Sin asignar —</option>
        </select>
      </div>
      <div class="form-group">
        <label>Tipo contrato *</label>
        <select id="empTipoContrato">
          <option value="tiempo_completo">Tiempo Completo</option>
          <option value="medio_tiempo">Medio Tiempo</option>
          <option value="contrato">Contrato</option>
          <option value="temporal">Temporal</option>
        </select>
      </div>
    </div>
    <div class="form-row">
      <div class="form-group"><label>No. Identidad</label><input type="text" id="empIdentidad" placeholder="0000-0000-000000"></div>
      <div class="form-group"><label>Teléfono</label><input type="text" id="empTelefono" placeholder="0000-0000"></div>
    </div>
    <div class="form-row">
      <div class="form-group"><label>Correo</label><input type="email" id="empCorreo" placeholder="correo@ejemplo.com"></div>
      <div class="form-group"><label>Dirección</label><input type="text" id="empDireccion"></div>
    </div>

    <div class="section-title">💼 Datos laborales</div>
    <div class="form-row">
      <div class="form-group"><label>Tipo de contrato</label>
        <select id="empContrato">
          <option value="tiempo_completo">Tiempo completo</option>
          <option value="medio_tiempo">Medio tiempo</option>
          <option value="por_obra">Por obra</option>
        </select>
      </div>
      <div class="form-group"><label>Salario mensual (L.) *</label><input type="number" id="empSalario" min="0" step="0.01" placeholder="0.00"></div>
      <div class="form-group"><label>Fecha de ingreso</label><input type="date" id="empFechaIngreso"></div>
    </div>
    <div class="form-row">
      <div class="form-group"><label>No. IHSS</label><input type="text" id="empIHSS" placeholder="Número IHSS"></div>
      <div class="form-group"><label>No. RAP</label><input type="text" id="empRAP" placeholder="Número RAP"></div>
    </div>

    <div class="section-title">🏦 Datos bancarios</div>
    <div class="form-row">
      <div class="form-group"><label>Banco</label><input type="text" id="empBanco" placeholder="Banco Atlántida, BAC..."></div>
      <div class="form-group"><label>No. Cuenta</label><input type="text" id="empCuenta" placeholder="Número de cuenta"></div>
    </div>

    <div class="section-title">⚙️ Deducciones</div>
    <div style="background:var(--bg);border:1px solid var(--border);border-radius:8px;padding:14px 16px">
      <div style="color:var(--muted);font-size:12px;margin-bottom:10px">IHSS, RAP e ISR están inactivos por defecto. Activar solo si aplica.</div>
      <div style="display:flex;gap:20px;flex-wrap:wrap;margin-bottom:12px">
        <label style="font-size:13px;display:flex;align-items:center;gap:8px;cursor:pointer">
          <input type="checkbox" id="empAplicaIHSS"> Aplicar IHSS (2.5% emp. / 5% pat.)
        </label>
        <label style="font-size:13px;display:flex;align-items:center;gap:8px;cursor:pointer">
          <input type="checkbox" id="empAplicaRAP"> Aplicar RAP (1.5%)
        </label>
        <label style="font-size:13px;display:flex;align-items:center;gap:8px;cursor:pointer">
          <input type="checkbox" id="empAplicaISR"> Aplicar ISR (tabla SAR)
        </label>
      </div>
      <div class="form-row">
        <div class="form-group">
          <label>Seguro privado (L.) <span style="color:var(--muted);font-size:11px">monto fijo quincenal — se autocompleta según ubicación</span></label>
          <input type="number" id="empSeguro" min="0" step="0.01" placeholder="0.00" value="0">
        </div>
        <div style="font-size:12px;color:var(--muted);padding-top:28px">
          SOLDYMEG → L.352.25 &nbsp;|&nbsp; VESTA → L.211.35
        </div>
      </div>
    </div>

    <div class="modal-footer">
      <button class="btn btn-secondary" onclick="cerrarModal('modalEmpleado')">Cancelar</button>
      <button class="btn btn-primary" onclick="guardarEmpleado()">💾 Guardar</button>
    </div>
  </div>
</div>

<!-- MODAL GENERAR PLANILLA -->
<div class="modal-bg" id="modalGenerarPlanilla" style="align-items:flex-start;padding:10px">
  <div class="modal modal-lg" style="max-width:98vw;width:100%;max-height:calc(100vh - 20px);overflow-y:auto;margin:0 auto">
    <h4>📋 Generar Planilla Quincenal</h4>
    <div class="alert alert-error" id="errPlanilla"></div>

    <!-- Período: fila compacta horizontal -->
    <div style="display:grid;grid-template-columns:auto auto auto 1fr 1fr;gap:12px;align-items:end;margin-bottom:14px;flex-wrap:wrap">
      <!-- Quincena -->
      <div>
        <label style="display:block;font-size:12px;color:var(--muted);margin-bottom:5px">Quincena *</label>
        <div style="display:flex;gap:8px">
          <div class="quincena-btn" onclick="selQuincena('1ra')" data-q="1ra"
            style="border:2px solid var(--accent);background:rgba(232,160,32,.12);border-radius:8px;padding:8px 14px;text-align:center;cursor:pointer;min-width:90px">
            <div style="font-size:15px">1️⃣</div>
            <div style="font-size:11px;font-weight:600">1ra Quincena</div>
            <div style="font-size:10px;color:var(--muted)">Días 1–15</div>
          </div>
          <div class="quincena-btn" onclick="selQuincena('2da')" data-q="2da"
            style="border:2px solid var(--border);border-radius:8px;padding:8px 14px;text-align:center;cursor:pointer;min-width:90px">
            <div style="font-size:15px">2️⃣</div>
            <div style="font-size:11px;font-weight:600">2da Quincena</div>
            <div style="font-size:10px;color:var(--muted)">Días 16–fin</div>
          </div>
        </div>
      </div>
      <!-- Mes -->
      <div class="form-group" style="margin:0">
        <label>Mes *</label>
        <select id="planMes" style="min-width:110px">
          <option value="1">Enero</option><option value="2">Febrero</option>
          <option value="3">Marzo</option><option value="4">Abril</option>
          <option value="5">Mayo</option><option value="6">Junio</option>
          <option value="7">Julio</option><option value="8">Agosto</option>
          <option value="9">Septiembre</option><option value="10">Octubre</option>
          <option value="11">Noviembre</option><option value="12">Diciembre</option>
        </select>
      </div>
      <!-- Año -->
      <div class="form-group" style="margin:0">
        <label>Año *</label>
        <select id="planAnio" style="min-width:80px">
          <option value="2025">2025</option><option value="2026" selected>2026</option><option value="2027">2027</option>
        </select>
      </div>
      <!-- Fecha pago -->
      <div class="form-group" style="margin:0">
        <label>Fecha de pago</label>
        <input type="date" id="planFechaPago">
      </div>
      <!-- Observaciones -->
      <div class="form-group" style="margin:0">
        <label>Observaciones</label>
        <input type="text" id="planObs" placeholder="Opcional...">
      </div>
    </div>

    <!-- Tabla de ajustes por empleado -->
    <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:8px">
      <div class="section-title" style="margin:0">⚙️ Ajustes por empleado</div>
      <div style="display:flex;gap:8px;align-items:center">
        <label style="font-size:12px;color:var(--muted);white-space:nowrap">Empresa:</label>
        <select id="planFiltroEmpresa" style="padding:5px 10px;background:var(--bg);border:1px solid var(--border);border-radius:6px;color:var(--text);font-size:13px">
          <option value="">Todas</option>
          <option value="1">SOLDYMEG</option>
          <option value="2">VAMER</option>
        </select>
        <button class="btn btn-secondary btn-sm" onclick="cargarExtrasEmpleados()">🔄 Cargar empleados</button>
      </div>
    </div>
    <div id="planExtrasWrap" style="overflow-x:auto;border:1px solid var(--border);border-radius:8px;padding:8px;background:var(--bg);min-height:60px">
      <p style="color:var(--muted);font-size:13px;padding:8px">Haz clic en "Cargar empleados" para ver la tabla.</p>
    </div>

    <!-- Vista previa -->
    <div id="planPreview" style="display:none;background:var(--sidebar);border:1px solid var(--border);border-radius:8px;padding:10px 14px;font-size:13px;margin-top:10px">
      <div style="font-size:11px;text-transform:uppercase;letter-spacing:.5px;color:var(--muted);margin-bottom:8px;font-weight:600">📊 Vista previa</div>
      <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(130px,1fr));gap:10px">
        <div><div style="color:var(--muted);font-size:11px">Empleados</div><strong id="pvEmpleados">—</strong></div>
        <div><div style="color:var(--muted);font-size:11px">Total salarios</div><strong id="pvSalarios">—</strong></div>
        <div><div style="color:var(--muted);font-size:11px">Deducciones</div><strong style="color:var(--danger)" id="pvDeducciones">—</strong></div>
        <div><div style="color:var(--muted);font-size:11px">Neto a pagar</div><strong style="color:var(--accent)" id="pvNeto">—</strong></div>
      </div>
    </div>

    <div class="modal-footer" style="margin-top:14px">
      <button class="btn btn-secondary" onclick="cerrarModal('modalGenerarPlanilla')">Cancelar</button>
      <button class="btn btn-secondary" onclick="previsualizarPlanilla()">👁️ Previsualizar</button>
      <button class="btn btn-primary"   onclick="confirmarGenerarPlanilla()">✓ Generar Planilla</button>
    </div>
  </div>
</div>

<!-- MODAL DETALLE PLANILLA -->
<div class="modal-bg" id="modalDetallePlanilla">
  <div class="modal modal-lg" style="max-width:960px">
    <div id="contenidoDetallePlanilla"><p class="loading">Cargando...</p></div>
    <div class="modal-footer" id="footerDetallePlanilla">
      <button class="btn btn-secondary" onclick="cerrarModal('modalDetallePlanilla')">Cerrar</button>
    </div>
  </div>
</div>
