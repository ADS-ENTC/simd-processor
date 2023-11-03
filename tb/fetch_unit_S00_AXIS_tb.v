`timescale 1 ns / 1 ps

module fetch_unit_S00_AXIS_tb;
    parameter integer MATRIX_SIZE	= 4;
    parameter integer W_IN = 8;
    parameter integer C_S_AXIS_TDATA_WIDTH	= 32;

    wire  [4*2*MATRIX_SIZE*MATRIX_SIZE*W_IN-1 : 0] data_out;

    // AXI4Stream sink: Clock
    reg S_AXIS_ACLK;
    // AXI4Stream sink: Reset
    reg  S_AXIS_ARESETN;
    // Ready to accept data in
    wire  S_AXIS_TREADY;
    // Data in
    reg [C_S_AXIS_TDATA_WIDTH-1 : 0] S_AXIS_TDATA;
    // Byte qualifier
    reg [(C_S_AXIS_TDATA_WIDTH/8)-1 : 0] S_AXIS_TSTRB;
    // Indicates boundary of last packet
    reg  S_AXIS_TLAST;
    // Data is in valid
    reg  S_AXIS_TVALID;

    fetch_unit_v1_0_S00_AXIS #(
        .MATRIX_SIZE(MATRIX_SIZE),
        .W_IN(W_IN),
        .C_S_AXIS_TDATA_WIDTH(C_S_AXIS_TDATA_WIDTH)
    ) fetch_unit_S00_AXIS_inst (
        .data_out(data_out),
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
        S_AXIS_TSTRB = 15;
        S_AXIS_ARESETN = 0;
        #10 S_AXIS_ARESETN = 1;
        #20 S_AXIS_TVALID = 1;

        #1;
        S_AXIS_TDATA = 5;
        @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 8;
        @(negedge S_AXIS_ACLK);
        S_AXIS_TDATA = 2;
        @(negedge S_AXIS_ACLK);

    end





endmodule