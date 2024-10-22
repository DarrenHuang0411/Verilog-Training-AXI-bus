//////////////////////////////////////////////////////////////////////
//          ██╗       ██████╗   ██╗  ██╗    ██████╗            		//
//          ██║       ██╔══█║   ██║  ██║    ██╔══█║            		//
//          ██║       ██████║   ███████║    ██████║            		//
//          ██║       ██╔═══╝   ██╔══██║    ██╔═══╝            		//
//          ███████╗  ██║  	    ██║  ██║    ██║  	           		//
//          ╚══════╝  ╚═╝  	    ╚═╝  ╚═╝    ╚═╝  	           		//
//                                                             		//
// 	2024 Advanced VLSI System Design, advisor: Lih-Yih, Chiou		//
//                                                             		//
//////////////////////////////////////////////////////////////////////
//                                                             		//
// 	Autor: 			TZUNG-JIN, TSAI (Leo)				  	   		//
//	Filename:		 AXI.sv			                            	//
//	Description:	Top module of AXI	 							//
// 	Version:		1.0	    								   		//
//////////////////////////////////////////////////////////////////////
`include "../../include/AXI_define.svh"
`include "Waddr.sv"
`include "Wdata.sv"
`include "Wresp.sv"
`include "Raddr.sv"
`include "Rdata.sv"

module AXI(

	input ACLK,
	input ARESETn,

	//SLAVE INTERFACE FOR MASTERS
	
	//WRITE ADDRESS
	input [`AXI_ID_BITS-1:0] AWID_M1,
	input [`AXI_ADDR_BITS-1:0] AWADDR_M1,
	input [`AXI_LEN_BITS-1:0] AWLEN_M1,
	input [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
	input [1:0] AWBURST_M1,
	input AWVALID_M1,
	output logic AWREADY_M1,
	
	//WRITE DATA
	input [`AXI_DATA_BITS-1:0] WDATA_M1,
	input [`AXI_STRB_BITS-1:0] WSTRB_M1,
	input WLAST_M1,
	input WVALID_M1,
	output logic WREADY_M1,
	
	//WRITE RESPONSE
	output logic [`AXI_ID_BITS-1:0] BID_M1,
	output logic [1:0] BRESP_M1,
	output logic BVALID_M1,
	input BREADY_M1,

	//READ ADDRESS0
	input [`AXI_ID_BITS-1:0] ARID_M0,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M0,
	input [`AXI_LEN_BITS-1:0] ARLEN_M0,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M0,
	input [1:0] ARBURST_M0,
	input ARVALID_M0,
	output logic ARREADY_M0,
	
	//READ DATA0
	output logic [`AXI_ID_BITS-1:0] RID_M0,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M0,
	output logic [1:0] RRESP_M0,
	output logic RLAST_M0,
	output logic RVALID_M0,
	input RREADY_M0,
	
	//READ ADDRESS1
	input [`AXI_ID_BITS-1:0] ARID_M1,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M1,
	input [`AXI_LEN_BITS-1:0] ARLEN_M1,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
	input [1:0] ARBURST_M1,
	input ARVALID_M1,
	output logic ARREADY_M1,
	
	//READ DATA1
	output logic [`AXI_ID_BITS-1:0] RID_M1,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M1,
	output logic [1:0] RRESP_M1,
	output logic RLAST_M1,
	output logic RVALID_M1,
	input RREADY_M1,

	//MASTER INTERFACE FOR SLAVES
	//WRITE ADDRESS0
	output logic [`AXI_IDS_BITS-1:0] AWID_S0,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S0,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S0,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S0,
	output logic [1:0] AWBURST_S0,
	output logic AWVALID_S0,
	input AWREADY_S0,
	
	//WRITE DATA0
	output logic [`AXI_DATA_BITS-1:0] WDATA_S0,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S0,
	output logic WLAST_S0,
	output logic WVALID_S0,
	input WREADY_S0,
	
	//WRITE RESPONSE0
	input [`AXI_IDS_BITS-1:0] BID_S0,
	input [1:0] BRESP_S0,
	input BVALID_S0,
	output logic BREADY_S0,
	
	//WRITE ADDRESS1
	output logic [`AXI_IDS_BITS-1:0] AWID_S1,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S1,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S1,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S1,
	output logic [1:0] AWBURST_S1,
	output logic AWVALID_S1,
	input AWREADY_S1,
	
	//WRITE DATA1
	output logic [`AXI_DATA_BITS-1:0] WDATA_S1,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S1,
	output logic WLAST_S1,
	output logic WVALID_S1,
	input WREADY_S1,
	
	//WRITE RESPONSE1
	input [`AXI_IDS_BITS-1:0] BID_S1,
	input [1:0] BRESP_S1,
	input BVALID_S1,
	output logic BREADY_S1,
	
	//READ ADDRESS0
	output logic [`AXI_IDS_BITS-1:0] ARID_S0,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S0,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S0,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S0,
	output logic [1:0] ARBURST_S0,
	output logic ARVALID_S0,
	input ARREADY_S0,
	
	//READ DATA0
	input [`AXI_IDS_BITS-1:0] RID_S0,
	input [`AXI_DATA_BITS-1:0] RDATA_S0,
	input [1:0] RRESP_S0,
	input RLAST_S0,
	input RVALID_S0,
	output logic RREADY_S0,
	
	//READ ADDRESS1
	output logic [`AXI_IDS_BITS-1:0] ARID_S1,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S1,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S1,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S1,
	output logic [1:0] ARBURST_S1,
	output logic ARVALID_S1,
	input ARREADY_S1,
	
	//READ DATA1
	input [`AXI_IDS_BITS-1:0] RID_S1,
	input [`AXI_DATA_BITS-1:0] RDATA_S1,
	input [1:0] RRESP_S1,
	input RLAST_S1,
	input RVALID_S1,
	output logic RREADY_S1
	
);

  //---------- you should put your design here ----------//
	Raddr	Raddr_inst(
	  //M0
		.M0_ARID(),   
		.M0_ARAddr(), 
		.M0_ARLen(),  
		.M0_ARSize(), 
		.M0_ARBurst(),
		.M0_ARValid(),
		.M0_ARReady(),
	  //M1
		.M1_ARID(),   
		.M1_ARAddr(), 
		.M1_ARLen(),  
		.M1_ARSize(), 
		.M1_ARBurst(),
		.M1_ARValid(),
		.M1_ARReady(),
	  //S0
		.S0_ARID(),   
		.S0_ARAddr(), 
		.S0_ARLen(),  
		.S0_ARSize(), 
		.S0_ARBurst(),
		.S0_ARValid(),
		.S0_ARReady(),
	  //S1
		.S1_ARID(),   
		.S1_ARAddr(), 
		.S1_ARLen(),  
		.S1_ARSize(), 
		.S1_ARBurst(),
		.S1_ARValid(),
		.S1_ARReady(),
	  //DS
		.DS_ARID(),   
		.DS_ARAddr(), 
		.DS_ARLen(),  
		.DS_ARSize(), 
		.DS_ARBurst(),
		.DS_ARValid(),
		.DS_ARReady()
	);

	Rdata	Rdata_inst(
	  //M0
		.M0_RID(),  
		.M0_RData(),
		.M0_RStrb(),
		.M0_RLast(),
		.M0_RValid(),
		.M0_RReady(),
	  //M1
		.M1_RID(),  
		.M1_RData(),
		.M1_RStrb(),
		.M1_RLast(),
		.M1_RValid(),
		.M1_RReady(),
	  //S0
		.S0_RID(),  
		.S0_RData(),
		.S0_RStrb(),
		.S0_RLast(),
		.S0_RValid(),
		.S0_RReady(),
	  //S1		
		.S1_RID(),  
		.S1_RData(),
		.S1_RStrb(),
		.S1_RLast(),
		.S1_RValid(),
		.S1_RReady(),
	  //DS		
		.DS_RID(),  
		.DS_RData(),
		.DS_RStrb(),
		.DS_RLast(),
		.DS_RValid(),
		.DS_RReady()
	);

	Waddr	Waddr_inst(
	  //M0
	  //M1
		.M1_AWID(),   
		.M1_AWAddr(), 
		.M1_AWLen(),  
		.M1_AWSize(), 
		.M1_AWBurst(),
		.M1_AWValid(),
		.M1_AWReady(),
	  //S0
		.S0_AWID(),   
		.S0_AWAddr(), 
		.S0_AWLen(),  
		.S0_AWSize(), 
		.S0_AWBurst(),
		.S0_AWValid(),
		.S0_AWReady(),
	  //S1
		.S1_AWID(),   
		.S1_AWAddr(), 
		.S1_AWLen(),  
		.S1_AWSize(), 
		.S1_AWBurst(),
		.S1_AWValid(),
		.S1_AWReady(),
	  //DS
		.DS_AWID(),   
		.DS_AWAddr(), 
		.DS_AWLen(),  
		.DS_AWSize(), 
		.DS_AWBurst(),
		.DS_AWValid(),
		.DS_AWReady() 
	);

	Wdata	Wdata_inst(
		.M1_WData, 
		.M1_WStrb, 
		.M1_WLast, 
		.M1_WValid,
		.M1_WReady,
		.S0_WData, 
		.S0_WStrb, 
		.S0_WLast, 
		.S0_WValid,
		.S0_WReady,
		.S1_WData, 
		.S1_WStrb, 
		.S1_WLast, 
		.S1_WValid,
		.S1_WReady,
		.DS_WData, 
		.DS_WStrb, 
		.DS_WLast, 
		.DS_WValid,
		.DS_WReady 
	);

	Wresp	Wresp_inst(

	);
endmodule
