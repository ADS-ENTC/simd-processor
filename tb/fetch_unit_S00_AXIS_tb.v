`timescale 1 ns / 1 ps

module fetch_unit_S00_AXIS_tb;
    parameter BRAM_DEPTH = 10;
    parameter INSTR_BRAM_DEPTH = 11;
    parameter integer C_S_AXIS_TDATA_WIDTH	= 32;

    wire [BRAM_DEPTH-1:0] mat_a_addr;
    wire [31:0] mat_a_din;
    wire mat_a_en;
    wire [BRAM_DEPTH-1:0] mat_b_addr;
    wire [31:0] mat_b_din;
    wire mat_b_en;
    wire [INSTR_BRAM_DEPTH-1:0] instr_addr;
    wire [31:0] instr_din;
    wire instr_en;
    reg [1:0] bram_sel;
    reg [31:0] row_width;
    wire  VALID_FU2PE;

    reg   S_AXIS_ACLK;
    reg   S_AXIS_ARESETN;
    wire  S_AXIS_TREADY;
    reg  [C_S_AXIS_TDATA_WIDTH-1 : 0] S_AXIS_TDATA;
    reg  [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0] S_AXIS_TSTRB;
    reg   S_AXIS_TLAST;
    reg  S_AXIS_TVALID;


    fetch_unit_v1_0_S00_AXIS dut(
        .mat_a_addr(mat_a_addr),
        .mat_a_din(mat_a_din),
        .mat_a_en(mat_a_en),
        .mat_b_addr(mat_b_addr),
        .mat_b_din(mat_b_din),
        .mat_b_en(mat_b_en),
        .instr_addr(instr_addr),
        .instr_din(instr_din),
        .instr_en(instr_en),
        .bram_sel(bram_sel),
        .row_width(row_width),
        .VALID_FU2PE(VALID_FU2PE),

        .S_AXIS_ACLK(S_AXIS_ACLK),
        .S_AXIS_ARESETN(S_AXIS_ARESETN),
        .S_AXIS_TREADY(S_AXIS_TREADY),
        .S_AXIS_TDATA(S_AXIS_TDATA),
        .S_AXIS_TSTRB(S_AXIS_TSTRB),
        .S_AXIS_TLAST(S_AXIS_TLAST),
        .S_AXIS_TVALID(S_AXIS_TVALID)
    );

    initial begin
        S_AXIS_ACLK = 0;
        forever #5 S_AXIS_ACLK = ~S_AXIS_ACLK;
    end

    initial begin
        S_AXIS_ARESETN = 0;
        #10 S_AXIS_ARESETN = 1;
        S_AXIS_TVALID = 0;
        #50;

        bram_sel = 0;
        row_width = 2;
        
        #1;
        
        @(negedge S_AXIS_ACLK);
        S_AXIS_TVALID = 1;
        S_AXIS_TLAST = 0;
        S_AXIS_TSTRB = 15;
        S_AXIS_TDATA = 1;
        @(negedge S_AXIS_ACLK);
        while (S_AXIS_TREADY == 0) @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 2;
        @(negedge S_AXIS_ACLK);
        while (S_AXIS_TREADY == 0) @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 3;
        @(negedge S_AXIS_ACLK);
        while (S_AXIS_TREADY == 0) @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 4;
        @(negedge S_AXIS_ACLK);
        while (S_AXIS_TREADY == 0) @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 5;
        @(negedge S_AXIS_ACLK);
        while (S_AXIS_TREADY == 0) @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 6;
        @(negedge S_AXIS_ACLK);
        while (S_AXIS_TREADY == 0) @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 7;
        @(negedge S_AXIS_ACLK);
        while (S_AXIS_TREADY == 0) @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 8;
        @(negedge S_AXIS_ACLK);
        while (S_AXIS_TREADY == 0) @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 9;
        @(negedge S_AXIS_ACLK);
        while (S_AXIS_TREADY == 0) @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 10;
        @(negedge S_AXIS_ACLK);
        while (S_AXIS_TREADY == 0) @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 11;
        @(negedge S_AXIS_ACLK);
        while (S_AXIS_TREADY == 0) @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 12;
        @(negedge S_AXIS_ACLK);
        while (S_AXIS_TREADY == 0) @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 13;
        @(negedge S_AXIS_ACLK);
        while (S_AXIS_TREADY == 0) @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 14;
        @(negedge S_AXIS_ACLK);
        while (S_AXIS_TREADY == 0) @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 15;
        @(negedge S_AXIS_ACLK);
        while (S_AXIS_TREADY == 0) @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 16;
        S_AXIS_TLAST = 1;
        @(negedge S_AXIS_ACLK);
        S_AXIS_TVALID = 0;
        S_AXIS_TLAST = 0;

        #100;


        bram_sel = 1;
        row_width = 5;
        
        #1;
        
        @(negedge S_AXIS_ACLK);
        S_AXIS_TVALID = 1;
        S_AXIS_TLAST = 0;
        S_AXIS_TSTRB = 15;
        S_AXIS_TDATA = 1;
        @(negedge S_AXIS_ACLK);
        while (S_AXIS_TREADY == 0) @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 2;
        @(negedge S_AXIS_ACLK);
        while (S_AXIS_TREADY == 0) @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 3;
        @(negedge S_AXIS_ACLK);
        while (S_AXIS_TREADY == 0) @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 4;
        @(negedge S_AXIS_ACLK);
        while (S_AXIS_TREADY == 0) @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 5;
        @(negedge S_AXIS_ACLK);
        while (S_AXIS_TREADY == 0) @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 6;
        @(negedge S_AXIS_ACLK);
        while (S_AXIS_TREADY == 0) @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 7;
        @(negedge S_AXIS_ACLK);
        while (S_AXIS_TREADY == 0) @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 8;
        @(negedge S_AXIS_ACLK);
        while (S_AXIS_TREADY == 0) @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 9;
        @(negedge S_AXIS_ACLK);
        while (S_AXIS_TREADY == 0) @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 10;
        @(negedge S_AXIS_ACLK);
        while (S_AXIS_TREADY == 0) @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 11;
        @(negedge S_AXIS_ACLK);
        while (S_AXIS_TREADY == 0) @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 12;
        @(negedge S_AXIS_ACLK);
        while (S_AXIS_TREADY == 0) @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 13;
        @(negedge S_AXIS_ACLK);
        while (S_AXIS_TREADY == 0) @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 14;
        @(negedge S_AXIS_ACLK);
        while (S_AXIS_TREADY == 0) @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 15;
        S_AXIS_TLAST = 1;
        @(negedge S_AXIS_ACLK);
        S_AXIS_TVALID = 0;
        S_AXIS_TLAST = 0;

        #100;


        bram_sel = 2;
        row_width = 5;
        
        #1;
        
        @(negedge S_AXIS_ACLK);
        S_AXIS_TVALID = 1;
        S_AXIS_TLAST = 0;
        S_AXIS_TSTRB = 15;
        S_AXIS_TDATA = 1;
        @(negedge S_AXIS_ACLK);
        while (S_AXIS_TREADY == 0) @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 2;
        @(negedge S_AXIS_ACLK);
        while (S_AXIS_TREADY == 0) @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 3;
        @(negedge S_AXIS_ACLK);
        while (S_AXIS_TREADY == 0) @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 4;
        @(negedge S_AXIS_ACLK);
        while (S_AXIS_TREADY == 0) @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 5;
        @(negedge S_AXIS_ACLK);
        while (S_AXIS_TREADY == 0) @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 6;
        @(negedge S_AXIS_ACLK);
        while (S_AXIS_TREADY == 0) @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 7;
        @(negedge S_AXIS_ACLK);
        while (S_AXIS_TREADY == 0) @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 8;
        @(negedge S_AXIS_ACLK);
        while (S_AXIS_TREADY == 0) @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 9;
        @(negedge S_AXIS_ACLK);
        while (S_AXIS_TREADY == 0) @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 10;
        @(negedge S_AXIS_ACLK);
        while (S_AXIS_TREADY == 0) @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 11;
        @(negedge S_AXIS_ACLK);
        while (S_AXIS_TREADY == 0) @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 12;
        @(negedge S_AXIS_ACLK);
        while (S_AXIS_TREADY == 0) @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 13;
        @(negedge S_AXIS_ACLK);
        while (S_AXIS_TREADY == 0) @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 14;
        @(negedge S_AXIS_ACLK);
        while (S_AXIS_TREADY == 0) @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 15;
        S_AXIS_TLAST = 1;
        @(negedge S_AXIS_ACLK);
        S_AXIS_TVALID = 0;
        S_AXIS_TLAST = 0;

        #100;


    end





endmodule