module mat_mul_wrapper#(
    parameter W_IN = 8,
    parameter W_OUT = 32,
    parameter N = 8
)(
    input wire clk, resetn, valid_in,
    input wire signed [N*N*W_IN-1:0] matrix_1, 
    input wire signed [N*N*W_IN-1:0] matrix_2,
    output reg valid_out,
    output reg signed [N*N*W_OUT-1:0] result
);

mat_mul #(.W_IN(W_IN), .W_OUT(W_OUT), .N(N)) mm (.clk(clk), .resetn(resetn), .valid_in(valid_in), .matrix_1(matrix_1), .matrix_2(matrix_2), .valid_out(valid_out), .result(result));

endmodule