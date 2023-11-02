module mat_mul #(
    parameter W_IN = 8,
    parameter W_OUT = 32,
    parameter N = 2 // N*N matrix
)(
    input logic clk, cen, valid_in,  mode,
    input logic signed [W_IN-1:0] matrix_1 [N][N], 
    input logic signed [W_IN-1:0] matrix_2 [N][N],
    output logic valid_out,
    output logic signed [W_OUT-1:0] result [N][N]
);

localparam DEPTH = $clog2(N); // number of summation stages for multiplication

logic signed [W_OUT-1:0] partial_sum [N][N][DEPTH+1][N]; // holds the intermediate values of the summation stages in multiplication
logic valid_buffer[DEPTH+1]; // holds the valid signal for each summation stage for multiplication 

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
                
                // if the module is in multiplication mode buffer the valid signal
                valid_buffer[0] = valid_in & (~mode);
            end
        end
        
        // summation stages (tree - pipelined)
        for (depth = 0; depth < DEPTH; depth++) begin: depth_iter
            for (item_num = 0; item_num < N/2**(depth+1); item_num++) begin: item_iter
                always_ff @(posedge clk) begin
                  if (cen && mode == 0'b0) begin
                    partial_sum[m1_row_num][m2_col_num][depth+1][item_num] <= partial_sum[m1_row_num][m2_col_num][depth][2*item_num] + partial_sum[m1_row_num][m2_col_num][depth][2*item_num+1];
                    valid_buffer[depth+1] <= valid_buffer[depth];
                  end
                end
            end
        end

        // assign the result
        always_comb begin
            if (mode == 0'b0)
                result[m1_row_num][m2_col_num] = partial_sum[m1_row_num][m2_col_num][DEPTH][0];
            else
                result[m1_row_num][m2_col_num] = matrix_1[m1_row_num][m2_col_num] + matrix_2[m1_row_num][m2_col_num];
        end
    end
end
endgenerate

always_comb begin
    valid_out = (mode == 0'b0) ? valid_buffer[DEPTH] : valid_in;
end


endmodule