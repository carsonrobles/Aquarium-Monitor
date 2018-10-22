
///////////////////////////////////
//
//  Carson Robles
//  Sep 12, 2016
//
//  debounces input signal
//
///////////////////////////////////

module sig_deb #(
    parameter CLKS_PER_SMPL = 16,                       /* 2^CLKS_PER_SMPL clock cycles per sample */
    parameter SMPL_CNT      = 4                         /* number of samples to produce valid signal */
) (
    input  wire clk,                                    /* clock signal */

    input  wire i_sig,                                  /* input signal to debounce */

    output wire o_sig                                   /* clean output signal */
);

    /* 2 flop synchronizer for async input, sig_s is synchronized input signal */
    reg  [ 1:0] sync  = 2'b00;
    wire        sig_s = sync[1];

    /* synchronize input signal */
    always @ (posedge clk) begin
        sync <= (sync << 1) | i_sig;
    end

    /* tck pulses for 1 clk when cnt reaches CLKS_PER_SMPL */
    reg  [CLKS_PER_SMPL - 1:0] cnt = {CLKS_PER_SMPL{1'b0}};
    wire                       tck = &cnt;

    /* increment count */
    always @ (posedge clk) begin
        if (~sig_s | tck) begin
            cnt <= {CLKS_PER_SMPL{1'b0}};
        end else begin
            cnt <= cnt + 'h1;
        end
    end

    /* shift reg to shift in sychronized input signal */
    reg  [SMPL_CNT - 1:0] shft  = {SMPL_CNT{1'b0}};

    /* shift in synchronized input */
    always @ (posedge clk) begin
        if (~sig_s)   shft <= {SMPL_CNT{1'b0}};
        else if (tck) shft <= (shft << 1) | sig_s;
    end

    /* assign clean output to full shift reg */
    assign o_sig = &shft;

endmodule