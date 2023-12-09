timeprecision 1ps;
timeunit 1ns;

module pe_top_tb;

// signals for the module
logic clk, rstn, stop;

pe_top dut (.*);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end


logic [3:0][31:0] matrix_a [4];
logic [3:0][31:0] matrix_b [4];
logic [3:0][31:0] matrix_ans [4];

initial begin
    @(negedge clk);
    rstn = 0;
    
    #100;

    for (int i=0; i<4; i++) begin
        for (int j=0; j<4; j++) begin
            matrix_a[i][j] = 1;
            matrix_b[i][j] = 1;
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
    rstn = 1;


    while (!stop)
        @(negedge clk);
    
    #10;

    for (int i=0; i<4; i++) begin
        for (int j=0; j<4; j++) begin
            for (int k=0; k<4; k++) begin
                matrix_ans[i][j] = matrix_ans[i][j] + (matrix_a[i][k] * matrix_b[k][j]);
            end
        end
    end

    assert(matrix_ans[0] == dut.fetch_unit.ram_result[0] && matrix_ans[1] == dut.fetch_unit.ram_result[1] && matrix_ans[2] == dut.fetch_unit.ram_result[2] && matrix_ans[3] == dut.fetch_unit.ram_result[3])
        $display("Test passed");
    else
        $error("TEST FAILED. Expected: %p, Got: %p", matrix_ans, dut.fetch_unit.ram_result);

    $finish;
end

endmodule