
/*
 * Carson Robles
 * Jan 6, 2017
 *
 * debounces a signal
 * outputs noise free version
 */

module sig_deb (
    input  wire clk,                                    // system clock

    input  wire sig_i,                                  // potentially noisy signal

    output wire sig_o                                   // clean, debounced signal
);

reg [ 3:0] sft =  4'h0;                                 // 4 bit shift register to clean noise
reg [15:0] cnt = 16'h0;                                 // 16 bit counter to induce enable pulse

assign sig_o = &sft;                                    // assign clean signal to full shift reg

always @ (posedge clk or negedge sig_i) begin
    if (!sig_i) cnt <= 16'h0;                           // reset counter on low sig_i
    else        cnt <= cnt + 16'h1;                     // increment counter while sig_i high
end

always @ (posedge clk or negedge sig_i) begin
    if (!sig_i)    sft <= 4'h0;                         // sig_i acts as active low async reset
    else if (&cnt) sft <= (sft << 1) | sig_i;           // shift in sig_i on enable pulse
end

endmodule

