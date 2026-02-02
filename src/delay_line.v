// Delay Line using iCE40 Carry Chain
// 64-tap delay line for sub-clock-cycle interpolation
// Each tap adds ~150ps propagation delay (~9.6ns total)
// Output is thermometer-coded, then converted to binary
//
// IMPORTANT: This module must receive the RAW (unsynchronized) signal
// to accurately measure fine timing. The synchronizer delay is compensated
// by using a 4-cycle history buffer.

module delay_line (
    input  wire       signal_in,   // RAW signal to measure (propagates through chain)
    output wire[9:0]  carry_out    // Carry chain output
);

// Lots of carry-chain duplication below. Here's the reason:
// In the iCE40 FPGA, the COUT pin of an SB_CARRY primitive is physically
// hardwired directly to the CIN pin of the Logic Cell immediately above it.
// Dedicated Path: This connection exists on a special carry chain wire that
// does not connect to the general routing fabric (the switch matrix).
// The Conflict: Because it cannot touch the general routing fabric, it
// cannot be routed to a D-Flip-Flop (Register) input or a LUT input.

// 120 to 150ps * 7 ~= 900ps per delay step

genvar i;
generate
    for (i = 0; i < 10; i = i + 1) begin : delay_stage
        // Use SB_CARRY primitive for consistent delay
        // I0=0, I1=1 creates a simple propagation path
        carry_chain #(.TAPS((i + 1) * 7)) delay_stage_inst (
            .signal_in(signal_in),
            .signal_out(carry_out[i])
        );
    end
endgenerate

endmodule
