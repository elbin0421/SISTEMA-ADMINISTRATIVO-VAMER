<?php
// ============================================================
//  Convierte un número a letras (Lempiras) para facturas
//  Ej: 1234.56 -> "UN MIL DOSCIENTOS TREINTA Y CUATRO LEMPIRAS
//                  CON 56/100"
// ============================================================
if (!function_exists('numeroALetras')) {
function numeroALetras(float $numero): string {
    $entero   = (int)floor($numero);
    $decimal  = (int)round(($numero - $entero) * 100);

    $unidades = ['', 'UN', 'DOS', 'TRES', 'CUATRO', 'CINCO', 'SEIS', 'SIETE', 'OCHO', 'NUEVE'];
    $especiales = [
        10=>'DIEZ',11=>'ONCE',12=>'DOCE',13=>'TRECE',14=>'CATORCE',15=>'QUINCE',
        16=>'DIECISEIS',17=>'DIECISIETE',18=>'DIECIOCHO',19=>'DIECINUEVE',
        20=>'VEINTE',21=>'VEINTIUNO',22=>'VEINTIDOS',23=>'VEINTITRES',
        24=>'VEINTICUATRO',25=>'VEINTICINCO',26=>'VEINTISEIS',27=>'VEINTISIETE',
        28=>'VEINTIOCHO',29=>'VEINTINUEVE',
    ];
    $decenas = ['',10=>'DIEZ',20=>'VEINTE',30=>'TREINTA',40=>'CUARENTA',50=>'CINCUENTA',
        60=>'SESENTA',70=>'SETENTA',80=>'OCHENTA',90=>'NOVENTA'];
    $centenas = ['',100=>'CIENTO',200=>'DOSCIENTOS',300=>'TRESCIENTOS',400=>'CUATROCIENTOS',
        500=>'QUINIENTOS',600=>'SEISCIENTOS',700=>'SETECIENTOS',800=>'OCHOCIENTOS',900=>'NOVECIENTOS'];

    $convertirGrupo = function (int $n) use ($unidades, $especiales, $decenas, $centenas): string {
        if ($n == 0) return '';
        if ($n == 100) return 'CIEN';
        $resultado = '';
        if ($n >= 100) {
            $c = intdiv($n, 100) * 100;
            $resultado .= $centenas[$c] . ' ';
            $n %= 100;
        }
        if ($n >= 10 && $n <= 29 && $n != 0) {
            $resultado .= ($especiales[$n] ?? '') . ' ';
            return trim($resultado);
        }
        if ($n >= 30) {
            $d = intdiv($n, 10) * 10;
            $resultado .= $decenas[$d];
            $u = $n % 10;
            if ($u > 0) $resultado .= ' Y ' . $unidades[$u];
            $resultado .= ' ';
            return trim($resultado);
        }
        if ($n > 0) $resultado .= $unidades[$n] . ' ';
        return trim($resultado);
    };

    if ($entero == 0) {
        $textoEntero = 'CERO';
    } else {
        $textoEntero = '';
        $millones = intdiv($entero, 1000000);
        $resto    = $entero % 1000000;
        $miles    = intdiv($resto, 1000);
        $cientos  = $resto % 1000;

        if ($millones > 0) {
            $textoEntero .= ($millones == 1 ? 'UN MILLON ' : $convertirGrupo($millones) . ' MILLONES ');
        }
        if ($miles > 0) {
            $textoEntero .= ($miles == 1 ? 'MIL ' : $convertirGrupo($miles) . ' MIL ');
        }
        if ($cientos > 0) {
            $textoEntero .= $convertirGrupo($cientos) . ' ';
        }
        $textoEntero = trim($textoEntero);
    }

    return $textoEntero . ' LEMPIRAS CON ' . str_pad((string)$decimal, 2, '0', STR_PAD_LEFT) . '/100';
}
}
