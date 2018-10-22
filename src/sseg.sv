module sseg (
  input  wire         clk,
  input  wire         rst,

  input  wire  [63:0] data,
  input  wire         vld,
  output wire         rdy,

  output wire         sclk,
  output wire         sdo,
  output wire         ss
);

  localparam int BOOT_INST_CNT = 5;
  localparam int DIGIT_CNT     = 8;

  enum {
    IDLE,
    BOOT,
    DATA
  } fsm = IDLE, fsm_d;

  logic [15:0] data_pkt = '0;
  wire  [15:0] pkt      = (fsm == BOOT) ? boot_pkt : data_pkt;
  wire         pkt_vld  = (fsm != IDLE);
  wire         pkt_rdy;
  wire         pkt_ok   = pkt_vld & pkt_rdy;

  spi_pkt spi_pkt_i (
    .clk  (clk),
    .rst  (rst),
    .pkt  (pkt),
    .vld  (pkt_vld),
    .rdy  (pkt_rdy),
    .sclk (sclk),
    .sdo  (sdo),
    .ss   (ss)
  );

  // sseg boot logic
  logic [ 2:0] boot_addr = '0;
  wire  [15:0] boot_pkt;

  sseg_rom sseg_rom_i (
    .addr (boot_addr),
    .data (boot_pkt)
  );

  always_ff @ (posedge clk) begin
    if (rst || fsm != BOOT)
      boot_addr <= '0;
    else if (pkt_ok)
      boot_addr <= boot_addr + 1;
  end

  assign rdy = (fsm == IDLE);

  logic [63:0] data_r = '0;

  always_ff @ (posedge clk) begin
    if (rst)
      data_r <= '0;
    else if (vld & rdy)
      data_r <= data;
  end

  // digit select
  logic [3:0] dig_cnt = '0;

  always_ff @ (posedge clk) begin
    if (rst || fsm != DATA)
      dig_cnt <= '0;
    else if (pkt_ok)
      dig_cnt <= dig_cnt + 1;
  end

  always_comb begin
    case (dig_cnt)
      3'h0   : data_pkt[7:0] = data_r[ 7: 0];
      3'h1   : data_pkt[7:0] = data_r[15: 8];
      3'h2   : data_pkt[7:0] = data_r[23:16];
      3'h3   : data_pkt[7:0] = data_r[31:24];
      3'h4   : data_pkt[7:0] = data_r[39:32];
      3'h5   : data_pkt[7:0] = data_r[47:40];
      3'h6   : data_pkt[7:0] = data_r[55:48];
      3'h7   : data_pkt[7:0] = data_r[63:56];
      default: data_pkt[7:0] = '0;
    endcase
  end

  always_comb data_pkt[15:8] = {4'h0, dig_cnt};

  // fsm
  always_ff @ (posedge clk) begin
    fsm <= (rst) ? IDLE : fsm_d;
  end

  always_comb begin
    case (fsm)
      IDLE   : fsm_d = (vld & rdy)                  ? BOOT : IDLE;
      BOOT   : fsm_d = (boot_addr >= BOOT_INST_CNT) ? DATA : BOOT;
      DATA   : fsm_d = (dig_cnt   >=     DIGIT_CNT) ? IDLE : DATA;
      default: fsm_d = IDLE;
    endcase
  end

endmodule
