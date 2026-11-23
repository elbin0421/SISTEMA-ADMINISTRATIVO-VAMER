<div class="module" id="mod-carnets">
<style>
  .cr-wrap{display:grid;grid-template-columns:190px 1fr;gap:16px;align-items:start}
  @media(max-width:820px){.cr-wrap{grid-template-columns:1fr}}
  .cr-side{display:flex;flex-direction:column;gap:10px}
  .cr-tools{background:var(--surface);border:1px solid var(--border);border-radius:12px;padding:8px;display:grid;grid-template-columns:1fr 1fr;gap:8px}
  @media(max-width:820px){.cr-tools{grid-template-columns:repeat(3,1fr)}}
  .cr-tool{background:var(--bg);border:1px solid var(--border);border-radius:10px;padding:10px 4px;text-align:center;font-size:11px;color:var(--text);cursor:pointer;transition:.15s}
  .cr-tool:hover{border-color:var(--accent);color:var(--accent);background:rgba(0,200,83,.08);transform:translateY(-1px)}
  .cr-tool span{display:block;font-size:20px;margin-bottom:3px}
  .cr-lbl{font-size:11px;color:var(--muted);margin:4px 0 -4px}
  .cr-side select,.cr-side input[type=text]{width:100%;padding:8px 10px;background:var(--bg);border:1px solid var(--border);border-radius:8px;color:var(--text);font-size:13px;box-sizing:border-box}
  .cr-sw{display:flex;gap:7px}
  .cr-sw i{width:22px;height:22px;border-radius:50%;cursor:pointer;border:2px solid transparent;box-sizing:border-box}
  .cr-sw i.on{border-color:var(--text);box-shadow:0 0 0 2px var(--bg) inset}
  .cr-tabs{display:inline-flex;background:var(--surface);border:1px solid var(--border);border-radius:10px;padding:3px;margin-bottom:12px}
  .cr-tabs button{border:0;background:transparent;color:var(--text);padding:7px 22px;border-radius:8px;cursor:pointer;font-size:13px}
  .cr-tabs button:hover{color:var(--accent)}
  .cr-tabs button.on{background:var(--accent);color:#0f1923;font-weight:700}
  .cr-stage{background:var(--surface);border:1px solid var(--border);border-radius:12px;padding:22px;display:flex;justify-content:center;min-height:470px;align-items:center}
  .cr-stage canvas{box-shadow:none;filter:drop-shadow(0 8px 20px rgba(0,0,0,.5));max-width:100%;height:auto}
  .cr-plant{display:flex;gap:14px;flex-wrap:wrap;background:var(--surface);border:1px solid var(--border);border-radius:12px;padding:14px}
  .cr-pl{cursor:pointer;text-align:center;font-size:12px;border:2px solid transparent;border-radius:10px;padding:6px}
  .cr-pl.on{border-color:var(--accent)}
  .cr-pl canvas{border-radius:8px;display:block;margin-bottom:4px}
  .cr-vacio{color:var(--muted);text-align:center;font-size:13px}
</style>

  <div style="margin-bottom:14px">
    <h4 style="margin:0;font-size:18px">🪪 Carnets de empleados</h4>
    <div style="font-size:12px;color:var(--muted);margin-top:2px">Los datos salen de Empleados. El QR del carnet abre la ficha del empleado.</div>
  </div>

  <div class="cr-wrap">
    <div class="cr-side">
      <div>
        <div class="cr-lbl">Empleado</div>
        <input type="text" id="crBuscar" placeholder="🔍 Buscar empleado..." autocomplete="off" oninput="crBuscarEmp()" onfocus="crBuscarEmp()"
          onblur="setTimeout(()=>{document.getElementById('crSug').style.display='none'},180)" style="margin-top:6px">
        <div id="crSug" style="display:none;position:absolute;z-index:50;width:250px;background:var(--surface);border:1px solid var(--border);border-radius:8px;max-height:260px;overflow-y:auto;box-shadow:0 8px 24px rgba(0,0,0,.35)"></div>
      </div>
      <div class="cr-tools">
        <div class="cr-tool" onclick="crPedirImagen('foto')"><span>👤</span>Subir foto</div>
        <div class="cr-tool" onclick="crAbrirDatos()"><span>✏️</span>Editar datos</div>
        <div class="cr-tool" onclick="crPedirImagen('logo')"><span>🏷️</span>Subir logo</div>
        <div class="cr-tool" onclick="crPedirImagen('firma')"><span>✍️</span>Subir firma</div>
        <div class="cr-tool" onclick="crAbrirFondo()"><span>🎨</span>Fondo</div>
        <div class="cr-tool" onclick="document.getElementById('crPlantillas').scrollIntoView({behavior:'smooth'})"><span>▦</span>Diseño</div>
      </div>
      <input type="file" id="crFile" accept="image/*" style="display:none" onchange="crArchivoElegido(this)">

      <div class="cr-lbl">Tamaño</div>
      <select id="crTamano" onchange="crCambio('tamano', this.value)"></select>
      <div class="cr-lbl">Estilo de texto</div>
      <select id="crEstilo" onchange="crCambio('estilo_texto', this.value)"></select>
      <div class="cr-lbl">Color de texto</div>
      <div class="cr-sw" id="crColores"></div>

      <button class="btn btn-primary" onclick="crGuardar()" style="margin-top:4px">💾 Guardar carnet</button>
      <button class="btn btn-secondary" onclick="crExportarPDF()">⬇ Exportar PDF</button>
      <button class="btn btn-secondary" onclick="crExportarPNG()">🖼 Imagen (PNG)</button>
    </div>

    <div>
      <div class="cr-tabs">
        <button id="crTabFrente" class="on" onclick="crLado('frente')">Frente</button>
        <button id="crTabReverso" onclick="crLado('reverso')">Reverso</button>
      </div>
      <div class="cr-stage">
        <canvas id="crCanvas"></canvas>
        <div id="crVacio" class="cr-vacio">Elige un empleado para ver su carnet.</div>
      </div>
    </div>
  </div>

  <div id="crPlantillas" style="margin-top:18px">
    <div style="font-weight:700;margin-bottom:8px">Plantillas</div>
    <div class="cr-plant" id="crPlantList"></div>
  </div>
</div>
