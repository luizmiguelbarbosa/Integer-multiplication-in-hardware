module multiplier_control (
    input  logic clk,
    input  logic rst_n,
    input  logic start,
    output logic done,
    input  logic multiplier_lsb, 
    output logic load,           
    output logic product_wr,     
    output logic shift_en        
);

    typedef enum logic [4:0] {
        IDLE        = 5'b00001,
        LOAD        = 5'b00010,
        ADD_OR_SKIP = 5'b00100, 
        SHIFT       = 5'b01000, 
        DONE        = 5'b10000
    } state_t;

    state_t state, next_state;

    logic [5:0] count;
    logic       count_en;
    logic       count_rst;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count <= 6'd0;
        else if (count_rst)
            count <= 6'd0;
        else if (count_en)
            count <= count + 6'd1;
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    always_comb begin
        next_state = state;
        case (state)
            IDLE:
                if (start)
                    next_state = LOAD;
            LOAD:
                next_state = ADD_OR_SKIP;
            ADD_OR_SKIP:
                next_state = SHIFT;
            SHIFT:
                if (count == 6'd31)
                    next_state = DONE;
                else
                    next_state = ADD_OR_SKIP;
            DONE:
                if (!start)
                    next_state = IDLE;
            default:
                next_state = IDLE;
        endcase
    end

    always_comb begin
        load       = 1'b0;
        product_wr = 1'b0;
        shift_en   = 1'b0;
        done       = 1'b0;
        count_en   = 1'b0;
        count_rst  = 1'b0;

        case (state)
            IDLE: begin
                count_rst = 1'b1;
            end
            LOAD: begin
                load      = 1'b1;
                count_rst = 1'b1;
            end
            ADD_OR_SKIP: begin
                product_wr = multiplier_lsb;
            end
            SHIFT: begin
                shift_en = 1'b1;
                count_en = 1'b1;
            end
            DONE: begin
                done = 1'b1;
            end
        endcase
    end

endmodule