/*

Title: UART RX module
Designer: Guerrout adem
Affiliation: University of Blida 1 - CDTA

UART Information:
  Baudrate: 115200
  Frame shape: 1'b start | 8'b data LSB first | 1'b stop
  Parity: N/A
*/



module uart_rx (
   input wire clk,
   input wire rst,
   input wire rx,
   input wire tick,
   output reg [7:0] rx_data,
   output reg rx_done
);
   // states encoding
   localparam IDLE = 2'b00;
   localparam START = 2'b01;
   localparam DATA = 2'b10;
   localparam STOP = 2'b11;
   reg [1:0] state;
   
   //internal counters
   
   reg [3:0] tick_reg;
   reg [2:0] bit_reg;
   reg [7:0] data_reg;
   
   reg rx_sync1 , rx_sync2;
   
   always @(posedge clk or negedge rst )
   begin
   if (!rst) begin 
      rx_sync1 <= 1'b1;
      rx_sync2 <= 1'b1;
   end 
   else begin
      rx_sync1 <=rx;
      rx_sync2 <=rx_sync1;
   end
   end
   
   // FSM State Register & Next State Logic
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            state    <= IDLE;
            tick_reg <= 4'b0;
            bit_reg  <= 3'b0;
            data_reg <= 8'b0;
            rx_data  <= 8'b0;
            rx_done  <= 1'b0;
        end else begin
            // Default: rx_done is a 1-cycle pulse, so clear it every clock cycle
            rx_done <= 1'b0;

        case (state)
                // IDLE: Wait for start bit
             IDLE: begin
                    if (rx_sync2 == 1'b0) begin
                        state    <= START;
                        tick_reg <= 4'b0;
                    end
                end
                //START: take midpoint of start bit
             START: begin
                    if (tick) begin
                        if (tick_reg == 4'd7) begin
                            state    <= DATA;
                            tick_reg <= 4'b0;
                            bit_reg  <= 3'b0; // Reset bit counter (0 to 7)
                        end else begin
                            tick_reg <= tick_reg + 1'b1;
                        end
                    end
                end

                //DATA: Sample 8 data bits, each 16 ticks 
             DATA: begin
                    if (tick) begin
                        if (tick_reg == 4'd15) begin
                            tick_reg <= 4'b0;
                            
                            // Shift incoming bit into MSB (LSB received first)
                            data_reg <= {rx_sync2, data_reg[7:1]};

                            if (bit_reg == 3'd7) begin
                                state <= STOP; // Received all 8 bits
                            end else begin
                                bit_reg <= bit_reg + 1'b1;
                            end
                        end else begin
                            tick_reg <= tick_reg + 1'b1;
                        end
                    end
                end

                // STOP: Wait 16 ticks for the stop bit
             STOP: begin
                    if (tick) begin
                        if (tick_reg == 4'd15) begin
                            state   <= IDLE;      // Back to IDLE
                            rx_data <= data_reg;  // Output final byte
                            rx_done <= 1'b1;      // Flag data ready!
                        end else begin
                            tick_reg <= tick_reg + 1'b1;
                        end
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule
