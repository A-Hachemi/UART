/*

Title: UART baud generator testbunch
Designer: Guerrout adem
Affiliation: University of Blida 1 - CDTA

UART Information:
  Baudrate: 115200
  Frame shape: 1'b start | 8'b data LSB first | 1'b stop
  Parity: N/A
*/


`timescale 1ns/1ps

module baud_tb;

    reg clk = 0;
    reg rst;

    wire tick_baud;
    wire tick_16x;
    // DUT
    baud #(
        .CLK_freq(50000000),
        .BAUD_RATE(115200)
    ) uut (
        .clk(clk),
        .rst(rst),
        .tick_baud(tick_baud),
        .tick_16x(tick_16x)
    );
    
    always #10 clk = ~clk;     // 50 MHz clk

    initial begin

        // GTKWave VCD
        $dumpfile("baud_gen.vcd");
        $dumpvars(0, baud_tb);
        rst = 0; #20; rst = 1;
        #20000;// Run simulation

        $display("Simulation complete.");
        $finish;
    end

endmodule