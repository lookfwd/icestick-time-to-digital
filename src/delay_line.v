// Delay Line using iCE40 Carry Chain
// 64-tap delay line for sub-clock-cycle interpolation
// Each tap adds ~150ps propagation delay (~9.6ns total)
// Output is thermometer-coded, then converted to binary
//
// IMPORTANT: This module must receive the RAW (unsynchronized) signal
// to accurately measure fine timing. The synchronizer delay is compensated
// by using a 4-cycle history buffer.

module delay_line (
    input  wire        signal_in,    // RAW signal to measure (propagates through chain)
    input  wire        clk,          // Clock for sampling
    input  wire        rst_n,        // Active low reset
    input  wire        sample,       // Sample the delay line state (from synchronized edge detection)
    output wire [5:0]  fine_count,   // Binary-encoded position (0-63)
    output wire        valid         // Output is valid
);

    // Delay line taps (directly from carry chain)
    wire [63:0] taps;

    // Carry chain instantiation
    // Each SB_CARRY adds propagation delay
    // The signal ripples through the chain

    wire [64:0] carry;
    assign carry[0] = signal_in;

    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin : delay_stage
            // Use SB_CARRY primitive for consistent delay
            // I0=0, I1=1 creates a simple propagation path
            SB_CARRY carry_inst (
                .CO(carry[i+1]),
                .CI(carry[i]),
                .I0(1'b0),
                .I1(1'b1)
            );
            assign taps[i] = carry[i+1];
        end
    endgenerate

    // History buffer for fine_count values
    // The synchronized edge detection is 4 cycles behind the raw edge:
    //   - 3 cycles in synchronizer (signal_sync[2:0])
    //   - 1 cycle for sample_delay_line register
    // We need to output the fine_count from when the raw edge arrived,
    // so we keep a 4-cycle history and output history[3] when sampled.
    reg [5:0] fine_count_history [0:3];

    // Sample the delay line on every clock edge and maintain history
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fine_count_history[0] <= 6'd0;
            fine_count_history[1] <= 6'd0;
            fine_count_history[2] <= 6'd0;
            fine_count_history[3] <= 6'd0;
        end else begin
            // Shift history (oldest value gets overwritten)
            fine_count_history[3] <= fine_count_history[2];
            fine_count_history[2] <= fine_count_history[1];
            fine_count_history[1] <= fine_count_history[0];
            // Compute new fine_count from current taps
            fine_count_history[0] <= count_ones(taps);
        end
    end

    // Output the historical fine_count from 4 cycles ago
    // This corresponds to when the raw edge actually arrived
    // (compensating for synchronizer + sample register delay)
    assign fine_count = fine_count_history[3];
    assign valid = sample;

    // Count ones in thermometer code
    // The thermometer code shows how far the signal has propagated
    // More 1s = signal arrived earlier relative to the clock edge
    function [5:0] count_ones;
        input [63:0] therm;
        integer j;
        begin
            count_ones = 0;
            for (j = 0; j < 64; j = j + 1) begin
                count_ones = count_ones + therm[j];
            end
        end
    endfunction

endmodule
