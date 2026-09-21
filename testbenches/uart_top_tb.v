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

  // 50 MHz Clock
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

  // Clock & Reset Init
  initial begin 
    clk = 1'b0;
    rst = 1'b0;
    tx_in = 8'b0;
    start = 1'b0;
  end

  // Test Sequence
  initial begin
    $dumpfile("sim/uart_top_tb.vcd");
    $dumpvars(0, uart_top_tb);

    #25;
    rst = 1'b1;

    // Pulse START to transmit 0b10110010
    tx_in = 8'b10110010;
    start = 1'b1;
    #20;            // Held for 1 full clock cycle
    start = 1'b0;

    // Dynamically wait until RX finishes receiving the byte
    @(posedge rx_done);

    // Give 1 extra clock cycle for rx_out to stabilize
    @(posedge clk);

    if (rx_out == 8'b10110010)
      $display("[%0t ns] PASS: RX received %b correctly!", $time, rx_out);
    else
      $display("[%0t ns] FAIL: RX = %b, rx_done = %b", $time, rx_out, rx_done);

    #10000;
    $finish;
  end

endmodule
