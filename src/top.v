// Top-level module for iCEstick Time-to-Digital Converter
// Integrates PLL, TDC core, and UART transmitter

module top (
    input  wire clk_12m,      // 12 MHz oscillator
    input  wire start_in,     // START signal (PMOD1 pin 1)
    input  wire stop_in,      // STOP signal (PMOD1 pin 2)
    output wire uart_tx,      // UART TX to FTDI
    output wire [3:0] led     // Status LEDs
);

    // Internal signals
    wire clk_200m;
    wire pll_locked;
    wire rst_n;

    // TDC signals
    wire [39:0] measurement;
    wire meas_valid;
    wire [1:0] tdc_state;

    // UART signals
    wire uart_busy;

    // Measurement buffer (decouples TDC from UART timing)
    reg [39:0] meas_buffer;
    reg meas_pending;
    reg uart_busy_d;  // For edge detection
    wire uart_done = uart_busy_d & ~uart_busy;  // Falling edge of busy
    reg uart_start;  // Trigger for UART

    // Input synchronization
    reg [2:0] start_sync;
    reg [2:0] stop_sync;
    wire start_synced = start_sync[2];
    wire stop_synced  = stop_sync[2];

    // Reset generation (hold reset until PLL locks)
    reg [7:0] reset_counter = 0;
    reg rst_n_reg = 0;

    always @(posedge clk_200m or negedge pll_locked) begin
        if (!pll_locked) begin
            reset_counter <= 0;
            rst_n_reg <= 0;
        end else if (reset_counter < 255) begin
            reset_counter <= reset_counter + 1;
            rst_n_reg <= 0;
        end else begin
            rst_n_reg <= 1;
        end
    end

    assign rst_n = rst_n_reg;

    // Synchronize external inputs to 200 MHz domain
    always @(posedge clk_200m or negedge rst_n) begin
        if (!rst_n) begin
            start_sync <= 3'b000;
            stop_sync  <= 3'b000;
        end else begin
            start_sync <= {start_sync[1:0], start_in};
            stop_sync  <= {stop_sync[1:0], stop_in};
        end
    end

    // Auto-arm: TDC is always armed when idle (decoupled from UART)
    wire auto_arm = (tdc_state == 2'd0);

    // Measurement buffering logic
    // When a new measurement arrives, buffer it. When UART is free and we have
    // a pending measurement, send it. This allows TDC to run continuously
    // without waiting for UART transmission to complete.
    always @(posedge clk_200m or negedge rst_n) begin
        if (!rst_n) begin
            meas_buffer  <= 40'd0;
            meas_pending <= 1'b0;
            uart_busy_d  <= 1'b0;
            uart_start   <= 1'b0;
        end else begin
            uart_busy_d <= uart_busy;
            uart_start  <= 1'b0;  // Default: no start pulse

            // Buffer new measurement when it arrives
            if (meas_valid) begin
                meas_buffer  <= measurement;
                meas_pending <= 1'b1;
            end

            // When UART finishes and we have a pending measurement, send it
            if (uart_done && meas_pending) begin
                uart_start   <= 1'b1;
                meas_pending <= 1'b0;
            end

            // If UART is idle and we have a pending measurement, send it
            if (!uart_busy && !uart_busy_d && meas_pending) begin
                uart_start   <= 1'b1;
                meas_pending <= 1'b0;
            end
        end
    end

    // PLL: 12 MHz -> 200 MHz
    pll pll_inst (
        .clk_12m(clk_12m),
        .clk_200m(clk_200m),
        .locked(pll_locked)
    );

    // TDC Core
    tdc_core tdc_inst (
        .clk(clk_200m),
        .rst_n(rst_n),
        .start(start_synced),
        .stop(stop_synced),
        .arm(auto_arm),
        .measurement(measurement),
        .meas_valid(meas_valid),
        .state_out(tdc_state)
    );

    // UART Transmitter
    // Uses buffered measurement and start signal (decoupled from TDC timing)
    uart_tx #(
        .CLK_FREQ(200_000_000),
        .BAUD(115200)
    ) uart_inst (
        .clk(clk_200m),
        .rst_n(rst_n),
        .data(meas_buffer),
        .data_valid(uart_start),
        .tx(uart_tx),
        .busy(uart_busy)
    );

    // LED status display
    // LED[0]: PLL locked
    // LED[1]: TDC armed (waiting for START)
    // LED[2]: TDC measuring (between START and STOP)
    // LED[3]: UART transmitting
    assign led[0] = pll_locked;
    assign led[1] = (tdc_state == 2'd1);  // ARMED
    assign led[2] = (tdc_state == 2'd2);  // MEASURING
    assign led[3] = uart_busy;

endmodule
