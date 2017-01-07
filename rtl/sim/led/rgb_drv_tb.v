
/*
 * Carson Robles
 * Jan 6, 2017
 *
 * testbench for rgb driver
 */

module rgb_drv_tb;

reg clk = 1'b0;

wire rgb;

rgb_drv drv (
    .clk (clk),
    .rgb (rgb)
);

always #5 clk <= ~clk;

endmodule

