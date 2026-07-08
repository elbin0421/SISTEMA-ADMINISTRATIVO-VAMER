<?php
require_once __DIR__ . '/../config/db.php';

class RequisicionModel {

    public static function siguienteNumero(): string {
        $anio = date('Y');
        $stmt = getDB()->prepare("SELECT MAX(CAST(SUBSTRING_INDEX(numero,'-',-1) AS UNSIGNED)) AS max_n FROM requisiciones_materiales WHERE numero LIKE ?");
        $stmt->execute(["REQ-$anio-%"]);
        $n = (int)($stmt->fetch()['max_n'] ?? 0) + 1;
        return "REQ-$anio-" . str_pad($n, 3, '0', STR_PAD_LEFT);
    }

    public static function listar(string $estado = 'todos', string $q = ''): array {
        $where = "WHERE 1=1"; $params = [];
        if ($estado !== 'todos') { $where .= " AND r.estado = ?"; $params[] = $estado; }
        if ($q) {
            $where .= " AND (r.numero LIKE ? OR r.departamento LIKE ? OR r.numero_ot LIKE ? OR r.unidad LIKE ? OR CONCAT(e.nombres,' ',e.apellidos) LIKE ?)";
            for ($i = 0; $i < 5; $i++) $params[] = "%$q%";
        }
        $pdo  = getDB();
        $nova = $pdo->query("SHOW COLUMNS FROM empleados LIKE 'nombres'")->fetchAll();
        $empNombre = $nova ? "CONCAT(e.nombres,' ',e.apellidos)" : "e.nombre";
        $stmt = $pdo->prepare("
            SELECT r.*, $empNombre AS empleado_nombre,
                   c.nombre AS cliente_nombre
            FROM requisiciones_materiales r
            JOIN empleados e ON e.id_empleado = r.empleado_id
            LEFT JOIN clientes c ON c.id_cliente = r.cliente_id
            $where ORDER BY r.fecha_creacion DESC");
        $stmt->execute($params);
        return $stmt->fetchAll();
    }

    public static function obtener(int $id): ?array {
        $pdo  = getDB();
        $nova = $pdo->query("SHOW COLUMNS FROM empleados LIKE 'nombres'")->fetchAll();
        $empNombre = $nova ? "CONCAT(e.nombres,' ',e.apellidos)" : "e.nombre";
        $stmt = $pdo->prepare("
            SELECT r.*, $empNombre AS empleado_nombre,
                   c.nombre AS cliente_nombre
            FROM requisiciones_materiales r
            JOIN empleados e ON e.id_empleado = r.empleado_id
            LEFT JOIN clientes c ON c.id_cliente = r.cliente_id
            WHERE r.id_requisicion = ?");
        $stmt->execute([$id]);
        $row = $stmt->fetch();
        if (!$row) return null;
        $d = $pdo->prepare("
            SELECT rd.*, m.nombre AS material_nombre, m.codigo AS material_codigo, m.stock AS stock_actual
            FROM requisicion_detalle rd
            LEFT JOIN materiales m ON m.id_material = rd.material_id
            WHERE rd.requisicion_id = ? ORDER BY rd.id_detalle");
        $d->execute([$id]);
        $row['detalle'] = $d->fetchAll();
        return $row;
    }

    public static function crear(array $h, array $detalle, int $usuario_id): int {
        $pdo    = getDB();
        $numero = self::siguienteNumero();
        $pdo->prepare("
            INSERT INTO requisiciones_materiales
              (numero, fecha_solicitud, empleado_id, departamento, numero_ot, unidad, cliente_id, observaciones, usuario_id)
            VALUES (?,?,?,?,?,?,?,?,?)
        ")->execute([
            $numero, $h['fecha_solicitud'], (int)$h['empleado_id'],
            trim($h['departamento']),
            trim($h['numero_ot'] ?? '') ?: null,
            strtoupper(trim($h['unidad'] ?? '')) ?: null,
            !empty($h['cliente_id']) ? (int)$h['cliente_id'] : null,
            trim($h['observaciones'] ?? '') ?: null,
            $usuario_id,
        ]);
        $id = (int)$pdo->lastInsertId();
        self::insertarDetalle($pdo, $id, $detalle);
        return $id;
    }

    public static function actualizar(int $id, array $h, array $detalle): void {
        $pdo = getDB();
        $pdo->prepare("
            UPDATE requisiciones_materiales SET
              fecha_solicitud=?, empleado_id=?, departamento=?, numero_ot=?, unidad=?, cliente_id=?, observaciones=?
            WHERE id_requisicion=?
        ")->execute([
            $h['fecha_solicitud'], (int)$h['empleado_id'], trim($h['departamento']),
            trim($h['numero_ot'] ?? '') ?: null,
            strtoupper(trim($h['unidad'] ?? '')) ?: null,
            !empty($h['cliente_id']) ? (int)$h['cliente_id'] : null,
            trim($h['observaciones'] ?? '') ?: null,
            $id,
        ]);
        $pdo->prepare("DELETE FROM requisicion_detalle WHERE requisicion_id=?")->execute([$id]);
        self::insertarDetalle($pdo, $id, $detalle);
    }

    public static function cambiarEstado(int $id, string $estado, int $usuario_id = 0): void {
        $pdo = getDB();

        if ($estado === 'despachada') {
            $req = self::obtener($id);
            if (!$req) throw new \Exception('Requisición no encontrada.');

            // Validar stock
            $errores = [];
            foreach ($req['detalle'] as $it) {
                if (empty($it['material_id'])) continue;
                $s = $pdo->prepare("SELECT nombre, stock FROM materiales WHERE id_material = ?");
                $s->execute([(int)$it['material_id']]);
                $mat = $s->fetch();
                if (!$mat) continue;
                if ((float)$mat['stock'] <= 0)
                    $errores[] = "{$mat['nombre']}: sin stock (disponible: {$mat['stock']})";
                elseif ((float)$mat['stock'] < (float)$it['cantidad'])
                    $errores[] = "{$mat['nombre']}: stock insuficiente (necesario: {$it['cantidad']}, disponible: {$mat['stock']})";
            }
            if ($errores)
                throw new \Exception('No se puede despachar. Stock insuficiente: ' . implode('; ', $errores));

            $pdo->prepare("UPDATE requisiciones_materiales SET estado=? WHERE id_requisicion=?")->execute([$estado, $id]);

            $stmtUpd = $pdo->prepare("UPDATE materiales SET stock = GREATEST(0, stock - ?) WHERE id_material = ?");
            $stmtMov = $pdo->prepare("
                INSERT INTO movimientos_inventario
                  (material_id, tipo, cantidad, costo_unitario, tipo_referencia, referencia_id, usuario_id, observaciones)
                VALUES (?, 'salida', ?, 0, 'ajuste_manual', ?, ?, ?)
            ");
            foreach ($req['detalle'] as $it) {
                if (empty($it['material_id'])) continue;
                $stmtUpd->execute([(float)$it['cantidad'], (int)$it['material_id']]);
                $stmtMov->execute([(int)$it['material_id'], (float)$it['cantidad'], $id, $usuario_id ?: 1, 'Requisición '.$req['numero']]);
            }
            return;
        }

        $pdo->prepare("UPDATE requisiciones_materiales SET estado=? WHERE id_requisicion=?")->execute([$estado, $id]);
    }

    private static function insertarDetalle(\PDO $pdo, int $req_id, array $detalle): void {
        $stmt = $pdo->prepare("
            INSERT INTO requisicion_detalle (requisicion_id, material_id, descripcion, unidad_medida, cantidad, observacion)
            VALUES (?,?,?,?,?,?)");
        foreach ($detalle as $it) {
            if (empty($it['descripcion'])) continue;
            $stmt->execute([
                $req_id,
                isset($it['material_id']) && $it['material_id'] ? (int)$it['material_id'] : null,
                trim($it['descripcion']),
                trim($it['unidad_medida'] ?? 'unidad'),
                (float)($it['cantidad'] ?? 1),
                trim($it['observacion'] ?? '') ?: null,
            ]);
        }
    }
}
