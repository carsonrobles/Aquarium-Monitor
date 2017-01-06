
module top (
    input  wire clk,
    input  wire rst,

    input  wire btn_u,
    input  wire btn_d,

    output wire sclk,
    output wire load,
    output wire sdo
);

reg  [31:0] dat = 32'h0;
wire [63:0] seg;

sseg_dcd dcd (
    .dat (dat),
    .seg (seg)
);

sseg_drv drv (
    .clk  (clk ),
    .seg  (seg ),
    .sclk (sclk),
    .load (load),
    .sdo  (sdo )
);

wire btn_u_d;
wire btn_d_d;

wire btn_u_e = (bu_sft == 2'h1);
wire btn_d_e = (bd_sft == 2'h1);

reg  [1:0] bu_sft = 2'h0;
reg  [1:0] bd_sft = 2'h0;

sig_deb deb_u (
    .clk   (clk    ),
    .sig_i (~btn_u  ),
    .sig_o (btn_u_d)
);

sig_deb deb_d (
    .clk   (clk    ),
    .sig_i (~btn_d  ),
    .sig_o (btn_d_d)
);

always @ (posedge clk or posedge rst) begin
    if (rst) begin
        bu_sft <= 2'h0;
        bd_sft <= 2'h0;
    end else begin
        bu_sft <= (bu_sft << 1) | btn_u_d;
        bd_sft <= (bd_sft << 1) | btn_d_d;
    end
end

always @ (posedge clk or posedge rst) begin
    if (rst) dat <= 32'h0;
    else begin
        if (btn_u_e)      dat <= dat + 32'h1;
        else if (btn_d_e) dat <= dat - 32'h1;
    end
end

endmodule

