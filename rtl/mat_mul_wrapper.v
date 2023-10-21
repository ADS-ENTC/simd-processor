module mat_mul_wrapper(
    input wire clk, cen, valid_in,
    input wire signed [W_IN-1:0] matrix_1 [N][N], 
    input reg signed [W_IN-1:0] matrix_2 [N][N],
    output reg valid_out,
    output reg signed [W_OUT-1:0] result [N][N]
)

localparam W_IN = 8;
localparam W_OUT = 32;
localparam N = 8;

mat_mul #(.W_IN(W_IN), .W_OUT(W_OUT), .N(N)) mm (.clk(clk), .cen(cen), .valid_in(valid_in), .matrix_1(matrix_1), .matrix_2(matrix_2), .valid_out(valid_out), .result(result));

endmodule