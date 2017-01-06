
/*
 * Carson Robles
 * Jan 5, 2017
 *
 * decodes 32 bit number to 64 bit segments
 */

module sseg_dcd (
    input  wire [31:0] din,
    output reg  [63:0] dout
);

genvar g;

generate for (g = 0; g < 8; g = g + 1) begin : digit
    always @ (*) begin
        case (din[g*4+:4])
            4'h0:    dout[g*8+:8] = 8'h7e;
            4'h1:    dout[g*8+:8] = 8'h30;
            4'h2:    dout[g*8+:8] = 8'h6d;
            4'h3:    dout[g*8+:8] = 8'h79;
            4'h4:    dout[g*8+:8] = 8'h33;
            4'h5:    dout[g*8+:8] = 8'h5b;
            4'h6:    dout[g*8+:8] = 8'h5f;
            4'h7:    dout[g*8+:8] = 8'h70;
            4'h8:    dout[g*8+:8] = 8'h7f;
            4'h9:    dout[g*8+:8] = 8'h7b;
            default: dout[g*8+:8] = 8'h0;
        endcase
    end
end endgenerate

endmodule

