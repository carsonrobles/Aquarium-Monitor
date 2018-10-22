module spi_pkt_tb;

  logic        clk = '1;
  logic        rst = '0;

  logic [15:0] pkt = '0;
  logic        vld =  0;
  wire         rdy;

  wire         sclk;
  wire         sdo;
  wire         ss;

  spi_pkt dut (
    .clk  (clk),
    .rst  (rst),
    .pkt  (pkt),
    .vld  (vld),
    .rdy  (rdy),
    .sclk (sclk),
    .sdo  (sdo),
    .ss   (ss)
  );

  always_latch clk <= #5 ~clk;

  initial begin
    @ (posedge clk);
    rst <= 1;

    @ (posedge clk);
    rst <= 0;
    pkt <= 16'habcd;
    vld <= 1;

    while (~(vld & rdy))
      @ (posedge clk);

    vld <= 0;
  end

endmodule
