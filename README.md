<<<<<<< ours
# IE0621 - Verificación funcional de darkriscv/darksocv

Repositorio del proyecto de verificación funcional del curso **IE0621: Verificación Funcional del Diseño de Circuitos Integrados**.

El objetivo del proyecto es construir un ambiente de verificación funcional en **SystemVerilog/UVM** para verificar el comportamiento del core RISC-V `darkriscv`, integrado dentro del módulo `darksocv`.

El proyecto evolucionó desde un testbench por capas inicial hacia un ambiente UVM con generación aleatoria de instrucciones, monitor, scoreboard, cobertura funcional y aserciones.

---

## Estado actual del proyecto

Actualmente se cuenta con un ambiente UVM funcional para verificar instrucciones simples del core `darkriscv`.

El ambiente ya permite:

* Instanciar el DUT `darksocv`.
* Ejecutar el core `darkriscv` dentro del SoC.
* Generar instrucciones aleatorias mediante `randomize()`.
* Codificar instrucciones RISC-V soportadas.
* Generar automáticamente el archivo `darksocv.mem`.
* Agregar una instrucción final `jal x0, 0` para detener el programa.
* Rellenar memoria con instrucciones `nop`.
* Aplicar y liberar reset externo desde el driver.
* Observar señales internas del DUT mediante una interfaz.
* Monitorear instrucciones ejecutadas y el banco de registros `REGS[0:15]`.
* Comparar resultados contra un modelo de referencia en el scoreboard.
* Medir cobertura funcional mediante un subscriber.
* Evaluar aserciones básicas en la interfaz.
* Exponer señales de writeback para mejorar la observación del core.

---

## Estructura general

```text
VERIFICACION-RISCV/
│
├── rtl/
│   ├── config.vh
│   ├── darkcache.v
│   ├── darkpll.v
│   ├── darkriscv.v
│   ├── darksocv.v
│   ├── darksocv.mem
│   ├── darkuart.v
│   └── design.sv
│
├── tb/
│   ├── testbench.sv
│   ├── tb_top.sv
│   ├── ifc_darksocv.sv
│   ├── darksocv_pkg.sv
│   ├── darksocv_item.sv
│   ├── darksocv_sequence.sv
│   ├── darksocv_sequencer.sv
│   ├── darksocv_driver.sv
│   ├── darksocv_monitor.sv
│   ├── darksocv_scoreboard.sv
│   ├── darksocv_subscriber.sv
│   ├── darksocv_agent.sv
│   ├── darksocv_env.sv
│   └── darksocv_test.sv
│
├── docs/
├── LICENSE
└── README.md
```

---

## DUT

El DUT principal utilizado en la simulación es:

```text
darksocv
```

Dentro de `darksocv` se instancia el core:

```text
darkriscv core0
```

El testbench verifica principalmente el comportamiento del core `darkriscv`, pero se instancia mediante `darksocv` porque este módulo contiene la memoria, la carga de `darksocv.mem` y las señales internas necesarias para la simulación.

---

## Arquitectura UVM

La jerarquía principal del ambiente es:

```text
tb_top
│
├── DUT: darksocv
│   └── core0: darkriscv
│
├── ifc_darksocv
│
└── uvm_test_top
    └── darksocv_test
        └── darksocv_env
            ├── darksocv_agent
            │   ├── darksocv_sequence
            │   ├── darksocv_sequencer
            │   ├── darksocv_driver
            │   └── darksocv_monitor
            │
            ├── darksocv_scoreboard
            └── darksocv_subscriber
```

---

## Flujo de simulación

El flujo actual del testbench es:

```text
darksocv_sequence
        |
        v
darksocv_sequencer
        |
        v
darksocv_driver
        |
        | genera darksocv.mem
        v
darksocv.mem
        |
        | $readmemh
        v
DUT: darksocv / darkriscv
        |
        | señales internas copiadas por tb_top
        v
ifc_darksocv
        |
        v
darksocv_monitor
        |
        +-----------------> darksocv_scoreboard
        |
        +-----------------> darksocv_subscriber
```

La secuencia genera instrucciones aleatorias. El driver las escribe en `darksocv.mem`, agrega un `jal x0, 0` al final y rellena el resto con `nop`. Luego libera reset para que el DUT ejecute el programa generado.

El monitor observa la ejecución, decodifica instrucciones soportadas y publica transacciones. El scoreboard calcula los valores esperados con un modelo de referencia y compara contra el DUT. El subscriber toma muestras de cobertura funcional.

---

## Componentes principales

### `tb_top.sv`

Es el módulo superior del testbench.

Funciones principales:

* Genera el reloj externo `XCLK`.
* Instancia el DUT `darksocv`.
* Instancia la interfaz `ifc_darksocv`.
* Publica la interfaz usando `uvm_config_db`.
* Copia señales internas del DUT hacia la interfaz.
* Expone señales auxiliares para EPWave, como `reg_x0` a `reg_x15`.

---

### `ifc_darksocv.sv`

Interfaz entre el ambiente UVM y el DUT.

Expone:

* Señales externas: `XRES`, `UART_RXD`, `UART_TXD`, `LED`, `DEBUG`.
* Señales internas: `IADDR`, `IDATA`, `DADDR`, `DATAI`, `DATAO`, `RD`, `WR`, `BE`.
* Banco de registros: `REGS[0:15]`.
* Palabras de memoria: `MEM_WORD[0:63]`.
* Señales de writeback: `WB_VALID`, `WB_RD`, `WB_DATA`, `WB_PC`, `WB_INSTR`.

También contiene tres aserciones básicas:

* `x0` debe permanecer en cero fuera de reset.
* `IADDR` debe estar alineado a 4 bytes.
* `RD` y `WR` no deben estar activos simultáneamente.

---

### `darksocv_item.sv`

Define la transacción UVM que representa una instrucción.

Cada item contiene:

* Tipo de instrucción.
* Operación.
* Registro destino `rd`.
* Registros fuente `rs1` y `rs2`.
* Inmediato.
* Palabra codificada `instr_word`.
* Texto ensamblador `asm_text`.
* Valor observado y esperado.

Actualmente soporta instrucciones:

```text
ADD, SUB, AND, OR, XOR, ADDI, LUI
```

---

### `darksocv_sequence.sv`

Genera instrucciones aleatorias usando `randomize()`.

Actualmente se generan instrucciones de tipo:

* R-type.
* I-type.
* U-type.

La primera instrucción se dirige para producir un cambio visible en el banco de registros. Esto evita que la simulación pase únicamente porque todos los registros permanecen en cero.

---

### `darksocv_driver.sv`

Recibe items desde el sequencer y genera el archivo `darksocv.mem`.

Funciones principales:

* Abre `darksocv.mem`.
* Escribe las instrucciones generadas.
* Agrega `jal x0, 0` como instrucción final.
* Rellena memoria con `nop`.
* Cierra el archivo.
* Aplica y libera el reset externo `XRES`.

---

### `darksocv_monitor.sv`

Observa la ejecución del DUT.

Actualmente:

* Observa `IADDR`.
* Usa `MEM_WORD[IADDR[7:2]]` para recuperar la instrucción ejecutada.
* Decodifica instrucciones soportadas.
* Detecta `jal x0, 0` como final del programa.
* Observa cambios en `REGS[0:15]`.
* Publica transacciones hacia scoreboard y subscriber.
* Utiliza una alineación temporal aproximada para compensar el desfase del pipeline.

También se expusieron señales `WB_*` para migrar a una observación basada en writeback real.

---

### `darksocv_scoreboard.sv`

Funciona como checker del ambiente.

Contiene un modelo de referencia con:

```text
ref_regs[0:15]
```

El scoreboard calcula el resultado esperado para cada instrucción soportada y compara contra los valores observados. También realiza una comparación final del banco completo de registros.

Actualmente soporta modelo de referencia para:

```text
ADD, SUB, AND, OR, XOR, ADDI, LUI
```

---

### `darksocv_subscriber.sv`

Mide cobertura funcional.

Contiene 9 coverpoints:

* Tipo de instrucción.
* Operación.
* Registro destino `rd`.
* Registro fuente `rs1`.
* Registro fuente `rs2`.
* `rd == x0`.
* `rs1 == x0`.
* Rango del inmediato.
* Resultado observado igual a cero.

Contiene 3 crosses:

* Tipo de instrucción contra operación.
* Tipo de instrucción contra registro destino.
* Operación contra resultado cero.

---

## Señales de writeback

Para mejorar la observación del core, se agregaron señales de writeback en la interfaz:

```systemverilog
logic        WB_VALID;
logic [3:0]  WB_RD;
logic [31:0] WB_DATA;
logic [31:0] WB_PC;
logic [31:0] WB_INSTR;
```

Estas señales se calculan en `tb_top.sv` a partir de señales internas de `darkriscv`, como:

* `DPTR`
* `XIDATA`
* `PC`
* `LCC`
* `AUIPC`
* `JAL`
* `JALR`
* `LUI`
* `MCC`
* `RCC`
* `LDATA`
* `PCSIMM`
* `NXPC`
* `SIMM`
* `RMDATA`

La intención es migrar el monitor para que use `WB_VALID`, `WB_RD` y `WB_DATA` como evento real de escritura al banco de registros, en lugar de depender de una latencia fija del pipeline.

---

## Cobertura y aserciones

El ambiente incluye cobertura funcional y aserciones.

La cobertura se toma desde los items publicados por el monitor hacia el subscriber. Las aserciones se encuentran en la interfaz `ifc_darksocv`.

Las aserciones implementadas son:

```text
x0 constante
IADDR alineado
no RD && WR simultáneos
```

---

## Archivos para EDA Playground

Para simular en EDA Playground, usar los siguientes archivos.

### RTL

```text
rtl/design.sv
rtl/config.vh
rtl/darkpll.v
rtl/darkuart.v
rtl/darkriscv.v
rtl/darksocv.v
rtl/darksocv.mem
```

### Testbench

```text
tb/testbench.sv
tb/ifc_darksocv.sv
tb/darksocv_pkg.sv
tb/darksocv_item.sv
tb/darksocv_sequence.sv
tb/darksocv_sequencer.sv
tb/darksocv_driver.sv
tb/darksocv_monitor.sv
tb/darksocv_scoreboard.sv
tb/darksocv_subscriber.sv
tb/darksocv_agent.sv
tb/darksocv_env.sv
tb/darksocv_test.sv
tb/tb_top.sv
```

El archivo superior del testbench es:

```text
tb/testbench.sv
```

El archivo superior de diseño es:

```text
rtl/design.sv
```

---

## Resultado esperado

En una simulación correcta se deben observar mensajes UVM similares a:

```text
[TEST] Inicio de darksocv_test
[SEQ] Instruccion randomizada ...
[DRV] Escribiendo instruccion ...
[MON] Instruccion soportada guardada ...
[SCB] Valor teorico calculado ...
[SCB] Resultado final: PASS
[SUB] Cobertura final subscriber = ...
```

También deben observarse:

```text
UVM_ERROR : 0
UVM_FATAL : 0
```

---

## Limitaciones actuales

El ambiente actual verifica correctamente instrucciones simples ALU, `ADDI` y `LUI`. Sin embargo, todavía existen limitaciones importantes:

* El monitor actual aún no usa completamente `WB_VALID` como evento principal.
* Parte de la asociación instrucción-resultado depende de una latencia aproximada del pipeline.
* El scoreboard aún no modela memoria.
* Todavía no se verifican instrucciones `load` y `store`.
* No se modelan byte enables ni sign-extension de loads.
* El monitoreo de stores requiere observar `WR`, `DADDR`, `DATAO` y `BE`.

---

## Trabajo pendiente

Para el siguiente avance se recomienda:

* Migrar el monitor para usar directamente `WB_VALID`, `WB_RD`, `WB_DATA`, `WB_PC` y `WB_INSTR`.
* Mantener el snapshot final como chequeo global.
* Agregar soporte para instrucciones `load` y `store`.
* Monitorear el bus de memoria: `RD`, `WR`, `DADDR`, `DATAI`, `DATAO`, `BE`.
* Agregar un modelo de memoria en el scoreboard.
* Ampliar cobertura funcional para accesos a memoria.
* Agregar sequences dirigidas para cubrir casos específicos.

---

## Resumen

El proyecto cuenta actualmente con un ambiente UVM funcional que genera instrucciones aleatorias, crea el archivo de memoria, ejecuta el programa en `darkriscv`, observa la ejecución, compara contra un modelo de referencia y mide cobertura funcional.

El ambiente ya implementa la estructura base requerida para verificación funcional UVM y queda preparado para evolucionar hacia una verificación más precisa basada en eventos de writeback y accesos de memoria.

>>>>>>> theirs
