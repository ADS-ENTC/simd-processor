

	module fetch_unit_v1_0 #
	(
		// Users to add parameters here
		parameter BRAM_DEPTH = 10,
		parameter INSTR_BRAM_DEPTH = 11,
		// User parameters ends
		// Do not modify the parameters beyond this line

		// Parameters of Axi Slave Bus Interface S00_AXI
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 4,

		// Parameters of Axi Master Bus Interface M00_AXIS
		parameter integer C_M00_AXIS_TDATA_WIDTH	= 32,
		parameter integer C_M00_AXIS_START_COUNT	= 32,

		// Parameters of Axi Slave Bus Interface S00_AXIS
		parameter integer C_S00_AXIS_TDATA_WIDTH	= 32
	)
	(
		// Users to add ports here
		output [BRAM_DEPTH-1:0] mat_a_addr,
		output mat_a_clk,
		output [31:0] mat_a_din,
		output mat_a_en,
		output mat_a_we,

		output [BRAM_DEPTH-1:0] mat_b_addr,
		output mat_b_clk,
		output [31:0] mat_b_din,
		output mat_b_en,
		output mat_b_we,

		output [INSTR_BRAM_DEPTH-1:0] instr_addr,
		output instr_clk,
		output [31:0] instr_din,
		output instr_en,
		output instr_we,

		output wire VALID_FU2PE,

		
		output [BRAM_DEPTH-1:0] mat_res_addr,
		output mat_res_clk,
		input [31:0] mat_res_dout,
		output mat_res_ren,

		input wire VALID_PE2FU,


		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S00_AXI
		input wire  s00_axi_aclk,
		input wire  s00_axi_aresetn,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_awaddr,
		input wire [2 : 0] s00_axi_awprot,
		input wire  s00_axi_awvalid,
		output wire  s00_axi_awready,
		input wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_wdata,
		input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0] s00_axi_wstrb,
		input wire  s00_axi_wvalid,
		output wire  s00_axi_wready,
		output wire [1 : 0] s00_axi_bresp,
		output wire  s00_axi_bvalid,
		input wire  s00_axi_bready,
		input wire [C_S00_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
		input wire [2 : 0] s00_axi_arprot,
		input wire  s00_axi_arvalid,
		output wire  s00_axi_arready,
		output wire [C_S00_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
		output wire [1 : 0] s00_axi_rresp,
		output wire  s00_axi_rvalid,
		input wire  s00_axi_rready,

		// Ports of Axi Master Bus Interface M00_AXIS
		input wire  m00_axis_aclk,
		input wire  m00_axis_aresetn,
		output wire  m00_axis_tvalid,
		output wire [C_M00_AXIS_TDATA_WIDTH-1 : 0] m00_axis_tdata,
		output wire [(C_M00_AXIS_TDATA_WIDTH/8)-1 : 0] m00_axis_tstrb,
		output wire  m00_axis_tlast,
		input wire  m00_axis_tready,

		// Ports of Axi Slave Bus Interface S00_AXIS
		input wire  s00_axis_aclk,
		input wire  s00_axis_aresetn,
		output wire  s00_axis_tready,
		input wire [C_S00_AXIS_TDATA_WIDTH-1 : 0] s00_axis_tdata,
		input wire [(C_S00_AXIS_TDATA_WIDTH/8)-1 : 0] s00_axis_tstrb,
		input wire  s00_axis_tlast,
		input wire  s00_axis_tvalid
	);

	wire [1:0] bram_sel;
	wire [31:0] row_width;
	wire [31:0] res_size;

// Instantiation of Axi Bus Interface S00_AXI
	fetch_unit_v1_0_S00_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S00_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S00_AXI_ADDR_WIDTH)
	) fetch_unit_v1_0_S00_AXI_inst (
		.bram_sel(bram_sel),
		.row_width(row_width),
		.res_size(res_size),
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready)
	);

// Instantiation of Axi Bus Interface M00_AXIS
	fetch_unit_v1_0_M00_AXIS # (
		.BRAM_DEPTH(BRAM_DEPTH),
		.C_M_AXIS_TDATA_WIDTH(C_M00_AXIS_TDATA_WIDTH),
		.C_M_START_COUNT(C_M00_AXIS_START_COUNT)
	) fetch_unit_v1_0_M00_AXIS_inst (
		.mat_res_addr(mat_res_addr),
		.mat_res_dout(mat_res_dout),
		.mat_res_ren(mat_res_ren),
		.res_size(res_size),
		.VALID_PE2FU(VALID_PE2FU),
		.M_AXIS_ACLK(m00_axis_aclk),
		.M_AXIS_ARESETN(m00_axis_aresetn),
		.M_AXIS_TVALID(m00_axis_tvalid),
		.M_AXIS_TDATA(m00_axis_tdata),
		.M_AXIS_TSTRB(m00_axis_tstrb),
		.M_AXIS_TLAST(m00_axis_tlast),
		.M_AXIS_TREADY(m00_axis_tready)
	);

// Instantiation of Axi Bus Interface S00_AXIS
	fetch_unit_v1_0_S00_AXIS # ( 
		.BRAM_DEPTH(BRAM_DEPTH),
		.C_S_AXIS_TDATA_WIDTH(C_S00_AXIS_TDATA_WIDTH)
	) fetch_unit_v1_0_S00_AXIS_inst (
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
		.S_AXIS_ACLK(s00_axis_aclk),
		.S_AXIS_ARESETN(s00_axis_aresetn),
		.S_AXIS_TREADY(s00_axis_tready),
		.S_AXIS_TDATA(s00_axis_tdata),
		.S_AXIS_TSTRB(s00_axis_tstrb),
		.S_AXIS_TLAST(s00_axis_tlast),
		.S_AXIS_TVALID(s00_axis_tvalid)
	);

	// Add user logic here

	assign mat_a_clk = s00_axis_aclk;
	assign mat_a_we = 1'b1;
	assign mat_b_clk = s00_axis_aclk;
	assign mat_b_we = 1'b1;
	assign instr_clk = s00_axis_aclk;
	assign instr_we = 1'b1;
	assign mat_res_clk = m00_axis_aclk;

	// User logic ends

	endmodule
