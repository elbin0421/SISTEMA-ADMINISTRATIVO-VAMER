<?php
// ============================================================
//  SOLDYMEG — OrdenModel
// ============================================================
require_once __DIR__ . '/../config/db.php';

class OrdenModel {

    public static function listar(string $estado = ''): array {
        $where  = $estado ? "WHERE ot.estado = ?" : "WHERE ot.estado != 'anulada'";
        $params = $estado ? [$estado] : [];
        $stmt   = getDB()->prepare("
            SELECT ot.id_orden, ot.numero_orden, ot.fecha_apertura, ot.fecha_cierre,
                   ot.placa, ot.marca, ot.modelo, ot.anio, ot.estado,
                   ot.descripcion_trabajo,
                   cl.nombre AS cliente,
                   u.nombre  AS usuario,
                   GROUP_CONCAT(CONCAT(e.nombres, ' ', e.apellidos) ORDER BY e.apellidos SEPARATOR ', ') AS tecnicos
            FROM ordenes_trabajo ot
            JOIN clientes cl  ON cl.id_cliente  = ot.cliente_id
            JOIN usuarios u   ON u.id_usuario   = ot.usuario_id
            LEFT JOIN orden_tecnicos ott ON ott.orden_id   = ot.id_orden
            LEFT JOIN empleados      e   ON e.id_empleado = ott.empleado_id
            $where
            GROUP BY ot.id_orden
            ORDER BY ot.fecha_apertura DESC, ot.id_orden DESC
            LIMIT 300
        ");
        $stmt->execute($params);
        return $stmt->fetchAll();
    }

    public static function obtener(int $id): ?array {
        $pdo  = getDB();
        $stmt = $pdo->prepare("
            SELECT ot.*, cl.nombre AS cliente, cl.telefono AS cliente_tel,
                   u.nombre AS usuario
            FROM ordenes_trabajo ot
            JOIN clientes cl ON cl.id_cliente = ot.cliente_id
            JOIN usuarios u  ON u.id_usuario  = ot.usuario_id
            WHERE ot.id_orden = ?
        ");
        $stmt->execute([$id]);
        $ot = $stmt->fetch();
        if (!$ot) return null;

        $s = $pdo->prepare("
            SELECT e.id_empleado, CONCAT(e.nombres, ' ', e.apellidos) AS nombre, e.puesto, e.salario_mensual
            FROM orden_tecnicos ott
            JOIN empleados e ON e.id_empleado = ott.empleado_id
            WHERE ott.orden_id = ? ORDER BY e.apellidos, e.nombres
        ");
        $s->execute([$id]);
        $ot['tecnicos'] = $s->fetchAll();

        $s = $pdo->prepare("
            SELECT d.id_detalle_om, d.material_id, d.cantidad,
                   d.precio_unitario, d.subtotal,
                   m.nombre AS material, m.unidad_medida
            FROM detalle_orden_materiales d
            JOIN materiales m ON m.id_material = d.material_id
            WHERE d.orden_id = ?
        ");
        $s->execute([$id]);
        $ot['materiales'] = $s->fetchAll();

        $s = $pdo->prepare("SELECT * FROM detalle_orden_mano_obra WHERE orden_id = ?");
        $s->execute([$id]);
        $ot['mano_obra'] = $s->fetchAll();

        $ot['total_materiales'] = array_sum(array_column($ot['materiales'], 'subtotal'));
        $ot['total_mano_obra']  = array_sum(array_column($ot['mano_obra'],  'subtotal'));
        $ot['total_general']    = $ot['total_materiales'] + $ot['total_mano_obra'];

        return $ot;
    }

    public static function cambiarEstado(int $id, string $estado): bool {
        $fecha_cierre = in_array($estado, ['finalizada', 'facturada', 'cotizado'])
            ? date('Y-m-d') : null;
        if ($fecha_cierre) {
            return getDB()->prepare(
                "UPDATE ordenes_trabajo SET estado=?, fecha_cierre=? WHERE id_orden=?"
            )->execute([$estado, $fecha_cierre, $id]);
        }
        return getDB()->prepare(
            "UPDATE ordenes_trabajo SET estado=? WHERE id_orden=?"
        )->execute([$estado, $id]);
    }

    public static function tecnicos(): array {
        $stmt = getDB()->prepare(
            "SELECT id_empleado,
                    CONCAT(nombres, ' ', apellidos) AS nombre,
                    puesto, salario_mensual
             FROM empleados
             WHERE estado = 'activo' AND (ubicacion = 'SOLDYMEG' OR ubicacion IS NULL)
             ORDER BY apellidos, nombres"
        );
        $stmt->execute();
        return $stmt->fetchAll();
    }

    public static function quitarMaterial(int $detalle_id): bool {
        return getDB()->prepare(
            "DELETE FROM detalle_orden_materiales WHERE id_detalle_om=?"
        )->execute([$detalle_id]);
    }

    public static function quitarManoObra(int $mo_id): bool {
        return getDB()->prepare(
            "DELETE FROM detalle_orden_mano_obra WHERE id_mano_obra=?"
        )->execute([$mo_id]);
    }

    public static function agregarManoObra(int $orden_id, string $desc, float $dias, float $tarifa, float $subtotal): int {
        $pdo = getDB();
        $pdo->prepare(
            "INSERT INTO detalle_orden_mano_obra (orden_id, descripcion, dias, tarifa_dia, subtotal) VALUES (?,?,?,?,?)"
        )->execute([$orden_id, $desc, $dias, $tarifa, $subtotal]);
        return (int)$pdo->lastInsertId();
    }
}
