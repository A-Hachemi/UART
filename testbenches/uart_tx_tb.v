`timescale 1ns/1ps

module uart_tx_tb;

  reg clk;
  reg rst;
  reg [7:0] data_in;
  reg start;
  reg tick;

  wire busy;
  wire serial_out;

  uart_tx dut(
    .clk(clk),
    .rst(rst),
    .tick(tick),
    .data_in(data_in),
    .start(start),
    .busy(busy),
    .serial_out(serial_out)
  );

integer count;

always #10 clk = ~clk;

always @(posedge clk) begin 
  if (count == 3) begin 
    tick <= 1'b1;
    count <= 0;
  end
  else begin 
    tick <= 1'b0;
    count <= count + 1;
  end
end

initial begin
  clk = 1'b0;
  tick = 1'b0;
  count = 0;
end 

initial begin

  $dumpfile("sim/uart_tx_tb.vcd");
  $dumpvars(0, uart_tx_tb);

  rst = 1'b0;
  start = 1'b0;
  data_in = 8'b0;

  #30;

  rst = 1'b1;

  data_in = 8'b10110010;
  start = 1'b1;

  #10;
  start = 1'b0;

  #1000;

  $finish;

end

endmodule
