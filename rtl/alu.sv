module alu #(
    parameter OPCODE_WIDTH = 4
)(
    input logic clk,
    input logic [31:0] a,
    input logic [31:0] b,
    input logic [OPCODE_WIDTH-1:0] opcode_in,
    output logic [31:0] out
);

typedef enum logic [OPCODE_WIDTH-1:0] {NOOP, ADD, SUB, MUL, DOTP, STORE_TEMP_S1, STORE_TEMP_S2, STORE_RESULT, STOP} mode;

logic [31:0] add_out;
logic [42:0] mult_out;
logic carry_out;
logic [OPCODE_WIDTH-1:0]opcode;

ADDSUB_MACRO #(
    .DEVICE("7SERIES"), // Target Device: "VIRTEX5", "VIRTEX6", "SPARTAN6", "7SERIES"
    .LATENCY(1), // Desired clock cycle latency, 0-2
    .WIDTH(32) // Input / output bus width, 1-48
) ADDSUB_MACRO_inst (
    .CARRYOUT(carry_out),
    .RESULT(add_out), // Add/sub result output, width defined by WIDTH parameter
    .A(a), // Input A bus, width defined by WIDTH parameter
    .ADD_SUB(opcode_in[0]), // 1-bit add/sub input, high selects add, low selects subtract
    .B(b), // Input B bus, width defined by WIDTH parameter
    .CARRYIN(1'b0), // 1-bit carry-in input
    .CE(1'b1), // 1-bit clock enable input
    .CLK(clk), // 1-bit clock input
    .RST(1'b0) // 1-bit active high synchronous reset
);

MULT_MACRO #(
.DEVICE("7SERIES"), // Target Device: "VIRTEX5", "VIRTEX6", "SPARTAN6","7SERIES"
.LATENCY(1), // Desired clock cycle latency, 0-4
.WIDTH_A(25), // Multiplier A-input bus width, 1-25
.WIDTH_B(18) // Multiplier B-input bus width, 1-18
) MULT_MACRO_inst (
.P(mult_out), // Multiplier output bus, width determined by WIDTH_P parameter
.A(a[25-1:0]), // Multiplier input A bus, width determined by WIDTH_A parameter
.B(b[18-1:0]), // Multiplier input B bus, width determined by WIDTH_B parameter
.CE(1'b1), // 1-bit active high input clock enable
.CLK(clk), // 1-bit positive edge clock input
.RST(1'b0) // 1-bit input active high reset
);

always_comb begin
    unique0 case(opcode)
        NOOP: out = 0;
        ADD: out = add_out;
        SUB: out = add_out;
        MUL: out = mult_out;
        DOTP: out = mult_out;
        STORE_TEMP_S1: out = 0;
        STORE_TEMP_S2: out = 0;
        STORE_RESULT: out = 0;
        STOP: out = 0;
        default: out = 0;
    endcase
end

always_ff@(posedge clk) begin
    opcode <= opcode_in;
end

endmodule