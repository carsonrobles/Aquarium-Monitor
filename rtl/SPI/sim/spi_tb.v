
/*
 * Carson Robles
 * Dec 27, 2016
 *
 * test bench for SPI communication module
 */

module spi_tb;

// input signals
reg       clk = 1'b0;
reg       req = 1'b0;
reg [7:0] dat = 8'h00;

// output signals
wire      sclk;
wire      ss;
wire      sdo;
wire      snt;

// clock logic
always #5 clk <= ~clk;

// module instantiation
spi spi_test (
    .clk  (clk ),
    .req  (req ),
    .dat  (dat ),
    .sclk (sclk),
    .ss   (ss  ),
    .sdo  (sdo ),
    .snt  (snt )
);

// input logic
initial begin
    #10 dat = 8'h0c;
    #20 req = 1'b1;
    #190 req = 1'b0;
    #10 dat = 8'h01;
    #20 req = 1'b1;
end

endmodule
