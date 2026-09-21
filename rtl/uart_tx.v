/*

Title: UART TX module
Designer: AFIR Hachemi
Affiliation: University of Blida 1 - CDTA

UART Information:
  Baudrate: 115200
  Frame shape: 1'b start | 8'b data LSB first | 1'b stop
  Parity: N/A
*/

module uart_tx (
  input wire clk,
  input wire rst,
  input wire tick,
  input wire [7:0] data_in,
  input wire start,

  output reg busy,
  output reg serial_out
);

localparam IDLE  = 2'b00;
localparam START = 2'b01;
localparam DATA  = 2'b10;
localparam STOP  = 2'b11;

reg [1:0] state;
reg [1:0] next_state;

reg [3:0] tick_count; // <-- ADDED: Counts 16 ticks (0 to 15) per bit
reg [2:0] bit_count;
reg [7:0] data_reg;

reg start_pending;

always @(posedge clk or negedge rst) begin
  if (!rst) begin
    state         <= IDLE;
    data_reg      <= 8'b0;
    bit_count     <= 3'b0;
    tick_count    <= 4'b0;
    start_pending <= 1'b0;
  end
  else begin 
    if (!busy && start && !start_pending) begin 
      start_pending <= 1'b1;
      data_reg      <= data_in;
    end

    if (tick) begin 
      // Only step FSM state and increment registers after 16 ticks pass
      if (tick_count == 4'd15) begin
        tick_count <= 4'b0;
        state      <= next_state;

        if (state == IDLE && start_pending) begin 
          start_pending <= 1'b0;
          bit_count     <= 3'b0;
        end
        else if (state == DATA) begin 
          bit_count <= bit_count + 1'b1;
          data_reg  <= data_reg >> 1;
        end 
      end else begin
        tick_count <= tick_count + 1'b1;
      end
    end
  end
end

always @(*) begin
  busy = (state != IDLE) || start_pending;

  case (state)
    IDLE: begin
      serial_out = 1'b1;
      if (start_pending)
        next_state = START;
      else
        next_state = IDLE;
    end

    START: begin
      serial_out = 1'b0;
      if (tick_count == 4'd15)
        next_state = DATA;
      else
        next_state = START;
    end

    DATA: begin
      serial_out = data_reg[0];
      if (tick_count == 4'd15 && bit_count == 3'd7)
        next_state = STOP;
      else
        next_state = DATA;
    end

    STOP: begin
      serial_out = 1'b1;
      if (tick_count == 4'd15)
        next_state = IDLE;
      else
        next_state = STOP;
    end

    default: begin
      serial_out = 1'b1;
      next_state = IDLE;
    end
  endcase
end

endmodule