`timescale 1 ns / 1 ps

module fetch_unit_M00_AXIS_tb;
    parameter BRAM_DEPTH = 10;
    parameter integer C_M_AXIS_TDATA_WIDTH	= 32;
    parameter integer C_M_START_COUNT	= 32;

    reg  						VALID_PE2FU;
    wire  	[31:0] 				mat_res_dout;
    wire 	[BRAM_DEPTH-1:0] 	mat_res_addr;
    wire                        mat_res_ren;
    reg [31:0] res_size;
    reg   M_AXIS_ACLK;
    reg   M_AXIS_ARESETN;
    wire   M_AXIS_TVALID;
    wire  [C_M_AXIS_TDATA_WIDTH-1 : 0] M_AXIS_TDATA;
    wire  [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] M_AXIS_TSTRB;
    wire   M_AXIS_TLAST;
    reg   M_AXIS_TREADY;

    fetch_unit_v1_0_M00_AXIS dut(
        .VALID_PE2FU(VALID_PE2FU),
        .mat_res_dout(mat_res_dout),
        .mat_res_addr(mat_res_addr),
        .mat_res_ren(mat_res_ren),
        .res_size(res_size),

        .M_AXIS_ACLK(M_AXIS_ACLK),
        .M_AXIS_ARESETN(M_AXIS_ARESETN),
        .M_AXIS_TVALID(M_AXIS_TVALID),
        .M_AXIS_TDATA(M_AXIS_TDATA),
        .M_AXIS_TSTRB(M_AXIS_TSTRB),
        .M_AXIS_TLAST(M_AXIS_TLAST),
        .M_AXIS_TREADY(M_AXIS_TREADY)
    );

    bram #(
        .DATA_WIDTH(C_M_AXIS_TDATA_WIDTH),
        .DEPTH(256)
    ) bram_inst (
        .clk(M_AXIS_ACLK),
        .addr(mat_res_addr),
        .data_out(mat_res_dout),
        .data_in(32'h0),
        .we(1'b0),
        .re(mat_res_ren)
    );


    initial begin
        M_AXIS_ACLK = 0;
        forever #5 M_AXIS_ACLK = ~M_AXIS_ACLK;
    end

    initial begin
        $readmemh("/home/dakshina/Projects/ADS/simd-matrix-accelerator/tb/ram.txt", bram_inst.mem);
        res_size = 8;

        M_AXIS_ARESETN = 0;
        #10 M_AXIS_ARESETN = 1;

        @(negedge M_AXIS_ACLK);
        VALID_PE2FU = 0;
        M_AXIS_TREADY = 0;

        @(negedge M_AXIS_ACLK);
        VALID_PE2FU = 1;

        @(negedge M_AXIS_ACLK);
        @(negedge M_AXIS_ACLK);
        M_AXIS_TREADY = 1;

        @(negedge M_AXIS_ACLK);
        @(negedge M_AXIS_ACLK);
        @(negedge M_AXIS_ACLK);
        @(negedge M_AXIS_ACLK);
        @(negedge M_AXIS_ACLK);
        M_AXIS_TREADY = 0;

        @(negedge M_AXIS_ACLK);
        M_AXIS_TREADY = 1;





        #5000;
    end


endmodule