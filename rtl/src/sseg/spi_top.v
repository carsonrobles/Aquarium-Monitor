
module spi_top (
    input  wire clk,
    input  wire rst,

    input  wire btn_d,
    input  wire btn_u,

    output wire sclk,
    output wire load,
    output wire sdo
);

reg  [15:0] cnt = 16'h0;
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
    .dat (dat),
    .seg (seg)
);

always @ (posedge clk or posedge rst) begin
    if (rst) begin
        cnt <= 16'h0;
        dat <= 32'h0;
    end else begin
        cnt <= cnt + 16'h1;

        if (&cnt) dat <= dat + 32'h1;
    end
end

endmodule

