
/*
 * Carson Robles
 * Jan 6, 2017
 *
 * driver for an rgb led
 */

module rgb_drv (
    input  wire       clk,                              // system clock
    input  wire       rst_n,                            // active low reset

    output wire [2:0] rgb                               // red, green, blue values, active low
);

/* --- COUNTER LOGIC --- */

reg [23:0] cnt = 24'h0;                                 // free running counter

always @ (posedge clk or negedge rst_n) begin
    if (!rst_n) cnt <= 24'h0;                           // reset counter
    else        cnt <= cnt + 24'h1;                     // otherwise increment
end

/* --- COUNTER LOGIC --- */

/* --- LED LOGIC --- */

reg [7:0] lvl_g = 8'hff;                                // green level
reg [7:0] lvl_b = 8'h00;                                // blue level

assign rgb[0] = 1'b1;
assign rgb[1] = cnt[23];
assign rgb[2] = ~cnt[23];


/* --- LED LOGIC --- */

endmodule

