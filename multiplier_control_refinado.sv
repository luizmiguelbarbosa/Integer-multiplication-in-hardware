module multiplier_control (
    input  logic clk,
    input  logic rst_n,

    input  logic start,
    output logic done,

    output logic load,
    output logic compute_en
);

    // estados da FSM
    typedef enum logic [1:0] {
        IDLE,
        LOAD,
        COMPUTE,
        DONE
    } state_t;

    state_t state, next_state;

    // contador de iteracoes
    logic [5:0] count;

    // registrador de estado
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    // contador de iteracoes
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count <= 6'd0;
        else begin
            case (state)
                IDLE:    count <= 6'd0;
                LOAD:    count <= 6'd0;
                COMPUTE: count <= count + 1; // avanca para o proximo bit (shift)
                default: count <= count;
            endcase
        end
    end

    // logica de proximo estado
    always_comb begin
        next_state = state;

        case (state)
            IDLE: begin
                if (start)
                    next_state = LOAD;
            end

            LOAD: begin
                next_state = COMPUTE;
            end

            COMPUTE: begin
                if (count == 6'd31) // apos processar 32 bits
                    next_state = DONE;
            end

            DONE: begin
                if (!start)
                    next_state = IDLE;
            end
        endcase
    end

    // saidas da FSM
    always_comb begin
        load       = 1'b0;
        compute_en = 1'b0;
        done       = 1'b0;

        case (state)
            LOAD: begin
                load = 1'b1; // carrega multiplicando e multiplicador no datapath
            end

            COMPUTE: begin
                compute_en = 1'b1; 
                // executa em 1 ciclo:
                // testa o bit LSB atual (product[0])
                // soma se necessario
                // shift a direita = pula para o proximo bit do multiplicador
            end

            DONE: begin
                done = 1'b1; // resultado final
            end
        endcase
    end

endmodule