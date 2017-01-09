
/*
 * Carson Robles
 * Jan 2, 2017
 *
 * test bench for sseg driver
 */

module sseg_drv_tb;

reg        clk =  1'b0;
reg [63:0] seg = 64'h0;;

wire sclk;
wire load;
wire sdo;

sseg_drv sseg (
    .clk  (clk ),
    .seg  (seg ),
    .sclk (sclk),
    .load (load),
    .sdo  (sdo )
);

always #5 clk <= ~clk;

initial begin
    seg = 64'h1234567890abcdef;
end

endmodule

