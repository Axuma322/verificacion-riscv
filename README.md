<<<<<<< ours
# IE0621 - Verificación funcional de darkriscv/darksocv

Repositorio del proyecto de verificación funcional del curso **IE0621: Verificación Funcional del Diseño de Circuitos Integrados**.

El objetivo del proyecto es construir un ambiente de verificación en **SystemVerilog** para verificar funcionalmente el comportamiento del core RISC-V `darkriscv`, el cual se encuentra integrado dentro del módulo `darksocv`.

Este repositorio corresponde al **avance #1** del proyecto, enfocado en la construcción de un **testbench basado en capas**.

---

## Estado actual del proyecto

Actualmente se cuenta con un ambiente de verificación funcional inicial para `darksocv`.

Ya se logró:

- Cargar los archivos RTL requeridos en EDA Playground.
- Instanciar el DUT `darksocv`.
- Generar la señal de reloj externa `XCLK`.
- Controlar el reset externo `XRES`.
- Cargar instrucciones desde `darksocv.mem`.
- Ejecutar un programa básico en el core `darkriscv`.
- Observar señales internas del DUT mediante una interfaz.
- Monitorear el banco de registros interno `REGS[0:15]`.
- Comparar valores observados contra valores esperados.
- Obtener un resultado final `PASS/FAIL` mediante scoreboard/checker.

El ambiente actual implementa una prueba dirigida basada en un programa RISC-V conocido. No pretende verificar aún todo el ISA ni todos los casos posibles del procesador, sino demostrar la estructura funcional del testbench por capas solicitada para el primer avance.

---

## DUT

El DUT principal utilizado en la simulación es:

```text
darksocv
=======
# IE0621 - Segundo avance de verificacion funcional darkriscv/darksocv

Repositorio del proyecto de verificacion funcional del curso **IE0621: Verificacion Funcional del Diseno de Circuitos Integrados**.

El objetivo del segundo avance es implementar un ambiente de verificacion en **SystemVerilog/UVM** para el core RISC-V `darkriscv`, integrado dentro del modulo `darksocv`.

## Estado del avance

El ambiente implementado en `Proyecto/tb` sigue la jerarquia UVM solicitada:

- `darksocv_item.sv`: sequence item con instrucciones R, I y U.
- `darksocv_sequence.sv`: genera dos instrucciones aleatorizadas para la demostracion.
- `darksocv_sequencer.sv`: sequencer UVM.
- `darksocv_driver.sv`: escribe `darksocv.mem` y libera reset despues de generar el programa.
- `darksocv_monitor.sv`: observa instrucciones ejecutadas, registros internos y publica transacciones.
- `darksocv_scoreboard.sv`: calcula el modelo de referencia, compara contra el snapshot final y funciona como checker.
- `darksocv_subscriber.sv`: implementa cobertura funcional.
- `darksocv_agent.sv`, `darksocv_env.sv`, `darksocv_test.sv`: jerarquia agente, environment y test.
- `ifc_darksocv.sv`: interfaz con tres aserciones.

## Cobertura y aserciones

El subscriber contiene 9 coverpoints:

- Tipo de instruccion.
- Operacion ALU.
- Registro destino `rd`.
- Registro fuente `rs1`.
- Registro fuente `rs2`.
- `rd == x0`.
- `rs1 == x0`.
- Rango de inmediato.
- Resultado observado igual a cero.

Tambien contiene 3 cruces de cobertura:

- Tipo de instruccion contra operacion.
- Tipo de instruccion contra registro destino.
- Operacion contra resultado cero.

Las 3 aserciones estan en `ifc_darksocv.sv`:

- `x0` permanece en cero fuera de reset.
- `IADDR` esta alineado a 4 bytes.
- `RD` y `WR` no estan activos simultaneamente.

## Archivos para EDA Playground

Como el desarrollo se copia manualmente a EDA Playground, usar estos archivos:

RTL:

- `Proyecto/rtl/design.sv`
- `Proyecto/rtl/config.vh`
- `Proyecto/rtl/darkpll.v`
- `Proyecto/rtl/darkuart.v`
- `Proyecto/rtl/darkriscv.v`
- `Proyecto/rtl/darksocv.v`

Testbench:

- `Proyecto/tb/testbench.sv`
- `Proyecto/tb/ifc_darksocv.sv`
- `Proyecto/tb/darksocv_pkg.sv`
- todos los archivos `Proyecto/tb/darksocv_*.sv`
- `Proyecto/tb/tb_top.sv`

El archivo superior de testbench para compilar es `Proyecto/tb/testbench.sv`. El archivo superior de diseno es `Proyecto/rtl/design.sv`.

## Evidencia esperada

En la simulacion deben observarse mensajes UVM de:

- La secuencia generando dos instrucciones aleatorias.
- El driver escribiendo esas instrucciones en `darksocv.mem`.
- El monitor publicando las instrucciones ejecutadas.
- El scoreboard calculando el valor teorico y reportando `PASS` o `FAIL`.
- El subscriber reportando cobertura funcional.

Para el video, conviene mostrar el diagrama de bloques con esta ruta:

```text
sequence -> sequencer -> driver -> darksocv/darkriscv -> monitor -> scoreboard
                                                       -> subscriber
```

El driver genera el programa, el DUT lo ejecuta, el monitor observa el estado final, el scoreboard compara contra el modelo de referencia y el subscriber toma las muestras de cobertura.
>>>>>>> theirs
