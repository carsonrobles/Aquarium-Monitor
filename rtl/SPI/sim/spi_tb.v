
/*
 * Carson Robles
 * Dec 27, 2016
 *
 * test bench for SPI communication module
 */

module spi_tb;

// input signals
reg       clk = 1'b0;
reg       en  = 1'b0;
reg [7:0] dat = 8'h39;

// output signals
wire      sclk;
wire      sdo;
wire      done;

// clock logic
always #5 clk <= ~clk;

// module instantiation
spi spi_test (
    .clk  (clk ),
    .en   (en  ),
    .dat  (dat ),
    .sclk (sclk),
    .sdo  (sdo ),
    .done (done)
);

// input logic
initial begin
    #20 en  <= 1'b1;
end

endmodule
