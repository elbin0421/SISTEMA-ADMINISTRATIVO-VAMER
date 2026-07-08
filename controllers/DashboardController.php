<?php
require_once __DIR__ . '/../config/db.php';
require_once __DIR__ . '/../config/auth.php';
header('Content-Type: application/json');
$sesion = requireAuth();
$action = $_GET['action'] ?? 'kpis';
match($action) {
    'kpis'           => kpisDashboard(),
    'grafico_ventas' => graficoVentas(),
    default          => responder(400, ['error' => 'Acción no válida'])
};

function kpisDashboard(): void {
    $pdo = getDB(); $hoy = date('Y-m-d');

    // Ventas del día
    $s = $pdo->prepare("SELECT COALESCE(SUM(total),0) AS monto, COUNT(*) AS cant FROM facturas WHERE fecha=? AND estado!='anulada'");
    $s->execute([$hoy]); $ventasDia = $s->fetch();

    // Cuentas por cobrar
    $s = $pdo->query("SELECT COUNT(*) AS cant, COALESCE(SUM(f.total-COALESCE(pg.pagado,0)),0) AS monto
        FROM facturas f
        LEFT JOIN (SELECT factura_id, SUM(monto) AS pagado FROM pagos_clientes WHERE estado='aplicado' GROUP BY factura_id) pg ON pg.factura_id=f.id_factura
        WHERE f.estado IN ('emitida','pendiente') AND (f.total-COALESCE(pg.pagado,0))>0.01");
    $cxc = $s->fetch();

    // Cotizaciones pendientes de factura (aprobadas o aprobadas por cliente, sin factura emitida válida)
    $s = $pdo->query("SELECT COUNT(*) AS cant, COALESCE(SUM(c.total),0) AS monto
        FROM cotizaciones c
        WHERE c.estado IN ('aprobada','aprobada_cliente')
          AND NOT EXISTS (
              SELECT 1 FROM facturas f
              WHERE f.cotizacion_id = c.id_cotizacion AND f.estado != 'anulada'
          )");
    $ocPend = $s->fetch();

    // OT en proceso
    $s = $pdo->query("SELECT COUNT(*) FROM ordenes_trabajo WHERE estado='en_proceso'");
    $otProceso = (int)$s->fetchColumn();

    // Stock bajo mínimo
    $s = $pdo->query("SELECT COUNT(*) FROM materiales WHERE estado='activo' AND stock_minimo>0 AND stock<=stock_minimo");
    $stockBajo = (int)$s->fetchColumn();

    // Últimas 5 cotizaciones
    $s = $pdo->query("SELECT c.numero_cotizacion,c.fecha,c.total,c.estado,cl.nombre AS cliente
        FROM cotizaciones c JOIN clientes cl ON cl.id_cliente=c.cliente_id
        ORDER BY c.fecha DESC, c.id_cotizacion DESC LIMIT 5");
    $cotizaciones = $s->fetchAll();

    // OT recientes (6)
    $s = $pdo->query("SELECT ot.numero_orden,ot.fecha_apertura,ot.estado,cl.nombre AS cliente,ot.marca,ot.modelo,ot.placa
        FROM ordenes_trabajo ot JOIN clientes cl ON cl.id_cliente=ot.cliente_id
        WHERE ot.estado!='anulada' ORDER BY ot.fecha_apertura DESC, ot.id_orden DESC LIMIT 6");
    $otRecientes = $s->fetchAll();

    responder(200, ['ok'=>true,'data'=>[
        'ventas_dia'=>$ventasDia, 'cxc'=>$cxc, 'oc_pend'=>$ocPend,
        'ot_proceso'=>$otProceso, 'stock_bajo'=>$stockBajo,
        'cotizaciones'=>$cotizaciones, 'ot_recientes'=>$otRecientes,
    ]]);
}

function graficoVentas(): void {
    $s = getDB()->query("SELECT DATE_FORMAT(fecha,'%Y-%m') AS mes, DATE_FORMAT(fecha,'%b %Y') AS label,
        COALESCE(SUM(total),0) AS total, COUNT(*) AS cantidad
        FROM facturas WHERE estado!='anulada' AND fecha>=DATE_SUB(CURDATE(),INTERVAL 6 MONTH)
        GROUP BY DATE_FORMAT(fecha,'%Y-%m') ORDER BY mes ASC");
    responder(200, ['ok'=>true,'data'=>$s->fetchAll()]);
}

function responder(int $code, array $data): void {
    http_response_code($code); echo json_encode($data); exit;
}
