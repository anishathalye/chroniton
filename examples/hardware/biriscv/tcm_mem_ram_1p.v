
module tcm_mem_ram_1p
(
    // Inputs
     input           clk_i
    ,input           rst_i
    ,input  [ 13:0]  addr_i
    ,input  [ 63:0]  data_i
    ,input  [  7:0]  wr_i

    // Outputs
    ,output [ 63:0]  data_o
);



//-----------------------------------------------------------------
// Single Port RAM 128KB
// Mode: Read First
//-----------------------------------------------------------------
/* verilator lint_off MULTIDRIVEN */
reg [63:0]   ram [511:0] /*verilator public*/;
/* verilator lint_on MULTIDRIVEN */

reg [63:0] ram_read_q;


// Synchronous write
always @ (posedge clk_i)
begin
    if (!rst_i) begin
        if (wr_i[0])
            ram[addr_i][7:0] <= data_i[7:0];
        if (wr_i[1])
            ram[addr_i][15:8] <= data_i[15:8];
        if (wr_i[2])
            ram[addr_i][23:16] <= data_i[23:16];
        if (wr_i[3])
            ram[addr_i][31:24] <= data_i[31:24];
        if (wr_i[4])
            ram[addr_i][39:32] <= data_i[39:32];
        if (wr_i[5])
            ram[addr_i][47:40] <= data_i[47:40];
        if (wr_i[6])
            ram[addr_i][55:48] <= data_i[55:48];
        if (wr_i[7])
            ram[addr_i][63:56] <= data_i[63:56];
    end

    ram_read_q <= ram[addr_i];
end

assign data_o = ram_read_q;



endmodule
