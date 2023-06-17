
module tcm_mem_rom_2p
(
    // Inputs
     input           clk0_i
    ,input  [ 13:0]  addr0_i
    ,input           clk1_i
    ,input  [ 13:0]  addr1_i

    // Outputs
    ,output [ 63:0]  data0_o
    ,output [ 63:0]  data1_o
);



//-----------------------------------------------------------------
// Dual Port ROM 128KB
//-----------------------------------------------------------------
/* verilator lint_off MULTIDRIVEN */
reg [63:0]   ram [16383:0] /*verilator public*/;
/* verilator lint_on MULTIDRIVEN */

reg [63:0] ram_read0_q;
reg [63:0] ram_read1_q;


// Synchronous read
always @ (posedge clk0_i)
begin
    ram_read0_q <= ram[addr0_i];
end

always @ (posedge clk1_i)
begin
    ram_read1_q <= ram[addr1_i];
end

assign data0_o = ram_read0_q;
assign data1_o = ram_read1_q;



endmodule
