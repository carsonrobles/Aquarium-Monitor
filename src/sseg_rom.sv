module sseg_rom (
  input  wire  [ 2:0] addr,

  output logic [15:0] data
);

  always_comb begin
    case (addr)
      3'h0:    data = 16'h0900;
      3'h1:    data = 16'h0a07;
      3'h2:    data = 16'h0b07;
      3'h3:    data = 16'h0f00;
      3'h4:    data = 16'h0c01;
      default: data = '0;
    endcase
  end

endmodule
