
module sseg_spi_wrap (
    input  wire       clk,

    output wire       sclk,
    output wire       sdo,

    output wire [1:0] led
);

wire       en = 1'b1;
wire [7:0] dat = data[0];

wire       done;

spi spi_sseg (
    .clk  (clk ),
    .en   (en  ),
    .dat  (dat ),
    .sclk (sclk),
    .sdo  (sdo ),
    .done (done)
);

assign led = {sclk, sdo};

reg [7:0] data [0:9];

initial begin
    data[0] <= 8'h00;

    data[1] <= 8'h0c;
    data[2] <= 8'h01;

    data[3] <= 8'h0f;
    data[4] <= 8'h01;

    /*data[2] <= 8'h09;
    data[3] <= 8'h00;

    data[4] <= 8'h0a;
    data[5] <= 8'h0f;

    data[6] <= 8'h0b;
    data[7] <= 8'h07;

    data[8] <= 8'h0f;
    data[9] <= 8'h01;*/
end

integer i;

always @ (posedge clk) begin
    if (done) begin

        for (i = 0; i < 9; i = i + 1) begin
            data[i] <= data[i + 1];
        end

        data[9] <= 8'h00;
    end
end

endmodule

