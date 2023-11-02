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

logic signed [W_OUT-1:0] partial_sum [N][N][DEPTH+1][N][SIMD_WIDTH]; // SIMD for the intermediate values
logic valid_buffer[DEPTH+1]; // holds the valid signal for each summation stage

genvar m1_row_num, m2_col_num, d0_item_num, depth, item_num;
generate
for (m1_row_num = 0; m1_row_num < N; m1_row_num = m1_row_num + 1) begin: m1_row_iter
    for (m2_col_num = 0; m2_col_num < N; m2_col_num++) begin: m2_col_iter

        // multiplication stage with SIMD
        for (d0_item_num = 0; d0_item_num < N; d0_item_num = d0_item_num + SIMD_WIDTH) begin: d0_item_iter
            always_comb begin
                // Perform SIMD multiplications if valid_in is high
                if (valid_in) begin
                    for (genvar simd_idx = 0; simd_idx < SIMD_WIDTH; simd_idx = simd_idx + 1) begin: simd_mul_iter
                        partial_sum[m1_row_num][m2_col_num][0][d0_item_num + simd_idx][simd_idx] =
                            $signed(matrix_1[m1_row_num][d0_item_num + simd_idx]) *
                            $signed(matrix_2[d0_item_num + simd_idx][m2_col_num]);
                    end
                end else begin
                    for (genvar simd_idx = 0; simd_idx < SIMD_WIDTH; simd_idx = simd_idx + 1) begin: simd_zero_iter
                        partial_sum[m1_row_num][m2_col_num][0][d0_item_num + simd_idx][simd_idx] = 0;
                    end
                end
                valid_buffer[0] = valid_in;
            end
        end
        
        // summation stages (tree - pipelined)
        for (depth = 0; depth < DEPTH; depth++) begin: depth_iter
            for (item_num = 0; item_num < N/2**(depth+1); item_num++) begin: item_iter
                always_ff @(posedge clk) begin
                  if (cen) begin
                    for (genvar simd_idx = 0; simd_idx < SIMD_WIDTH; simd_idx = simd_idx + 1) begin: simd_sum_iter
                        partial_sum[m1_row_num][m2_col_num][depth+1][item_num*SIMD_WIDTH + simd_idx][simd_idx] <=
                            partial_sum[m1_row_num][m2_col_num][depth][2*item_num*SIMD_WIDTH + simd_idx] +
                            partial_sum[m1_row_num][m2_col_num][depth][2*item_num*SIMD_WIDTH + simd_idx + 1];
                    end
                    valid_buffer[depth+1] <= valid_buffer[depth];
                  end
                end
            end
        end

        assign result[m1_row_num][m2_col_num] = partial_sum[m1_row_num][m2_col_num][DEPTH][0][0]; // Take the result from one lane of SIMD
        assign valid_out = valid_buffer[DEPTH];
    end
end
endgenerate
endmodule