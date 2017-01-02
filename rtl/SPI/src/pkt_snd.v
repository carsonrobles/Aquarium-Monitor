
/*
 * Carson Robles
 * Jan 2, 2017
 *
 * uses generic 1-byte SPI module
 * to send 1 packet (16 bits)
 */

// fsm states
`define ST_IDL 2'b00                                    // idle state
`define ST_END 2'b01                                    // finished state
`define ST_ADR 2'b10                                    // send address state
`define ST_DAT 2'b11                                    // send content state

module pkt_snd (
    input  wire        clk,                             // system clock
    input  wire        preq,                            // packet send request

    input  wire [15:0] pkt,                             // 16 bit packet to be sent

    output wire        sclk,                            // serial clock
    output wire        load,                            // load latch
    output wire        sdo                              // serial data out
);

reg       req = 1'b0;                                   // request data send
reg [7:0] snd = 8'h0;                                   // byte to send

wire ss;                                                // slave select (not used)
wire snt;                                               // high when full byte has been sent

// instantiate SPI module
spi spi_sseg (
    .clk  (clk ),
    .req  (req ),
    .dat  (snd ),
    .sclk (sclk),
    .ss   (ss  ),
    .sdo  (sdo ),
    .snt  (snt )
);

/* --- PKT LOGIC --- */

reg [7:0] addr = 8'h0;                                  // address portion of packet
reg [7:0] cont = 8'h0;                                  // content portion of packet

always @ (posedge clk) begin
    if (fsm == `ST_IDL) begin
        addr <= pkt[15:8];                              // latch address portion of packet
        cont <= pkt[ 7:0];                              // latch content portion of packet
    end
end

always @ (posedge clk) begin
    if (fsm_d == `ST_ADR)      snd <= addr;             // in addr state send address
    else if (fsm_d == `ST_DAT) snd <= cont;             // in data state send content
end

/* --- PKT LOGIC --- */

/* --- REQUEST LOGIC --- */

always @ (posedge clk) begin
    if (fsm == `ST_ADR || fsm == `ST_DAT) begin
        if (req & snt)       req <= 1'b0;               // if req & snt, end current request
        //else if (~req & snt) req <= 1'b1;               // if ~req & snt, submit new request
        else                 req <= 1'b1;
    end
end

/* --- REQUEST LOGIC --- */

/* --- FSM --- */

reg [1:0] fsm = `ST_IDL;                                // current state
reg [1:0] fsm_d;                                        // next state

// state assignment
always @ (posedge clk) fsm <= fsm_d;

// combinatorial state change logic
always @ (*) begin
    case (fsm)
        `ST_IDL:
            if (preq) fsm_d = `ST_ADR;                  // switch to send addr on request
            else      fsm_d = `ST_IDL;
        `ST_ADR:
            if (req & snt) fsm_d = `ST_DAT;             // switch to send data on first done state
            else           fsm_d = `ST_ADR;
        `ST_DAT:
            if (req & snt) fsm_d = `ST_END;             // finish upon final done state
            else           fsm_d = `ST_DAT;
        `ST_END:
            if (~preq) fsm_d = `ST_IDL;                 // switch to idle when request is low
            else       fsm_d = `ST_END;
        default:
            fsm_d = `ST_IDL;                            // send to idle in case of invalid state
    endcase
end

/* --- FSM --- */

endmodule

