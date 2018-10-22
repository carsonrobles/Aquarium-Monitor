module sseg_tb;

  logic        clk  = '1;
  logic        rst  = '0;

  logic [63:0] data = '0;
  logic        vld  = '0;
  wire         rdy;

  wire         sclk;
  wire         sdo;
  wire         ss;

  sseg dut (
    .clk  (clk),
    .rst  (rst),
    .data (data),
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
    rst  <= 0;
    data <= 64'hdeadbeefbeefface;
    vld  <= 1;

    while (~(vld & rdy))
      @ (posedge clk);

    vld <= 0;

    repeat (100) @ (posedge clk);
    rst <= 1;
    repeat ( 10) @ (posedge clk);
    rst <= 0;
    repeat ( 10) @ (posedge clk);
    vld  <= 1;

    while (~(vld & rdy))
      @ (posedge clk);

    vld <= 0;
  end

endmodule
