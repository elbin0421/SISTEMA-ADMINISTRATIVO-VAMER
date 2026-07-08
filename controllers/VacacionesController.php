<?php
// ============================================================
//  SOLDYMEG — VacacionesController
//  Cálculo y registro de vacaciones según Código del Trabajo HN
//  Art. 346: 1-2 años=10 días | 2-3=12 | 3-4=15 | 4+=20
// ============================================================
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/auth.php';
header('Content-Type: application/json');

$sesion = requireAuth();
$action = $_GET['action'] ?? 'listar';
$method = $_SERVER['REQUEST_METHOD'];

match(true) {
    $action === 'listar'         && $method === 'GET'  => listar(),
    $action === 'calcular'       && $method === 'GET'  => calcular(),
    $action === 'obtener'        && $method === 'GET'  => obtener(),
    $action === 'resumen'        && $method === 'GET'  => resumen(),
    $action === 'registrar'      && $method === 'POST' => registrar($sesion),
    $action === 'editar'         && $method === 'POST' => editar($sesion),
    $action === 'anular'         && $method === 'POST' => anular($sesion),
    default => responder(400, ['error' => 'Acción no válida'])
};

// ── TABLAS CÓDIGO TRABAJO HONDURAS ────────────────────────────
// Años COMPLETOS cumplidos (no decimales):
//   1 año exacto  → 10 días
//   2 años exactos → 12 días
//   3 años exactos → 15 días
//   4+ años        → 20 días
function diasVacaciones(int $aniosCompletos): int {
    if ($aniosCompletos < 1)  return 0;   // Menos de 1 año: no tiene derecho
    if ($aniosCompletos === 1) return 10;
    if ($aniosCompletos === 2) return 12;
    if ($aniosCompletos === 3) return 15;
    return 20; // 4 o más años
}

function calcularVacacion(array $emp, string $fechaInicio, string $fechaFin): array {
    $inicio = new DateTime($fechaInicio);
    $fin    = new DateTime($fechaFin);
    $diff   = $inicio->diff($fin);

    // Años COMPLETOS cumplidos (no decimales — igual que cumpleaños)
    $aniosCompletos = (int)$diff->y;
    // Para mostrar referencia: años + meses como decimal
    $aniosDecimal   = round($aniosCompletos + ($diff->m / 12), 2);

    $dias  = diasVacaciones($aniosCompletos);

    $salarioDiario = round((float)$emp['salario_mensual'] / 30, 4);
    $monto         = round($salarioDiario * $dias, 2);

    return [
        'anios_laborados'       => $aniosDecimal,
        'anios_completos'       => $aniosCompletos,
        'dias_correspondientes' => $dias,
        'salario_diario'        => $salarioDiario,
        'monto_vacaciones'      => $monto,
        'aplica'                => $dias > 0,
    ];
}

// ── LISTAR ────────────────────────────────────────────────────
function listar(): void {
    $empId  = isset($_GET['empleado_id']) ? (int)$_GET['empleado_id'] : null;
    $estado = $_GET['estado'] ?? null;

    $sql = "
        SELECT v.*,
               CONCAT(e.nombres, ' ', e.apellidos) AS empleado, e.puesto, e.salario_mensual,
               u.nombre AS registrado_por
        FROM vacaciones v
        JOIN empleados e ON e.id_empleado = v.empleado_id
        JOIN usuarios  u ON u.id_usuario  = v.usuario_id
        WHERE 1=1
    ";
    $params = [];
    if ($empId)  { $sql .= " AND v.empleado_id = ?"; $params[] = $empId; }
    if ($estado && $estado !== 'todos') { $sql .= " AND v.estado = ?"; $params[] = $estado; }
    $sql .= " ORDER BY v.fecha_creacion DESC";

    $stmt = getDB()->prepare($sql);
    $stmt->execute($params);
    responder(200, ['ok' => true, 'data' => $stmt->fetchAll()]);
}

// ── CALCULAR (preview antes de registrar) ─────────────────────
function calcular(): void {
    $empId      = (int)($_GET['empleado_id'] ?? 0);
    $fechaInicio = $_GET['fecha_inicio'] ?? '';
    $fechaFin   = $_GET['fecha_fin']    ?? date('Y-m-d');

    if (!$empId || !$fechaInicio) {
        responder(400, ['error' => 'empleado_id y fecha_inicio requeridos']); return;
    }

    $stmt = getDB()->prepare("SELECT * FROM empleados WHERE id_empleado = ?");
    $stmt->execute([$empId]);
    $emp = $stmt->fetch();
    if (!$emp) { responder(404, ['error' => 'Empleado no encontrado']); return; }

    $calc = calcularVacacion($emp, $fechaInicio, $fechaFin);
    responder(200, ['ok' => true, 'empleado' => $emp, 'calculo' => $calc]);
}

// ── OBTENER uno ───────────────────────────────────────────────
function obtener(): void {
    $id = (int)($_GET['id'] ?? 0);
    $stmt = getDB()->prepare("
        SELECT v.*, CONCAT(e.nombres, ' ', e.apellidos) AS empleado, e.puesto, e.salario_mensual
        FROM vacaciones v JOIN empleados e ON e.id_empleado = v.empleado_id
        WHERE v.id_vacacion = ?
    ");
    $stmt->execute([$id]);
    $row = $stmt->fetch();
    if (!$row) { responder(404, ['error' => 'Registro no encontrado']); return; }
    responder(200, ['ok' => true, 'data' => $row]);
}

// ── RESUMEN por empleado ──────────────────────────────────────
function resumen(): void {
    $stmt = getDB()->query("
        SELECT e.id_empleado, CONCAT(e.nombres, ' ', e.apellidos) AS nombre, e.puesto, e.fecha_ingreso, e.salario_mensual,
               COUNT(v.id_vacacion)                                       AS total_registros,
               COALESCE(SUM(CASE WHEN v.tipo='descanso' AND v.estado NOT IN ('anulada') THEN v.dias_correspondientes END),0) AS dias_descanso,
               COALESCE(SUM(CASE WHEN v.tipo='pago'     AND v.estado NOT IN ('anulada') THEN v.dias_correspondientes END),0) AS dias_pagados,
               COALESCE(SUM(CASE WHEN v.estado NOT IN ('anulada') THEN v.monto_vacaciones END),0)                            AS monto_total_pagado
        FROM empleados e
        LEFT JOIN vacaciones v ON v.empleado_id = e.id_empleado
        WHERE e.estado = 'activo'
        GROUP BY e.id_empleado
        ORDER BY e.apellidos, e.nombres
    ");
    $rows = $stmt->fetchAll();

    // Calcular días actuales que le corresponden según fecha de ingreso
    $hoy = new DateTime();
    foreach ($rows as &$r) {
        if ($r['fecha_ingreso']) {
            $ingreso        = new DateTime($r['fecha_ingreso']);
            $diff           = $ingreso->diff($hoy);
            $aniosCompletos = (int)$diff->y;
            $aniosDecimal   = round($aniosCompletos + ($diff->m / 12), 2);
            $diasCorr       = diasVacaciones($aniosCompletos);
            $salDiario      = round((float)$r['salario_mensual'] / 30, 2);
            $r['anios_actuales'] = $aniosDecimal;
            $r['anios_completos']= $aniosCompletos;
            $r['dias_actuales']  = $diasCorr;
            $r['salario_diario'] = $salDiario;
            $r['monto_actual']   = round($salDiario * $diasCorr, 2);
        } else {
            $r['anios_actuales']  = 0;
            $r['anios_completos'] = 0;
            $r['dias_actuales']   = 0;
            $r['salario_diario']  = 0;
            $r['monto_actual']    = 0;
        }
    }
    responder(200, ['ok' => true, 'data' => $rows]);
}

// ── REGISTRAR ─────────────────────────────────────────────────
function registrar(array $sesion): void {
    $d = json_decode(file_get_contents('php://input'), true) ?? [];

    $empId       = (int)($d['empleado_id']   ?? 0);
    $fechaInicio = trim($d['fecha_inicio']   ?? '');
    $fechaFin    = trim($d['fecha_fin']      ?? date('Y-m-d'));
    $tipo        = trim($d['tipo']           ?? 'descanso');
    $fechaReg    = trim($d['fecha_registro'] ?? date('Y-m-d'));
    $obs         = strtoupper(trim($d['observaciones'] ?? ''));
    $diasAUsar   = isset($d['dias_a_usar']) ? (int)$d['dias_a_usar'] : null;

    if (!$empId || !$fechaInicio) {
        responder(400, ['error' => 'Empleado y fecha de inicio son requeridos.']); return;
    }
    if (!in_array($tipo, ['descanso', 'pago'])) {
        responder(400, ['error' => 'Tipo inválido.']); return;
    }

    $pdo  = getDB();
    $stmt = $pdo->prepare("SELECT * FROM empleados WHERE id_empleado = ?");
    $stmt->execute([$empId]);
    $emp  = $stmt->fetch();
    if (!$emp) { responder(404, ['error' => 'Empleado no encontrado.']); return; }

    $calc = calcularVacacion($emp, $fechaInicio, $fechaFin);
    if (!$calc['aplica']) {
        responder(400, ['error' => 'El empleado necesita al menos 1 año laborado para tener derecho a vacaciones.']); return;
    }

    // Días ya usados (sin anulados)
    $stmtUsados = $pdo->prepare("
        SELECT COALESCE(SUM(dias_correspondientes),0) AS usados
        FROM vacaciones
        WHERE empleado_id = ? AND estado NOT IN ('anulada')
    ");
    $stmtUsados->execute([$empId]);
    $usados      = (int)$stmtUsados->fetchColumn();
    $disponibles = $calc['dias_correspondientes'] - $usados;

    if ($disponibles <= 0) {
        responder(400, ['error' => "El empleado ya utilizó todos sus días ({$calc['dias_correspondientes']} días). Anule un registro anterior para continuar."]); return;
    }

    // Validar días a usar (parciales)
    if ($diasAUsar === null || $diasAUsar <= 0) {
        $diasAUsar = $disponibles; // Default: usar todos los disponibles
    }
    if ($diasAUsar > $disponibles) {
        responder(400, ['error' => "Solo quedan {$disponibles} días disponibles. No puede usar {$diasAUsar} días."]); return;
    }

    // Recalcular monto con los días parciales
    $salarioDiario  = $calc['salario_diario'];
    $montoParcial   = round($salarioDiario * $diasAUsar, 2);
    $monto          = $tipo === 'pago' ? $montoParcial : 0.00;
    $estado         = $tipo === 'pago' ? 'pagada' : 'tomada';

    $pdo->prepare("
        INSERT INTO vacaciones
          (empleado_id, fecha_inicio, fecha_fin, anios_laborados,
           dias_correspondientes, salario_diario, monto_vacaciones,
           tipo, fecha_registro, observaciones, estado, usuario_id)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?)
    ")->execute([
        $empId,
        $fechaInicio,
        $fechaFin,
        $calc['anios_laborados'],
        $diasAUsar,            // Guardar los días EFECTIVAMENTE usados
        $salarioDiario,
        $monto,
        $tipo,
        $fechaReg,
        $obs ?: null,
        $estado,
        $sesion['usuario_id'],
    ]);

    responder(201, [
        'ok'             => true,
        'id'             => (int)$pdo->lastInsertId(),
        'calculo'        => $calc,
        'dias_usados'    => $diasAUsar,
        'dias_disponibles' => $disponibles - $diasAUsar,
        'monto_parcial'  => $montoParcial,
    ]);
}

// ── EDITAR ────────────────────────────────────────────────────
function editar(array $sesion): void {
    $d = json_decode(file_get_contents('php://input'), true) ?? [];

    $id          = (int)($d['id']            ?? 0);
    $fechaInicio = trim($d['fecha_inicio']   ?? '');
    $fechaFin    = trim($d['fecha_fin']      ?? '');
    $tipo        = trim($d['tipo']           ?? 'descanso');
    $fechaReg    = trim($d['fecha_registro'] ?? date('Y-m-d'));
    $obs         = strtoupper(trim($d['observaciones'] ?? ''));
    $diasAUsar   = isset($d['dias_a_usar']) ? (int)$d['dias_a_usar'] : null;

    if (!$id || !$fechaInicio || !$fechaFin) {
        responder(400, ['error' => 'ID, fecha inicio y fecha fin son requeridos.']); return;
    }

    $pdo = getDB();
    // Obtener registro actual con salario del empleado
    $stmtVac = $pdo->prepare("
        SELECT v.*, e.salario_mensual
        FROM vacaciones v
        JOIN empleados e ON e.id_empleado = v.empleado_id
        WHERE v.id_vacacion = ?
    ");
    $stmtVac->execute([$id]);
    $vac = $stmtVac->fetch();
    if (!$vac) { responder(404, ['error' => 'Registro no encontrado.']); return; }

    $emp  = ['salario_mensual' => $vac['salario_mensual']];
    $calc = calcularVacacion($emp, $fechaInicio, $fechaFin);
    if (!$calc['aplica']) {
        responder(400, ['error' => 'El período no alcanza 1 año laborado.']); return;
    }

    // Días disponibles excluyendo este registro
    $stmtUsados = $pdo->prepare("
        SELECT COALESCE(SUM(dias_correspondientes),0) AS usados
        FROM vacaciones
        WHERE empleado_id = ? AND estado NOT IN ('anulada') AND id_vacacion != ?
    ");
    $stmtUsados->execute([$vac['empleado_id'], $id]);
    $usados      = (int)$stmtUsados->fetchColumn();
    $disponibles = $calc['dias_correspondientes'] - $usados;

    if ($diasAUsar === null || $diasAUsar <= 0) {
        $diasAUsar = $disponibles;
    }
    if ($diasAUsar > $disponibles) {
        responder(400, ['error' => "Solo quedan {$disponibles} días disponibles."]); return;
    }

    $salarioDiario = $calc['salario_diario'];
    $montoParcial  = round($salarioDiario * $diasAUsar, 2);
    $monto         = $tipo === 'pago' ? $montoParcial : 0.00;
    $estado        = $tipo === 'pago' ? 'pagada' : 'tomada';

    $pdo->prepare("
        UPDATE vacaciones SET
          fecha_inicio=?, fecha_fin=?, anios_laborados=?,
          dias_correspondientes=?, salario_diario=?, monto_vacaciones=?,
          tipo=?, fecha_registro=?, observaciones=?, estado=?
        WHERE id_vacacion=?
    ")->execute([
        $fechaInicio,
        $fechaFin,
        $calc['anios_laborados'],
        $diasAUsar,
        $salarioDiario,
        $monto,
        $tipo,
        $fechaReg,
        $obs ?: null,
        $estado,
        $id,
    ]);

    responder(200, [
        'ok'              => true,
        'calculo'         => $calc,
        'dias_usados'     => $diasAUsar,
        'dias_disponibles'=> $disponibles - $diasAUsar,
    ]);
}

// ── ANULAR ────────────────────────────────────────────────────
function anular(array $sesion): void {
    $d  = json_decode(file_get_contents('php://input'), true) ?? [];
    $id = (int)($d['id'] ?? 0);
    if (!$id) { responder(400, ['error' => 'ID requerido.']); return; }
    getDB()->prepare("UPDATE vacaciones SET estado='anulada' WHERE id_vacacion=?")->execute([$id]);
    responder(200, ['ok' => true]);
}

function responder(int $code, array $data): void {
    http_response_code($code); echo json_encode($data); exit;
}
