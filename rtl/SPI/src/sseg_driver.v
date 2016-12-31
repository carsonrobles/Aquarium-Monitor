
/*
 * Carson Robles
 * Dec 30, 2016
 *
 * driver for an 8 digit SPI 7 segment display
 * 32 bits (dat) are sent to display
 */

module sseg_driver (
    input  wire        clk,                         // system clock

    input  wire [31:0] dat,                         // 32 bits to be displayed

    output wire        sclk,                        // serial clock
    output wire        sdo                          // serial data out
);

reg       req = 1'b0;                               // request data send
reg [7:0] snd = 8'h0;                               // byte to send

wire snt;                                           // high when full byte has been sent

// instantiate SPI module
spi spi_sseg (
    .clk  (clk ),
    .req  (req ),
    .dat  (snd ),
    .sclk (sclk),
    .sdo  (sdo ),
    .snt  (snt )
);

endmodule

