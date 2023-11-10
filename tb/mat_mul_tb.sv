`timescale 1ns/1ps

module mat_mul_tb;
    localparam W_IN = 8;
    localparam W_OUT = 32;
    localparam N = 4;

    localparam delay = $clog2(N) + 2;

    logic clk, resetn, valid_in, valid_out;
    // logic signed [N-1:0][N-1:0][W_IN-1:0] matrix_1, matrix_2;
    logic signed [2*N*N*W_IN-1:0] data_in;
    logic signed [N-1:0][N-1:0][W_OUT-1:0] result, exp_result;

    mat_mul_wrapper #(.W_IN(W_IN), .W_OUT(W_OUT), .N(N)) dut (.clk(clk), .resetn(resetn), .valid_in(valid_in), .data_in(data_in), .valid_out(valid_out), .result(result));
    // mat_mul #(.W_IN(W_IN), .W_OUT(W_OUT), .N(N)) dut (.*);

    logic signed [N-1:0][4*N-1:0][W_IN-1:0] big_matrix_1;
    logic signed [4*N-1:0][N-1:0][W_IN-1:0] big_matrix_2;

    logic signed [N-1:0][N-1:0][W_IN-1:0] matrix_1;
    logic signed [N-1:0][N-1:0][W_IN-1:0] matrix_2;

    int start_index;
    int valid_out_count;

    covergroup cg;
        cp_matrix_1: coverpoint matrix_1;
        cp_matrix_2: coverpoint matrix_2;
    endgroup

    cg cg_inst;

    // simulating the clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // simulating the device functionality
    initial begin
        cg_inst = new();
        
        $srandom(1);
        valid_in = 0;
        repeat (10) begin
            // making random big matrices
            for (int i=0; i<N; i++) begin
                for (int j=0; j<4*N; j++) begin
                    big_matrix_1[i][j] = $urandom_range(0, 2**W_IN-1);
                    big_matrix_2[j][i] = $urandom_range(0, 2**W_IN-1);
                end
            end

            // resetting the MM
            @(posedge clk);
            #1
            resetn = 0;

            @(posedge clk);
            #1
            resetn = 1;

            start_index = 0;
            valid_out_count = 0;

            repeat (4) begin
                @(posedge clk);
                #1
                valid_in = 1;
                for (int i=0; i<N; i++) begin
                    for (int j=0; j<N; j++) begin
                        matrix_1[i][j] = big_matrix_1[i][start_index+j];
                        matrix_2[i][j] = big_matrix_2[start_index+i][j];
                    end
                end

                data_in = {matrix_2, matrix_1};

                start_index += N;

                if (valid_out)
                    valid_out_count += 1;
                
                cg_inst.sample();
            end

            @(posedge clk);
            #1
            valid_in = 0;
            if (valid_out)
                valid_out_count += 1;

            // waiting for the latency
            while (valid_out_count < 4) begin
                @(posedge clk);
                #1
                if (valid_out)
                    valid_out_count += 1;
            end


            // calculating the expected result
            for (int i=0; i<N; i++) begin
                for (int j=0; j<N; j++) begin
                    exp_result[i][j] = 0;
                    for (int k=0; k<4*N; k++) begin
                        exp_result[i][j] = $signed(exp_result[i][j]) + $signed(big_matrix_1[i][k]) * $signed(big_matrix_2[k][j]);
                    end
                end
            end

            // checking the accuracy of the result
            assert (result == exp_result) 
                $display("OK");
            else
                $error("Output does not match: result = %p, exp_result = %p", result, exp_result);
        end
        
        $display("Matrix 1 Coverage: %0.2f %%", cg_inst.cp_matrix_1.get_inst_coverage());
        $display("Matrix 2 Coverage: %0.2f %%", cg_inst.cp_matrix_2.get_inst_coverage());
        
        $stop;
    end
    
endmodule