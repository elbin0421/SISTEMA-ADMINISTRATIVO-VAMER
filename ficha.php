<?php
// ============================================================
//  Ficha pública del empleado (se abre al escanear el QR del carnet).
//  No requiere sesión: solo muestra datos básicos; el N.º de identidad va enmascarado.
// ============================================================
require_once __DIR__ . '/models/CarnetModel.php';
header('X-Robots-Tag: noindex, nofollow');
header('Cache-Control: no-store');

$f = CarnetModel::fichaPorToken((string)($_GET['t'] ?? ''));
$h = fn($s) => htmlspecialchars((string)$s, ENT_QUOTES, 'UTF-8');
$meses = ['enero','febrero','marzo','abril','mayo','junio','julio','agosto','septiembre','octubre','noviembre','diciembre'];
if (!$f) { http_response_code(404); }
$activo = $f && $f['estado'] === 'activo';
$nombre = $f ? trim($f['nombres'] . ' ' . $f['apellidos']) : '';
$id = $f ? (string)$f['identidad'] : '';
/*$idMask = $id !== '' ? str_repeat('•', max(0, strlen($id) - 4)) . substr($id, -4) : '';*/
$tel = $f ? ($f['telefono_carnet'] ?: $f['telefono']) : '';
$ingreso = ($f && $f['fecha_ingreso']) ? (int)date('j', strtotime($f['fecha_ingreso'])) . ' de ' . $meses[(int)date('n', strtotime($f['fecha_ingreso'])) - 1] . ' de ' . date('Y', strtotime($f['fecha_ingreso'])) : '';
?><!DOCTYPE html>
<html lang="es"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="robots" content="noindex,nofollow">
<title>Ficha de empleado<?= $f ? ' — ' . $h($nombre) : '' ?></title>
<style>
  *{box-sizing:border-box}body{margin:0;font-family:Arial,Helvetica,sans-serif;background:#eef2f1;color:#1d2b26;min-height:100vh;display:flex;align-items:center;justify-content:center;padding:18px}
  .card{background:#fff;border-radius:18px;box-shadow:0 8px 30px rgba(0,0,0,.12);max-width:400px;width:100%;overflow:hidden}
  .top{background:#0a6b36;color:#fff;padding:18px 20px 54px;text-align:center}
  .top img{height:42px;max-width:150px;object-fit:contain;background:#fff;border-radius:8px;padding:4px;margin-bottom:6px}
  .top b{display:block;font-size:15px}.top small{opacity:.85;font-size:12px}
  .foto{width:112px;height:112px;border-radius:50%;border:4px solid #fff;margin:-56px auto 0;display:block;object-fit:cover;background:#cfd8dc;box-shadow:0 2px 10px rgba(0,0,0,.18)}
  .ph{display:flex;align-items:center;justify-content:center;font-size:40px;color:#78909c;font-weight:700}
  .body{padding:14px 22px 22px;text-align:center}
  h1{font-size:21px;margin:8px 0 2px}.puesto{color:#0a6b36;font-weight:700;font-size:14px}
  .estado{display:inline-block;margin:12px 0 4px;padding:5px 14px;border-radius:20px;font-size:12px;font-weight:700}
  .ok{background:#d9f2e6;color:#0a6b36}.no{background:#fbd9d9;color:#b3261e}
  dl{text-align:left;margin:14px 0 0;border-top:1px solid #e3e8e6}
  dl div{display:flex;justify-content:space-between;gap:12px;padding:9px 0;border-bottom:1px solid #e3e8e6;font-size:14px}
  dt{color:#6b7a75}dd{margin:0;font-weight:700;text-align:right}
  .pie{font-size:11px;color:#8a9893;margin-top:14px}
  .err{padding:40px 24px;text-align:center}
</style></head><body>
<div class="card">
<?php if (!$f): ?>
  <div class="err"><div style="font-size:42px">⚠️</div><h1>Carnet no válido</h1><p>No se encontró información para este código.</p></div>
<?php else: ?>
  <div class="top">
    <?php if ($f['logo']): ?><img src="<?= $h($f['logo']) ?>" alt=""><br><?php endif; ?>
    <b><?= $h($f['nombre_mostrado'] ?: $f['empresa']) ?></b><small>Ficha de empleado</small>
  </div>
  <?php if ($f['foto']): ?><img class="foto" src="<?= $h($f['foto']) ?>" alt="">
  <?php else: ?><div class="foto ph"><?= $h(mb_strtoupper(mb_substr($f['nombres'], 0, 1) . mb_substr($f['apellidos'], 0, 1))) ?></div><?php endif; ?>
  <div class="body">
    <h1><?= $h($nombre) ?></h1>
    <div class="puesto"><?= $h($f['puesto']) ?></div>
    <span class="estado <?= $activo ? 'ok' : 'no' ?>"><?= $activo ? '✔ Empleado activo' : '✖ Carnet no vigente' ?></span>
    <dl>
      <?php if ($f['departamento']): ?><div><dt>Departamento</dt><dd><?= $h($f['departamento']) ?></dd></div><?php endif; ?>
      <div><dt>Empresa</dt><dd><?= $h($f['empresa']) ?></dd></div>
      <?php if ($f['mostrar_identidad'] && $id): ?><div><dt>Identidad</dt><dd><?= $h($id) ?></dd></div><?php endif; ?>
      <?php if ($f['mostrar_telefono'] && $tel): ?><div><dt>Teléfono</dt><dd><?= $h($tel) ?></dd></div><?php endif; ?>
      <?php if ($f['mostrar_ingreso'] && $ingreso): ?><div><dt>Ingreso</dt><dd><?= $h($ingreso) ?></dd></div><?php endif; ?>
    </dl>
    <div class="pie">Consultado el <?= date('d/m/Y H:i') ?></div>
  </div>
<?php endif; ?>
</div></body></html>
