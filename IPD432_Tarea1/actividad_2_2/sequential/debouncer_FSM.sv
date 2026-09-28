module PB_Debouncer_FSM #(
    parameter DELAY = 15
)
(
    input  logic clk,
    input  logic rst,
    input  logic PB,
    output logic PB_pressed_status,
    output logic PB_pressed_pulse,
    output logic PB_released_pulse
);

    logic PB_sync_aux, PB_sync;

    // Sincronización de la entrada asíncrona PB.
    always_ff @(posedge clk) begin
        if (rst) begin
            PB_sync_aux <= 1'b0;
            PB_sync     <= 1'b0;
        end
        else begin
            PB_sync_aux <= PB;
            PB_sync     <= PB_sync_aux;
        end
    end

    localparam DELAY_WIDTH = $clog2(DELAY);
    logic [DELAY_WIDTH-1:0] delay_timer;

    // La descripción funcional es idéntica para las cuatro pruebas.
    typedef enum logic [5:0] {
        PB_IDLE,
        PB_COUNT,
        PB_PRESSED,
        PB_STABLE,
        PB_RELEASED
    } state_t;

    (* fsm_encoding = "sequential" *)
    state_t state;
    state_t next_state;

    // Temporizador: incrementa mientras se permanece en el mismo estado
    // y se reinicia cuando la FSM cambia de estado.
    always_ff @(posedge clk) begin
        if (rst)
            delay_timer <= 0;
        else if (state != next_state)
            delay_timer <= 0;
        else
            delay_timer <= delay_timer + 1;
    end

    // Lógica combinacional de próximo estado y salidas Moore.
    always_comb begin
        next_state          = PB_IDLE;
        PB_pressed_status   = 1'b0;
        PB_pressed_pulse    = 1'b0;
        PB_released_pulse   = 1'b0;

        case (state)
            PB_IDLE: begin
                if (PB_sync)
                    next_state = PB_COUNT;
            end

            PB_COUNT: begin
                if (PB_sync && (delay_timer >= DELAY-1))
                    next_state = PB_PRESSED;
                else if (PB_sync)
                    next_state = PB_COUNT;
            end

            PB_PRESSED: begin
                PB_pressed_pulse = 1'b1;
                if (PB_sync)
                    next_state = PB_STABLE;
            end

            PB_STABLE: begin
                PB_pressed_status = 1'b1;
                next_state = PB_STABLE;

                if (~PB_sync)
                    next_state = PB_RELEASED;
            end

            PB_RELEASED: begin
                PB_released_pulse = 1'b1;
                next_state = PB_IDLE;
            end

            default: begin
                next_state          = PB_IDLE;
                PB_pressed_status   = 1'b0;
                PB_pressed_pulse    = 1'b0;
                PB_released_pulse   = 1'b0;
            end
        endcase
    end

    // Registro de estado.
    always_ff @(posedge clk) begin
        if (rst)
            state <= PB_IDLE;
        else
            state <= next_state;
    end

endmodule
