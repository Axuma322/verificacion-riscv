# IE0621 - Verificación funcional de darkriscv/darksocv

Repositorio del proyecto de verificación funcional del curso **IE0621: Verificación Funcional del Diseño de Circuitos Integrados**.

El objetivo del proyecto es construir un ambiente de verificación en **SystemVerilog** para verificar funcionalmente el comportamiento del core RISC-V incluido dentro del sistema `darksocv`.

## Estado actual del proyecto

Actualmente el proyecto se encuentra en la etapa de integración inicial del DUT. Ya se logró:

- Cargar los archivos RTL requeridos en EDA Playground.
- Instanciar `darksocv` desde un `top.sv`.
- Generar señales básicas de `clk` y `reset`.
- Cargar instrucciones desde `darksocv.mem`.
- Ejecutar una simulación inicial del procesador.

Esta etapa no representa todavía una verificación funcional completa. Es el punto de partida para construir el ambiente de verificación basado en capas.

## DUT

El DUT principal usado en la simulación es:

```text
darksocv
