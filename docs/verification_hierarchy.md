flowchart TD
    TEST[Test / Escenario] --> GEN[Generador de estímulo]
    GEN --> DRV[Driver]
    DRV --> DUT[DUT: darksocv / darkriscv core]

    DUT --> MON[Monitor]
    MON --> SB[Scoreboard]
    SB --> CHK[Checker]

    GEN --> SB
    CHK --> RESULT[Resultado de verificación]
