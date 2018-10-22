module clk_div #(
  parameter int N = 2
) (
  input  wire  clk,
  output logic clk_o = 0
);

  logic [3:0] cnt = '0;

  always_ff @ (posedge clk) begin
    if (cnt < N)
      cnt <= cnt + 1;
    else
      cnt <= '0;
  end

  always_ff @ (posedge clk)
    if (cnt == N) clk_o <= ~clk_o;

endmodule
