/*

Title: UART baud generator
Designer: Guerrout adem
Affiliation: University of Blida 1 - CDTA

UART Information:
  Baudrate: 115200
  Frame shape: 1'b start | 8'b data LSB first | 1'b stop
  Parity: N/A
*/


module baud #(
    parameter CLK_freq  = 50000000, // 50 MHz default
    parameter BAUD_RATE = 115200    // Target Baud Rate
)(
    input  wire clk,   // System clock
    input  wire rst, // Active-low asynchronous reset
    output wire tick   // 16x Baud tick pulse
);

    // Calculate count threshold M = CLK_freq / (16 * BAUD_RATE)
    localparam M = CLK_freq / (16 * BAUD_RATE);
    localparam COUNTER_WIDTH = $clog2(M);

    reg [COUNTER_WIDTH-1:0] count_reg;

    always @(posedge clk or negedge rst) begin
        if (!rst) 
        begin
            count_reg <= {COUNTER_WIDTH{1'b0}};
        end 
        else begin
            if (count_reg == M - 1)
                count_reg <= {COUNTER_WIDTH{1'b0}};
            else
                count_reg <= count_reg + 1'b1;
        end
    end

    // Tick pulse goes HIGH for exactly one clock period when count reaches M-1
    assign tick = (count_reg == M - 1);

endmodule
