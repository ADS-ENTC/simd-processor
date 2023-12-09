module pe_fetch_unit #(
    parameter INST_LEN = 12,
    parameter DATA_LEN = 32,
    parameter PE_ELEMENTS = 4,
    parameter PC_LEN = 12,
    parameter OPCODE_LEN = 4,
    parameter PE_OPCODE_LEN = 4,
    parameter DRAM_DEPTH = 512
)(
    input logic rstn, clk, pe_stage_1_valid, pe_stage_2_valid, store_result, valid, stop,
    input logic [PE_ELEMENTS-1:0][DATA_LEN-1:0] pe_stage_1_output,
    input logic [DATA_LEN-1:0] pe_stage_2_output,

    output logic [PE_OPCODE_LEN-1:0] pe_opcode,
    output logic [PE_ELEMENTS-1:0][DATA_LEN-1:0] data_a, data_b,

    input [INST_LEN-1:0]inst_read_data,
    output [PC_LEN-1:0]inst_read_addr,  

    input [PE_ELEMENTS-1:0][DATA_LEN-1:0]ram_a_read_data,
    output [DRAM_ADDR_WIDTH-1:0]ram_a_read_addr, 

    input [PE_ELEMENTS-1:0][DATA_LEN-1:0]ram_b_read_data,
    output [DRAM_ADDR_WIDTH-1:0]ram_b_read_addr, 

    output [DRAM_ADDR_WIDTH-1:0]ram_result_write_addr, 
    output [PE_ELEMENTS-1:0][DATA_LEN-1:0]ram_result_write_data,
    output ram_result_wr_en,  
);

typedef enum logic [OPCODE_LEN-1:0] {NOOP, FETCH_A, FETCH_B, ADD, SUB, MUL, DOTP, STORE_TEMP_S1, STORE_TEMP_S2, STORE_RESULT, STOP} OPCODE; 

// local parameters
localparam DRAM_ADDR_WIDTH = $clog2(DRAM_DEPTH);

// internal signals
logic save_res_addr, load_a, load_b;
logic [DRAM_ADDR_WIDTH-1:0] res_addr;
logic [INST_LEN-1:0] instruction;
logic [PC_LEN-1:0] pc;
logic [PE_ELEMENTS-1:0][DATA_LEN-1:0] result;
logic [DRAM_ADDR_WIDTH-1:0] data_addr;
logic pe_stage_2_valid_buffer;
logic valid_hold;

// hardwired connections
assign inst_read_addr = pc;
assign instruction = inst_read_data;

assign data_addr = instruction[OPCODE_LEN+8-1:OPCODE_LEN];
assign ram_a_read_addr = data_addr;
assign ram_b_read_addr = data_addr;
assign data_a = ram_a_read_data;
assign data_b = ram_b_read_data;

assign ram_result_wr_en = store_result;
assign ram_result_write_data = result;
assign ram_result_write_addr = res_addr;

// opcode decoding
always_comb begin
    unique0 case (instruction[OPCODE_LEN-1:0])
        STOP: begin
            load_a = 0;
            load_b = 0;
            pe_opcode = 8;
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
        valid_hold <= 0;
    end
    else begin
        if (valid_hold == 1) begin
            if (instruction[OPCODE_LEN-1:0] != STOP)
                pc <= pc + 1;
            else begin
                valid_hold <= 0;
                pc <= 0;
            end
        end
        else begin
            if (valid == 1) begin
                pc <= 0;
                valid_hold <= 1;
            end
        end 
    end 
end

// handling outputs from the programming elements
always_ff@(posedge clk) begin
    if (pe_stage_1_valid && !store_result)
        result <= pe_stage_1_output;
    else if (pe_stage_2_valid_buffer && !store_result) begin
        {result[DATA_LEN*PE_ELEMENTS-1:DATA_LEN], result[DATA_LEN-1:0]} <= {result[DATA_LEN*PE_ELEMENTS-DATA_LEN-1:0], pe_stage_2_output};
    end
end

// handling internal signals
always_ff@(posedge clk) begin
    if (save_res_addr == 1) begin
        res_addr <= data_addr;
    end
end

// buffering the pe_stage_2_valid signal
always_ff@(posedge clk) begin
    pe_stage_2_valid_buffer <= pe_stage_2_valid;
end

endmodule