`timescale 1ns/1ps

module uart_tx_tb;

  reg clk;
  reg rst;
  reg [7:0] data_in;
  reg start;

  wire busy;
  wire serial_out;

  uart_tx dut(
    .clk(clk),
    .rst(rst),
    .data_in(data_in),
    .start(start),
    .busy(busy),
    .serial_out(serial_out)
  );

always #5 clk = ~clk;

initial begin
  clk = 1'b0;
end 

initial begin

  $dumpfile("sim/uart_tx_tb.vcd");
  $dumpvars(0, uart_tx_tb);

  rst = 1'b0;
  start = 1'b0;
  data_in = 8'b0;

  #20;

  rst = 1'b1;

  data_in = 8'b10110010;
  start = 1'b1;

  #10;
  start = 1'b0;

  #120;

  $finish;

end

endmodule
