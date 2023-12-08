
module PE(
    input clk,
    input [31:0] a,
    input [31:0] b,
    input [1:0] mode,
    output reg [31:0] out
);
    wire carry_out;
    wire [31:0] add_out;
    wire [42:0] mult_out;

    ADDSUB_MACRO #(
        .DEVICE("7SERIES"), // Target Device: "VIRTEX5", "VIRTEX6", "SPARTAN6", "7SERIES"
        .LATENCY(1), // Desired clock cycle latency, 0-2
        .WIDTH(32) // Input / output bus width, 1-48
    ) ADDSUB_MACRO_inst (
        .CARRYOUT(carry_out), // 1-bit carry-out output signal
        .RESULT(add_out), // Add/sub result output, width defined by WIDTH parameter
        .A(a), // Input A bus, width defined by WIDTH parameter
        .ADD_SUB(mode[1]), // 1-bit add/sub input, high selects add, low selects subtract
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
    .A(a), // Multiplier input A bus, width determined by WIDTH_A parameter
    .B(b), // Multiplier input B bus, width determined by WIDTH_B parameter
    .CE(1'b1), // 1-bit active high input clock enable
    .CLK(clk), // 1-bit positive edge clock input
    .RST(1'b0) // 1-bit input active high reset
    );

    always @(*) begin
        case(mode)
        2'b00: out = mult_out[31:0];
        2'b01: out = add_out;
        2'b10: out = add_out;
        2'b11: out = add_out;
    endcase
    end


endmodule
