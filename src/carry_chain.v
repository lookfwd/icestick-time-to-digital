module carry_chain #(
    parameter TAPS = 1
)(
    input  wire signal_in,   // RAW signal to measure (propagates through chain)
    output wire signal_out    // Carry chain output
);

    wire [TAPS:0] carry;
    assign carry[0] = signal_in;
    assign signal_out = carry[TAPS];

    genvar i;
    generate
        for (i = 0; i < TAPS; i = i + 1) begin : delay_stage
            // Use SB_CARRY primitive for consistent delay
            // I0=0, I1=1 creates a simple propagation path
            (* keep = 1 *) SB_CARRY carry_inst (
                .CO(carry[i+1]),
                .CI(carry[i]),
                .I0(1'b0),
                .I1(1'b1)
            );
        end
    endgenerate

endmodule
