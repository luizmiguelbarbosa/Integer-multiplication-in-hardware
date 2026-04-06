`timescale 1ns/1ps

module multiplier_tb;

    logic clk;
    logic rst_n;
    logic start;
    logic [31:0] multiplicand_in;
    logic [31:0] multiplier_in;
    logic [63:0] product;
    logic done;

    multiplier_top dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .multiplicand_in(multiplicand_in),
        .multiplier_in(multiplier_in),
        .product(product),
        .done(done)
    );

    // clock
    initial clk = 0;
    always #5 clk = ~clk;

    task automatic run_test (
        input logic [31:0] a,
        input logic [31:0] b,
        input string name
    );
        logic [63:0] expected;
        begin
            expected = a * b;

            @(negedge clk);
            multiplicand_in = a;
            multiplier_in   = b;
            start = 1;

            @(negedge clk);
            start = 0;

            wait (done);

            @(negedge clk);

            if (product === expected)
                $display("[PASS] %s: %0d x %0d = %0d", name, a, b, product);
            else
                $display("[FAIL] %s: %0d x %0d = %0d (esperado %0d)",
                         name, a, b, product, expected);

            @(negedge clk);
        end
    endtask

    initial begin
        rst_n = 0;
        start = 0;
        multiplicand_in = 0;
        multiplier_in = 0;

        repeat (2) @(posedge clk);
        rst_n = 1;

        run_test(6, 7, "6x7");
        run_test(10, 20, "10x20");
        run_test(123, 456, "123x456");
        run_test(32'hFFFFFFFF, 2, "MAX x 2");

        $display("Fim da simulacao");
        $finish;
    end

endmodule