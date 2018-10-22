module sseg_dcd (
  input  wire  [31:0] data,
  output logic [63:0] seg
);

  always_comb begin
    int i;

    for (i = 0; i < 8; i += 1) begin
      case (data[i*4+:4])
        4'h0:    seg[i*8+:8] = 8'h7e;
        4'h1:    seg[i*8+:8] = 8'h30;
        4'h2:    seg[i*8+:8] = 8'h6d;
        4'h3:    seg[i*8+:8] = 8'h79;
        4'h4:    seg[i*8+:8] = 8'h33;
        4'h5:    seg[i*8+:8] = 8'h5b;
        4'h6:    seg[i*8+:8] = 8'h5f;
        4'h7:    seg[i*8+:8] = 8'h70;
        4'h8:    seg[i*8+:8] = 8'h7f;
        4'h9:    seg[i*8+:8] = 8'h7b;
        4'ha:    seg[i*8+:8] = 8'h77;
        4'hb:    seg[i*8+:8] = 8'h1f;
        4'hc:    seg[i*8+:8] = 8'h4e;
        4'hd:    seg[i*8+:8] = 8'h3d;
        4'he:    seg[i*8+:8] = 8'h4f;
        4'hf:    seg[i*8+:8] = 8'h47;
        default: seg[i*8+:8] = 8'h0;
    endcase
  end
end

endmodule
