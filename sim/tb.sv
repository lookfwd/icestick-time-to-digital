`timescale 1 ns / 100 ps

module top_tb;

reg clk_200m;
reg rst_n;
reg signal_in;

wire uart_tx;
wire [3:0] led;

always
    #2500ps clk_200m = ~clk_200m;


tdc #(
    .CLK_FREQ(200_000_000),
    .BAUD(115200)
) tdc_inst (
    .clk_200m(clk_200m),
    .rst_n(rst_n),
    .signal_in(signal_in),
    .uart_tx(uart_tx),
    .led(led)
);

initial
begin
    rst_n = 1'b0;
    #20 rst_n = 1'b1; 
end

initial
begin
    $display($time, "<< Starting the Simulation >>");
    clk_200m = 1'b0;
    signal_in = 1'b0;
    
    #1ms signal_in = 1'b1;

    #100 signal_in = 1'b0;
    
    #100 signal_in = 1'b1; // 200ns between edges

    #100 signal_in = 1'b0;
    
    #500us signal_in = 1'b1;

    #200 signal_in = 1'b0;
    
    #200 signal_in = 1'b1; // 400ns between edges

    #100 signal_in = 1'b0;

    #53ms;
    $display($time, "<< Simulation Complete >>");
    $stop;

end


endmodule
