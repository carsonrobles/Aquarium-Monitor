
/*
 * Carson Robles
 * Jan 6, 2017
 *
 * test bench for signal debouncer
 */

module sig_deb_tb;

reg  clk   = 1'b0;
reg  sig_i = 1'b0;

wire sig_o;

sig_deb deb (
    .clk   (clk  ),
    .sig_i (sig_i),
    .sig_o (sig_o)
);

always #5 clk <= ~clk;

initial begin
    #30  sig_i = 1'b1;
    #2   sig_i = 1'b0;
    #2   sig_i = 1'b1;
    #2   sig_i = 1'b0;
    #2   sig_i = 1'b1;
    #2   sig_i = 1'b0;
    #5   sig_i = 1'b1;
    #800 sig_i = 1'b0;
    #5   sig_i = 1'b1;
end

endmodule

