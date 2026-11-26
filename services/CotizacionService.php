<?php
// ============================================================
//  SOLDYMEG — CotizacionService
//  Orquesta el flujo completo de cotizaciones.
// ============================================================
require_once __DIR__ . '/../models/CotizacionModel.php';
require_once __DIR__ . '/../helpers/Calculos.php';

class CotizacionService {

    /**
     * Genera cotización desde OT finalizada (POST_TRABAJO).
     * Valida estado, calcula márgenes y crea la cotización.
     */
    public static function generarDesdeOT(int $orden_id, int $usuario_id, int $vigencia = 15): array {
        $cot_id = CotizacionModel::crearDesdeOT($orden_id, $usuario_id, $vigencia);
        $cot    = CotizacionModel::obtener($cot_id);
        return ['ok' => true, 'cotizacion' => $cot];
    }

    /**
     * Genera cotización directa sin OT.
     */
    public static function generarDirecta(array $datos, int $usuario_id): array {
        $cot_id = CotizacionModel::crearDirecta($datos, $usuario_id);
        $cot    = CotizacionModel::obtener($cot_id);
        return ['ok' => true, 'cotizacion' => $cot];
    }

    /**
     * Cambia el estado de una cotización.
     * Estados válidos: pendiente → enviada → aprobada|rechazada
     */
    public static function cambiarEstado(int $cotizacion_id, string $nuevo_estado, ?string $motivo_rechazo = null, ?array $sesion = null): array {
        $estados_validos = ['pendiente', 'pendiente_aprobacion', 'aprobada', 'aprobada_cliente', 'rechazada', 'enviada'];
        if (!in_array($nuevo_estado, $estados_validos)) {
            throw new Exception("Estado inválido: $nuevo_estado");
        }
        if ($nuevo_estado === 'rechazada' && empty(trim($motivo_rechazo ?? ''))) {
            throw new Exception("El motivo de rechazo es requerido.");
        }
        $cot = CotizacionModel::obtener($cotizacion_id);
        if (!$cot) throw new Exception('Cotización no encontrada.');
        // Un borrador solo sale hacia "solicitar aprobación"
        if ($cot['estado'] === 'borrador' && $nuevo_estado !== 'pendiente_aprobacion') {
            throw new Exception('La cotización está en borrador: edítala y envíala a aprobación.');
        }
        if (in_array($cot['estado'], ['facturada'], true)) throw new Exception('La cotización ya fue facturada.');

        CotizacionModel::cambiarEstado($cotizacion_id, $nuevo_estado, $motivo_rechazo);
        $res = ['ok' => true, 'estado' => $nuevo_estado];

        // Cliente aprobó una cotización directa → se activa la O.T.
        if ($nuevo_estado === 'aprobada_cliente' && $cot['estado'] !== 'aprobada_cliente') {
            $ot = CotizacionModel::activarOT($cotizacion_id, (int)($sesion['usuario_id'] ?? $cot['usuario_id']));
            if ($ot) $res['orden'] = $ot;
        }
        return $res;
    }

    /**
     * Devuelve el desglose de cálculo para mostrar en vista previa.
     */
    public static function previsualizarCalculo(float $total_materiales, float $total_mano_obra): array {
        return Calculos::calcularCotizacion($total_materiales, $total_mano_obra);
    }
}
