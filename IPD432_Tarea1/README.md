# IPD432 - Tarea 1 (Actividades 2.1 y 2.2)

Repositorio con los archivos SystemVerilog utilizados para las actividades 2.1 y 2.2 del análisis de un debouncer para pulsadores electromecánicos.

## Estructura

### `actividad_2_1/`
- `debouncer_counter_original.sv`: implementación de referencia basada en contador.
- `debouncer_FSM_original.sv`: implementación FSM original entregada como referencia.
- `debouncer_testbench_original.sv`: testbench base.
- `debouncer_testbench_extendido.sv`: testbench extendido con pulsación estable, rebote de liberación y liberación estable. Cambiar `DELAY_TEST` entre 5, 10 y 15 para repetir las pruebas.
- `debouncer_FSM_modificado.sv`: FSM modificada para reproducir el comportamiento entrada-salida del debouncer basado en contador seleccionado como referencia funcional.

> Nota: `debouncer_FSM_original.sv` y `debouncer_FSM_modificado.sv` declaran el mismo nombre de módulo (`PB_Debouncer_FSM`). No deben añadirse simultáneamente como Design Sources del mismo proyecto Vivado.

### `actividad_2_2/`
Contiene cuatro subcarpetas con la misma descripción funcional de la FSM original. La única diferencia entre ellas es la directiva `fsm_encoding`:
- `one_hot/`
- `sequential/`
- `johnson/`
- `gray/`

Cada subcarpeta contiene un `debouncer_FSM.sv` independiente para sintetizar por separado.

## Resultados obtenidos

### Actividad 2.1
- Counter original: 8 LUT, 7 FF.
- FSM original: 10 LUT, 11 FF.
- FSM modificada: 7 LUT, 8 FF.

### Actividad 2.2
- One-hot: 10 LUT, 11 FF.
- Sequential: 7 LUT, 9 FF.
- Johnson: 7 LUT, 9 FF.
- Gray: 7 LUT, 9 FF.

Dispositivo utilizado en la síntesis: `xc7a100tcsg324-3`.

## Reproducción

1. Crear/abrir un proyecto Vivado con el dispositivo correspondiente.
2. Para 2.1, añadir el counter y una sola versión de `PB_Debouncer_FSM`, junto con el testbench en Simulation Sources.
3. Para 2.2, sintetizar por separado cada archivo de las carpetas de codificación.
4. Verificar en el Synthesis Log la línea `using encoding ...`.

## Atribución

Las implementaciones originales del debouncer y el testbench base provienen del material de referencia del curso IPD432. Las extensiones, modificaciones y organización del repositorio corresponden al desarrollo de la Tarea 1.
