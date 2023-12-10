timeprecision 1ps;
timeunit 1ns;

module top_tb;

logic rstn, clk, valid, stop;

top dut (.*);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

logic [7:0][31:0] matrix_a [8];
logic [7:0][31:0] matrix_b [8];
logic [0:7][31:0] matrix_ans [8];
logic [0:7][31:0] matrix_hold [8];

initial begin
    @(negedge clk);
    rstn = 0;
    valid = 0;
    
    #100;

    @(negedge clk);
    rstn = 1;

    repeat (100) begin
        for (int i=0; i<8; i++) begin
            for (int j=0; j<8; j++) begin
                matrix_a[i][j] = $urandom_range(0, 2**32-1);
                matrix_b[i][j] = $urandom_range(0, 2**32-1);
                matrix_ans[i][j] = 0;
            end
        end

        @(negedge clk);
        for (int i=0; i<8; i++) begin
            dut.ram_a.mem[2*i] = matrix_a[i][3:0];
            dut.ram_a.mem[2*i+1] = matrix_a[i][7:4];

            dut.ram_b.mem[2*i] = matrix_b[i][3:0];
            dut.ram_b.mem[2*i+1] = matrix_b[i][7:4];
        end

        $readmemb("C:/Users/supun/OneDrive - University of Moratuwa/Campus Academics/Campus/Campus Notes/Sem 7/Advanced Digital Systems/SIMD Processor Project/simd-matrix-accelerator/compiler/cmds/MATMUL_8x8_8x8_4.bin.txt", dut.ram_inst.mem);

        @(negedge clk);
        valid = 1;

        @(negedge clk);
        valid = 0;


        while (!stop)
            @(negedge clk);
        
        #10;

        for (int i=0; i<8; i++) begin
            for (int j=0; j<8; j++) begin
                for (int k=0; k<8; k++) begin
                    matrix_ans[i][j] = matrix_ans[i][j] + (matrix_a[i][k] * matrix_b[j][k]);
                end
            end
        end

        for (int i=0; i<8; i++) begin
            matrix_hold[i] = {dut.ram_result.mem[2*i], dut.ram_result.mem[2*i+1]};
        end

        assert(matrix_ans == matrix_hold)
            $display("Test passed");
        else
            $error("TEST FAILED. Expected: %p, Got: %p", matrix_ans, matrix_hold);
    end

    $finish;
end

endmodule