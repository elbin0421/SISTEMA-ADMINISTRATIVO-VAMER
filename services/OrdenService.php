<?php
// ============================================================
//  SOLDYMEG — OrdenService
//  Orquesta transiciones de estado de Órdenes de Trabajo.
//  Reglas de negocio centralizadas aquí, no en controladores.
// ============================================================
require_once __DIR__ . '/../models/OrdenModel.php';

class OrdenService {

    // Transiciones válidas de estado
    private static array $transiciones = [
        'borrador'   => ['en_proceso', 'anulada'],
        'en_proceso' => ['finalizada', 'anulada'],
        'finalizada' => ['cotizado', 'facturada'],
        'cotizado'   => ['facturada'],
        'facturada'  => [],
        'anulada'    => [],
    ];

    /**
     * Cambia el estado de una OT validando la transición.
     *
     * @throws Exception si la transición no es válida
     */
    public static function cambiarEstado(int $orden_id, string $nuevo_estado): array {
        $ot = OrdenModel::obtener($orden_id);
        if (!$ot) throw new Exception('Orden no encontrada.');

        $estado_actual = $ot['estado'];
        $permitidos    = self::$transiciones[$estado_actual] ?? [];

        if (!in_array($nuevo_estado, $permitidos)) {
            throw new Exception(
                "No se puede cambiar de '$estado_actual' a '$nuevo_estado'. " .
                "Estados permitidos: " . implode(', ', $permitidos ?: ['ninguno'])
            );
        }

        // Validaciones adicionales por estado
        if ($nuevo_estado === 'finalizada') {
            if (empty($ot['mano_obra']) && empty($ot['materiales'])) {
                throw new Exception('No se puede finalizar una OT sin materiales ni mano de obra.');
            }
        }

        OrdenModel::cambiarEstado($orden_id, $nuevo_estado);

        return [
            'ok'             => true,
            'estado_anterior' => $estado_actual,
            'estado_nuevo'    => $nuevo_estado,
        ];
    }

    /**
     * Verifica si una OT puede generar cotización.
     */
    public static function puedeGenerarCotizacion(int $orden_id): bool {
        $ot = OrdenModel::obtener($orden_id);
        return $ot && $ot['estado'] === 'finalizada';
    }
}
