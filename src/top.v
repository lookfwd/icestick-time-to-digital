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

    // Auto-arm: TDC is always armed when idle and UART is not busy
    wire auto_arm = (tdc_state == 2'd0) && !uart_busy;

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
    uart_tx #(
        .CLK_FREQ(200_000_000),
        .BAUD(115200)
    ) uart_inst (
        .clk(clk_200m),
        .rst_n(rst_n),
        .data(measurement),
        .data_valid(meas_valid),
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
