module multiplier_top (
    input  logic clk,
    input  logic rst_n,
    input  logic start,

    input  logic [31:0] multiplicand_in,
    input  logic [31:0] multiplier_in,

    output logic [63:0] product,
    output logic done
);

    logic load, product_wr, shift_en;
    logic multiplier_lsb;

    multiplier_control control (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .multiplier_lsb(multiplier_lsb),
        .done(done),
        .load(load),
        .product_wr(product_wr),
        .shift_en(shift_en)
    );

    multiplier_datapath datapath (
        .clk(clk),
        .rst_n(rst_n),
        .multiplicand_in(multiplicand_in),
        .multiplier_in(multiplier_in),
        .load(load),
        .product_wr(product_wr),
        .shift_en(shift_en),
        .multiplier_lsb(multiplier_lsb),
        .product(product)
    );

endmodule