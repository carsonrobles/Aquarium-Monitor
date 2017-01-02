
/*
 * Carson Robles
 * Jan 1, 2017
 *
 * test bench for sseg driver
 */

module sseg_driver_tb;

reg        clk;
reg [31:0] dat;

wire sclk;
wire ss;
wire sdo;

sseg_driver sseg_sim (
    .clk  (clk ),
    .dat  (dat ),
    .sclk (sclk),
    .ss   (ss  ),
    .sdo  (sdo )
);

always #5 clk <= ~clk;



endmodule

