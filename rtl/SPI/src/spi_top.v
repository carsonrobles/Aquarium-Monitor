
module spi_top (
    input  wire clk,
    input  wire rst,

    output wire sclk,
    output wire load,
    output wire sdo
);

reg  [22:0] cnt = 23'h0;
reg  [31:0] dat = 32'h0;
wire [63:0] seg;

sseg_driver sseg (
    .clk  (clk ),
    //.seg  (64'h7e306d79335b5f70),
    .seg  (seg ),
    .sclk (sclk),
    .load (load),
    .sdo  (sdo )
);

sseg_dcd dcd (
    .din  (dat),
    .dout (seg)
);

always @ (posedge clk or posedge rst) begin
    if (rst) begin
        cnt <= 23'h0;
        dat <= 32'h0;
    end else begin
        cnt <= cnt + 23'h1;

        if (&cnt) dat <= dat + 32'h1;
    end
end

endmodule

