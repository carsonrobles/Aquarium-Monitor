
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

module sseg_driver (
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
pkt_snd sndr (
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
    if (preq & psnt) preq <= 1'b0;
    else             preq <= 1'b1;
end

/* --- SETUP LOGIC --- */

/* --- DATA LATCH --- */

reg [63:0] seg_r;

always @ (posedge clk) begin
    if (fsm == `ST_GET) seg_r <= seg;
end

/* --- DATA LATCH --- */

/* --- PACKET LOGIC --- */

reg [3:0] addr = 4'h0;
reg [7:0] cont = 8'h0;

assign pkt = {4'h0, addr, cont};

always @ (posedge clk) begin
    if (fsm == `ST_DCD) begin
        addr <= 4'h9;
        cont <= 8'h0;
    end else if (fsm == `ST_INT) begin
        addr <= 4'ha;
        cont <= 8'hf;
    end else if (fsm == `ST_SCN) begin
        addr <= 4'hb;
        cont <= 8'h7;
    end else if (fsm == `ST_TST) begin
        addr <= 4'hf;
        cont <= 8'h0;
    end else if (fsm == `ST_WAK) begin
        addr <= 4'hc;
        cont <= 8'h1;
    end else if (fsm == `ST_GET) begin
        addr <= 4'h0;
    end else if (fsm == `ST_DIG) begin
        case (addr)
            4'h0: cont <= seg_r[ 7: 0];
            4'h1: cont <= seg_r[15: 8];
            4'h2: cont <= seg_r[23:16];
            4'h3: cont <= seg_r[31:24];
            4'h4: cont <= seg_r[39:32];
            4'h5: cont <= seg_r[47:40];
            4'h6: cont <= seg_r[55:48];
            4'h7: cont <= seg_r[63:56];
        endcase
    end else if (fsm == `ST_INC) begin
        addr <= addr + 4'h1;
    end
end

/* --- PACKET LOGIC --- */

/* --- FSM --- */

reg [2:0] fsm = `ST_DCD;
reg [2:0] fsm_d;

// state assignment
always @ (posedge clk) fsm <= fsm_d;

// combinatorial state change logic
always @ (*) begin
    case (fsm)
        `ST_DCD:
            if (preq & psnt) fsm_d = `ST_INT;
            else             fsm_d = `ST_DCD;
        `ST_INT:
            if (preq & psnt) fsm_d = `ST_SCN;
            else             fsm_d = `ST_INT;
        `ST_SCN:
            if (preq & psnt) fsm_d = `ST_TST;
            else             fsm_d = `ST_SCN;
        `ST_TST:
            if (preq & psnt) fsm_d = `ST_WAK;
            else             fsm_d = `ST_TST;
        `ST_WAK:
            if (preq & psnt) fsm_d = `ST_GET;
            else             fsm_d = `ST_WAK;
        `ST_GET:
            fsm_d = `ST_DIG;
        `ST_DIG:
            if (preq & psnt)
                if (addr == 4'h8) fsm_d = `ST_GET;
                else              fsm_d = `ST_INC;
            else                  fsm_d = `ST_DIG;
        `ST_INC:
            fsm_d = `ST_DIG;
        default:
            fsm_d = `ST_DCD;                            // in case of invalid state send to DCD
    endcase
end

/* --- FSM --- */

endmodule

