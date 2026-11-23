<?php
// URL base (hasta la carpeta del sistema, sin barra final) que se graba dentro del QR del carnet.
// El celular NO puede resolver nombres de PC como "SOLDYMEG-1": usa la IP del servidor
// (ej. 'http://192.168.1.50/admin') o un dominio público ('https://sistema.midominio.com/admin').
// Vacío = se toma automáticamente de la dirección con que entras al sistema.
return [
    'base_url' => 'http://SOLDYMEG-1/admin',
];
