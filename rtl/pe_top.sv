module pe_top #(
    parameter DATA_WIDTH = 32,
    parameter OPCODE_WIDTH = 4,
    parameter INST_LEN = 12,
    parameter PE_ELEMENTS = 4,
    parameter PC_LEN = 12,
    parameter DRAM_DEPTH = 256,
    parameter DRAM_ADDR_WIDTH = $clog2(DRAM_DEPTH)
)(
    input logic rstn, clk, valid,
    output logic stop,

    input logic [INST_LEN-1:0]inst_read_data,
    output logic [PC_LEN-1:0]inst_read_addr,  

    input logic [PE_ELEMENTS-1:0][DATA_WIDTH-1:0]ram_a_read_data,
    output logic [DRAM_ADDR_WIDTH-1:0]ram_a_read_addr, 
    output ram_a_rd_en,

    input logic [PE_ELEMENTS-1:0][DATA_WIDTH-1:0]ram_b_read_data,
    output logic [DRAM_ADDR_WIDTH-1:0]ram_b_read_addr, 
    output logic ram_b_rd_en,

    output logic [DRAM_ADDR_WIDTH-1:0]ram_result_write_addr, 
    output logic [PE_ELEMENTS-1:0][DATA_WIDTH-1:0]ram_result_write_data,
    output logic ram_result_wr_en
);

// instructions
typedef enum logic [OPCODE_WIDTH-1:0] {NOOP, ADD, SUB, MUL, DOTP, STORE_TEMP_S1, STORE_TEMP_S2, STORE_RESULT, STOP} mode;

// signals for the fetch unit
logic pe_stage_1_valid, pe_stage_2_valid, store_result;
logic [3:0][DATA_WIDTH-1:0] pe_stage_1_output;
logic [DATA_WIDTH-1:0] pe_stage_2_output;
logic [OPCODE_WIDTH-1:0] pe_opcode;
logic [3:0][DATA_WIDTH-1:0] data_a, data_b;

// signals for the ALUs
logic [DATA_WIDTH-1:0]pe_1_out;
logic [DATA_WIDTH-1:0]pe_2_out;
logic [DATA_WIDTH-1:0]pe_3_out;
logic [DATA_WIDTH-1:0]pe_4_out;

// internal signals
logic [3:0][DATA_WIDTH-1:0] pe_stage_1_output_buffer[2]; 
logic [OPCODE_WIDTH-1:0] opcode_buffer[3];
logic carry_out_1, carry_out_2, carry_out_3, carry_out_4;

// signals for the summation stages
logic [1:0][DATA_WIDTH-1:0] sum_stage_out_1;
logic [DATA_WIDTH-1:0] sum_stage_out_2;
logic [DATA_WIDTH-1:0] acc_output;
logic [DATA_WIDTH-1:0] acc_output_hold;

// submodules
pe_fetch_unit fetch_unit (.*);

alu pe_1 (
    .clk(clk),
    .a(data_a[0]),
    .b(data_b[0]),
    .opcode_in(pe_opcode),
    .out(pe_1_out)
);

alu pe_2 (
    .clk(clk),
    .a(data_a[1]),
    .b(data_b[1]),
    .opcode_in(pe_opcode),
    .out(pe_2_out)
);

alu pe_3 (
    .clk(clk),
    .a(data_a[2]),
    .b(data_b[2]),
    .opcode_in(pe_opcode),
    .out(pe_3_out)
);

alu pe_4 (
    .clk(clk),
    .a(data_a[3]),
    .b(data_b[3]),
    .opcode_in(pe_opcode),
    .out(pe_4_out)
);

// summation stage
ADDSUB_MACRO #(
    .DEVICE("7SERIES"), // Target Device: "VIRTEX5", "VIRTEX6", "SPARTAN6", "7SERIES"
    .LATENCY(1), // Desired clock cycle latency, 0-2
    .WIDTH(32) // Input / output bus width, 1-48
) ADDSUB_MACRO_inst_1 (
    .CARRYOUT(carry_out_1),
    .RESULT(sum_stage_out_1[0]), // Add/sub result output, width defined by WIDTH parameter
    .A(pe_1_out), // Input A bus, width defined by WIDTH parameter
    .ADD_SUB(1'b1), // 1-bit add/sub input, high selects add, low selects subtract
    .B(pe_2_out), // Input B bus, width defined by WIDTH parameter
    .CARRYIN(1'b0), // 1-bit carry-in input
    .CE(1'b1), // 1-bit clock enable input
    .CLK(clk), // 1-bit clock input
    .RST(~rstn | valid) // 1-bit active high synchronous reset
);

ADDSUB_MACRO #(
    .DEVICE("7SERIES"), // Target Device: "VIRTEX5", "VIRTEX6", "SPARTAN6", "7SERIES"
    .LATENCY(1), // Desired clock cycle latency, 0-2
    .WIDTH(32) // Input / output bus width, 1-48
) ADDSUB_MACRO_inst_2 (
    .CARRYOUT(carry_out_2),
    .RESULT(sum_stage_out_1[1]), // Add/sub result output, width defined by WIDTH parameter
    .A(pe_3_out), // Input A bus, width defined by WIDTH parameter
    .ADD_SUB(1'b1), // 1-bit add/sub input, high selects add, low selects subtract
    .B(pe_4_out), // Input B bus, width defined by WIDTH parameter
    .CARRYIN(1'b0), // 1-bit carry-in input
    .CE(1'b1), // 1-bit clock enable input
    .CLK(clk), // 1-bit clock input
    .RST(~rstn | valid) // 1-bit active high synchronous reset
);

ADDSUB_MACRO #(
    .DEVICE("7SERIES"), // Target Device: "VIRTEX5", "VIRTEX6", "SPARTAN6", "7SERIES"
    .LATENCY(1), // Desired clock cycle latency, 0-2
    .WIDTH(32) // Input / output bus width, 1-48
) ADDSUB_MACRO_inst_3 (
    .CARRYOUT(carry_out_3),
    .RESULT(sum_stage_out_2), // Add/sub result output, width defined by WIDTH parameter
    .A(sum_stage_out_1[0]), // Input A bus, width defined by WIDTH parameter
    .ADD_SUB(1'b1), // 1-bit add/sub input, high selects add, low selects subtract
    .B(sum_stage_out_1[1]), // Input B bus, width defined by WIDTH parameter
    .CARRYIN(1'b0), // 1-bit carry-in input
    .CE(1'b1), // 1-bit clock enable input
    .CLK(clk), // 1-bit clock input
    .RST(~rstn | valid) // 1-bit active high synchronous reset
);

ADDSUB_MACRO #(
    .DEVICE("7SERIES"), // Target Device: "VIRTEX5", "VIRTEX6", "SPARTAN6", "7SERIES"
    .LATENCY(1), // Desired clock cycle latency, 0-2
    .WIDTH(32) // Input / output bus width, 1-48
) ADDSUB_MACRO_inst_4 (
    .CARRYOUT(carry_out_4),
    .RESULT(acc_output_hold), // Add/sub result output, width defined by WIDTH parameter
    .A(sum_stage_out_2), // Input A bus, width defined by WIDTH parameter
    .ADD_SUB(1'b1), // 1-bit add/sub input, high selects add, low selects subtract
    .B(acc_output), // Input B bus, width defined by WIDTH parameter
    .CARRYIN(1'b0), // 1-bit carry-in input
    .CE(1'b1), // 1-bit clock enable input
    .CLK(clk), // 1-bit clock input
    .RST(~rstn | valid) // 1-bit active high synchronous reset
);

// buffering the stage 1 output of PEs
always@(posedge clk) begin
    pe_stage_1_output_buffer[0] <= {pe_4_out, pe_3_out, pe_2_out, pe_1_out};
    pe_stage_1_output_buffer[1] <= pe_stage_1_output_buffer[0];
end

// buffering the opcodes of PEs
always@(posedge clk) begin
    opcode_buffer[0] <= pe_opcode;
    opcode_buffer[1] <= opcode_buffer[0];
    opcode_buffer[2] <= opcode_buffer[1];
end

// connections back to the PE fetch unit
assign pe_stage_1_output = pe_stage_1_output_buffer[1];
assign pe_stage_2_output = acc_output_hold;

assign pe_stage_1_valid = opcode_buffer[1] == STORE_TEMP_S1;
assign pe_stage_2_valid = opcode_buffer[1] == STORE_TEMP_S2;
assign store_result = opcode_buffer[2] == STORE_RESULT;
assign stop = opcode_buffer[2] == STOP;

always_comb begin
    acc_output = (opcode_buffer[2] == STORE_TEMP_S2) ? 0 : acc_output_hold;
end

endmodule