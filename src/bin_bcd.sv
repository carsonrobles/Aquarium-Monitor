module bin_bcd #(
  parameter integer N = 8
) (
  input  wire [N-1:0] bin,

  output wire [N+3:0] bcd
);

  localparam int DATA_BITS = 2*N+4;

  logic [DATA_BITS-1:0] data = '0;

  always_comb begin
    integer i, j;

    data = bin;

    for (i = N-1; i >= 0; i -= 1) begin
      for (j = N; j <= 2*N; j += 4)
        if (data[j+:4] >= 5) data[j+:4] = data[j+:4] + 3;

      data = data << 1;
    end
  end

  assign bcd = data[DATA_BITS-1:N];

endmodule
