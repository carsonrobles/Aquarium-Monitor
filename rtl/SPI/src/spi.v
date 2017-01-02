
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
    input  wire       req,                          // request to send byte

    input  wire [7:0] dat,                          // byte to send

    output reg        sclk = 1'b0,                  // serial clock
    output reg        ss   = 1'b1,                  // slave select
    output wire       sdo,                          // serial data out

    output wire       snt                           // high when full byte has been sent
);

/* --- clock --- */

// clock divider to half system clock
always @ (posedge clk) begin
    if (fsm != `ST_RUN) sclk <= 1'b0;               // serial clock only operates in RUN state
    else                sclk <= ~sclk;
end

/* --- clock --- */

/* --- data --- */

reg [2:0] scnt  = 3'h0;                             // data shift count
reg [7:0] dat_r = 8'h0;                             // data register to be shifted out

assign sdo = dat_r[7];                              // sdo is MSB of dat_r (shifted left)
assign snt = (fsm == `ST_END);                      // set high when full byte sent

always @ (posedge clk) begin
    if (fsm_d == `ST_RUN || fsm == `ST_RUN) ss <= 1'b0;
    else    ss <= 1'b1;
end

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
always @ (posedge clk)
    if (~sclk) fsm <= fsm_d;

// combinatorial state change logic
always @ (*) begin
    case (fsm)
        `ST_IDL:
            if (req) fsm_d = `ST_RUN;               // begin running when request issued
            else     fsm_d = `ST_IDL;               // stay in idle if no request
        `ST_RUN:
            if (&scnt) fsm_d = `ST_END;             // if full byte sent, finish
            else       fsm_d = `ST_RUN;             // stay running if not yet sent
        `ST_END:
            if (~req) fsm_d = `ST_IDL;              // back to idle after finish
            else      fsm_d = `ST_END;              // stay in end until request is pulled low
        default:
            fsm_d = `ST_IDL;                        // send to idle in case of invalid state
    endcase
end

/* --- FSM --- */

endmodule

