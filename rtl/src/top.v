
module top (
    input  wire       clk,
    input  wire       rst,

    input  wire       btn_u,
    input  wire       btn_d,

    output wire [2:0] rgb,

    output wire       sclk,
    output wire       load,
    output wire       sdo
);

rgb_drv rgb_d (
    .clk   (clk ),
    .rst_n (~rst),
    .rgb   (rgb )
);

reg  [15:0] dat = 16'h0;
reg  [15:0] psh = 16'h0;
wire [63:0] seg;

wire [31:0] snd = {dat, psh};

reg [15:0] cnt = 16'h0;

always @ (posedge clk or posedge rst) begin
    if (rst) cnt <= 16'h0;
    else     cnt <= cnt + 16'h1;
end

always @ (posedge clk or posedge rst) begin
    if (rst)       dat <= 16'h0;
    else if (&cnt) dat <= dat + 16'h1;
end

sseg_dcd dcd (
    .dat (snd),
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
    .sig_i (~btn_u ),
    .sig_o (btn_u_d)
);

sig_deb deb_d (
    .clk   (clk    ),
    .sig_i (~btn_d ),
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
    if (rst) psh <= 16'h0;
    else begin
        if (btn_u_e)      psh <= psh + 16'h1;
        else if (btn_d_e) psh <= psh - 16'h1;
    end
end

endmodule

