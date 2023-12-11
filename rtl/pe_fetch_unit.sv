module pe_fetch_unit #(
    parameter INST_LEN = 12,
    parameter DATA_LEN = 32,
    parameter PE_ELEMENTS = 4,
    parameter PC_LEN = 12,
    parameter OPCODE_LEN = 4,
    parameter PE_OPCODE_LEN = 4,
    parameter DRAM_DEPTH = 256,
    localparam DRAM_ADDR_WIDTH = $clog2(DRAM_DEPTH)
)(
    input logic rstn, clk, pe_stage_1_valid, pe_stage_2_valid, store_result, valid,
    input logic [PE_ELEMENTS-1:0][DATA_LEN-1:0] pe_stage_1_output,
    input logic [DATA_LEN-1:0] pe_stage_2_output,

    output logic [PE_OPCODE_LEN-1:0] pe_opcode,
    output logic [PE_ELEMENTS-1:0][DATA_LEN-1:0] data_a, data_b,

    input logic [INST_LEN-1:0]inst_read_data,
    output logic [PC_LEN-1:0]inst_read_addr,  

    input logic [PE_ELEMENTS-1:0][DATA_LEN-1:0]ram_a_read_data,
    output logic [DRAM_ADDR_WIDTH-1:0]ram_a_read_addr, 
    output logic ram_a_rd_en,

    input logic [PE_ELEMENTS-1:0][DATA_LEN-1:0]ram_b_read_data,
    output logic [DRAM_ADDR_WIDTH-1:0]ram_b_read_addr, 
    output logic ram_b_rd_en,

    output logic [DRAM_ADDR_WIDTH-1:0]ram_result_write_addr, 
    output logic [PE_ELEMENTS-1:0][DATA_LEN-1:0]ram_result_write_data,
    output logic ram_result_wr_en  
);

typedef enum logic [OPCODE_LEN-1:0] {NOOP, FETCH_A, FETCH_B, ADD, SUB, MUL, DOTP, STORE_TEMP_S1, STORE_TEMP_S2, STORE_RESULT, STOP} OPCODE; 

// internal signals
logic load_a, load_b, save_res_addr;
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
assign ram_a_rd_en = load_a;
assign ram_b_rd_en = load_b;

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
        result[PE_ELEMENTS-1] <= pe_stage_2_output;

        for (int i=1; i<PE_ELEMENTS; i++) begin
            result[i-1] <= result[i];
        end
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