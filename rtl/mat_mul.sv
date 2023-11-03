module mat_mul #(
    parameter W_IN = 8,
    parameter W_OUT = 32,
    parameter N = 2 // N*N matrix
)(
    input logic clk, cen, valid_in,
    input logic signed [N-1:0][N-1:0][W_IN-1:0] matrix_1, matrix_2,
    output logic valid_out,
    output logic signed [N-1:0][N-1:0][W_OUT-1:0] result
);

localparam DEPTH = $clog2(N); // number of summation stages

logic signed [N-1:0][N-1:0][DEPTH:0][N-1:0][W_OUT-1:0] partial_sum; // holds the intermediate values of the summation stages
logic valid_buffer[DEPTH+1]; // holds the valid signal for each summation stage

genvar m1_row_num, m2_col_num, d0_item_num, depth, item_num;
generate
for (m1_row_num = 0; m1_row_num < N; m1_row_num = m1_row_num + 1) begin: m1_row_iter
    for (m2_col_num = 0; m2_col_num < N; m2_col_num++) begin: m2_col_iter

        // multiplication stage
        for (d0_item_num = 0; d0_item_num < N; d0_item_num++) begin: d0_item_iter
            always_comb begin
                // takes the inputs only if the valid is high
                if (valid_in)
                    partial_sum[m1_row_num][m2_col_num][0][d0_item_num] = $signed(matrix_1[m1_row_num][d0_item_num]) * $signed(matrix_2[d0_item_num][m2_col_num]);
                else
                    partial_sum[m1_row_num][m2_col_num][0][d0_item_num] = 0;
                
                valid_buffer[0] = valid_in;
            end
        end
        
        // summation stages (tree - pipelined)
        for (depth = 0; depth < DEPTH; depth++) begin: depth_iter
            for (item_num = 0; item_num < N/2**(depth+1); item_num++) begin: item_iter
                always_ff @(posedge clk) begin
                  if (cen) begin
                    partial_sum[m1_row_num][m2_col_num][depth+1][item_num] <= partial_sum[m1_row_num][m2_col_num][depth][2*item_num] + partial_sum[m1_row_num][m2_col_num][depth][2*item_num+1];
                    valid_buffer[depth+1] <= valid_buffer[depth];
                  end
                end
            end
        end

        assign result[m1_row_num][m2_col_num] = partial_sum[m1_row_num][m2_col_num][DEPTH][0];
        assign valid_out = valid_buffer[DEPTH];
    end
end
endgenerate
endmodule