module multiplier_control (
    input  logic clk,
    input  logic rst_n,
    input  logic start,

    input  logic multiplier_lsb,

    output logic done,
    output logic load,
    output logic product_wr,
    output logic shift_en
);

    typedef enum logic [4:0] {
        IDLE        = 5'b00001,
        LOAD        = 5'b00010,
        ADD_OR_SKIP = 5'b00100,
        SHIFT       = 5'b01000,
        DONE_S      = 5'b10000
    } state_t;

    state_t state, next_state;

    logic [5:0] count;
    logic count_en, count_rst;

    // contador
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count <= 0;
        else if (count_rst)
            count <= 0;
        else if (count_en)
            count <= count + 1;
    end

    // estado
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    // transições
    always_comb begin
        next_state = state;

        case (state)
            IDLE:        if (start) next_state = LOAD;
            LOAD:        next_state = ADD_OR_SKIP;
            ADD_OR_SKIP: next_state = SHIFT;
            SHIFT:       if (count == 6'd31) next_state = DONE_S;
                         else next_state = ADD_OR_SKIP;
            DONE_S:      if (!start) next_state = IDLE;
            default:     next_state = IDLE;
        endcase
    end

    // saídas
    always_comb begin
        load       = 0;
        product_wr = 0;
        shift_en   = 0;
        done       = 0;
        count_en   = 0;
        count_rst  = 0;

        case (state)
            IDLE: count_rst = 1;

            LOAD: begin
                load      = 1;
                count_rst = 1;
            end

            ADD_OR_SKIP: begin
                product_wr = multiplier_lsb;
            end

            SHIFT: begin
                shift_en = 1;
                count_en = 1;
            end

            DONE_S: done = 1;
        endcase
    end

endmodule