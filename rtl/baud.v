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
    parameter CLK_freq  = 50000000, 
    parameter BAUD_RATE = 115200    // Target Baud Rate
)(
    input  wire clk,   
    input  wire rst, // Active-low 
    output wire tick_baud,
    output wire tick_16x
);
    localparam N = CLK_freq / BAUD_RATE;
    localparam COUNTER_WIDTH1 = $clog2(N);
    
    localparam M = CLK_freq / (16 * BAUD_RATE);
    localparam COUNTER_WIDTH2 = $clog2(M);

    reg [COUNTER_WIDTH1-1:0] count_reg1;
    reg [COUNTER_WIDTH2-1:0] count_reg2;

    always @(posedge clk or negedge rst) begin
        if (!rst) 
        begin
            count_reg1 <= {COUNTER_WIDTH1{1'b0}};
            count_reg2 <= {COUNTER_WIDTH2{1'b0}};
        end 
        else begin
            if (count_reg1 == N - 1 )
                count_reg1 <= {COUNTER_WIDTH1{1'b0}};
            else
                count_reg1 <= count_reg1 + 1'b1;

           if (count_reg2 == M - 1 )
                count_reg2 <= {COUNTER_WIDTH2{1'b0}};
            else
                count_reg2 <= count_reg2 + 1'b1;
         end
    end

    assign tick_baud = (count_reg1 == N - 1);
    assign tick_16x  = (count_reg2 == M - 1);
endmodule