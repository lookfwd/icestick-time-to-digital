// Delay Line using iCE40 Carry Chain
// 32-tap delay line for sub-clock-cycle interpolation
// Each tap adds ~150ps propagation delay
// Output is thermometer-coded, then converted to binary

module delay_line (
    input  wire        signal_in,    // Signal to measure (propagates through chain)
    input  wire        clk,          // Clock for sampling
    input  wire        sample,       // Sample the delay line state
    output reg  [4:0]  fine_count,   // Binary-encoded position (0-31)
    output reg         valid         // Output is valid
);

    // Delay line taps (directly from carry chain)
    wire [31:0] taps;

    // Sampled thermometer code
    reg [31:0] thermometer;

    // Carry chain instantiation
    // Each SB_CARRY adds propagation delay
    // The signal ripples through the chain

    wire [32:0] carry;
    assign carry[0] = signal_in;

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : delay_stage
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

    // Sample the thermometer code on sample pulse
    always @(posedge clk) begin
        if (sample) begin
            thermometer <= taps;
            valid <= 1'b1;
        end else begin
            valid <= 1'b0;
        end
    end

    // Thermometer to binary encoder
    // Counts the number of '1's in the thermometer code
    // This represents how far the signal propagated
    always @(posedge clk) begin
        if (sample) begin
            // Priority encoder - find the transition point
            // The thermometer code should be like: 11111100000
            // We count how many 1s there are
            fine_count <= count_ones(taps);
        end
    end

    // Count ones in thermometer code (simple implementation)
    function [4:0] count_ones;
        input [31:0] therm;
        integer j;
        begin
            count_ones = 0;
            for (j = 0; j < 32; j = j + 1) begin
                count_ones = count_ones + therm[j];
            end
        end
    endfunction

endmodule
