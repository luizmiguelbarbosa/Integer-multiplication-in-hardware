module multiplier_control_refinado (
    input  logic clk,
    input  logic rst_n,

    input  logic start,
    output logic done,

    output logic load,
    output logic compute_en
);

    typedef enum logic [1:0] {
        IDLE,
        LOAD,
        COMPUTE,
        DONE
    } state_t;

    state_t state, next_state;

    logic [5:0] count;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 6'd0;
        end else begin
            case (state)
                IDLE:    count <= 6'd0;
                LOAD:    count <= 6'd0;
                COMPUTE: count <= count + 1;
                default: count <= count;
            endcase
        end
    end

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
                if (count == 6'd31)
                    next_state = DONE;
            end

            DONE: begin
                if (!start)
                    next_state = IDLE;
            end
        endcase
    end

    always_comb begin
        load       = 1'b0;
        compute_en = 1'b0;
        done       = 1'b0;

        case (state)
            LOAD: begin
                load = 1'b1;
            end

            COMPUTE: begin
                compute_en = 1'b1;
            end

            DONE: begin
                done = 1'b1;
            end
        endcase
    end

endmodule