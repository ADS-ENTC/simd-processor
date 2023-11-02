module mat_mul_optimized_SIMD #(
    parameter W_IN = 8,
    parameter W_OUT = 32,
    parameter N = 2, // N*N matrix
    parameter SIMD_WIDTH = 4 // Number of parallel multiplications in SIMD
)(
    input logic clk, cen, valid_in,
    input logic signed [W_IN-1:0] matrix_1 [N][N], 
    input logic signed [W_IN-1:0] matrix_2 [N][N],
    output logic valid_out,
    output logic signed [W_OUT-1:0] result [N][N]
);

localparam DEPTH = $clog2(N); // number of summation stages

// Define the module structure, parameters, and local parameters

// Commit this as the basic structure of the module.
endmodule