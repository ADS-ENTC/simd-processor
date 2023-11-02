`timescale 1ns/1ps

module mat_mul_tb;
    localparam W_IN = 8;
    localparam W_OUT = 32;
    localparam N = 8;

    localparam delay = $clog2(N) + 1;

    logic clk, cen, valid_in, valid_out, mode;
    logic signed [N-1:0][N-1:0][W_IN-1:0] matrix_1;
    logic signed [N-1:0][N-1:0][W_IN-1:0] matrix_2;
    logic signed [N-1:0][N-1:0][W_OUT-1:0] result;
    logic signed [N-1:0][N-1:0][W_OUT-1:0] exp_result;

    mat_mul #(.W_IN(W_IN), .W_OUT(W_OUT), .N(N)) dut (.*);

    // simulating the clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // simulating the device functionality
    initial begin
        $srandom(56);

        // testing for multiplication
        $display("Testing the multiplication");

        cen = 1;
        mode = 0;
        repeat (10) begin
            $display("========== Test Case ==========");
            valid_in = $urandom_range(0, 1);

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
            assert (valid_in == valid_out)
                $display("OK Valid: %d", valid_out);
            else
                $error("Valid signals do not match: valid_in = %d, valid_out = %d", valid_in, valid_out);

            if (valid_out == 1) begin
                assert (result == exp_result) 
                    $display("OK Result");
                else
                    $error("Output does not match: result = %p, exp_result = %p", result, exp_result);
            end
        end

        // testing for addition
        $display("Testing the addition");

        cen = 1;
        mode = 1;
        repeat (10) begin
            $display("========== Test Case ==========");
            valid_in = $urandom_range(0, 1);

            // giving the inputs
            @(posedge clk);
            #1
            for (int i=0; i<N; i++) begin
                for (int j=0; j<N; j++) begin
                    matrix_1[i][j] = $urandom_range(0, 2**W_IN-1);
                    matrix_2[i][j] = $urandom_range(0, 2**W_IN-1);
                end
            end

            // calculating the expected result
            for (int i=0; i<N; i++) begin
                for (int j=0; j<N; j++) begin
                    exp_result[i][j] = $signed(matrix_1[i][j]) + $signed(matrix_2[i][j]);
                end
            end

            // checking the accuracy of the result
            @(posedge clk);
            #1

            assert (valid_in == valid_out)
                $display("OK Valid: %d", valid_out);
            else
                $error("Valid signals do not match: valid_in = %d, valid_out = %d", valid_in, valid_out);

            if (valid_out == 1) begin
                assert (result == exp_result) 
                    $display("OK Result");
                else
                    $error("Output does not match: result = %p, exp_result = %p", result, exp_result);
            end
        end

        // testing for multiplication and addition intermitently
        $display("Testing the multiplication and addition intermitently");

        cen = 1;

        repeat (10) begin
            $display("========== Test Case ==========");
            
            // Multiplication
            mode = 0;
            valid_in = $urandom_range(0, 1);

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
            assert (valid_in == valid_out)
                $display("OK Valid: %d [Multiplication]", valid_out);
            else
                $error("Valid signals do not match: valid_in = %d, valid_out = %d [Multiplication]", valid_in, valid_out);

            if (valid_out == 1) begin
                assert (result == exp_result) 
                    $display("OK Result [Multiplication]");
                else
                    $error("Output does not match: result = %p, exp_result = %p [Multiplication]", result, exp_result);
            end      

            // Addition 
            mode = 1;
            valid_in = $urandom_range(0, 1);

            // giving the inputs
            @(posedge clk);
            #1
            for (int i=0; i<N; i++) begin
                for (int j=0; j<N; j++) begin
                    matrix_1[i][j] = $urandom_range(0, 2**W_IN-1);
                    matrix_2[i][j] = $urandom_range(0, 2**W_IN-1);
                end
            end

            // calculating the expected result
            for (int i=0; i<N; i++) begin
                for (int j=0; j<N; j++) begin
                    exp_result[i][j] = $signed(matrix_1[i][j]) + $signed(matrix_2[i][j]);
                end
            end

            // checking the accuracy of the result
            @(posedge clk);
            #1

            assert (valid_in == valid_out)
                $display("OK Valid: %d [Addition]", valid_out);
            else
                $error("Valid signals do not match: valid_in = %d, valid_out = %d [Addition]", valid_in, valid_out);

            if (valid_out == 1) begin
                assert (result == exp_result) 
                    $display("OK Result [Addition]");
                else
                    $error("Output does not match: result = %p, exp_result = %p [Addition]", result, exp_result);
            end      
        end
        
        $stop;
    end
    
endmodule