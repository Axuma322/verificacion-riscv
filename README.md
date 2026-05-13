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
