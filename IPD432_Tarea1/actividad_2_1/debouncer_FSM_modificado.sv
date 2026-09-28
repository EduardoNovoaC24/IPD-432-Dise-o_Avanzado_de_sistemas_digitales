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

    // Sincronizador de dos flip-flops para la entrada asíncrona PB.
    logic PB_sync_aux;
    logic PB_sync;

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

    // Se replica el criterio temporal de la implementación counter
    // seleccionada como referencia funcional en la actividad 2.1.
    localparam DELAY_WIDTH = $clog2(DELAY);

    logic [DELAY_WIDTH-1:0] delay_timer;
    logic                   delay_max;

    assign delay_max = &delay_timer;

    typedef enum logic [1:0] {
        PB_IDLE_LOW,
        PB_COUNT_PRESS,
        PB_STABLE_HIGH,
        PB_COUNT_RELEASE
    } state_t;

    state_t state;

    // Máquina de estados secuencial.
    always_ff @(posedge clk) begin
        if (rst) begin
            state       <= PB_IDLE_LOW;
            delay_timer <= '0;
        end
        else begin
            case (state)

                PB_IDLE_LOW: begin
                    delay_timer <= '0;

                    if (PB_sync) begin
                        state       <= PB_COUNT_PRESS;
                        delay_timer <= 'd1;
                    end
                end

                PB_COUNT_PRESS: begin
                    if (!PB_sync) begin
                        state       <= PB_IDLE_LOW;
                        delay_timer <= '0;
                    end
                    else if (delay_max) begin
                        state       <= PB_STABLE_HIGH;
                        delay_timer <= '0;
                    end
                    else begin
                        delay_timer <= delay_timer + 1'b1;
                    end
                end

                PB_STABLE_HIGH: begin
                    delay_timer <= '0;

                    if (!PB_sync) begin
                        state       <= PB_COUNT_RELEASE;
                        delay_timer <= 'd1;
                    end
                end

                PB_COUNT_RELEASE: begin
                    if (PB_sync) begin
                        state       <= PB_STABLE_HIGH;
                        delay_timer <= '0;
                    end
                    else if (delay_max) begin
                        state       <= PB_IDLE_LOW;
                        delay_timer <= '0;
                    end
                    else begin
                        delay_timer <= delay_timer + 1'b1;
                    end
                end

                default: begin
                    state       <= PB_IDLE_LOW;
                    delay_timer <= '0;
                end

            endcase
        end
    end

    // Lógica de salida tipo Moore con pulsos en los estados de confirmación.
    always_comb begin
        PB_pressed_status = 1'b0;
        PB_pressed_pulse  = 1'b0;
        PB_released_pulse = 1'b0;

        case (state)
            PB_IDLE_LOW: begin
                PB_pressed_status = 1'b0;
            end

            PB_COUNT_PRESS: begin
                PB_pressed_status = 1'b0;
                if (PB_sync && delay_max)
                    PB_pressed_pulse = 1'b1;
            end

            PB_STABLE_HIGH: begin
                PB_pressed_status = 1'b1;
            end

            PB_COUNT_RELEASE: begin
                PB_pressed_status = 1'b1;
                if (!PB_sync && delay_max)
                    PB_released_pulse = 1'b1;
            end

            default: begin
                PB_pressed_status = 1'b0;
                PB_pressed_pulse  = 1'b0;
                PB_released_pulse = 1'b0;
            end
        endcase
    end

endmodule
