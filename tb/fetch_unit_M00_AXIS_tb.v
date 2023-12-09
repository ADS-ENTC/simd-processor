`timescale 1 ns / 1 ps

module fetch_unit_M00_AXIS_tb;
    parameter BRAM_DEPTH = 10;
    parameter integer C_M_AXIS_TDATA_WIDTH	= 32;
    parameter integer C_M_START_COUNT	= 32;

    reg  						VALID_PE2FU;
    reg  	[31:0] 				mat_res_dout;
    wire 	[BRAM_DEPTH-1:0] 	mat_res_addr;
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
        .res_size(res_size),

        .M_AXIS_ACLK(M_AXIS_ACLK),
        .M_AXIS_ARESETN(M_AXIS_ARESETN),
        .M_AXIS_TVALID(M_AXIS_TVALID),
        .M_AXIS_TDATA(M_AXIS_TDATA),
        .M_AXIS_TSTRB(M_AXIS_TSTRB),
        .M_AXIS_TLAST(M_AXIS_TLAST),
        .M_AXIS_TREADY(M_AXIS_TREADY)
    );

    initial begin
        M_AXIS_ACLK = 0;
        forever #5 M_AXIS_ACLK = ~M_AXIS_ACLK;
    end

    initial begin
        res_size = 16;

        M_AXIS_ARESETN = 0;
        #10 M_AXIS_ARESETN = 1;

        @(negedge M_AXIS_ACLK);
        VALID_PE2FU = 0;
        M_AXIS_TREADY = 0;
        mat_res_dout = 1;

        @(negedge M_AXIS_ACLK);
        VALID_PE2FU = 1;

        while (M_AXIS_TVALID == 0) begin
            @(negedge M_AXIS_ACLK);
        end
        M_AXIS_TREADY = 1;

        while (mat_res_addr != 1) begin
            @(negedge M_AXIS_ACLK);
        end
        @(negedge M_AXIS_ACLK);
        mat_res_dout = 2;

        @(negedge M_AXIS_ACLK);
        mat_res_dout = 3;

        @(negedge M_AXIS_ACLK);
        mat_res_dout = 4;

        @(negedge M_AXIS_ACLK);
        mat_res_dout = 5;

        @(negedge M_AXIS_ACLK);
        mat_res_dout = 6;

        @(negedge M_AXIS_ACLK);
        mat_res_dout = 7    ;




    end


endmodule