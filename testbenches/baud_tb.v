`timescale 1ns/1ps

module baud_tb;

    reg clk = 0;
    reg rst;
    wire tick;

    // Instantiate with smaller parameters for fast simulation viewing
    // M = 50000000 / (16 * 115200) = 27 clock ticks per baud pulse
    baud #(
        .CLK_freq(50000000),
        .BAUD_RATE(115200)
    ) uut (
        .clk(clk),
        .rst(rst),
        .tick(tick)
    );

    // 50MHz clock generation 
    always #10 clk = ~clk;

    initial begin
        // --- GTKWave VCD Setup ---
        $dumpfile("baud_gen.vcd");
        $dumpvars(0, baud_tb);

        // --- Test Sequence ---
        rst = 0;

        // Apply Reset
        #20 rst = 1;

        // Run simulation long enough to capture multiple tick pulses
        #2000;

        $display("Simulation complete. Open GTKWave to inspect baud_gen.vcd");
        $finish;
    end

endmodule
