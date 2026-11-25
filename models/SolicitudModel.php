<?php
// ============================================================
//  SolicitudModel — inicio del flujo Solicitud → (OT | COT) → Factura
// ============================================================
require_once __DIR__ . '/../config/db.php';

class SolicitudModel {

    private const SELECT = "
        SELECT s.*, c.nombre AS cliente,
               ot.numero_orden,
               COALESCE(s.cotizacion_id, ot.cotizacion_id) AS cot_id,
               cot.numero_cotizacion,
               (SELECT f.numero_factura FROM facturas f
                 WHERE f.estado <> 'anulada'
                   AND ( (s.orden_id IS NOT NULL AND f.orden_id = s.orden_id)
                      OR (COALESCE(s.cotizacion_id, ot.cotizacion_id) IS NOT NULL
                          AND f.cotizacion_id = COALESCE(s.cotizacion_id, ot.cotizacion_id)) )
                 ORDER BY f.id_factura DESC LIMIT 1) AS numero_factura
        FROM solicitudes s
        JOIN clientes c              ON c.id_cliente = s.cliente_id
        LEFT JOIN ordenes_trabajo ot ON ot.id_orden = s.orden_id
        LEFT JOIN cotizaciones cot   ON cot.id_cotizacion = COALESCE(s.cotizacion_id, ot.cotizacion_id)";

    public static function listar(string $estado = ''): array {
        $sql = self::SELECT . ($estado !== '' ? " WHERE s.estado = ?" : '') . " ORDER BY s.id_solicitud DESC";
        $st = getDB()->prepare($sql);
        $st->execute($estado !== '' ? [$estado] : []);
        return $st->fetchAll(PDO::FETCH_ASSOC);
    }

    public static function obtener(int $id): ?array {
        $st = getDB()->prepare(self::SELECT . " WHERE s.id_solicitud = ?");
        $st->execute([$id]);
        return $st->fetch(PDO::FETCH_ASSOC) ?: null;
    }

    private static function numero(): string {
        $year = date('Y');
        $st = getDB()->prepare("SELECT numero_solicitud FROM solicitudes WHERE numero_solicitud LIKE ?");
        $st->execute(["SOL-$year-%"]);
        $max = 0;
        foreach ($st->fetchAll(PDO::FETCH_COLUMN) as $n) { $max = max($max, (int)substr($n, -3)); }
        return sprintf('SOL-%s-%03d', $year, $max + 1);
    }

    /** Valida y normaliza los datos del formulario. */
    private static function normalizar(array $d): array {
        $clienteId = (int)($d['cliente_id'] ?? 0);
        $decision  = $d['decision'] ?? '';
        if (!$clienteId) throw new Exception('Selecciona un cliente.');
        if (!in_array($decision, ['ot', 'cotizacion'], true)) throw new Exception('Indica qué se solicita: O.T. o Cotización.');

        // Vehículo (solo si pertenece al cliente)
        $veh = ['id' => null, 'placa' => null, 'marca' => null, 'modelo' => null, 'anio' => null];
        $vid = (int)($d['vehiculo_id'] ?? 0);
        if ($vid) {
            $st = getDB()->prepare("SELECT id_vehiculo, placa, marca, modelo, anio FROM vehiculos WHERE id_vehiculo=? AND cliente_id=?");
            $st->execute([$vid, $clienteId]);
            if ($v = $st->fetch(PDO::FETCH_ASSOC)) $veh = ['id' => $v['id_vehiculo'], 'placa' => $v['placa'], 'marca' => $v['marca'], 'modelo' => $v['modelo'], 'anio' => $v['anio']];
        }

        $desc = ''; $items = null;
        if ($decision === 'ot') {
            $lineas = array_filter(array_map('trim', preg_split('/\R/', (string)($d['descripcion'] ?? ''))), 'strlen');
            if (!$lineas) throw new Exception('La descripción del trabajo es requerida.');
            $desc = implode("\n", $lineas);
        } else {
            $lim = [];
            foreach (($d['items'] ?? []) as $it) {
                $dsc = mb_substr(trim((string)($it['descripcion'] ?? '')), 0, 200);
                $cant = (float)($it['cantidad'] ?? 0); $pre = (float)($it['precio_unitario'] ?? -1);
                if ($dsc === '' || $cant <= 0 || $pre < 0) continue;
                $tipo = in_array(($it['tipo'] ?? ''), ['material', 'mano_obra', 'otro'], true) ? $it['tipo'] : 'material';
                $lim[] = ['descripcion' => $dsc, 'tipo' => $tipo, 'cantidad' => $cant, 'precio_unitario' => $pre, 'descuento_porcentaje' => 0, 'descuento_monto' => 0];
            }
            if (!$lim) throw new Exception('Agrega al menos un ítem a la cotización.');
            $items = json_encode($lim, JSON_UNESCAPED_UNICODE);
            $desc = mb_substr('Cotización: ' . implode('; ', array_column($lim, 'descripcion')), 0, 1000);
        }
        return [$clienteId, $decision, $desc, $items, $veh, ($d['prioridad'] ?? '') === 'urgente' ? 'urgente' : 'normal'];
    }

    public static function crear(array $d, int $uid, string $nombreUsuario): int {
        [$cli, $dec, $desc, $items, $v, $prio] = self::normalizar($d);
        $pdo = getDB();
        for ($i = 0; $i < 3; $i++) {
            try {
                $pdo->prepare("INSERT INTO solicitudes (numero_solicitud, fecha, cliente_id, solicitante, descripcion, placa, marca, modelo, anio, vehiculo_id, prioridad, decision, items_json, usuario_id)
                               VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)")
                    ->execute([self::numero(), date('Y-m-d'), $cli, $nombreUsuario, $desc, $v['placa'], $v['marca'], $v['modelo'], $v['anio'], $v['id'], $prio, $dec, $items, $uid]);
                return (int)$pdo->lastInsertId();
            } catch (PDOException $e) { if ($e->getCode() != 23000 || $i == 2) throw $e; }
        }
        return 0;
    }

    public static function editar(int $id, array $d): void {
        $s = self::obtener($id);
        if (!$s) throw new Exception('Solicitud no encontrada.');
        if ($s['estado'] !== 'pendiente') throw new Exception('Solo se puede editar una solicitud pendiente.');
        [$cli, $dec, $desc, $items, $v, $prio] = self::normalizar($d);
        getDB()->prepare("UPDATE solicitudes SET cliente_id=?, descripcion=?, placa=?, marca=?, modelo=?, anio=?, vehiculo_id=?, prioridad=?, decision=?, items_json=? WHERE id_solicitud=?")
            ->execute([$cli, $desc, $v['placa'], $v['marca'], $v['modelo'], $v['anio'], $v['id'], $prio, $dec, $items, $id]);
    }

    public static function anular(int $id): void {
        $s = self::obtener($id);
        if (!$s) throw new Exception('Solicitud no encontrada.');
        if ($s['estado'] !== 'pendiente') throw new Exception('Solo se puede anular una solicitud pendiente (aún sin OT ni cotización).');
        getDB()->prepare("UPDATE solicitudes SET estado='anulada' WHERE id_solicitud=?")->execute([$id]);
    }

    /** La solicitud (tipo O.T.) ya se guardó como Orden de Trabajo desde su pantalla. */
    public static function vincularOrden(int $id, int $ordenId): void {
        $s = self::obtener($id);
        if (!$s) throw new Exception('Solicitud no encontrada.');
        if ($s['estado'] !== 'pendiente') throw new Exception('Esta solicitud ya fue procesada.');
        $ok = getDB()->prepare("SELECT 1 FROM ordenes_trabajo WHERE id_orden=? AND cliente_id=?");
        $ok->execute([$ordenId, $s['cliente_id']]);
        if (!$ok->fetchColumn()) throw new Exception('La O.T. no existe o es de otro cliente.');
        getDB()->prepare("UPDATE solicitudes SET decision='ot', estado='en_ot', orden_id=? WHERE id_solicitud=?")->execute([$ordenId, $id]);
    }

    /** La solicitud (tipo Cotización) ya se guardó como cotización desde su pantalla. */
    public static function vincularCotizacion(int $id, int $cotId): void {
        $s = self::obtener($id);
        if (!$s) throw new Exception('Solicitud no encontrada.');
        if ($s['estado'] !== 'pendiente') throw new Exception('Esta solicitud ya fue procesada.');
        $ok = getDB()->prepare("SELECT 1 FROM cotizaciones WHERE id_cotizacion=? AND cliente_id=?");
        $ok->execute([$cotId, $s['cliente_id']]);
        if (!$ok->fetchColumn()) throw new Exception('La cotización no existe o es de otro cliente.');
        getDB()->prepare("UPDATE solicitudes SET decision='cotizacion', estado='en_cotizacion', cotizacion_id=? WHERE id_solicitud=?")->execute([$cotId, $id]);
    }
}
