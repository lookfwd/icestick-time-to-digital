// TDC Core Module
// Measures time between two rising edges of the input signal
// Uses coarse counter (100 MHz) + fine delay line interpolation
//
// State machine: IDLE -> ARMED -> MEASURING -> DONE

module tdc_core (
    input  wire        clk,           // 100 MHz clock
    input  wire        rst_n,         // Active low reset
    input  wire        signal_in,     // Raw input signal (unsynchronized) - for delay line fine measurement
    input  wire        arm,           // Arm the TDC for measurement
    output reg  [39:0] measurement,   // Combined measurement result (40-bit)
    output reg         meas_valid,    // Measurement is valid
    output reg  [1:0]  state_out      // Current state for LED display
);

    // States
    localparam IDLE      = 2'd0;
    localparam ARMED     = 2'd1;
    localparam MEASURING = 2'd2;
    localparam DONE      = 2'd3;

    reg [1:0] state;

    // Coarse counter (28-bit @ 100 MHz = 2.68s range)
    reg [27:0] coarse_count;

    wire[9:0]  carry_out_line;
    // Instantiate delay line
    // Uses raw (unsynchronized) signal to capture precise edge timing
    delay_line delay_line_inst (
        .signal_in(signal_in),
        .carry_out(carry_out_line)
    );

    // Input synchronization
    reg [2:0] signal_sync;

    reg [9:0] carry_out_r_0;
    reg [5:0] carry_out_r_1;
    reg [5:0] carry_out_r_2;
    reg [5:0] carry_out_r_3;

    // Count ones in thermometer code
    // The thermometer code shows how far the signal has propagated
    // More 1s = signal arrived earlier relative to the clock edge
    function [5:0] count_ones;
        input [9:0] therm;
        integer j;
        begin
            count_ones = 0;
            for (j = 0; j < 10; j = j + 1) begin
                count_ones = count_ones + therm[j];
            end
        end
    endfunction
    

    // Synchronize external input to 100 MHz domain
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            signal_sync <= 3'b000;
        end else begin
            signal_sync <= {signal_sync[1:0], signal_in};
            carry_out_r_0 <= carry_out_line;
            carry_out_r_1 <= count_ones(carry_out_r_0);
            carry_out_r_2 <= carry_out_r_1;
            carry_out_r_3 <= carry_out_r_2;
        end
    end

   wire signal = signal_sync[2];
   wire [5:0] fine_count = carry_out_r_3;

    // Edge detection
    reg signal_d;
    wire signal_rising = signal & ~signal_d;

    // Edge detection registers
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            signal_d <= 1'b0;
        end else begin
            signal_d <= signal;
        end
    end

    // State machine
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state             <= IDLE;
            coarse_count      <= 0;
            measurement       <= 0;
            meas_valid        <= 1'b0;
        end else begin
            meas_valid        <= 1'b0;  // Default: not valid

            case (state)
                IDLE: begin
                    coarse_count <= 0;
                    if (arm) begin
                        state <= ARMED;
                    end
                end

                ARMED: begin
                    coarse_count <= 0;
                    if (signal_rising) begin
                        state <= MEASURING;
                    end
                end

                MEASURING: begin
                    // Increment coarse counter
                    if (coarse_count < 28'hFFFFFFF) begin
                        coarse_count <= coarse_count + 1;
                    end

                    // Check for second rising edge
                    if (signal_rising) begin
                        state <= DONE;
                    end
                end

                DONE: begin
                    // Combine coarse and fine counts
                    // Format: [39:34] = unused, [33:6] = coarse_count, [5:0] = fine_count
                    // Each coarse tick = 10ns (100 MHz)
                    // Each fine tick = ~150ps (64 taps cover ~9.6ns)
                    measurement <= {6'b000000, coarse_count, fine_count};
                    meas_valid  <= 1'b1;

                    // Return to IDLE after outputting
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

    // Output current state for LED display
    always @(*) begin
        state_out = state;
    end

endmodule
