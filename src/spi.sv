module spi (
  input  wire        clk,

  input  wire  [7:0] data,
  input  wire        vld,
  output wire        rdy,

  output wire        sclk,
  output logic       sdo
);

  enum {
    IDLE,
    SEND
  } fsm = IDLE, fsm_d;

  wire div_clk;

  clk_div # (
    .N (3)
  ) div (
    .clk   (clk),
    .clk_o (div_clk)
  );

  assign sclk = (fsm == SEND) ? div_clk : 1;

  assign rdy = (fsm == IDLE);
  wire   ok  = vld & rdy;

  logic [1:0] sclk_sft   = '0;
  wire        sclk_pedge = ~sclk_sft[1] &  sclk_sft[0];
  wire        sclk_nedge =  sclk_sft[1] & ~sclk_sft[0];

  always_ff @ (posedge clk)
    sclk_sft <= (sclk_sft << 1) | sclk;

  logic [3:0] cnt = '0;

  always_ff @ (posedge clk) begin
    if (fsm != SEND) begin
      cnt <= '0;
    end else begin
      if (sclk_pedge) begin
        cnt <= cnt + 1;
      end
    end
  end

  logic [8:0] data_r = '0;

  always_ff @ (posedge clk) begin
    if (fsm == IDLE && ok) begin
      data_r <= data;
    end else if (sclk_nedge) begin
      data_r <= data_r << 1;
    end
  end

  always_comb sdo = data_r[8];

  // fsm
  always_ff @ (posedge clk) fsm <= fsm_d;

  always_comb begin
    case (fsm)
      IDLE    : fsm_d = (ok      ) ? SEND : IDLE;
      SEND    : fsm_d = (cnt == 8) ? IDLE : SEND;
      default : fsm_d = IDLE;
    endcase
  end

endmodule
