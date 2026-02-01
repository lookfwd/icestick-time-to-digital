`timescale 1 ns / 100 ps

module top_tb;

reg clk_100m;
reg rst_n;
reg signal_in;

wire uart_tx;
wire [3:0] led;

always
    #5000ps clk_100m = ~clk_100m;


tdc #(
    .CLK_FREQ(100_000_000),
    .BAUD(115200)
) tdc_inst (
    .clk_100m(clk_100m),
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
    clk_100m = 1'b0;
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
