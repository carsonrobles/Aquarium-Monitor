
/*
 * Carson Robles
 * Jan 2, 2017
 *
 * uses generic 1-byte SPI module
 * to send 1 packet (16 bits)
 */

module pkt_snd (
    input  wire       clk,                          // system clock

    input  wire [7:0] addr,                         // address portion of packet
    input  wire [7:0] dat,                          // data portion of packet

    output wire       sclk,                         // serial clock
    output wire       ss,                           // slave select
    output wire       sdo                           // serial data out
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
    .ss   (ss  ),
    .sdo  (sdo ),
    .snt  (snt )
);





wire snt_e = (sft == 2'b01);
reg [1:0] sft = 2'b0;

always @ (posedge clk) sft <= (sft << 1) | snt;

always @ (posedge clk) cnt <= cnt + sft;

endmodule

