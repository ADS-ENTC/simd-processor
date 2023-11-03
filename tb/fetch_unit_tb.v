`timescale 1ns / 1ps

module fetch_unit_tb;
    parameter integer MATRIX_SIZE = 2;
    parameter integer W_IN = 8;
    parameter integer C_S00_AXI_DATA_WIDTH	= 32;
    parameter integer C_S00_AXI_ADDR_WIDTH	= 4;
    parameter integer C_M00_AXIS_TDATA_WIDTH	= 32;
    parameter integer C_M00_AXIS_START_COUNT	= 32;
    parameter integer C_S00_AXIS_TDATA_WIDTH	= 32;

    wire  [2*MATRIX_SIZE*MATRIX_SIZE*W_IN-1 : 0] DATA_FU2PE_1;
    wire  [2*MATRIX_SIZE*MATRIX_SIZE*W_IN-1 : 0] DATA_FU2PE_2;
    wire  [2*MATRIX_SIZE*MATRIX_SIZE*W_IN-1 : 0] DATA_FU2PE_3;
    wire  [2*MATRIX_SIZE*MATRIX_SIZE*W_IN-1 : 0] DATA_FU2PE_4;

    wire VALID_FU2PE;

    reg [MATRIX_SIZE*MATRIX_SIZE*C_M00_AXIS_TDATA_WIDTH-1:0] DATA_PE2FU_1;
    reg [MATRIX_SIZE*MATRIX_SIZE*C_M00_AXIS_TDATA_WIDTH-1:0] DATA_PE2FU_2;
    reg [MATRIX_SIZE*MATRIX_SIZE*C_M00_AXIS_TDATA_WIDTH-1:0] DATA_PE2FU_3;
    reg [MATRIX_SIZE*MATRIX_SIZE*C_M00_AXIS_TDATA_WIDTH-1:0] DATA_PE2FU_4;

    reg VALID_PE2FU_1;
    reg VALID_PE2FU_2;
    reg VALID_PE2FU_3;
    reg VALID_PE2FU_4;
    // User ports ends
    // Do not modify the ports beyond this line


    // Ports of Axi Slave Bus Interface S00_AXI
    reg  s00_axi_aclk;
    reg  s00_axi_aresetn;
    reg [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr;
    reg [2 : 0] s00_axi_awprot;
    reg  s00_axi_awvalid;
    wire  s00_axi_awready;
    reg [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata;
    reg [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb;
    reg  s00_axi_wvalid;
    wire  s00_axi_wready;
    wire [1 : 0] s00_axi_bresp;
    wire  s00_axi_bvalid;
    reg  s00_axi_bready;
    reg [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr;
    reg [2 : 0] s00_axi_arprot;
    reg  s00_axi_arvalid;
    wire  s00_axi_arready;
    wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata;
    wire [1 : 0] s00_axi_rresp;
    wire  s00_axi_rvalid;
    reg  s00_axi_rready;

    // Ports of Axi Master Bus Interface M00_AXIS
    reg  m00_axis_aclk;
    reg  m00_axis_aresetn;
    wire  m00_axis_tvalid;
    wire [C_M00_AXIS_TDATA_WIDTH-1 : 0] m00_axis_tdata;
    wire [(C_M00_AXIS_TDATA_WIDTH/8)-1 : 0] m00_axis_tstrb;
    wire  m00_axis_tlast;
    reg  m00_axis_tready;

    // Ports of Axi Slave Bus Interface S00_AXIS
    reg  s00_axis_aclk;
    reg  s00_axis_aresetn;
    wire  s00_axis_tready;
    reg [C_S00_AXIS_TDATA_WIDTH-1 : 0] s00_axis_tdata;
    reg [(C_S00_AXIS_TDATA_WIDTH/8)-1 : 0] s00_axis_tstrb;
    reg  s00_axis_tlast;
    reg  s00_axis_tvalid;

    fetch_unit_v1_0 # ( 
        .MATRIX_SIZE(MATRIX_SIZE),
        .W_IN(W_IN),
        .C_S00_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
        .C_S00_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH),
        .C_M00_AXIS_TDATA_WIDTH(C_M00_AXIS_TDATA_WIDTH),
        .C_M00_AXIS_START_COUNT(C_M00_AXIS_START_COUNT),
        .C_S00_AXIS_TDATA_WIDTH(C_S00_AXIS_TDATA_WIDTH)
    ) fetch_unit_v1_0_inst (
        .DATA_FU2PE_1(DATA_FU2PE_1),
        .DATA_FU2PE_2(DATA_FU2PE_2),
        .DATA_FU2PE_3(DATA_FU2PE_3),
        .DATA_FU2PE_4(DATA_FU2PE_4),
        .VALID_FU2PE(VALID_FU2PE),
        .DATA_PE2FU_1(DATA_PE2FU_1),
        .DATA_PE2FU_2(DATA_PE2FU_2),
        .DATA_PE2FU_3(DATA_PE2FU_3),
        .DATA_PE2FU_4(DATA_PE2FU_4),
        .VALID_PE2FU_1(VALID_PE2FU_1),
        .VALID_PE2FU_2(VALID_PE2FU_2),
        .VALID_PE2FU_3(VALID_PE2FU_3),
        .VALID_PE2FU_4(VALID_PE2FU_4),
        .s00_axi_aclk(s00_axi_aclk),
        .s00_axi_aresetn(s00_axi_aresetn),
        .s00_axi_awaddr(s00_axi_awaddr),
        .s00_axi_awprot(s00_axi_awprot),
        .s00_axi_awvalid(s00_axi_awvalid),
        .s00_axi_awready(s00_axi_awready),
        .s00_axi_wdata(s00_axi_wdata),
        .s00_axi_wstrb(s00_axi_wstrb),
        .s00_axi_wvalid(s00_axi_wvalid),
        .s00_axi_wready(s00_axi_wready),
        .s00_axi_bresp(s00_axi_bresp),
        .s00_axi_bvalid(s00_axi_bvalid),
        .s00_axi_bready(s00_axi_bready),
        .s00_axi_araddr(s00_axi_araddr),
        .s00_axi_arprot(s00_axi_arprot),
        .s00_axi_arvalid(s00_axi_arvalid),
        .s00_axi_arready(s00_axi_arready),
        .s00_axi_rdata(s00_axi_rdata),
        .s00_axi_rresp(s00_axi_rresp),
        .s00_axi_rvalid(s00_axi_rvalid),
        .s00_axi_rready(s00_axi_rready),
        .m00_axis_aclk(m00_axis_aclk),
        .m00_axis_aresetn(m00_axis_aresetn),
        .m00_axis_tvalid(m00_axis_tvalid),
        .m00_axis_tdata(m00_axis_tdata),
        .m00_axis_tstrb(m00_axis_tstrb),
        .m00_axis_tlast(m00_axis_tlast),
        .m00_axis_tready(m00_axis_tready),
        .s00_axis_aclk(s00_axis_aclk),
        .s00_axis_aresetn(s00_axis_aresetn),
        .s00_axis_tready(s00_axis_tready),
        .s00_axis_tdata(s00_axis_tdata),
        .s00_axis_tstrb(s00_axis_tstrb),
        .s00_axis_tlast(s00_axis_tlast),
        .s00_axis_tvalid(s00_axis_tvalid)
    );

    initial begin
        s00_axis_aclk = 0;
        forever #5 s00_axis_aclk = ~s00_axis_aclk;
    end

    initial begin
        s00_axis_tstrb = 15;
        s00_axis_tlast = 0;
        s00_axis_aresetn = 0;
        #10 s00_axis_aresetn = 1;
        #20 s00_axis_tvalid = 1;

        #1;
        s00_axis_tdata = 5;
        @(negedge s00_axis_aclk);
        s00_axis_tdata = 8;
        @(negedge s00_axis_aclk);
        s00_axis_tdata = 2;
        @(negedge s00_axis_aclk);
        s00_axis_tdata = 3;
        @(negedge s00_axis_aclk);
        s00_axis_tdata = 4;
        @(negedge s00_axis_aclk);
        s00_axis_tdata = 5;
        @(negedge s00_axis_aclk);
        s00_axis_tdata = 6;
        @(negedge s00_axis_aclk);
        s00_axis_tdata = 7;
        // s00_axis_tlast = 1;
        @(negedge s00_axis_aclk);
        s00_axis_tvalid = 0;
        s00_axis_tlast = 0;

        #100;

        @(negedge s00_axis_aclk);
        s00_axis_tvalid = 1;
        s00_axis_tdata = 20;
        @(negedge s00_axis_aclk);
        s00_axis_tdata = 19;
        @(negedge s00_axis_aclk);
        s00_axis_tdata = 18;
        @(negedge s00_axis_aclk);
        s00_axis_tdata = 17;
        @(negedge s00_axis_aclk);
        s00_axis_tdata = 16;
        @(negedge s00_axis_aclk);
        s00_axis_tdata = 15;
        @(negedge s00_axis_aclk);
        s00_axis_tdata = 14;
        @(negedge s00_axis_aclk);
        s00_axis_tdata = 13;
        s00_axis_tlast = 1;
        @(negedge s00_axis_aclk);
        s00_axis_tvalid = 0;
        s00_axis_tlast = 0;


    end





endmodule
