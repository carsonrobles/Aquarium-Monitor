
/*
 * Carson Robles
 * Jan 2, 2017
 *
 * uses packet sender module to communicate with
 * MAX7219 LED driver chip
 */

// fsm states
`define ST_DCD 3'b000                                   // set decode state
`define ST_INT 3'b001                                   // set intensity state
`define ST_SCN 3'b010                                   // set scan state
`define ST_TST 3'b011
`define ST_WAK 3'b100                                   // wake up state
`define ST_GET 3'b101                                   // latch data state
`define ST_DIG 3'b110                                   // write digit state
`define ST_INC 3'b111                                   // increment address

module sseg_drv (
    input  wire        clk,                             // system clock

    input  wire [63:0] seg,                             // segments to be displayed

    output wire        sclk,                            // serial clock
    output wire        load,                            // load data latch
    output wire        sdo                              // serial data out
);

reg         preq =  1'b0;                               // packet send request
wire [15:0] pkt;

wire psnt;                                              // high when packet has been sent

// instantiate packet sender
pkt_snd snd (
    .clk  (clk ),
    .preq (preq),
    .pkt  (pkt ),
    .sclk (sclk),
    .load (load),
    .sdo  (sdo ),
    .psnt (psnt)
);

/* --- SETUP LOGIC --- */

always @ (posedge clk) begin
    if (preq & psnt) preq <= 1'b0;                      // if both high, drop request
    else             preq <= 1'b1;                      // issue new request/hold request
end

/* --- SETUP LOGIC --- */

/* --- DATA LATCH --- */

reg [63:0] seg_r = 64'h0;                               // internal segment register

always @ (posedge clk) begin
    if (fsm == `ST_GET) seg_r <= seg;                   // latch new set of segs in get state
end

/* --- DATA LATCH --- */

/* --- PACKET LOGIC --- */

reg [3:0] addr = 4'h0;                                  // 4 bit register address
reg [7:0] cont = 8'h0;                                  // 8 bit register content

assign pkt = {4'h0, addr, cont};                        // packet composed of addr and cont

always @ (posedge clk) begin
    if (fsm == `ST_DCD) begin                           // set decode address and content
        addr <= 4'h9;
        cont <= 8'h0;
    end else if (fsm == `ST_INT) begin                  // set intensity address and content
        addr <= 4'ha;
        cont <= 8'h7;
    end else if (fsm == `ST_SCN) begin                  // set scan address and content
        addr <= 4'hb;
        cont <= 8'h7;
    end else if (fsm == `ST_TST) begin                  // set test mode address and content
        addr <= 4'hf;
        cont <= 8'h0;
    end else if (fsm == `ST_WAK) begin                  // set shutdown address and content
        addr <= 4'hc;
        cont <= 8'h1;
    end else if (fsm == `ST_GET) begin                  // reset address
        addr <= 4'h0;
    end else if (fsm == `ST_DIG) begin                  // get corresponding segments for addr
        case (addr)
            4'h0:   cont <= seg_r[ 7: 0];
            4'h1:   cont <= seg_r[15: 8];
            4'h2:   cont <= seg_r[23:16];
            4'h3:   cont <= seg_r[31:24];
            4'h4:   cont <= seg_r[39:32];
            4'h5:   cont <= seg_r[47:40];
            4'h6:   cont <= seg_r[55:48];
            4'h7:   cont <= seg_r[63:56];
            default cont <= 4'h0;
        endcase
    end else if (fsm == `ST_INC) begin                  // inrement address for next digit
        addr <= addr + 4'h1;
    end
end

/* --- PACKET LOGIC --- */

/* --- FSM --- */

reg [2:0] fsm = `ST_DCD;                                // current state, start in decode
reg [2:0] fsm_d;                                        // next state

// state assignment
always @ (posedge clk) fsm <= fsm_d;

// combinatorial state change logic
always @ (*) begin
    case (fsm)
        `ST_DCD:
            if (preq & psnt) fsm_d = `ST_INT;           // change when packet sent
            else             fsm_d = `ST_DCD;
        `ST_INT:
            if (preq & psnt) fsm_d = `ST_SCN;           // change when packet sent
            else             fsm_d = `ST_INT;
        `ST_SCN:
            if (preq & psnt) fsm_d = `ST_TST;           // change when packet sent
            else             fsm_d = `ST_SCN;
        `ST_TST:
            if (preq & psnt) fsm_d = `ST_WAK;           // change when packet sent
            else             fsm_d = `ST_TST;
        `ST_WAK:
            if (preq & psnt) fsm_d = `ST_GET;           // change when packet sent
            else             fsm_d = `ST_WAK;
        `ST_GET:
            fsm_d = `ST_DIG;                            // switch to send digit state
        `ST_DIG:
            if (preq & psnt)                            // wait for packet sent
                if (addr == 4'h8) fsm_d = `ST_GET;      // if address reaches 8th digit, relatch
                else              fsm_d = `ST_INC;      // otherwise continue incrementing addr
            else                  fsm_d = `ST_DIG;
        `ST_INC:
            fsm_d = `ST_DIG;                            // go back for next digit send
        default:
            fsm_d = `ST_DCD;                            // in case of invalid state send to DCD
    endcase
end

/* --- FSM --- */

endmodule

