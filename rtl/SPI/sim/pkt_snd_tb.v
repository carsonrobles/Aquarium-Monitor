
module pkt_snd_tb;

reg        clk  =  1'b0;
reg        preq = 1'b0;
reg [15:0] pkt  = 16'h0;;

wire sclk;
wire load;
wire sdo;

pkt_snd sender (
    .clk  (clk ),
    .preq (preq),
    .pkt  (pkt ),
    .sclk (sclk),
    .load (load),
    .sdo  (sdo )
);

always #5 clk <= ~clk;

initial begin
    #30 pkt  = 16'habcd;
    #30 preq =  1'b1;
    #700 preq = 1'b0;
    pkt    = 16'h00ef;
    #20 preq = 1'b1;
end

endmodule

