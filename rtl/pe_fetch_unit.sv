module pe_fetch_unit #(
    parameter INST_LEN = 12,
    parameter DATA_LEN = 32,
    parameter PE_ELEMENTS = 4,
    parameter PC_LEN = 12,
    parameter OPCODE_LEN = 4,
    parameter PE_OPCODE_LEN = 3,
    parameter DRAM_DEPTH = 256
)(
    input logic rstn, clk, pe_stage_1_valid, pe_stage_2_valid, store_result,
    input logic [DATA_LEN*PE_ELEMENTS-1:0] pe_stage_1_output,
    input logic [DATA_LEN-1:0] pe_stage_2_output,

    output logic stop,
    output logic [PE_OPCODE_LEN-1:0] pe_opcode,
    output logic [DATA_LEN*PE_ELEMENTS-1:0] data_a, data_b
);

typedef enum logic [OPCODE_LEN-1:0] {NOOP, FETCH_A, FETCH_B, ADD, SUB, MUL, DOTP, STORE_TEMP_S1, STORE_TEMP_S2, STORE_RESULT, STOP} OPCODE; 

// local parameters
localparam DRAM_ADDR_WIDTH = $clog2(DRAM_DEPTH);

// temporary internal memories
logic [INST_LEN-1:0]ram_inst[64];
logic [DATA_LEN*PE_ELEMENTS-1:0]ram_a[64];
logic [DATA_LEN*PE_ELEMENTS-1:0]ram_b[64];
logic [DATA_LEN*PE_ELEMENTS-1:0]ram_result[64];

// internal signals
logic save_res_addr, load_a, load_b;
logic [DRAM_ADDR_WIDTH-1:0] res_addr;
logic [INST_LEN-1:0] instruction;
logic [PC_LEN-1:0] pc;
logic [DATA_LEN*PE_ELEMENTS-1:0] result;
logic [DRAM_ADDR_WIDTH-1:0] data_addr;

// hardwired connections
assign instruction = ram_inst[pc];
assign data_addr = instruction[OPCODE_LEN+8-1:OPCODE_LEN];
assign stop = (instruction[OPCODE_LEN-1:0] == STOP);


// opcode decoding
always_comb begin
    unique0 case (instruction[OPCODE_LEN-1:0])
        STOP: begin
            load_a = 0;
            load_b = 0;
            pe_opcode = 0;
            save_res_addr = 0; 
        end
        FETCH_A: begin
            load_a = 1;
            load_b = 0;
            pe_opcode = 0;
            save_res_addr = 0;
        end
        FETCH_B: begin
            load_a = 0;
            load_b = 1;
            pe_opcode = 0;
            save_res_addr = 0; 
        end
        ADD: begin
            load_a = 0;
            load_b = 0;
            pe_opcode = 1;
            save_res_addr = 0; 
        end
        SUB: begin
            load_a = 0;
            load_b = 0;
            pe_opcode = 2;
            save_res_addr = 0; 
        end
        MUL: begin
            load_a = 0;
            load_b = 0;
            pe_opcode = 3;
            save_res_addr = 0; 
        end
        DOTP: begin
            load_a = 0;
            load_b = 0;
            pe_opcode = 4;
            save_res_addr = 0; 
        end
        STORE_TEMP_S1: begin
            load_a = 0;
            load_b = 0;
            pe_opcode = 5;
            save_res_addr = 0; 
        end
        STORE_TEMP_S2: begin
            load_a = 0;
            load_b = 0;
            pe_opcode = 6;
            save_res_addr = 0; 
        end
        STORE_RESULT: begin
            load_a = 0;
            load_b = 0;
            pe_opcode = 7;
            save_res_addr = 1; 
        end
        default: begin
            load_a = 0;
            load_b = 0;
            pe_opcode = 0;
            save_res_addr = 0; 
        end
    endcase
end

// program counter routine
always_ff@(posedge clk) begin
    if (!rstn) begin
        pc <= 0;
    end
    else begin
        if (instruction[OPCODE_LEN-1:0] != STOP)
            pc <= pc + 1;
    end
end

// handling outputs from the programming elements
always_ff@(posedge clk) begin
    if (store_result)
        ram_result[res_addr] <= result;
    else if (pe_stage_1_valid)
        result <= pe_stage_1_output;
    else if (pe_stage_2_valid) begin
        result[DATA_LEN*PE_ELEMENTS-1:DATA_LEN] <= result[DATA_LEN*PE_ELEMENTS-DATA_LEN-1:0];
        result[DATA_LEN-1:0] <= pe_stage_2_output;
    end
end

// handling internal signals
always_ff@(posedge clk) begin
    if (load_a == 1)
        data_a <= ram_a[data_addr];
    
    if (load_b == 1)
        data_b <= ram_b[data_addr];

    if (save_res_addr == 1) begin
        res_addr <= data_addr;
    end
end

endmodule