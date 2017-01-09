
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

reg [23:0] cnt = 24'h0;

always @ (posedge clk or posedge rst) begin
    if (rst) cnt <= 24'h0;
    else     cnt <= cnt + 24'h1;
end

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

reg [7:0] tmp_s = 8'h0;
reg [7:0] tmp_a = 8'h0;

wire [11:0] bcd_1;
wire [11:0] bcd_2;

wire [63:0] seg;

sseg_dcd dcd (
    .dat ({4'hf, bcd_1[7:0], 8'hff, bcd_2[7:0], 4'hf}),
    .seg (seg)
);

sseg_drv drv (
    .clk  (clk ),
    .seg  (seg ),
    .sclk (sclk),
    .load (load),
    .sdo  (sdo )
);

bcd b_1 (
    .number (tmp_s),
    .hundreds (bcd_1[11:8]),
    .tens (bcd_1[7:4]),
    .ones (bcd_1[3:0])
);

bcd b_2 (
    .number (tmp_a),
    .hundreds (bcd_2[11:8]),
    .tens (bcd_2[7:4]),
    .ones (bcd_2[3:0])
);

always @ (posedge clk or posedge rst) begin
    if (rst) tmp_s <= 8'h0;
    else begin
        if (btn_u_e)      tmp_s <= tmp_s + 8'h1;
        else if (btn_d_e) tmp_s <= tmp_s - 8'h1;
    end
end

always @ (posedge clk or posedge rst) begin
    if (rst)                        tmp_a <= 8'h0;
    else if (&cnt && tmp_a < tmp_s) tmp_a <= tmp_a + 8'h1;
    else if (&cnt && tmp_a > tmp_s) tmp_a <= tmp_a - 8'h1;
end

assign rgb[0] = ~(tmp_a < tmp_s);
assign rgb[1] = ~(tmp_a == tmp_s);
assign rgb[2] = ~(tmp_a > tmp_s);

endmodule

