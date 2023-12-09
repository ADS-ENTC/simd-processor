timeprecision 1ps;
timeunit 1ns;

module pe_top_tb;

// signals for the module
logic clk, rstn, stop, valid;

pe_top dut (.*);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end


logic [3:0][31:0] matrix_a [4];
logic [3:0][31:0] matrix_b [4];
logic [0:3][31:0] matrix_ans [4];

initial begin
    @(negedge clk);
    rstn = 0;
    valid = 0;
    
    #100;

    @(negedge clk);
    rstn = 1;

    repeat (100) begin
        for (int i=0; i<4; i++) begin
            for (int j=0; j<4; j++) begin
                matrix_a[i][j] = $urandom_range(0, 2**32-1);
                matrix_b[i][j] = $urandom_range(0, 2**32-1);
                matrix_ans[i][j] = 0;
            end
        end

        @(negedge clk);
        for (int i=0; i<4; i++) begin
            dut.fetch_unit.ram_a[i] = matrix_a[i];
            dut.fetch_unit.ram_b[i] = matrix_b[i];
        end

        $readmemb("C:/Users/supun/OneDrive - University of Moratuwa/Campus Academics/Campus/Campus Notes/Sem 7/Advanced Digital Systems/SIMD Processor Project/simd-matrix-accelerator/tb/cmds_bin.mem", dut.fetch_unit.ram_inst);

        @(negedge clk);
        valid = 1;

        @(negedge clk);
        valid = 0;


        while (!stop)
            @(negedge clk);
        
        #10;

        for (int i=0; i<4; i++) begin
            for (int j=0; j<4; j++) begin
                for (int k=0; k<4; k++) begin
                    matrix_ans[i][j] = matrix_ans[i][j] + (matrix_a[i][k] * matrix_b[j][k]);
                end
            end
        end

        assert(matrix_ans == dut.fetch_unit.ram_result[0:3])
            $display("Test passed");
        else
            $error("TEST FAILED. Expected: %p, Got: %p", matrix_ans, dut.fetch_unit.ram_result[0:3]);
            // $display("M1: %p & M2: %p", matrix_a, matrix_b);
        
        // @(negedge clk);
        // rstn = 0;

        // @(negedge clk);
        // rstn = 1;
    end

    $finish;
end

endmodule