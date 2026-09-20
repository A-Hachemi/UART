/*

Title: UART RX module testbunch
Designer: Guerrout adem
Affiliation: University of Blida 1 - CDTA

UART Information:
  Baudrate: 115200
  Frame shape: 1'b start | 8'b data LSB first | 1'b stop
  Parity: N/A
*/


`timescale 1ns/1ps

module uart_rx_alone_tb;

    //Inputs to uut 
    reg clk = 0;
    reg rst = 0;
    reg rx  = 1; // Idle state
    reg tick = 0;

    //Outputs from uut
    wire [7:0] rx_data;
    wire rx_done;

    //50MHz clk
    always #10 clk = ~clk;

  
    uart_rx uut (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .tick(tick),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

    // Generates a 1-clock-cycle pulse every 160ns to simulate 'tick'
    always begin
        #140;
        tick = 1;
        #20; 
        tick = 0;
    end

    //  Task to Send 1 Serial Bit (Holds 'rx' for 16 ticks)
    task send_bit(input bit_val);
        integer i;
        begin
            rx = bit_val;
            for (i = 0; i < 16; i = i + 1) begin
                @(posedge tick); // Wait for the next tick pulse
            end
        end
    endtask

    // --- Test Sequence ---
    initial begin
        // Setup GTKWave dump file
        $dumpfile("rx_alone.vcd");
        $dumpvars(0, uart_rx_alone_tb);

        // Reset
        rst = 0;
        #40 rst = 1;
        #100;

        $display("[%0t ns] --- Test 1: Sending ASCII 'A' (0x41) ---", $time);

        // 1. Start Bit (0)
        send_bit(0);

        // 2. 8 Data Bits (LSB First for 0x41 = 8'b01000001)
        send_bit(1); // Bit 0 (LSB)
        send_bit(0); 
        send_bit(0); 
        send_bit(0); 
        send_bit(0); 
        send_bit(0); 
        send_bit(1); 
        send_bit(0); // Bit 7 (MSB)

        // 3. Stop Bit (1)
        send_bit(1);

        // Idle time between frames
        #1000;

        $display("[%0t ns] Simulation finished successfully!", $time);
        $finish;
    end

    // --- Self-Checking Monitor ---
    always @(posedge clk) begin
        if (rx_done) begin
            $display("[%0t ns] SUCCESS: Received Byte = 0x%h ('%c')", $time, rx_data, rx_data);
        end
    end

endmodule