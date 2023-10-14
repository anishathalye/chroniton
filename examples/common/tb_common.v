module tb_common(
    output clk,
    output resetn,
    output [7:0] gpio_pin_in,
    input [7:0] gpio_pin_out
);

reg clk;
reg resetn;
reg [63:0] cycle_count;
reg [7:0] gpio_pin_in;
wire [7:0] gpio_pin_out;

initial begin
    forever begin
        clk = 0;
        #1;
        clk = 1;
        #1;
        cycle_count = cycle_count + 1;
    end
end

initial begin
    gpio_pin_in = 8'h00;
    cycle_count = 0;
    resetn = 0;
    #2;
    resetn = 1;
end

always @(*) begin
    if (gpio_pin_out == 8'hff) begin
        $display("finished in %d cycles", cycle_count);
        $finish;
    end
end

endmodule
