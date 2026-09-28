`timescale 1ns / 1ps

module debouncer_testbench();

    // Cambiar entre 5, 10 y 15 para repetir las pruebas reportadas.
    localparam integer DELAY_TEST = 15;

    logic clk;
    logic rst;
    logic PB;

    logic PB_pressed_status_FSM;
    logic PB_pressed_pulse_FSM;
    logic PB_released_pulse_FSM;

    logic PB_pressed_status_logic;
    logic PB_pressed_pulse_logic;
    logic PB_released_pulse_logic;

    PB_Debouncer_FSM #(
        .DELAY(DELAY_TEST)
    ) DUT_FSM (
        .clk                (clk),
        .rst                (rst),
        .PB                 (PB),
        .PB_pressed_status  (PB_pressed_status_FSM),
        .PB_pressed_pulse   (PB_pressed_pulse_FSM),
        .PB_released_pulse  (PB_released_pulse_FSM)
    );

    PB_Debouncer_counter #(
        .DELAY(DELAY_TEST)
    ) DUT_counter (
        .clk                (clk),
        .rst                (rst),
        .PB                 (PB),
        .PB_pressed_status  (PB_pressed_status_logic),
        .PB_pressed_pulse   (PB_pressed_pulse_logic),
        .PB_released_pulse  (PB_released_pulse_logic)
    );

    // Periodo del reloj = 2 ns.
    always #1 clk = ~clk;

    initial begin
        clk = 1'b0;
        rst = 1'b1;
        PB  = 1'b0;

        // Reset durante 5 ciclos.
        // Las entradas se modifican en negedge para no coincidir con
        // el flanco ascendente usado por los circuitos síncronos.
        repeat (5) @(negedge clk);
        rst = 1'b0;

        repeat (5) @(negedge clk);

        // Prueba 1: pulsación válida y estable.
        PB = 1'b1;
        repeat (25) @(negedge clk);

        // Prueba 2: rebote corto durante la liberación.
        PB = 1'b0;
        repeat (3) @(negedge clk);
        PB = 1'b1;
        repeat (10) @(negedge clk);

        // Prueba 3: liberación real y estable.
        PB = 1'b0;
        repeat (25) @(negedge clk);

        repeat (5) @(negedge clk);
        $finish;
    end

endmodule
