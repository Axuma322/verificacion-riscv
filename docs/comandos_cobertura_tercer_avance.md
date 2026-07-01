# Comandos de cobertura para tercer avance

## Cobertura funcional en Riviera/EDA Playground

El ejemplo dado por el profesor usa Riviera-PRO y `acdb report`. Usar `Proyecto/tb/run.do` como script de simulacion para generar:

- `fcover.acdb`
- `cov.txt`

El `run.do` imprime `cov.txt` en consola con granularidad por bins, igual que el ejemplo `EDA_example.zip`.

## Plusargs utiles

Prueba mixta de 400 instrucciones:

```text
+NUM_ITEMS=400 +SEQ_MODE=MIXED
```

Pruebas por funcion:

```text
+NUM_ITEMS=400 +SEQ_MODE=R
+NUM_ITEMS=400 +SEQ_MODE=I
+NUM_ITEMS=400 +SEQ_MODE=U
+NUM_ITEMS=400 +SEQ_MODE=LOAD
+NUM_ITEMS=400 +SEQ_MODE=STORE
+NUM_ITEMS=400 +SEQ_MODE=BRANCH
+NUM_ITEMS=400 +SEQ_MODE=JUMP
```

## Cobertura estructural con Covered

La guia pide analizar:

- Line coverage.
- Toggle coverage.
- FSM coverage, o justificar si no aplica.

El comando exacto depende de como EDA Playground exponga Covered. La evidencia esperada es el reporte de Covered y una justificacion escrita para cualquier metrica menor a 100%.
