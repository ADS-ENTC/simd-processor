module processor#(
    parameter DATA_WIDTH = 32,
    parameter OPCODE_WIDTH = 4,
    parameter INST_LEN = 12,
    parameter PE_ELEMENTS = 4,
    parameter PC_LEN = 12,
    parameter DRAM_DEPTH = 256,
    parameter DRAM_ADDR_WIDTH = $clog2(DRAM_DEPTH)
)(
    input clk, rstn, valid,
    output stop,

    input [INST_LEN-1:0]inst_read_data,
    output [PC_LEN-1:0]inst_read_addr,

    input [DATA_WIDTH*PE_ELEMENTS-1:0]ram_a_read_data,
    output [DRAM_ADDR_WIDTH-1:0]ram_a_read_addr,
    output ram_a_rd_en,

    input [DATA_WIDTH*PE_ELEMENTS-1:0]ram_b_read_data,
    output [DRAM_ADDR_WIDTH-1:0]ram_b_read_addr,
    output ram_b_rd_en,

    output [DRAM_ADDR_WIDTH-1:0]ram_result_write_addr,
    output [DATA_WIDTH*PE_ELEMENTS-1:0]ram_result_write_data,
    output ram_result_wr_en
);

pe_top simd_processor(
    .clk(clk),
    .rstn(rstn),
    .valid(valid),
    .stop(stop),
    .inst_read_data(inst_read_data),
    .inst_read_addr(inst_read_addr),
    .ram_a_read_data(ram_a_read_data),
    .ram_a_read_addr(ram_a_read_addr),
    .ram_a_rd_en(ram_a_rd_en),
    .ram_b_read_data(ram_b_read_data),
    .ram_b_read_addr(ram_b_read_addr),
    .ram_b_rd_en(ram_b_rd_en),
    .ram_result_write_addr(ram_result_write_addr),
    .ram_result_write_data(ram_result_write_data),
    .ram_result_wr_en(ram_result_wr_en)
);

endmodule