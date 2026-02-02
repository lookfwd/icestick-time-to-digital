`timescale 1 ns / 10 ps

module SB_CARRY (
    input  wire I0,
    input  wire I1,
    input  wire CI,
    output wire CO
);

    assign #150ps CO = CI;

            
endmodule
