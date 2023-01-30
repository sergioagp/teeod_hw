
`timescale 1 ns / 1 ps

	module teeod_ipc_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface TEE_AXI
		parameter integer C_TEE_AXI_DATA_WIDTH	= 32,
		parameter integer C_TEE_AXI_ADDR_WIDTH	= 6,

		// Parameters of Axi Slave Bus Interface ENCL_AXI
		parameter integer C_ENCL_AXI_DATA_WIDTH	= 32,
		parameter integer C_ENCL_AXI_ADDR_WIDTH	= 6
	)
	(
		// Users to add ports here
    // User ports ends

		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface TEE_AXI
		input wire  tee_axi_aclk,
		input wire  tee_axi_aresetn,
		input wire [C_TEE_AXI_ADDR_WIDTH-1 : 0] tee_axi_awaddr,
		input wire [2 : 0] tee_axi_awprot,
		input wire  tee_axi_awvalid,
		output wire  tee_axi_awready,
		input wire [C_TEE_AXI_DATA_WIDTH-1 : 0] tee_axi_wdata,
		input wire [(C_TEE_AXI_DATA_WIDTH/8)-1 : 0] tee_axi_wstrb,
		input wire  tee_axi_wvalid,
		output wire  tee_axi_wready,
		output wire [1 : 0] tee_axi_bresp,
		output wire  tee_axi_bvalid,
		input wire  tee_axi_bready,
		input wire [C_TEE_AXI_ADDR_WIDTH-1 : 0] tee_axi_araddr,
		input wire [2 : 0] tee_axi_arprot,
		input wire  tee_axi_arvalid,
		output wire  tee_axi_arready,
		output wire [C_TEE_AXI_DATA_WIDTH-1 : 0] tee_axi_rdata,
		output wire [1 : 0] tee_axi_rresp,
		output wire  tee_axi_rvalid,
		input wire  tee_axi_rready,

		// Ports of Axi Slave Bus Interface ENCL_AXI
		input wire  encl_axi_aclk,
		input wire  encl_axi_aresetn,
		input wire [C_ENCL_AXI_ADDR_WIDTH-1 : 0] encl_axi_awaddr,
		input wire [2 : 0] encl_axi_awprot,
		input wire  encl_axi_awvalid,
		output wire  encl_axi_awready,
		input wire [C_ENCL_AXI_DATA_WIDTH-1 : 0] encl_axi_wdata,
		input wire [(C_ENCL_AXI_DATA_WIDTH/8)-1 : 0] encl_axi_wstrb,
		input wire  encl_axi_wvalid,
		output wire  encl_axi_wready,
		output wire [1 : 0] encl_axi_bresp,
		output wire  encl_axi_bvalid,
		input wire  encl_axi_bready,
		input wire [C_ENCL_AXI_ADDR_WIDTH-1 : 0] encl_axi_araddr,
		input wire [2 : 0] encl_axi_arprot,
		input wire  encl_axi_arvalid,
		output wire  encl_axi_arready,
		output wire [C_ENCL_AXI_DATA_WIDTH-1 : 0] encl_axi_rdata,
		output wire [1 : 0] encl_axi_rresp,
		output wire  encl_axi_rvalid,
		input wire  encl_axi_rready
	);


//***************************** Internal Params ********************************
	parameter integer C_S_AXI_REGS_NUMBER	= 16;

//***************************** Internal I/O Declarations***********************
	wire [C_S_AXI_REGS_NUMBER-1:0]		tee_update_output;
	wire [C_TEE_AXI_DATA_WIDTH-1:0]		tee_data_slv_output		[C_S_AXI_REGS_NUMBER-1 : 0];

	wire [C_S_AXI_REGS_NUMBER-1:0]		encl_update_output;
	wire [C_ENCL_AXI_DATA_WIDTH-1:0]	encl_data_slv_output	[C_S_AXI_REGS_NUMBER-1 : 0];

//***************************Internal Register Declarations*********************
	reg  [C_TEE_AXI_DATA_WIDTH-1:0]		data_slv				[C_S_AXI_REGS_NUMBER-1 : 0];

//*******************************Assign Declarations****************************

//********************************Procedural Block******************************
	genvar i;
	generate
		for(i=0; i<C_S_AXI_REGS_NUMBER; i=i+1) begin
			always @( posedge tee_axi_aclk )
			begin
				if ( tee_axi_aresetn == 1'b0 )
					begin
						data_slv[i] = 0;
					end 
				else
					begin    
						if(tee_update_output[i]) begin
							data_slv[i] = tee_data_slv_output[i];
						end
						else if(encl_update_output[i]) begin
							data_slv[i] = encl_data_slv_output[i];
						end				
					end
			end
		end
	endgenerate

// Instantiation of Axi Bus Interface TEE_AXI
	teeod_ipc_v1_0_TEE_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_TEE_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_TEE_AXI_ADDR_WIDTH)
	) teeod_ipc_v1_0_TEE_AXI_inst (
    .update_output(tee_update_output),
		.slv_output(tee_data_slv_output),
		.slv_input(data_slv),
		.S_AXI_ACLK(tee_axi_aclk),
		.S_AXI_ARESETN(tee_axi_aresetn),
		.S_AXI_AWADDR(tee_axi_awaddr),
		.S_AXI_AWPROT(tee_axi_awprot),
		.S_AXI_AWVALID(tee_axi_awvalid),
		.S_AXI_AWREADY(tee_axi_awready),
		.S_AXI_WDATA(tee_axi_wdata),
		.S_AXI_WSTRB(tee_axi_wstrb),
		.S_AXI_WVALID(tee_axi_wvalid),
		.S_AXI_WREADY(tee_axi_wready),
		.S_AXI_BRESP(tee_axi_bresp),
		.S_AXI_BVALID(tee_axi_bvalid),
		.S_AXI_BREADY(tee_axi_bready),
		.S_AXI_ARADDR(tee_axi_araddr),
		.S_AXI_ARPROT(tee_axi_arprot),
		.S_AXI_ARVALID(tee_axi_arvalid),
		.S_AXI_ARREADY(tee_axi_arready),
		.S_AXI_RDATA(tee_axi_rdata),
		.S_AXI_RRESP(tee_axi_rresp),
		.S_AXI_RVALID(tee_axi_rvalid),
		.S_AXI_RREADY(tee_axi_rready)
	);

// Instantiation of Axi Bus Interface ENCL_AXI
	teeod_ipc_v1_0_ENCL_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_ENCL_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_ENCL_AXI_ADDR_WIDTH)
	) teeod_ipc_v1_0_ENCL_AXI_inst (
		.update_output(encl_update_output),
		.slv_output(encl_data_slv_output),
		.slv_input(data_slv),
		.S_AXI_ACLK(encl_axi_aclk),
		.S_AXI_ARESETN(encl_axi_aresetn),
		.S_AXI_AWADDR(encl_axi_awaddr),
		.S_AXI_AWPROT(encl_axi_awprot),
		.S_AXI_AWVALID(encl_axi_awvalid),
		.S_AXI_AWREADY(encl_axi_awready),
		.S_AXI_WDATA(encl_axi_wdata),
		.S_AXI_WSTRB(encl_axi_wstrb),
		.S_AXI_WVALID(encl_axi_wvalid),
		.S_AXI_WREADY(encl_axi_wready),
		.S_AXI_BRESP(encl_axi_bresp),
		.S_AXI_BVALID(encl_axi_bvalid),
		.S_AXI_BREADY(encl_axi_bready),
		.S_AXI_ARADDR(encl_axi_araddr),
		.S_AXI_ARPROT(encl_axi_arprot),
		.S_AXI_ARVALID(encl_axi_arvalid),
		.S_AXI_ARREADY(encl_axi_arready),
		.S_AXI_RDATA(encl_axi_rdata),
		.S_AXI_RRESP(encl_axi_rresp),
		.S_AXI_RVALID(encl_axi_rvalid),
		.S_AXI_RREADY(encl_axi_rready)
	);

	// Add user logic here

	// User logic ends

	endmodule
