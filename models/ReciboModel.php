<?php
// ============================================================
//  VAMER — ReciboModel
//  Recibos (viáticos / adelantos de salario / abonos a préstamo)
//  integrables a la planilla quincenal.
// ============================================================
require_once __DIR__ . '/../config/db.php';

class ReciboModel {

    const TIPOS = ['viaticos', 'adelanto_salario', 'abono_prestamo', 'otro'];
    const MAX_LINEAS = 5;

    // ── Serie ─────────────────────────────────────────────
    public static function serie() {
        return getDB()->query("SELECT * FROM recibos_serie WHERE estado='activo' ORDER BY id_serie DESC LIMIT 1")->fetch();
    }

    public static function guardarSerie(array $d): void {
        $prefijo = trim($d['prefijo'] ?? '');
        $ini = (int)($d['rango_inicio'] ?? 0);
        $fin = (int)($d['rango_fin'] ?? 0);
        $act = (int)($d['correlativo_actual'] ?? 0);
        $lim = trim($d['fecha_limite_emision'] ?? '');
        if ($prefijo === '' || !preg_match('/^[0-9A-Za-z\-]+$/', $prefijo)) throw new Exception('Prefijo inválido (ej: 000-001-01).');
        if ($ini < 1 || $fin < $ini) throw new Exception('El rango final debe ser mayor o igual al inicial.');
        if ($act < 0 || $act > $fin) throw new Exception('El correlativo actual no puede ser mayor al rango final.');
        if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $lim)) throw new Exception('Fecha límite de emisión inválida.');
        $pdo = getDB();
        $s = self::serie();
        if ($s) {
            $pdo->prepare("UPDATE recibos_serie SET prefijo=?, rango_inicio=?, rango_fin=?, correlativo_actual=?, fecha_limite_emision=? WHERE id_serie=?")
                ->execute([$prefijo, $ini, $fin, $act, $lim, $s['id_serie']]);
        } else {
            $pdo->prepare("INSERT INTO recibos_serie (prefijo, rango_inicio, rango_fin, correlativo_actual, fecha_limite_emision) VALUES (?,?,?,?,?)")
                ->execute([$prefijo, $ini, $fin, $act, $lim]);
        }
    }

    private static function formatearNumero(string $prefijo, int $n): string {
        return $prefijo . '-' . str_pad((string)$n, 8, '0', STR_PAD_LEFT);
    }

    // ── Empleados (selector) ──────────────────────────────
    public static function empleados(): array {
        return getDB()->query("
            SELECT id_empleado, CONCAT(nombres,' ',apellidos) AS nombre, identidad, direccion, empresa_id
            FROM empleados WHERE estado='activo' ORDER BY nombres, apellidos
        ")->fetchAll();
    }

    // ── Listado ───────────────────────────────────────────
    public static function listar(array $f): array {
        $w = []; $p = [];
        if (!empty($f['desde']))       { $w[] = 'r.fecha >= ?'; $p[] = $f['desde']; }
        if (!empty($f['hasta']))       { $w[] = 'r.fecha <= ?'; $p[] = $f['hasta']; }
        if (!empty($f['estado']))      { $w[] = 'r.estado = ?'; $p[] = $f['estado']; }
        if (!empty($f['empleado_id'])) { $w[] = 'r.empleado_id = ?'; $p[] = (int)$f['empleado_id']; }
        if (!empty($f['q'])) {
            $w[] = '(r.numero LIKE ? OR r.empleado_nombre LIKE ?)';
            $p[] = '%' . $f['q'] . '%'; $p[] = '%' . $f['q'] . '%';
        }
        $where = $w ? 'WHERE ' . implode(' AND ', $w) : '';
        $stmt = getDB()->prepare("
            SELECT r.*, pl.periodo_mes, pl.periodo_anio, pl.quincena,
              (SELECT GROUP_CONCAT(DISTINCT d.concepto_tipo)
                 FROM recibos_detalle d WHERE d.recibo_id = r.id_recibo) AS tipos
            FROM recibos r
            LEFT JOIN planillas pl ON pl.id_planilla = r.planilla_id
            $where
            ORDER BY r.fecha DESC, r.id_recibo DESC
            LIMIT 1000
        ");
        $stmt->execute($p);
        return $stmt->fetchAll();
    }

    public static function obtener(int $id) {
        $pdo = getDB();
        $stmt = $pdo->prepare("
            SELECT r.*, pl.periodo_mes, pl.periodo_anio, pl.quincena
            FROM recibos r LEFT JOIN planillas pl ON pl.id_planilla = r.planilla_id
            WHERE r.id_recibo = ?");
        $stmt->execute([$id]);
        $r = $stmt->fetch();
        if (!$r) return false;
        $d = $pdo->prepare("SELECT concepto_tipo, descripcion, monto FROM recibos_detalle WHERE recibo_id=? ORDER BY id_detalle");
        $d->execute([$id]);
        $r['detalle'] = $d->fetchAll();
        return $r;
    }

    // ── Validación de datos ───────────────────────────────
    private static function validar(array $d): array {
        $empId = (int)($d['empleado_id'] ?? 0);
        if (!$empId) throw new Exception('Selecciona el empleado.');
        $fecha = trim($d['fecha'] ?? '') ?: date('Y-m-d');
        if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $fecha)) throw new Exception('Fecha inválida.');

        $st = getDB()->prepare("SELECT CONCAT(nombres,' ',apellidos) AS nombre, identidad, direccion FROM empleados WHERE id_empleado=?");
        $st->execute([$empId]);
        $emp = $st->fetch();
        if (!$emp) throw new Exception('Empleado no encontrado.');

        $lineas = [];
        foreach (($d['detalle'] ?? []) as $l) {
            $tipo  = $l['concepto_tipo'] ?? '';
            $desc  = trim($l['descripcion'] ?? '');
            $monto = round((float)($l['monto'] ?? 0), 2);
            if ($tipo === '' && $desc === '' && $monto == 0) continue; // línea vacía
            if (!in_array($tipo, self::TIPOS, true)) throw new Exception('Concepto inválido.');
            if ($monto <= 0) throw new Exception('Cada línea debe tener un monto mayor a cero.');
            $lineas[] = ['concepto_tipo' => $tipo, 'descripcion' => mb_substr($desc, 0, 255), 'monto' => $monto];
        }
        if (!$lineas) throw new Exception('Agrega al menos una línea al recibo.');
        if (count($lineas) > self::MAX_LINEAS) throw new Exception('Un recibo admite máximo ' . self::MAX_LINEAS . ' líneas.');

        $tieneViaticos = false;
        foreach ($lineas as $l) if ($l['concepto_tipo'] === 'viaticos') $tieneViaticos = true;
        $semana = (int)($d['semana'] ?? 0);
        if ($tieneViaticos && ($semana < 1 || $semana > 4)) throw new Exception('Selecciona la semana a la que pertenecen los viáticos (1 a 4).');
        if (!$tieneViaticos) $semana = 0;

        $subtotal = 0; foreach ($lineas as $l) $subtotal += $l['monto'];
        $ret = round((float)($d['retenciones'] ?? 0), 2);
        if ($ret < 0 || $ret > $subtotal) throw new Exception('Retenciones inválidas.');

        return [
            'empleado_id' => $empId,
            'empleado_nombre' => trim($emp['nombre']),
            'rtn' => trim($d['rtn'] ?? '') ?: ($emp['identidad'] ?? null),
            'direccion' => trim($d['direccion'] ?? '') ?: null,
            'fecha' => $fecha,
            'semana' => $semana ?: null,
            'subtotal' => round($subtotal, 2),
            'retenciones' => $ret,
            'total' => round($subtotal - $ret, 2),
            'observaciones' => mb_substr(trim($d['observaciones'] ?? ''), 0, 255) ?: null,
            'lineas' => $lineas,
        ];
    }

    private static function insertarLineas(PDO $pdo, int $id, array $lineas): void {
        $ins = $pdo->prepare("INSERT INTO recibos_detalle (recibo_id, concepto_tipo, descripcion, monto) VALUES (?,?,?,?)");
        foreach ($lineas as $l) $ins->execute([$id, $l['concepto_tipo'], $l['descripcion'], $l['monto']]);
    }

    // ── Crear (valida fecha límite y rango, igual que el CAI) ──
    public static function crear(array $d, int $usuario_id): int {
        $v   = self::validar($d);
        $pdo = getDB();
        $pdo->beginTransaction();
        try {
            $s = $pdo->query("SELECT * FROM recibos_serie WHERE estado='activo' ORDER BY id_serie DESC LIMIT 1 FOR UPDATE")->fetch();
            if (!$s) throw new Exception('Configura primero la serie de recibos (rango autorizado y fecha límite).');
            if (date('Y-m-d') > $s['fecha_limite_emision']) {
                throw new Exception('La Fecha Límite de Emisión (' . $s['fecha_limite_emision'] . ') ya venció. Actualiza la serie de recibos.');
            }
            $next = max((int)$s['correlativo_actual'] + 1, (int)$s['rango_inicio']);
            if ($next > (int)$s['rango_fin']) {
                throw new Exception('Se agotó el Rango Autorizado de recibos (' . self::formatearNumero($s['prefijo'], (int)$s['rango_fin']) . ').');
            }
            $numero = self::formatearNumero($s['prefijo'], $next);
            $rango  = self::formatearNumero($s['prefijo'], (int)$s['rango_inicio']) . ' AL ' . self::formatearNumero($s['prefijo'], (int)$s['rango_fin']);

            $pdo->prepare("
                INSERT INTO recibos (numero, correlativo, fecha, semana, empleado_id, empleado_nombre, rtn, direccion,
                    subtotal, retenciones, total, fecha_limite_emision, rango_autorizado, observaciones, usuario_id)
                VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
            ")->execute([$numero, $next, $v['fecha'], $v['semana'], $v['empleado_id'], $v['empleado_nombre'], $v['rtn'], $v['direccion'],
                $v['subtotal'], $v['retenciones'], $v['total'], $s['fecha_limite_emision'], $rango, $v['observaciones'], $usuario_id]);
            $id = (int)$pdo->lastInsertId();
            self::insertarLineas($pdo, $id, $v['lineas']);
            $pdo->prepare("UPDATE recibos_serie SET correlativo_actual=? WHERE id_serie=?")->execute([$next, $s['id_serie']]);
            $pdo->commit();
            return $id;
        } catch (Exception $e) {
            if ($pdo->inTransaction()) $pdo->rollBack();
            throw $e;
        }
    }

    // ── Editar (solo emitido y sin aplicar a planilla) ────
    public static function editar(int $id, array $d): void {
        $pdo = getDB();
        $st = $pdo->prepare("SELECT estado, planilla_id FROM recibos WHERE id_recibo=?");
        $st->execute([$id]);
        $r = $st->fetch();
        if (!$r) throw new Exception('Recibo no encontrado.');
        if ($r['estado'] !== 'emitido') throw new Exception('No se puede editar un recibo anulado.');
        if ($r['planilla_id']) throw new Exception('El recibo ya fue aplicado en una planilla. Elimina la planilla (borrador) para poder editarlo.');
        $v = self::validar($d);
        $pdo->beginTransaction();
        try {
            $pdo->prepare("
                UPDATE recibos SET fecha=?, semana=?, empleado_id=?, empleado_nombre=?, rtn=?, direccion=?,
                    subtotal=?, retenciones=?, total=?, observaciones=? WHERE id_recibo=?
            ")->execute([$v['fecha'], $v['semana'], $v['empleado_id'], $v['empleado_nombre'], $v['rtn'], $v['direccion'],
                $v['subtotal'], $v['retenciones'], $v['total'], $v['observaciones'], $id]);
            $pdo->prepare("DELETE FROM recibos_detalle WHERE recibo_id=?")->execute([$id]);
            self::insertarLineas($pdo, $id, $v['lineas']);
            $pdo->commit();
        } catch (Exception $e) {
            if ($pdo->inTransaction()) $pdo->rollBack();
            throw $e;
        }
    }

    public static function anular(int $id): void {
        $pdo = getDB();
        $st = $pdo->prepare("SELECT estado, planilla_id FROM recibos WHERE id_recibo=?");
        $st->execute([$id]);
        $r = $st->fetch();
        if (!$r) throw new Exception('Recibo no encontrado.');
        if ($r['estado'] === 'anulado') throw new Exception('El recibo ya está anulado.');
        if ($r['planilla_id']) throw new Exception('El recibo ya fue aplicado en una planilla. Elimina la planilla (borrador) para poder anularlo.');
        $pdo->prepare("UPDATE recibos SET estado='anulado' WHERE id_recibo=?")->execute([$id]);
    }

    // ── Integración con planilla ──────────────────────────
    private static function sqlSumas(): string {
        return "SELECT r.id_recibo, r.numero, r.fecha, r.semana, r.empleado_id, r.empleado_nombre,
                  SUM(CASE WHEN d.concepto_tipo='viaticos'         THEN d.monto ELSE 0 END) AS viaticos,
                  SUM(CASE WHEN d.concepto_tipo='adelanto_salario' THEN d.monto ELSE 0 END) AS adelanto,
                  SUM(CASE WHEN d.concepto_tipo='abono_prestamo'   THEN d.monto ELSE 0 END) AS abono_prestamo
                FROM recibos r
                JOIN recibos_detalle d ON d.recibo_id = r.id_recibo
                JOIN empleados e ON e.id_empleado = r.empleado_id";
    }

    /** Recibos emitidos y aún no aplicados, con fecha <= $hasta. */
    public static function pendientesPlanilla(string $hasta, int $empresa_id = 0, string $quincena = ''): array {
        $sql = self::sqlSumas() . " WHERE r.estado='emitido' AND r.planilla_id IS NULL AND r.fecha <= ?";
        $p = [$hasta];
        if ($empresa_id) { $sql .= ' AND e.empresa_id = ?'; $p[] = $empresa_id; }
        // Un recibo con viáticos solo entra en la quincena que contiene su semana (1-2 = 1ra, 3-4 = 2da)
        $semanas = $quincena === '2da' ? '3,4' : '1,2';
        $sql .= " GROUP BY r.id_recibo HAVING (viaticos + adelanto + abono_prestamo) > 0
                  AND (viaticos = 0 OR r.semana IN ($semanas)) ORDER BY r.fecha, r.id_recibo";
        $st = getDB()->prepare($sql);
        $st->execute($p);
        return $st->fetchAll();
    }

    public static function deLaPlanilla(int $planilla_id): array {
        $st = getDB()->prepare(self::sqlSumas() . " WHERE r.planilla_id = ? GROUP BY r.id_recibo ORDER BY r.fecha, r.id_recibo");
        $st->execute([$planilla_id]);
        return $st->fetchAll();
    }

    public static function aplicarAPlanilla(PDO $pdo, int $planilla_id, array $ids): void {
        $ids = array_values(array_filter(array_map('intval', $ids)));
        if (!$ids) return;
        $in = implode(',', array_fill(0, count($ids), '?'));
        $pdo->prepare("UPDATE recibos SET planilla_id=? WHERE id_recibo IN ($in) AND planilla_id IS NULL AND estado='emitido'")
            ->execute(array_merge([$planilla_id], $ids));
    }

    public static function liberarPlanilla(PDO $pdo, int $planilla_id): void {
        $pdo->prepare("UPDATE recibos SET planilla_id=NULL WHERE planilla_id=?")->execute([$planilla_id]);
    }
}
