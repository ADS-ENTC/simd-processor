timeprecision 1ps;
timeunit 1ns;

module pe_fetch_unit_tb;

localparam INST_LEN = 12;
localparam DATA_LEN = 32;
localparam DRAM_DEPTH = 256;
localparam DRAM_ADDR_WIDTH = $clog2(DRAM_DEPTH);

logic rstn, clk, pe_stage_1_valid, pe_stage_2_valid, store_result;
logic [DATA_LEN*4-1:0] pe_stage_1_output;
logic [DATA_LEN-1:0] pe_stage_2_output;

logic stop;
logic [3-1:0] pe_opcode;
logic [DATA_LEN*4-1:0] data_a, data_b;

pe_fetch_unit #(.DRAM_DEPTH(64)) dut (.*);


logic [DRAM_ADDR_WIDTH-1:0]data_addr;

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

integer i;

initial begin
    @(negedge clk);
    #1;
    rstn = 0;

    @(negedge clk);
    #1;
    dut.ram_inst[0] = {12'd0, 4'd0}; // NOOP

    data_addr = $urandom_range(2**DRAM_ADDR_WIDTH-1);
    dut.ram_inst[1] = {4'd0, data_addr, 4'd1}; // FETCH_A

    data_addr = $urandom_range(2**DRAM_ADDR_WIDTH-1);
    dut.ram_inst[2] = {4'd0, data_addr, 4'd2}; // FETCH_B

    dut.ram_inst[3] = {12'd0, 4'd3}; // ADD

    dut.ram_inst[4] = {12'd0, 4'd4}; // SUB

    dut.ram_inst[5] = {12'd0, 4'd5}; // MUL

    dut.ram_inst[6] = {12'd0, 4'd6}; // DOTP

    dut.ram_inst[7] = {12'd0, 4'd7}; // STORE_TEMP_S1

    dut.ram_inst[8] = {12'd0, 4'd8}; // STORE_TEMP_S2

    data_addr = $urandom_range(2**DRAM_ADDR_WIDTH-1);
    dut.ram_inst[9] = {4'd0, data_addr, 4'd9}; // STORE_RESULT

    dut.ram_inst[10] = {12'd0, 4'd10}; // STOP
    
    for (i=0; i<DRAM_DEPTH; i++) begin
        dut.ram_a[i] = {i, i, i, i};
        dut.ram_b[i] = {i+1, i+1, i+1, i+1};
    end

    @(negedge clk);
    #1;
    store_result = 0;
    pe_stage_1_valid = 0;
    pe_stage_2_valid = 0;
    rstn = 1;

    #400;

    $finish;
end


endmodule