// Top-level module for iCEstick Time-to-Digital Converter
// Integrates PLL, TDC core, and UART transmitter
// Measures time between two rising edges of the input signal

module tdc #(
    parameter CLK_FREQ = 100_000_000,  // 100 MHz clock
    parameter BAUD     = 115200
)(
    input  wire clk_100m,     // 100 MHz Clock
    input  wire rst_n,
    input  wire signal_in,    // Raw input signal (unsynchronized) - for delay line fine measurement
    output wire uart_tx,      // UART TX to FTDI
    output wire [3:0] led     // Status LEDs
);

    // TDC signals
    wire [39:0] measurement;
    wire meas_valid;
    wire [1:0] tdc_state;

    // UART signals
    wire uart_busy;

    // Rate limiter parameters
    // 100 MHz clock, 20 transmissions per second = 5,000,000 clock cycles between transmissions
    localparam CLKS_PER_TX = CLK_FREQ / 20;  // 5,000,000 cycles = 50ms
    reg [23:0] rate_counter;  // 24 bits can hold up to 16,777,215
    wire can_transmit;
    assign can_transmit = (rate_counter >= CLKS_PER_TX);

    // Measurement buffer (decouples TDC from UART timing)
    reg [39:0] meas_buffer;
    reg meas_pending;
    reg uart_start;  // Trigger for UART

    // Auto-arm: TDC is always armed when idle (decoupled from UART)
    wire auto_arm = (tdc_state == 2'd0);

    // Measurement buffering logic with rate limiting
    // When a new measurement arrives, buffer it. When UART is free, rate limit
    // allows, and we have a pending measurement, send it. This limits UART
    // transmission to 20 times per second while TDC runs continuously.
    always @(posedge clk_100m or negedge rst_n) begin
        if (!rst_n) begin
            meas_buffer  <= 40'd0;
            meas_pending <= 1'b0;
            uart_start   <= 1'b0;
            rate_counter <= CLKS_PER_TX;
        end else begin
            uart_start  <= 1'b0;  // Default: no start pulse

            // Increment rate counter (saturate at max to avoid overflow)
            if (rate_counter < CLKS_PER_TX)
                rate_counter <= rate_counter + 1'b1;

            // Buffer new measurement when it arrives
            if (meas_valid) begin
                meas_buffer  <= measurement;
                meas_pending <= 1'b1;
            end

            // When UART finishes and we have a pending measurement and rate limit allows, send it
            if (~uart_busy && meas_pending && can_transmit) begin
                uart_start   <= 1'b1;
                meas_pending <= 1'b0;
                rate_counter <= 24'd0;  // Reset rate limiter
            end
        end
    end

    // TDC Core
    tdc_core tdc_inst (
        .clk(clk_100m),
        .rst_n(rst_n),
        .signal_in(signal_in),
        .arm(auto_arm),
        .measurement(measurement),
        .meas_valid(meas_valid),
        .state_out(tdc_state)
    );

    // UART Transmitter
    // Uses buffered measurement and start signal (decoupled from TDC timing)
    uart_tx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD(BAUD)
    ) uart_inst (
        .clk(clk_100m),
        .rst_n(rst_n),
        .data(meas_buffer),
        .data_valid(uart_start),
        .tx(uart_tx),
        .busy(uart_busy)
    );

    // LED status display
    // LED[0]: PLL locked
    // LED[1]: TDC armed (waiting for first rising edge)
    // LED[2]: TDC measuring (between first and second rising edge)
    // LED[3]: UART transmitting
    assign led[0] = rst_n;
    assign led[1] = (tdc_state == 2'd1);  // ARMED
    assign led[2] = (tdc_state == 2'd2);  // MEASURING
    assign led[3] = uart_busy;

endmodule
