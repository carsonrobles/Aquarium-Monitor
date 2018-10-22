module spi_pkt (
  input  wire         clk,
  input  wire         rst,

  input  wire  [15:0] pkt,
  input  wire         vld,
  output wire         rdy,

  output wire         sclk,
  output wire         sdo,
  output wire         ss
);

  enum {
    IDLE,
    MSB_SEND,
    MSB_WAIT,
    LSB_SEND,
    LSB_WAIT
  } fsm = IDLE, fsm_d;

  logic [7:0] spi_data;
  wire        spi_vld  = (fsm == MSB_SEND || fsm == LSB_SEND);
  wire        spi_rdy;
  wire        spi_ok   = spi_vld & spi_rdy;

  // instantiate spi communication core
  spi spi_i (
    .clk  (clk),
    .data (spi_data),
    .vld  (spi_vld),
    .rdy  (spi_rdy),
    .sclk (sclk),
    .sdo  (sdo)
  );

  logic [15:0] pkt_r = '0;

  always_ff @ (posedge clk) begin
    if (rst)
      pkt_r <= '0;
    else if (fsm == IDLE)
      pkt_r <= pkt;
  end

  assign rdy = (fsm == IDLE);
  assign ss  = (fsm == IDLE);

  always_comb begin
    if (fsm == MSB_SEND)
      spi_data = pkt_r[15:8];
    else if (fsm == LSB_SEND)
      spi_data = pkt_r[ 7:0];
    else
      spi_data = '0;
  end

  // fsm
  always_ff @ (posedge clk) begin
    fsm <= (rst) ? IDLE : fsm_d;
  end

  always_comb begin
    case (fsm)
      IDLE    : fsm_d = (vld & rdy) ? MSB_SEND : IDLE;
      MSB_SEND: fsm_d = (spi_ok )   ? MSB_WAIT : MSB_SEND;
      MSB_WAIT: fsm_d = (spi_rdy)   ? LSB_SEND : MSB_WAIT;
      LSB_SEND: fsm_d = (spi_ok )   ? LSB_WAIT : LSB_SEND;
      LSB_WAIT: fsm_d = (spi_rdy)   ? IDLE     : LSB_WAIT;
      default : fsm_d = IDLE;
    endcase
  end

endmodule
