
`timescale 1 ns / 1 ps

	module teeod_ipc_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface TEE_AXI
		parameter integer C_TEE_AXI_DATA_WIDTH	= 32,
		parameter integer C_TEE_AXI_ADDR_WIDTH	= 8,

		// Parameters of Axi Slave Bus Interface ENCLV_AXI
		parameter integer C_ENCLV_AXI_DATA_WIDTH	= 32,
		parameter integer C_ENCLV_AXI_ADDR_WIDTH	= 8
	)
	(
		// Users to add ports here
		//output wire TEE_INT,
		//output wire operation_done,
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

		// Ports of Axi Slave Bus Interface ENCLV_AXI
		input wire  enclv_axi_aclk,
		input wire  enclv_axi_aresetn,
		input wire [C_ENCLV_AXI_ADDR_WIDTH-1 : 0] enclv_axi_awaddr,
		input wire [2 : 0] enclv_axi_awprot,
		input wire  enclv_axi_awvalid,
		output wire  enclv_axi_awready,
		input wire [C_ENCLV_AXI_DATA_WIDTH-1 : 0] enclv_axi_wdata,
		input wire [(C_ENCLV_AXI_DATA_WIDTH/8)-1 : 0] enclv_axi_wstrb,
		input wire  enclv_axi_wvalid,
		output wire  enclv_axi_wready,
		output wire [1 : 0] enclv_axi_bresp,
		output wire  enclv_axi_bvalid,
		input wire  enclv_axi_bready,
		input wire [C_ENCLV_AXI_ADDR_WIDTH-1 : 0] enclv_axi_araddr,
		input wire [2 : 0] enclv_axi_arprot,
		input wire  enclv_axi_arvalid,
		output wire  enclv_axi_arready,
		output wire [C_ENCLV_AXI_DATA_WIDTH-1 : 0] enclv_axi_rdata,
		output wire [1 : 0] enclv_axi_rresp,
		output wire  enclv_axi_rvalid,
		input wire  enclv_axi_rready
	);

//***************************** Internal Params ********************************
	parameter integer C_S_AXI_REGS_NUMBER	= 64;

	parameter integer INT_REG	= 0;
	parameter integer CLR_REG	= 0;
	parameter integer DONE_REG	= 0;

//***************************** Internal I/O Declarations***********************
	wire [C_S_AXI_REGS_NUMBER-1:0]		tee_update_output;
	wire [C_TEE_AXI_DATA_WIDTH-1:0]		tee_data_slv_output		[C_S_AXI_REGS_NUMBER-1 : 0];

	wire [C_S_AXI_REGS_NUMBER-1:0]		enclv_update_output;
	wire [C_ENCLV_AXI_DATA_WIDTH-1:0]	enclv_data_slv_output	[C_S_AXI_REGS_NUMBER-1 : 0];

//***************************Internal Register Declarations*********************
	reg  [C_TEE_AXI_DATA_WIDTH-1:0]		data_slv				[C_S_AXI_REGS_NUMBER-1 : 0];

//*******************************Assign Declarations****************************
	//assign operation_done = enclv_update_output[DONE_REG]; // TODO: also check DONE_VAL


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
						else if(enclv_update_output[i]) begin
							data_slv[i] = enclv_data_slv_output[i];
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

// Instantiation of Axi Bus Interface ENCLV_AXI
	teeod_ipc_v1_0_ENCLV_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_ENCLV_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_ENCLV_AXI_ADDR_WIDTH)
	) teeod_ipc_v1_0_ENCLV_AXI_inst (
		.update_output(enclv_update_output),
		.slv_output(enclv_data_slv_output),
		.slv_input(data_slv),
		.S_AXI_ACLK(enclv_axi_aclk),
		.S_AXI_ARESETN(enclv_axi_aresetn),
		.S_AXI_AWADDR(enclv_axi_awaddr),
		.S_AXI_AWPROT(enclv_axi_awprot),
		.S_AXI_AWVALID(enclv_axi_awvalid),
		.S_AXI_AWREADY(enclv_axi_awready),
		.S_AXI_WDATA(enclv_axi_wdata),
		.S_AXI_WSTRB(enclv_axi_wstrb),
		.S_AXI_WVALID(enclv_axi_wvalid),
		.S_AXI_WREADY(enclv_axi_wready),
		.S_AXI_BRESP(enclv_axi_bresp),
		.S_AXI_BVALID(enclv_axi_bvalid),
		.S_AXI_BREADY(enclv_axi_bready),
		.S_AXI_ARADDR(enclv_axi_araddr),
		.S_AXI_ARPROT(enclv_axi_arprot),
		.S_AXI_ARVALID(enclv_axi_arvalid),
		.S_AXI_ARREADY(enclv_axi_arready),
		.S_AXI_RDATA(enclv_axi_rdata),
		.S_AXI_RRESP(enclv_axi_rresp),
		.S_AXI_RVALID(enclv_axi_rvalid),
		.S_AXI_RREADY(enclv_axi_rready)
	);

	// Add user logic here

	// User logic ends

	endmodule
