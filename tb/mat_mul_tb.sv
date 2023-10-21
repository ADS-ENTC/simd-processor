`timescale 1ns/1ps

module mat_mul_tb;
    localparam W_IN = 8;
    localparam W_OUT = 32;
    localparam N = 8;

    localparam delay = $clog2(N) + 1;

    logic clk, cen, valid_in, valid_out;
    logic signed [N-1:0][N-1:0][W_IN-1:0] matrix_1, matrix_2;
    logic signed [N-1:0][N-1:0][W_OUT-1:0] result, exp_result;

    mat_mul #(.W_IN(W_IN), .W_OUT(W_OUT), .N(N)) dut (.*);

    // simulating the clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // simulating the device functionality
    initial begin
        $srandom(56);
        cen = 1;
        valid_in = 1;
        repeat (10) begin
            repeat (2) @(posedge clk);
            
            // giving the inputs
            @(posedge clk);
            #1
            for (int i=0; i<N; i++) begin
                for (int j=0; j<N; j++) begin
                    matrix_1[i][j] = $urandom_range(0, 2**W_IN-1);
                    matrix_2[i][j] = $urandom_range(0, 2**W_IN-1);
                end
            end

            // waiting for the latency
            repeat (delay) @(posedge clk);
            #1

            // calculating the expected result
            for (int i=0; i<N; i++) begin : matrix_1_row_iter
                for (int j=0; j<N; j++) begin : matrix_2_column_iter
                    exp_result[i][j] = 0;
                    for (int k=0; k<N; k++) begin : item_iter
                        exp_result[i][j] = $signed(exp_result[i][j]) + $signed(matrix_1[i][k]) * $signed(matrix_2[k][j]);
                    end
                end
            end

            // checking the accuracy of the result
            assert (result == exp_result) 
                $display("OK");
            else
                $error("Output does not match: result = %p, exp_result = %p", result, exp_result);
        end
        
        $stop;
    end
    
endmodule