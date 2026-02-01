module top (
    input  wire clk_12m,      // 12 MHz oscillator
    input  wire signal_in,    // Input signal (PMOD1 pin 1) - measures time between rising edges
    output wire uart_tx,      // UART TX to FTDI
    output wire [3:0] led     // Status LEDs
);

    // Internal signals
    wire clk_100m;
    wire pll_locked;
    wire rst_n;

    // PLL: 12 MHz -> 100 MHz
    pll pll_inst (
        .clk_12m(clk_12m),
        .clk_100m(clk_100m),
        .locked(pll_locked)
    );

    // Input synchronization
    reg [2:0] signal_sync;
    wire signal_synced = signal_sync[2];

    // Reset generation (hold reset until PLL locks)
    reg [7:0] reset_counter = 0;
    reg rst_n_reg = 0;

    always @(posedge clk_100m or negedge pll_locked) begin
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

    // Synchronize external input to 100 MHz domain
    always @(posedge clk_100m or negedge rst_n) begin
        if (!rst_n) begin
            signal_sync <= 3'b000;
        end else begin
            signal_sync <= {signal_sync[1:0], signal_in};
        end
    end

    tdc #(
        .CLK_FREQ(100_000_000),
        .BAUD(115200)
    ) tdc_inst (
        .clk_100m(clk_100m),
        .rst_n(rst_n),
        .signal_in(signal_sync),
        .uart_tx(uart_tx),
        .led(led)
    );
    
endmodule
