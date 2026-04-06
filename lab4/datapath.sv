module multiplier_datapath (
    input  logic clk,
    input  logic rst_n,

    input  logic [31:0] multiplicand_in,
    input  logic [31:0] multiplier_in,

    input  logic load,
    input  logic product_wr,
    input  logic shift_en,

    output logic multiplier_lsb,
    output logic [63:0] product
);

    logic [63:0] multiplicand_reg;
    logic [31:0] multiplier_reg;
    logic [63:0] product_reg;

    logic [63:0] alu_sum;

    assign alu_sum = product_reg + multiplicand_reg;

    assign multiplier_lsb = multiplier_reg[0];
    assign product = product_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            multiplicand_reg <= 0;
            multiplier_reg   <= 0;
            product_reg      <= 0;

        end else if (load) begin
            multiplicand_reg <= {32'b0, multiplicand_in};
            multiplier_reg   <= multiplier_in;
            product_reg      <= 0;

        end else begin
            if (product_wr)
                product_reg <= alu_sum;

            if (shift_en) begin
                multiplicand_reg <= multiplicand_reg << 1;
                multiplier_reg   <= multiplier_reg >> 1;
            end
        end
    end

endmodule