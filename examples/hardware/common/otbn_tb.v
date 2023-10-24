module otbn_tb;

wire clk;
wire resetn;
wire [7:0] gpio_pin_out;
assign gpio_pin_out = 8'h0;

tb_common tb_common(
    .clk,
    .resetn,
    .gpio_pin_out
);

wire status_idle;
reg start_cmd;
wire done;

soc soc(
    .clk,
    .resetn,
    .status_idle,
    .start_cmd,
    .done
);

reg started;

initial begin
    started = 0;
    start_cmd = 0;
end

always @(posedge clk) begin
    if (resetn) begin
        if (status_idle && !started) begin
            start_cmd <= 1;
            started <= 1;
        end else if (start_cmd) begin
            start_cmd <= 0;
        end

        if (started && done) begin
            $display("finished in %d cycles", tb_common.cycle_count);
            $finish;
        end
    end
end

endmodule
