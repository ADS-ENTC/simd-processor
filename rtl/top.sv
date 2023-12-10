module top#(
    parameter INST_LEN = 12,
    parameter DATA_WIDTH = 32,
    parameter PE_ELEMENTS = 4,
    parameter PC_LEN = 12,
    parameter DRAM_DEPTH = 256,
    localparam DRAM_ADDR_WIDTH = $clog2(DRAM_DEPTH)
)(
    input logic rstn, clk, valid,
    output logic stop
);

logic [INST_LEN-1:0]inst_read_data;
logic [PC_LEN-1:0]inst_read_addr;

logic [PE_ELEMENTS-1:0][DATA_WIDTH-1:0]ram_a_read_data;
logic [DRAM_ADDR_WIDTH-1:0]ram_a_read_addr;
logic ram_a_rd_en;

logic [PE_ELEMENTS-1:0][DATA_WIDTH-1:0]ram_b_read_data;
logic [DRAM_ADDR_WIDTH-1:0]ram_b_read_addr;
logic ram_b_rd_en;

logic [DRAM_ADDR_WIDTH-1:0]ram_result_write_addr; 
logic [PE_ELEMENTS-1:0][DATA_WIDTH-1:0]ram_result_write_data;
logic ram_result_wr_en;


pe_top simd_processor (.*);

bram #(
    .DATA_WIDTH(PC_LEN),
    .DEPTH(512)
) ram_inst (
    .clk(clk),
    .re(1'b1),
    .addr(inst_read_addr),
    .we(1'b0),
    .data_out(inst_read_data)
);

bram #(
    .DATA_WIDTH(PE_ELEMENTS*DATA_WIDTH),
    .DEPTH(DRAM_DEPTH)
) ram_a (
    .clk(clk),
    .re(ram_a_rd_en),
    .addr(ram_a_read_addr),
    .we(1'b0),
    .data_out(ram_a_read_data)
);

bram #(
    .DATA_WIDTH(PE_ELEMENTS*DATA_WIDTH),
    .DEPTH(DRAM_DEPTH)
) ram_b (
    .clk(clk),
    .re(ram_b_rd_en),
    .addr(ram_b_read_addr),
    .we(1'b0),
    .data_out(ram_b_read_data)
);

bram #(
    .DATA_WIDTH(PE_ELEMENTS*DATA_WIDTH),
    .DEPTH(DRAM_DEPTH)
) ram_result (
    .clk(clk),
    .addr(ram_result_write_addr),
    .we(ram_result_wr_en),
    .data_in(ram_result_write_data)
);

endmodule