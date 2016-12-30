
/*
 * Carson Robles
 * Dec 27, 2016
 *
 * implementation of SPI communication protocol
 * sends one byte (dat) when enabled
 * data is sent from MSB to LSB
 */

// fsm states
`define ST_IDL 2'b00                                // idle state
`define ST_RUN 2'b01                                // running state
`define ST_END 2'b10                                // finished state

module spi (
    input  wire       clk,                          // system clock
    input  wire       en,                           // enable communication

    input  wire [7:0] dat,                          // byte to send

    output reg        sclk = 1'b0,                  // serial clock
    output wire       sdo,                          // serial data out

    output wire       done                          // high when full byte has been sent
);

/* --- clock --- */

// clock divider to half system clock
always @ (posedge clk) begin
    if (!en) sclk <= 1'b0;                          // enable acts as synchronous active low reset
    else     sclk <= ~sclk;
end

/* --- clock --- */

/* --- data --- */

reg [2:0] scnt  = 3'h0;                             // data shift count
reg [7:0] dat_r = 8'h0;                             // data register to be shifted out

assign sdo  = dat_r[7];                             // sdo is MSB of dat_r (shifted left)
assign done = (fsm == `ST_END);                     // set done high when full byte sent

always @ (posedge clk) begin
    if (fsm == `ST_IDL) begin
        scnt  <= 3'h0;                              // reset scnt at idle
        dat_r <= dat;                               // when idle, latch dat to dat_r
    end else if (sclk) begin
        scnt  <= scnt + 3'h1;                       // increment shift count
        dat_r <= dat_r << 1;                        // shift bit out when sclk is high (falling)
    end
end

/* --- data --- */

/* --- FSM --- */

reg [1:0] fsm = `ST_IDL;                            // current state
reg [1:0] fsm_d;                                    // next state

// state assignment
always @ (posedge clk) fsm <= fsm_d;

// combinatorial state change logic
always @ (*) begin
    case (fsm)
        `ST_IDL:
            if (en) fsm_d = `ST_RUN;                // begin running when enabled
            else    fsm_d = `ST_IDL;                // stay in idle if not enabled
        `ST_RUN:
            if (&scnt) fsm_d = `ST_END;             // if full byte sent, finish
            else       fsm_d = `ST_RUN;             // stay running if not yet sent
        `ST_END:
            fsm_d = `ST_IDL;                        // back to idle after finish
        default:
            fsm_d = `ST_IDL;                        // send to idle in case of invalid state
    endcase
end

/* --- FSM --- */

endmodule

