<?php
// ============================================================
//  VAMER — AsistenciaModel
//  Registro de horas extra y días faltados. La planilla toma
//  solo las cantidades y calcula el valor.
// ============================================================
require_once __DIR__ . '/../config/db.php';

class AsistenciaModel {

    const TIPOS = ['horas_extra', 'dia_faltado'];

    public static function empleados(): array {
        return getDB()->query("
            SELECT id_empleado, CONCAT(nombres,' ',apellidos) AS nombre, empresa_id
            FROM empleados WHERE estado='activo' ORDER BY nombres, apellidos
        ")->fetchAll();
    }

    public static function listar(array $f): array {
        $w = []; $p = [];
        if (!empty($f['desde']))       { $w[] = 'a.fecha >= ?'; $p[] = $f['desde']; }
        if (!empty($f['hasta']))       { $w[] = 'a.fecha <= ?'; $p[] = $f['hasta']; }
        if (!empty($f['tipo']))        { $w[] = 'a.tipo = ?'; $p[] = $f['tipo']; }
        if (!empty($f['empleado_id'])) { $w[] = 'a.empleado_id = ?'; $p[] = (int)$f['empleado_id']; }
        if (($f['estado'] ?? '') === 'pendiente') $w[] = 'a.planilla_id IS NULL';
        if (($f['estado'] ?? '') === 'aplicado')  $w[] = 'a.planilla_id IS NOT NULL';
        $where = $w ? 'WHERE ' . implode(' AND ', $w) : '';
        $st = getDB()->prepare("
            SELECT a.*, CONCAT(e.nombres,' ',e.apellidos) AS empleado,
                   pl.periodo_mes, pl.periodo_anio, pl.quincena
            FROM asistencia_registros a
            JOIN empleados e ON e.id_empleado = a.empleado_id
            LEFT JOIN planillas pl ON pl.id_planilla = a.planilla_id
            $where
            ORDER BY a.fecha DESC, a.id_registro DESC
            LIMIT 1000
        ");
        $st->execute($p);
        return $st->fetchAll();
    }

    public static function obtener(int $id) {
        $st = getDB()->prepare("SELECT * FROM asistencia_registros WHERE id_registro=?");
        $st->execute([$id]);
        return $st->fetch();
    }

    private static function validar(array $d): array {
        $emp = (int)($d['empleado_id'] ?? 0);
        if (!$emp) throw new Exception('Selecciona el empleado.');
        $chk = getDB()->prepare("SELECT 1 FROM empleados WHERE id_empleado=?");
        $chk->execute([$emp]);
        if (!$chk->fetch()) throw new Exception('Empleado no encontrado.');
        $fecha = trim($d['fecha'] ?? '');
        if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $fecha)) throw new Exception('Fecha inválida.');
        $tipo = $d['tipo'] ?? '';
        if (!in_array($tipo, self::TIPOS, true)) throw new Exception('Tipo inválido.');
        $cant = round((float)($d['cantidad'] ?? 0), 2);
        if ($cant <= 0) throw new Exception('La cantidad debe ser mayor a cero.');
        if ($tipo === 'dia_faltado' && $cant > 31) throw new Exception('Los días faltados no pueden ser más de 31.');
        if ($tipo === 'horas_extra' && $cant > 300) throw new Exception('Cantidad de horas extra inválida.');
        $motivo = trim($d['motivo'] ?? '');
        return [$emp, $fecha, $tipo, $cant, $motivo === '' ? null : substr($motivo, 0, 255)];
    }

    public static function crear(array $d, int $usuario_id): int {
        [$emp, $fecha, $tipo, $cant, $motivo] = self::validar($d);
        $pdo = getDB();
        $pdo->prepare("INSERT INTO asistencia_registros (empleado_id, fecha, tipo, cantidad, motivo, usuario_id) VALUES (?,?,?,?,?,?)")
            ->execute([$emp, $fecha, $tipo, $cant, $motivo, $usuario_id]);
        return (int)$pdo->lastInsertId();
    }

    private static function pendienteOFalla(int $id, string $accion): void {
        $r = self::obtener($id);
        if (!$r) throw new Exception('Registro no encontrado.');
        if ($r['planilla_id']) throw new Exception("El registro ya fue aplicado en una planilla. Elimina la planilla (borrador) para poder $accion.");
    }

    public static function editar(int $id, array $d): void {
        self::pendienteOFalla($id, 'editarlo');
        [$emp, $fecha, $tipo, $cant, $motivo] = self::validar($d);
        getDB()->prepare("UPDATE asistencia_registros SET empleado_id=?, fecha=?, tipo=?, cantidad=?, motivo=? WHERE id_registro=?")
            ->execute([$emp, $fecha, $tipo, $cant, $motivo, $id]);
    }

    public static function eliminar(int $id): void {
        self::pendienteOFalla($id, 'eliminarlo');
        getDB()->prepare("DELETE FROM asistencia_registros WHERE id_registro=?")->execute([$id]);
    }

    // ── Integración con planilla ──────────────────────────
    public static function pendientesPlanilla(string $hasta, int $empresa_id = 0): array {
        $sql = "SELECT a.id_registro, a.fecha, a.empleado_id, a.tipo, a.cantidad,
                       CONCAT(e.nombres,' ',e.apellidos) AS empleado
                FROM asistencia_registros a
                JOIN empleados e ON e.id_empleado = a.empleado_id
                WHERE a.planilla_id IS NULL AND a.fecha <= ?";
        $p = [$hasta];
        if ($empresa_id) { $sql .= ' AND e.empresa_id = ?'; $p[] = $empresa_id; }
        $st = getDB()->prepare($sql . ' ORDER BY a.fecha, a.id_registro');
        $st->execute($p);
        return $st->fetchAll();
    }

    public static function dePlanilla(int $planilla_id): array {
        $st = getDB()->prepare("
            SELECT a.id_registro, a.fecha, a.empleado_id, a.tipo, a.cantidad,
                   CONCAT(e.nombres,' ',e.apellidos) AS empleado
            FROM asistencia_registros a JOIN empleados e ON e.id_empleado = a.empleado_id
            WHERE a.planilla_id = ? ORDER BY a.fecha, a.id_registro");
        $st->execute([$planilla_id]);
        return $st->fetchAll();
    }

    public static function aplicarAPlanilla(PDO $pdo, int $planilla_id, array $ids): void {
        $ids = array_values(array_filter(array_map('intval', $ids)));
        if (!$ids) return;
        $in = implode(',', array_fill(0, count($ids), '?'));
        $pdo->prepare("UPDATE asistencia_registros SET planilla_id=? WHERE id_registro IN ($in) AND planilla_id IS NULL")
            ->execute(array_merge([$planilla_id], $ids));
    }

    public static function liberarPlanilla(PDO $pdo, int $planilla_id): void {
        $pdo->prepare("UPDATE asistencia_registros SET planilla_id=NULL WHERE planilla_id=?")->execute([$planilla_id]);
    }
}
