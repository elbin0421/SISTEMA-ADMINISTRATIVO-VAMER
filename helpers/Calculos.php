<?php
// ============================================================
//  SOLDYMEG — Motor de Cálculo Centralizado
//  Fórmula oficial:
//    1. Costo base     = materiales + mano de obra (costo real)
//    2. + 35% margen SOLDYMEG  → subtotal_soldymeg
//    3. + 15% margen comercial → subtotal_comercial
//    4. + 15% ISV              → total_con_isv
//
//  NUNCA calcular precios en JS. Siempre usar este helper.
// ============================================================

class Calculos {

    // ── Constantes de márgenes ────────────────────────────────
    const MARGEN_SOLDYMEG  = 0.35;   // 35%
    const MARGEN_COMERCIAL = 0.15;   // 15%
    const ISV              = 0.15;   // 15%

    /**
     * Calcula el precio de venta de un material desde su costo de compra.
     * Aplica solo margen SOLDYMEG (35%).
     * Usado al crear/editar materiales en inventario.
     *
     * @param  float $costo_compra
     * @return array ['precio_venta' => float]
     */
    public static function precioVentaMaterial(float $costo_compra): array {
        $precio_venta = round($costo_compra * (1 + self::MARGEN_SOLDYMEG), 2);
        return [
            'costo_compra' => $costo_compra,
            'precio_venta' => $precio_venta,
            'margen_pesos' => round($precio_venta - $costo_compra, 2),
        ];
    }

    /**
     * Calcula el desglose completo de una cotización/factura.
     * Los valores de materiales y mano de obra se reciben YA con margen aplicado
     * (los materiales usan precio_venta y la MO ya lleva ×1.35 desde la OT).
     * Esta función solo suma los conceptos y aplica ISV 15%.
     *
     * @param  float $total_materiales  Subtotal materiales (precio venta, con margen)
     * @param  float $total_mano_obra   Subtotal MO (con margen 35% aplicado en OT)
     * @param  bool  $aplicar_isv
     * @return array Desglose completo
     */
    public static function calcularCotizacion(
        float $total_materiales,
        float $total_mano_obra,
        bool  $aplicar_isv = true
    ): array {
        $subtotal_comercial = round($total_materiales + $total_mano_obra, 2);

        // ISV 15%
        $isv   = $aplicar_isv ? round($subtotal_comercial * self::ISV, 2) : 0.00;
        $total = round($subtotal_comercial + $isv, 2);

        return [
            'subtotal_materiales'   => round($total_materiales, 2),
            'subtotal_mano_obra'    => round($total_mano_obra, 2),
            'costo_base'            => round($subtotal_comercial, 2),
            'margen_soldymeg_pct'   => 0,  // ya aplicado en OT/inventario
            'subtotal_con_soldymeg' => $subtotal_comercial,
            'subtotal_comercial'    => $subtotal_comercial,
            'isv_pct'               => self::ISV * 100,
            'isv'                   => $isv,
            'total'                 => $total,
        ];
    }

    /**
     * Calcula el subtotal de un ítem de mano de obra con margen SOLDYMEG 35%.
     * Fórmula: dias × tarifa_dia × 1.35
     *
     * @param  float $dias
     * @param  float $tarifa_dia  Tarifa diaria base (salario / 30)
     * @return array
     */
    public static function calcularManoObra(float $dias, float $tarifa_dia): array {
        $costo_base = $dias * $tarifa_dia;
        $subtotal   = round($costo_base * (1 + self::MARGEN_SOLDYMEG), 2);
        return [
            'dias'          => $dias,
            'tarifa_dia'    => $tarifa_dia,
            'costo_base'    => round($costo_base, 2),
            'subtotal'      => $subtotal,
            'margen_pesos'  => round($subtotal - $costo_base, 2),
        ];
    }

    /**
     * Calcula ISV sobre un subtotal dado.
     *
     * @param  float $subtotal
     * @return array ['isv' => float, 'total' => float]
     */
    public static function aplicarISV(float $subtotal): array {
        $isv   = round($subtotal * self::ISV, 2);
        $total = round($subtotal + $isv, 2);
        return [
            'subtotal' => $subtotal,
            'isv'      => $isv,
            'total'    => $total,
        ];
    }

    /**
     * Formatea un valor como moneda hondureña.
     *
     * @param  float  $valor
     * @param  bool   $con_simbolo
     * @return string
     */
    public static function formatear(float $valor, bool $con_simbolo = true): string {
        $num = number_format($valor, 2, '.', ',');
        return $con_simbolo ? 'L. ' . $num : $num;
    }
}
