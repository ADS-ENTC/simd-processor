`timescale 1 ns / 1 ps

module fetch_unit_v1_0_M00_AXIS #
(
	// Users to add parameters here
	parameter BRAM_DEPTH = 10,
	// User parameters ends
	// Do not modify the parameters beyond this line

	// Width of S_AXIS address bus. The slave accepts the read and write addresses of width C_M_AXIS_TDATA_WIDTH.
	parameter integer C_M_AXIS_TDATA_WIDTH	= 32,
	// Start count is the number of clock cycles the master will wait before initiating/issuing any transaction.
	parameter integer C_M_START_COUNT	= 32
)
(
	// Users to add ports here
	input wire 						VALID_PE2FU,
	input wire 	[31:0] 				mat_res_dout,
	output wire	[BRAM_DEPTH-1:0] 	mat_res_addr,
	output wire                     mat_res_ren,
	input [31:0] res_size,

	input wire  M_AXIS_ACLK,
	input wire  M_AXIS_ARESETN,
	output wire  M_AXIS_TVALID,
	output wire [C_M_AXIS_TDATA_WIDTH-1 : 0] M_AXIS_TDATA,
	output wire [(C_M_AXIS_TDATA_WIDTH/8)-1 : 0] M_AXIS_TSTRB,
	output wire  M_AXIS_TLAST,
	input wire  M_AXIS_TREADY
);
												
	parameter [1:0] IDLE = 2'b00,                                                                             
					INIT_COUNTER  = 2'b01,    
					SEND_STREAM   = 2'b10;   
																	
	reg [1:0] mst_exec_state;                                                                                                      
	reg [BRAM_DEPTH-1:0] read_pointer;

	wire  	axis_tvalid;
	reg  	axis_tvalid_delay;
	wire  	axis_tlast;
	reg  	axis_tlast_delay;
	wire  	tx_en;
	reg  	tx_done;

	// I/O Connections assignments
	assign M_AXIS_TVALID	= axis_tvalid_delay;
	assign M_AXIS_TDATA	= mat_res_dout;
	assign M_AXIS_TLAST	= axis_tlast_delay;
	assign M_AXIS_TSTRB	= {(C_M_AXIS_TDATA_WIDTH/8){1'b1}};


	// Control state machine implementation                             
	always @(posedge M_AXIS_ACLK)                                             
	begin                                                                     
		if (!M_AXIS_ARESETN)                                                     
		begin                                                                 
			mst_exec_state <= IDLE;                                                                                              
		end                                                                   
		else                                                                    
		case (mst_exec_state)                                                 
			IDLE:                                                     
			if (VALID_PE2FU) begin
				mst_exec_state <= SEND_STREAM;
			end else begin
				mst_exec_state <= IDLE;
			end     

			SEND_STREAM:                         
			if (tx_done)                                                      
				begin                                                           
				mst_exec_state <= IDLE;                    
				end                                                             
			else                                                              
				begin                                                           
				mst_exec_state <= SEND_STREAM;
				end                                                             
		endcase                                                               
	end                                                                       


	assign axis_tvalid = ((mst_exec_state == SEND_STREAM) && (read_pointer < res_size));                                                         
	assign axis_tlast = (read_pointer == res_size-1);                                
													
	always @(posedge M_AXIS_ACLK)                                                                  
	begin                                                                                          
		if (!M_AXIS_ARESETN)                                                                         
		begin                                                                                      
			axis_tvalid_delay <= 1'b0;                                                               
			axis_tlast_delay <= 1'b0;                                                                
		end                                                                                        
		else                                                                                         
		begin                                                                                      
			axis_tvalid_delay <= axis_tvalid;                                                        
			axis_tlast_delay <= axis_tlast;                                                          
		end                                                                                        
	end                                                                                            

	always@(posedge M_AXIS_ACLK)                                               
	begin                                                                            
		if(!M_AXIS_ARESETN)                                                            
		begin                                                                        
			read_pointer <= 0;                                                         
			tx_done <= 1'b0;                                                           
		end                                                                          
		else                                                                           
		if (read_pointer <= res_size-1)                                
			begin                                                                      
			if (tx_en)                                                             
				begin                                                                  
				read_pointer <= read_pointer + 1;                                    
				tx_done <= 1'b0;                                                     
				end                                                                    
			end                                                                        
		else if (read_pointer == res_size)                             
			if (!tx_done) begin                                                        
			tx_done <= 1'b1;                                           
			end else begin                                                            
			read_pointer <= 0;
			tx_done <= 0;                                                     
			end                                                                    
	end                                                                              

	assign tx_en = M_AXIS_TREADY && axis_tvalid;
	assign mat_res_addr = read_pointer;
	assign mat_res_ren = tx_en;										

endmodule
