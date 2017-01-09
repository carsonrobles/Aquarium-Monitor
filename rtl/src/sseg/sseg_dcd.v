
/*
 * Carson Robles
 * Jan 5, 2017
 *
 * decodes 32 bit number to 64 bit segments
 */

module sseg_dcd (
    input  wire [31:0] dat,                             // 32 bit number to be displayed
    output reg  [63:0] seg                              // corresponding segments to light up
);

genvar g;

generate for (g = 0; g < 8; g = g + 1) begin : digit    // generate this for all 8 digits
    always @ (*) begin
        case (dat[g*4+:4])                              // converts 4 bit number to 8 segments
            4'h0:    seg[g*8+:8] = 8'h7e;
            4'h1:    seg[g*8+:8] = 8'h30;
            4'h2:    seg[g*8+:8] = 8'h6d;
            4'h3:    seg[g*8+:8] = 8'h79;
            4'h4:    seg[g*8+:8] = 8'h33;
            4'h5:    seg[g*8+:8] = 8'h5b;
            4'h6:    seg[g*8+:8] = 8'h5f;
            4'h7:    seg[g*8+:8] = 8'h70;
            4'h8:    seg[g*8+:8] = 8'h7f;
            4'h9:    seg[g*8+:8] = 8'h7b;
            /*4'ha:    seg[g*8+:8] = 8'h77;
            4'hb:    seg[g*8+:8] = 8'h1f;
            4'hc:    seg[g*8+:8] = 8'h4e;
            4'hd:    seg[g*8+:8] = 8'h3d;
            4'he:    seg[g*8+:8] = 8'h4f;
            4'hf:    seg[g*8+:8] = 8'h47;*/
            default: seg[g*8+:8] = 8'h0;
        endcase
    end
end endgenerate

endmodule

