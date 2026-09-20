/*

Title: UART top module
Designer: AFIR Hachemi
Affiliation: University of Blida 1 - CDTA

UART Information:
  Baudrate: 115200
  Frame shape: 1'b start | 8'b data LSB first | 1'b stop
  Parity: N/A
*/

module uart_top (

  input wire clk,
  input wire rst,
  input wire [7:0] tx_in,
  input wire rx_in,
  input wire start,

  output wire [7:0] rx_out,
  output wire tx_out,

  output wire busy,
  output wire rx_done

);

  wire tick;

  uart_tx u_uart_tx (
    .clk (clk),
    .rst (rst),
    .tick (tick),
    .data_in (tx_in),
    .start (start),
    .busy (busy),
    .serial_out (tx_out)
  );

  uart_rx u_uart_rx (
    .clk (clk),
    .rst (rst),
    .tick (tick),
    .rx (rx_in),
    .rx_data (rx_out),
    .rx_done (rx_done)
  );

  baud u_baud_gen (
    .clk (clk),
    .rst (rst),
    .tick (tick)
  );
  
endmodule
