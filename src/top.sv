module top (
  input  wire       CLK12MHZ,
  input  wire [1:0] BTN,

  output wire [1:0] LED,
  output wire [2:0] RGB,
  output wire [2:0] GPIO
);

  wire rst;

  sig_deb rst_deb (
    .clk   (CLK12MHZ),
    .i_sig (BTN[0]),
    .o_sig (rst)
  );

  logic [31:0] data = '0;
  wire  [35:0] bcd;

  bin_bcd #(
    .N (32)
  ) bin_bcd_i (
    .bin (data),
    .bcd (bcd)
  );

  wire [63:0] sseg_data;

  sseg_dcd sseg_dcd_i (
    .data (bcd),
    .seg  (sseg_data)
  );

  wire        sclk;
  wire        sdo;

  sseg sseg_i (
    .clk  (CLK12MHZ),
    .rst  (rst),
    .data (sseg_data),
    .vld  (&cnt),
    .rdy  ( ),
    .sclk (sclk),
    .sdo  (sdo),
    .ss   (GPIO[2])
  );

  assign GPIO[1:0] = {sdo, sclk};
  assign LED       = GPIO[1:0];

  logic [15:0] cnt = '0;

  always_ff @ (posedge CLK12MHZ) begin
    if (rst)
      cnt <= '0;
    else
      cnt <= cnt + 1;
  end

  always_ff @ (posedge CLK12MHZ) begin
    if (rst)
      data <= '0;
    else if (&cnt)
      data <= data + 1;
  end

  assign RGB = (rst) ? '1 : data[6:4];

endmodule
