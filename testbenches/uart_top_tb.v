`timescale 1ns/1ps

module uart_top_tb;

  reg clk;
  reg rst;
  reg [7:0] tx_in;
  wire rx_in;
  reg start;

  wire [7:0] rx_out;
  wire rx_done;

  wire tx_out;
  wire busy;

  always #10 clk = ~clk;

  assign rx_in = tx_out;

  uart_top uut (
      .clk (clk),
      .rst (rst),
      .tx_in (tx_in),
      .rx_in (rx_in),
      .start (start),
      .rx_out (rx_out),
      .rx_done (rx_done),
      .tx_out (tx_out),
      .busy (busy)
  );

  initial begin 
    clk = 1'b0;
    rst = 1'b0;
    tx_in = 8'b0;
    start = 1'b0;
  end

  initial begin

  $dumpfile("sim/uart_top_tb.vcd");
  $dumpvars(0, uart_top_tb);

  #25;

  rst = 1'b1;

  tx_in = 8'b10110010;
  start = 1'b1;

  #10;
  start = 1'b0;

  #100_000;

  if (rx_out == 8'b10110010)
    $display("PASS: RX received 10110010");

  else
    $display("FAIL: RX = %b, rx_done = %b", rx_out, rx_done);


  rst = 1'b0;
  tx_in = 8'b0;

  #100;

  $finish;

  end

endmodule
