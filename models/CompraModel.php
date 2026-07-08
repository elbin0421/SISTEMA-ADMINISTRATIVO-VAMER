<?php
// ============================================================
//  SOLDYMEG — CompraModel
// ============================================================
require_once __DIR__ . '/../config/db.php';

class CompraModel {

    public static function listar(): array {
        $stmt = getDB()->query("
            SELECT c.id_compra, c.numero_documento, c.fecha, c.total,
                   c.estado, c.subtotal, c.impuesto,
                   p.nombre AS proveedor, u.nombre AS usuario
            FROM compras c
            JOIN proveedores p ON p.id_proveedor = c.proveedor_id
            JOIN usuarios    u ON u.id_usuario   = c.usuario_id
            ORDER BY c.fecha DESC, c.id_compra DESC
            LIMIT 200
        ");
        return $stmt->fetchAll();
    }

    public static function obtener(int $id): ?array {
        $pdo  = getDB();
        $stmt = $pdo->prepare("
            SELECT c.*, p.nombre AS proveedor
            FROM compras c JOIN proveedores p ON p.id_proveedor = c.proveedor_id
            WHERE c.id_compra = ?
        ");
        $stmt->execute([$id]);
        $c = $stmt->fetch();
        if (!$c) return null;
        $det = $pdo->prepare("
            SELECT d.*, m.nombre AS material, m.unidad_medida
            FROM detalle_compras d JOIN materiales m ON m.id_material = d.material_id
            WHERE d.compra_id = ?
        ");
        $det->execute([$id]);
        $c['detalle'] = $det->fetchAll();
        return $c;
    }

    public static function crear(array $d, int $usuario_id): int {
        $pdo   = getDB();
        $items = $d['items'] ?? [];
        if (empty($items)) throw new Exception('La compra debe tener al menos un ítem.');
        $subtotal = array_sum(array_map(fn($it) => $it['cantidad'] * $it['precio_unitario'], $items));
        $impuesto = (float)($d['impuesto'] ?? round($subtotal * 0.15, 2));
        $total    = $subtotal + $impuesto;
        $pdo->beginTransaction();
        try {
            $pdo->prepare("
                INSERT INTO compras
                  (numero_documento, proveedor_id, fecha, subtotal, impuesto, total, usuario_id, observaciones)
                VALUES (?,?,?,?,?,?,?,?)
            ")->execute([
                $d['numero_documento'] ?? null,
                (int)$d['proveedor_id'],
                $d['fecha'] ?? date('Y-m-d'),
                $subtotal, $impuesto, $total,
                $usuario_id,
                $d['observaciones'] ?? null,
            ]);
            $compra_id = (int)$pdo->lastInsertId();
            foreach ($items as $it) {
                $sub = (float)$it['cantidad'] * (float)$it['precio_unitario'];
                $pdo->prepare("
                    INSERT INTO detalle_compras (compra_id, material_id, cantidad, precio_unitario, subtotal)
                    VALUES (?,?,?,?,?)
                ")->execute([
                    $compra_id, (int)$it['material_id'],
                    (float)$it['cantidad'], (float)$it['precio_unitario'], $sub,
                ]);
                // Actualizar precio_compra y promediar precio_venta (precio_venta = nuevo_costo × 1.35)
                $nuevo_costo  = (float)$it['precio_unitario'];
                $nuevo_precio = round($nuevo_costo * 1.35, 2);
                // Promedio: (precio_venta_actual + nuevo_precio) / 2
                $pdo->prepare("
                    UPDATE materiales
                    SET precio_compra = ?,
                        precio_venta  = ROUND((precio_venta + ?) / 2, 2)
                    WHERE id_material = ?
                ")->execute([$nuevo_costo, $nuevo_precio, (int)$it['material_id']]);
            }
            $pdo->commit();
            return $compra_id;
        } catch (Exception $e) {
            $pdo->rollBack();
            throw $e;
        }
    }


    public static function actualizar(int $id, array $d): void {
        $pdo   = getDB();
        $items = $d['items'] ?? [];
        if (empty($items)) throw new \Exception('La compra debe tener al menos un ítem.');

        $subtotal = array_sum(array_map(fn($it)=>(float)$it['cantidad']*(float)$it['precio_unitario'], $items));
        $impuesto = (float)($d['impuesto'] ?? round($subtotal * 0.15, 2));
        $total    = $subtotal + $impuesto;

        $pdo->beginTransaction();
        try {
            // ── 1. Leer ítems actuales para revertir stock ─────────
            // El trigger trg_compra_entrada_inventario NO existe para DELETE,
            // así que revertimos manualmente stock y movimientos_inventario.
            $oldStmt = $pdo->prepare("SELECT material_id, cantidad FROM detalle_compras WHERE compra_id = ?");
            $oldStmt->execute([$id]);
            foreach ($oldStmt->fetchAll() as $row) {
                // Revertir stock
                $pdo->prepare("UPDATE materiales SET stock = stock - ? WHERE id_material = ?")
                    ->execute([(float)$row['cantidad'], (int)$row['material_id']]);
            }

            // ── 2. Eliminar movimientos_inventario de esta compra ──
            // (el trigger los crea en INSERT; al re-insertar se crean nuevos)
            $pdo->prepare("DELETE FROM movimientos_inventario WHERE tipo_referencia = 'compra' AND referencia_id = ?")
                ->execute([$id]);

            // ── 3. Eliminar ítems viejos de detalle_compras ────────
            $pdo->prepare("DELETE FROM detalle_compras WHERE compra_id = ?")->execute([$id]);

            // ── 4. Actualizar cabecera ─────────────────────────────
            $pdo->prepare(
                "UPDATE compras SET numero_documento=?, proveedor_id=?, fecha=?,
                 subtotal=?, impuesto=?, total=?, observaciones=?
                 WHERE id_compra=? AND estado='pendiente'"
            )->execute([
                $d['numero_documento'] ?? null,
                (int)$d['proveedor_id'],
                $d['fecha'] ?? date('Y-m-d'),
                $subtotal, $impuesto, $total,
                $d['observaciones'] ?? null,
                $id,
            ]);

            // ── 5. Insertar nuevos ítems ───────────────────────────
            // El trigger suma stock Y crea movimiento automáticamente
            foreach ($items as $it) {
                $sub = (float)$it['cantidad'] * (float)$it['precio_unitario'];
                $pdo->prepare(
                    "INSERT INTO detalle_compras(compra_id, material_id, cantidad, precio_unitario, subtotal)
                     VALUES (?,?,?,?,?)"
                )->execute([$id, (int)$it['material_id'], (float)$it['cantidad'], (float)$it['precio_unitario'], $sub]);

                // Actualizar precio de compra/venta en materiales
                $costo = (float)$it['precio_unitario'];
                $pdo->prepare(
                    "UPDATE materiales SET precio_compra=?, precio_venta=ROUND((precio_venta+?)/2,2) WHERE id_material=?"
                )->execute([$costo, round($costo * 1.35, 2), (int)$it['material_id']]);
            }

            $pdo->commit();
        } catch (\Exception $e) {
            $pdo->rollBack();
            throw $e;
        }
    }

    public static function cambiarEstado(int $id, string $estado, ?string $metodo = null, ?string $referencia = null): bool {
        if ($estado === 'pagada' && $metodo) {
            return getDB()->prepare(
                "UPDATE compras SET estado=?, metodo_pago=?, referencia_pago=? WHERE id_compra=?"
            )->execute([$estado, $metodo, $referencia ?: null, $id]);
        }
        return getDB()->prepare(
            "UPDATE compras SET estado=? WHERE id_compra=?"
        )->execute([$estado, $id]);
    }
}
