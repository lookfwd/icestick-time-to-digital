module delay_line (
    input  wire        signal_in,    // Signal to measure (propagates through chain)
    input  wire        clk,          // Clock for sampling
    input  wire        sample,       // Sample the delay line state
    output wire [4:0]  fine_count,   // Binary-encoded position (0-31)
    output reg         valid         // Output is valid
);

    always @(posedge clk) begin
        if (sample) begin
            valid <= 1'b1;
        end else begin
            valid <= 1'b0;
        end
    end

    assign fine_count = 5'b0;

endmodule
