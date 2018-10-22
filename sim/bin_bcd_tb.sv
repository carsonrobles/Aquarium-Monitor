module bin_bcd_tb;

  logic [ 7:0] bin = '0;
  wire  [11:0] bcd;

  bin_bcd #(
    .N (8)
  ) dut8 (
    .bin (bin),
    .bcd (bcd)
  );

  wire [19:0] bcd16;

  bin_bcd #(
    .N (16)
  ) dut16 (
    .bin ({bin, bin}),
    .bcd (bcd16)
  );

  initial begin
    #10 bin = 8'hab;
    #10 bin = 8'ha2;
    #10 bin = 8'h96;
  end

endmodule
