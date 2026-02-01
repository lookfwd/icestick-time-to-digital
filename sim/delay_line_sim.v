module delay_line (
    input  wire        signal_in,    // RAW signal to measure (propagates through chain)
    input  wire        clk,          // Clock for sampling
    input  wire        rst_n,        // Active low reset
    input  wire        sample,       // Sample the delay line state (from synchronized edge detection)
    output wire [5:0]  fine_count   // Binary-encoded position (0-63)
);
    assign fine_count = 6'b0;

endmodule
