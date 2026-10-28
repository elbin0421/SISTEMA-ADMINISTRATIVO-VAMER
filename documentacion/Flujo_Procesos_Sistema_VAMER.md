# Flujo de procesos del sistema administrativo VAMER

## Propósito y alcance

Este documento describe los procesos visibles en el sistema implementado: acceso, navegación, áreas administrativas, operación, comercial, recursos humanos y análisis. Los diagramas reflejan el comportamiento encontrado en el código y en la estructura de datos; no sustituyen políticas internas ni representan aprobaciones externas que no estén registradas en la aplicación.

## 1. Flujo general de uso

```mermaid
flowchart TD
    A[Usuario abre el sistema] --> B{¿Tiene sesión vigente?}
    B -- No --> C[Iniciar sesión]
    C --> D{Credenciales válidas y usuario activo}
    D -- No --> C1[Mostrar error y permitir reintento]
    D -- Sí --> E[Crear sesión de hasta 8 horas]
    B -- Sí --> F[Validar sesión]
    E --> F
    F --> G{Sesión y usuario válidos}
    G -- No --> H[Redirigir al inicio de sesión]
    G -- Sí --> I[Cargar panel y permisos del rol]
    I --> J[Seleccionar módulo]
    J --> K{¿El rol puede ver el módulo?}
    K -- No --> L[Denegar operación]
    K -- Sí --> M[Interfaz solicita datos al controlador]
    M --> N[Controlador valida sesión, permiso y datos]
    N --> O[Servicio o modelo procesa reglas y consulta MySQL]
    O --> P[Responder a la interfaz y actualizar vista]
    P --> J
    I --> Q[Cerrar sesión]
    Q --> R[Invalidar sesión y volver al inicio de sesión]
```

El acceso al panel usa una cookie de sesión y el navegador conserva datos de presentación del usuario. Las peticiones de los módulos consultan controladores PHP, que devuelven respuestas JSON; las operaciones de negocio se apoyan en modelos, servicios y la base de datos MySQL.

## 2. Mapa general de áreas y procesos

```mermaid
flowchart LR
    subgraph ADMIN[Administración]
        U[Usuarios]
        RP[Roles y permisos]
        U --- RP
    end

    subgraph OPS[Operaciones]
        C[Clientes]
        V[Vehículos]
        P[Proveedores]
        I[Inventario y materiales]
        RQ[Requisiciones]
        CO[Compras]
        OT[Órdenes de trabajo]
        C --> OT
        V -. Selección de datos del vehículo .-> OT
        I --> RQ
        RQ -->|Despacho: salida de inventario| I
        P --> CO
        CO -->|Recepción: entrada de inventario| I
        I -. Materiales asociados en la OT; sin movimiento de stock .-> OT
    end

    subgraph COM[Comercial y finanzas]
        CAT[Catálogo de precios]
        Q[Cotizaciones]
        MOV[Movimientos de transporte]
        CAI[CAI]
        F[Facturación]
        PG[Pagos]
        LV[Libro de ventas]
        GAS[Gastos DMC / SAR]
        OT --> Q
        Q --> F
        MOV --> F
        CAI --> F
        F --> PG
        F --> LV
    end

    subgraph RRHH[Recursos humanos]
        E[Empleados y departamentos]
        AS[Asistencia y tiempo extra/faltas]
        VAC[Vacaciones]
        PL[Planillas]
        REC[Recibos]
        E --> AS
        E --> VAC
        E --> PL
        AS -->|Datos de horas extra y faltas| PL
        PL --> REC
    end

    REP[Reportes] -. consulta información .-> OPS
    REP -. consulta información .-> COM
    REP -. consulta información .-> RRHH
    INI[Inicio / indicadores] -. consulta información .-> OPS
    INI -. consulta información .-> COM
```

El mapa indica relaciones funcionales encontradas, no que cada flecha represente una transferencia automática. Las requisiciones y las compras son procesos separados: despachar una requisición descuenta existencias; registrar una compra agrega materiales al inventario mediante el mecanismo de base de datos usado por el sistema. Los materiales registrados en una orden de trabajo son una lista de referencia y no descuentan existencias.

## 3. Procesos principales

### 3.1 Operación y abastecimiento

```mermaid
flowchart TD
    A[Registrar o mantener materiales y existencias] --> B{¿Se requiere material?}
    B -- Compra --> C[Seleccionar proveedor y registrar compra]
    C --> D[Registrar detalle, costo e impuesto]
    D --> E[Actualizar existencias y movimientos de inventario]
    B -- Solicitud interna --> F[Crear requisición con empleado, departamento y detalle]
    F --> G[Requisición pendiente]
    G --> H{Decisión de gestión}
    H -- Aprobar --> I[Requisición aprobada]
    H -- Anular --> X[Requisición anulada]
    I --> J{¿Hay stock suficiente?}
    J -- No --> K[No despachar; revisar inventario o abastecimiento]
    K --> C
    J -- Sí --> L[Despachar requisición]
    L --> M[Descontar existencias y registrar salida]
    M --> N[Entregar material solicitado]
```

- La requisición puede asociarse con empleado, departamento, cliente y número de orden de trabajo. El despacho exige stock suficiente para los materiales vinculados al inventario y deja movimientos de salida.
- Las compras registran proveedor, documento, fecha, detalle, impuesto y total. Los detalles de compra alimentan el inventario y actualizan información de costo/precio del material.
- El sistema permite gestionar clientes, vehículos, proveedores, materiales, categorías, inventario y movimientos de inventario como registros relacionados.
- El flujo muestra aprobación antes del despacho como recorrido operativo recomendado. En el controlador, los estados admitidos son `pendiente`, `aprobada`, `despachada` y `anulada`; la validación de stock se ejecuta específicamente al cambiar a `despachada`.

### 3.2 Orden de trabajo, cotización, factura y cobro

```mermaid
flowchart TD
    A[Seleccionar cliente y registrar orden de trabajo] --> B[Asociar vehículo, técnicos, materiales, mano de obra y fotos]
    B --> C[borrador]
    C --> D[en_proceso]
    D --> E{¿Trabajo listo?}
    E -- No --> D
    E -- Sí, con materiales o mano de obra --> F[finalizada]
    E -- Cancelar --> X[anulada]
    F --> G{Cómo se va a cobrar}
    G -- Cotizar el trabajo --> H[Crear cotización desde la OT]
    G -- Facturar sin cotización --> J[Emitir factura directa o desde la OT]
    H --> I[Enviar y gestionar aprobación o rechazo]
    I -->|Aprobada por cliente| J
    I -->|Rechazada con motivo| K[Conservar cotización rechazada]
    J --> L[Validar CAI y emitir factura]
    L --> M[Factura emitida con saldo pendiente]
    M --> N[Registrar pago parcial o total]
    N --> O{¿Saldo pendiente = 0?}
    O -- No --> M
    O -- Sí --> P[Factura pagada]
    L --> Q[Libro de ventas]
```

Estados de orden de trabajo implementados en el servicio:

| Estado actual | Siguiente estado permitido |
|---|---|
| `borrador` | `en_proceso`, `anulada` |
| `en_proceso` | `finalizada`, `anulada` |
| `finalizada` | `cotizado`, `facturada` |
| `cotizado` | `facturada` |
| `facturada` | Sin transición |
| `anulada` | Sin transición |

Una OT no se puede finalizar si no contiene materiales ni mano de obra. Las cotizaciones pueden crearse desde una OT finalizada o directamente; también existe cotización agrupada en una sola factura si todas las cotizaciones están aprobadas para el cliente y corresponden al mismo cliente. El sistema permite registrar pago parcial o total, calcula el saldo y no permite cobrar por encima del saldo pendiente. También contempla anulación de factura con motivo y administración de CAI.

### 3.3 Movimientos de transporte

1. Registrar el movimiento con tipo, fecha/hora, cliente, destino y datos disponibles del transporte (contenedor, chasis, motorista, placa, tarifa, entre otros).
2. El movimiento se crea como `pendiente`.
3. Consultar los pendientes del cliente y seleccionar movimientos para facturación.
4. Al facturar, asociarlos a una factura y marcarlos como `facturado`.
5. Los movimientos anulados o ya facturados no se pueden editar o anular por el flujo normal del módulo.

### 3.4 Recursos humanos

```mermaid
flowchart TD
    A[Administrar empleados y departamentos] --> B[Registrar asistencia, horas extra y días faltados]
    A --> C[Administrar solicitudes y registros de vacaciones]
    A --> R[Registrar recibos: viáticos, adelantos, abonos u otros]
    B --> D[Preparar planilla quincenal]
    D --> E[Previsualizar cálculo por empleado]
    E --> F[Seleccionar registros de asistencia y recibos que se aplicarán]
    B --> F
    R --> F
    F --> G[Guardar planilla]
```

La planilla considera salario quincenal, horas extra, faltas, seguro privado según ubicación y otros conceptos registrados. Los registros de asistencia y recibos se seleccionan y se vinculan a la planilla; no se presupone su aplicación automática sin revisión. El módulo también permite generar planillas especiales de catorceavo y aguinaldo. Vacaciones se administran en su módulo.

### 3.5 Administración, gastos y análisis

- **Usuarios, roles y permisos:** mantener cuentas, asignar roles y configurar permisos por módulo/acción. El menú filtra módulos según permiso de visualización; las operaciones protegidas también validan permisos en el servidor.
- **Gastos DMC / SAR:** registrar y consultar gastos y sus detalles. Es un proceso financiero independiente de facturas y planillas.
- **Inicio y reportes:** Inicio presenta indicadores de ventas, cuentas por cobrar, cotizaciones por facturar, órdenes en proceso y stock bajo. Reportes ofrece consultas de ventas, cuentas por cobrar, retenciones, inventario, rentabilidad de OT y salidas de planilla.
- **Catálogo de precios:** mantener precios de referencia para las operaciones comerciales.
- **Libro de ventas:** consultar las ventas por período a partir de la información de facturación.

## 4. Módulos cubiertos

El menú actual agrupa los módulos de esta manera:

| Área | Módulos |
|---|---|
| Inicio | Inicio |
| Administración | Usuarios; Roles y permisos |
| Operaciones | Clientes; Vehículos; Inventario; Requisiciones de materiales; Compras; Proveedores; Órdenes de trabajo |
| Comercial | Cotizaciones; Movimientos; Catálogo de precios; Facturación; CAI; Libro de ventas; Pagos; Gastos DMC |
| RRHH | Planillas quincenales y especiales (catorceavo / aguinaldo); Vacaciones; Recibos; Tiempo extra y faltas |
| Análisis | Reportes |

## 5. Referencias de implementación

- Entrada, autenticación del panel y carga de módulos: `dashboard.php`, `controllers/AuthController.php`, `config/auth.php`.
- Flujos comerciales: `services/OrdenService.php`, `services/CotizacionService.php`, `services/FacturacionService.php`.
- Abastecimiento y requisiciones: `models/CompraModel.php`, `models/RequisicionModel.php`.
- Órdenes y movimientos: `models/OrdenModel.php`, `models/MovimientoModel.php`.
- Recursos humanos: `models/PlanillaModel.php`, `models/PlanillaEspecialModel.php`, `models/AsistenciaModel.php`, `controllers/VacacionesController.php`, `models/ReciboModel.php`.
