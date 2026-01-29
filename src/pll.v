// PLL module: 12 MHz input -> 200 MHz output
// Uses iCE40 SB_PLL40_CORE primitive
//
// PLL calculation for 200 MHz from 12 MHz:
//   F_OUT = F_IN * (DIVF + 1) / ((DIVR + 1) * (2^DIVQ))
//   200 = 12 * (66 + 1) / ((0 + 1) * (2^2))
//   200 = 12 * 67 / 4 = 201 MHz (close enough)

module pll (
    input  wire clk_12m,      // 12 MHz input clock
    output wire clk_200m,     // 200 MHz output clock
    output wire locked        // PLL lock indicator
);

    SB_PLL40_CORE #(
        .FEEDBACK_PATH("SIMPLE"),
        .DIVR(4'b0000),        // DIVR = 0
        .DIVF(7'b1000010),     // DIVF = 66
        .DIVQ(3'b010),         // DIVQ = 2
        .FILTER_RANGE(3'b001)  // Filter range for 12 MHz input
    ) pll_inst (
        .REFERENCECLK(clk_12m),
        .PLLOUTCORE(clk_200m),
        .LOCK(locked),
        .RESETB(1'b1),
        .BYPASS(1'b0)
    );

endmodule
