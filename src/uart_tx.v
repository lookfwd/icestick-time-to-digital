// UART Transmitter
// 115200 baud, 8N1 format
// Transmits 40-bit value as 10 hex characters + newline

module uart_tx #(
    parameter CLK_FREQ = 200_000_000,  // 200 MHz clock
    parameter BAUD     = 115200
) (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [39:0] data,          // 40-bit data to transmit
    input  wire        data_valid,    // Pulse to start transmission
    output reg         tx,            // UART TX line
    output wire        busy           // High while transmitting
);

    // Baud rate divider: CLK_FREQ / BAUD
    localparam CLKS_PER_BIT = CLK_FREQ / BAUD;  // ~1736 for 200MHz/115200

    // States
    localparam IDLE      = 3'd0;
    localparam START_BIT = 3'd1;
    localparam DATA_BITS = 3'd2;
    localparam STOP_BIT  = 3'd3;
    localparam NEXT_CHAR = 3'd4;

    reg [2:0]  state;
    reg [15:0] clk_count;
    reg [2:0]  bit_index;
    reg [3:0]  char_index;      // 0-10: 10 hex chars + newline
    reg [7:0]  tx_byte;
    reg [39:0] data_reg;

    assign busy = (state != IDLE);

    // Convert nibble to ASCII hex character
    function [7:0] nibble_to_hex;
        input [3:0] nibble;
        begin
            if (nibble < 10)
                nibble_to_hex = 8'h30 + nibble;  // '0'-'9'
            else
                nibble_to_hex = 8'h41 + nibble - 10;  // 'A'-'F'
        end
    endfunction

    // Get the next character to transmit (10 hex chars + newline)
    function [7:0] get_char;
        input [3:0] idx;
        input [39:0] val;
        begin
            case (idx)
                4'd0:  get_char = nibble_to_hex(val[39:36]);
                4'd1:  get_char = nibble_to_hex(val[35:32]);
                4'd2:  get_char = nibble_to_hex(val[31:28]);
                4'd3:  get_char = nibble_to_hex(val[27:24]);
                4'd4:  get_char = nibble_to_hex(val[23:20]);
                4'd5:  get_char = nibble_to_hex(val[19:16]);
                4'd6:  get_char = nibble_to_hex(val[15:12]);
                4'd7:  get_char = nibble_to_hex(val[11:8]);
                4'd8:  get_char = nibble_to_hex(val[7:4]);
                4'd9:  get_char = nibble_to_hex(val[3:0]);
                4'd10: get_char = 8'h0A;  // newline
                default: get_char = 8'h00;
            endcase
        end
    endfunction

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= IDLE;
            tx         <= 1'b1;  // Idle high
            clk_count  <= 0;
            bit_index  <= 0;
            char_index <= 0;
            tx_byte    <= 0;
            data_reg   <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx <= 1'b1;
                    clk_count <= 0;
                    bit_index <= 0;
                    if (data_valid) begin
                        data_reg   <= data;
                        char_index <= 0;
                        tx_byte    <= get_char(0, data);
                        state      <= START_BIT;
                    end
                end

                START_BIT: begin
                    tx <= 1'b0;  // Start bit is low
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        bit_index <= 0;
                        state     <= DATA_BITS;
                    end
                end

                DATA_BITS: begin
                    tx <= tx_byte[bit_index];
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1;
                        end else begin
                            bit_index <= 0;
                            state     <= STOP_BIT;
                        end
                    end
                end

                STOP_BIT: begin
                    tx <= 1'b1;  // Stop bit is high
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        state     <= NEXT_CHAR;
                    end
                end

                NEXT_CHAR: begin
                    if (char_index < 10) begin
                        char_index <= char_index + 1;
                        tx_byte    <= get_char(char_index + 1, data_reg);
                        state      <= START_BIT;
                    end else begin
                        state <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
