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
`include "./AXI/Waddr.sv"
`include "./AXI/Wdata.sv"
`include "./AXI/Wresp.sv"
`include "./AXI/Raddr.sv"
`include "./AXI/Rdata.sv"
`include "./AXI/DefaultSlave.sv"

module AXI(

	input ACLK,
	input ARESETn,

	//SLAVE INTERFACE FOR MASTERS
	
	//WRITE ADDRESS
	input [`AXI_ID_BITS-1:0] 			AWID_M1,
	input [`AXI_ADDR_BITS-1:0] 			AWADDR_M1,
	input [`AXI_LEN_BITS-1:0] 			AWLEN_M1,
	input [`AXI_SIZE_BITS-1:0] 			AWSIZE_M1,
	input [1:0] 						AWBURST_M1,
	input 								AWVALID_M1,
	output logic 						AWREADY_M1,
	
	//WRITE DATA
	input [`AXI_DATA_BITS-1:0] 			WDATA_M1,
	input [`AXI_STRB_BITS-1:0] 			WSTRB_M1,
	input 								WLAST_M1,
	input 								WVALID_M1,
	output logic 						WREADY_M1,
	
	//WRITE RESPONSE
	output logic [`AXI_ID_BITS-1:0] 	BID_M1,
	output logic [1:0] 					BRESP_M1,
	output logic 						BVALID_M1,
	input 								BREADY_M1,

	//READ ADDRESS0
	input [`AXI_ID_BITS-1:0] 			ARID_M0,
	input [`AXI_ADDR_BITS-1:0] 			ARADDR_M0,
	input [`AXI_LEN_BITS-1:0] 			ARLEN_M0,
	input [`AXI_SIZE_BITS-1:0] 			ARSIZE_M0,
	input [1:0] 						ARBURST_M0,
	input 								ARVALID_M0,
	output logic 						ARREADY_M0,
	
	//READ DATA0
	output logic [`AXI_ID_BITS-1:0]   	RID_M0,
	output logic [`AXI_DATA_BITS-1:0] 	RDATA_M0,
	output logic [1:0] 					RRESP_M0,
	output logic 						RLAST_M0,
	output logic 						RVALID_M0,
	input 								RREADY_M0,
	
	//READ ADDRESS1
	input [`AXI_ID_BITS-1:0] 			ARID_M1,
	input [`AXI_ADDR_BITS-1:0] 			ARADDR_M1,
	input [`AXI_LEN_BITS-1:0] 			ARLEN_M1,
	input [`AXI_SIZE_BITS-1:0] 			ARSIZE_M1,
	input [1:0] 						ARBURST_M1,
	input 								ARVALID_M1,
	output logic 						ARREADY_M1,
	
	//READ DATA1
	output logic [`AXI_ID_BITS-1:0] 	RID_M1,
	output logic [`AXI_DATA_BITS-1:0] 	RDATA_M1,
	output logic [1:0] 					RRESP_M1,
	output logic 						RLAST_M1,
	output logic 						RVALID_M1,
	input 								RREADY_M1,

	//MASTER INTERFACE FOR SLAVES
	//WRITE ADDRESS0
	output logic [`AXI_IDS_BITS-1:0] 	AWID_S0,
	output logic [`AXI_ADDR_BITS-1:0] 	AWADDR_S0,
	output logic [`AXI_LEN_BITS-1:0] 	AWLEN_S0,
	output logic [`AXI_SIZE_BITS-1:0] 	AWSIZE_S0,
	output logic [1:0] 					AWBURST_S0,
	output logic 						AWVALID_S0,
	input 								AWREADY_S0,
	
	//WRITE DATA0
	output logic [`AXI_DATA_BITS-1:0] 	WDATA_S0,
	output logic [`AXI_STRB_BITS-1:0] 	WSTRB_S0,
	output logic 						WLAST_S0,
	output logic 						WVALID_S0,
	input 								WREADY_S0,
	
	//WRITE RESPONSE0
	input [`AXI_IDS_BITS-1:0] 			BID_S0,
	input [1:0] 						BRESP_S0,
	input 								BVALID_S0,
	output logic 						BREADY_S0,
	
	//WRITE ADDRESS1
	output logic [`AXI_IDS_BITS-1:0] 	AWID_S1,
	output logic [`AXI_ADDR_BITS-1:0] 	AWADDR_S1,
	output logic [`AXI_LEN_BITS-1:0] 	AWLEN_S1,
	output logic [`AXI_SIZE_BITS-1:0] 	AWSIZE_S1,
	output logic [1:0] 					AWBURST_S1,
	output logic 						AWVALID_S1,
	input 								AWREADY_S1,
	
	//WRITE DATA1
	output logic [`AXI_DATA_BITS-1:0] 	WDATA_S1,
	output logic [`AXI_STRB_BITS-1:0] 	WSTRB_S1,
	output logic 						WLAST_S1,
	output logic 						WVALID_S1,
	input 								WREADY_S1,
	
	//WRITE RESPONSE1
	input [`AXI_IDS_BITS-1:0] 			BID_S1,
	input [1:0] 						BRESP_S1,
	input 								BVALID_S1,
	output logic 						BREADY_S1,
	
	//READ ADDRESS0
	output logic [`AXI_IDS_BITS-1:0] 	ARID_S0,
	output logic [`AXI_ADDR_BITS-1:0] 	ARADDR_S0,
	output logic [`AXI_LEN_BITS-1:0] 	ARLEN_S0,
	output logic [`AXI_SIZE_BITS-1:0] 	ARSIZE_S0,
	output logic [1:0] 					ARBURST_S0,
	output logic 						ARVALID_S0,
	input 								ARREADY_S0,
	
	//READ DATA0
	input [`AXI_IDS_BITS-1:0] 			RID_S0,
	input [`AXI_DATA_BITS-1:0] 			RDATA_S0,
	input [1:0] 						RRESP_S0,
	input 								RLAST_S0,
	input 								RVALID_S0,
	output logic 						RREADY_S0,
	
	//READ ADDRESS1
	output logic [`AXI_IDS_BITS-1:0] 	ARID_S1,
	output logic [`AXI_ADDR_BITS-1:0] 	ARADDR_S1,
	output logic [`AXI_LEN_BITS-1:0] 	ARLEN_S1,
	output logic [`AXI_SIZE_BITS-1:0] 	ARSIZE_S1,
	output logic [1:0] 					ARBURST_S1,
	output logic 						ARVALID_S1,
	input 								ARREADY_S1,
	
	//READ DATA1
	input [`AXI_IDS_BITS-1:0] 			RID_S1,
	input [`AXI_DATA_BITS-1:0] 			RDATA_S1,
	input [1:0] 						RRESP_S1,
	input 								RLAST_S1,
	input 								RVALID_S1,
	output logic 						RREADY_S1	
);

  //---------- you should put your design here ----------//
  //-------------------- Parameter --------------------//	
  	//Default slave
	  logic	[`AXI_IDS_BITS -1:0]  	w_DS_AWID;
	  logic	[`AXI_ADDR_BITS -1:0]	w_DS_AWAddr; 
	  logic	[`AXI_LEN_BITS -1:0] 	w_DS_AWLen;  
	  logic	[`AXI_SIZE_BITS -1:0]	w_DS_AWSize; 
	  logic	[1:0]                	w_DS_AWBurst;
	  logic	                     	w_DS_AWValid;
	  logic							w_DS_AWReady;

	  logic	[`AXI_DATA_BITS -1:0]   w_DS_WData ;
	  logic	[`AXI_STRB_BITS -1:0]   w_DS_WStrb ;
	  logic	                        w_DS_WLast ;
	  logic	                        w_DS_WValid;
	  logic		                    w_DS_WReady;

	  logic [`AXI_IDS_BITS -1:0]    w_DS_BID	;
	  logic [1:0]                   w_DS_BResp	;
	  logic                         w_DS_BValid	;
	  logic                         w_DS_BReady	;

	  logic	[`AXI_IDS_BITS -1:0]    w_DS_ARID 	  ;  
	  logic	[`AXI_ADDR_BITS -1:0]   w_DS_ARAddr   ;
	  logic	[`AXI_LEN_BITS -1:0]    w_DS_ARLen    ;
	  logic	[`AXI_SIZE_BITS -1:0]   w_DS_ARSize   ;
	  logic	[1:0]                   w_DS_ARBurst  ;
	  logic	                        w_DS_ARValid  ;
	  logic                         w_DS_ARReady  ;  

	  logic [`AXI_IDS_BITS   -1:0]  w_DS_RID	;   
	  logic [`AXI_DATA_BITS -1:0]   w_DS_RData	; 
	  logic [1:0]                   w_DS_RResp	; 
	  logic                         w_DS_RLast	; 
	  logic                         w_DS_RValid	;
	  logic                         w_DS_RReady	; 

  //-------------------- Main code --------------------//	
	Raddr	Raddr_inst(
		.clk(ACLK), .rst(ARESETn),
	  //M0
		.M0_ARID	(ARID_M0),   
		.M0_ARAddr	(ARADDR_M0), 
		.M0_ARLen	(ARLEN_M0),  
		.M0_ARSize	(ARSIZE_M0), 
		.M0_ARBurst	(ARBURST_M0),
		.M0_ARValid	(ARVALID_M0),
		.M0_ARReady	(ARREADY_M0),
	  //M1
		.M1_ARID	(ARID_M1),   
		.M1_ARAddr	(ARADDR_M1), 
		.M1_ARLen	(ARLEN_M1),  
		.M1_ARSize	(ARSIZE_M1), 
		.M1_ARBurst	(ARBURST_M1),
		.M1_ARValid	(ARVALID_M1),
		.M1_ARReady	(ARREADY_M1),
	  //S0
		.S0_ARID	(ARID_S0),   
		.S0_ARAddr	(ARADDR_S0), 
		.S0_ARLen	(ARLEN_S0),  
		.S0_ARSize	(ARSIZE_S0), 
		.S0_ARBurst	(ARBURST_S0),
		.S0_ARValid	(ARVALID_S0),
		.S0_ARReady	(ARREADY_S0),
	  //S1
		.S1_ARID	(ARID_S1),      
		.S1_ARAddr	(ARADDR_S1),  
		.S1_ARLen	(ARLEN_S1),    
		.S1_ARSize	(ARSIZE_S1),  
		.S1_ARBurst	(ARBURST_S1),
		.S1_ARValid	(ARVALID_S1),
		.S1_ARReady	(ARREADY_S1),
	  //DS
		.DS_ARID	(w_DS_ARID),   
		.DS_ARAddr	(w_DS_ARAddr), 
		.DS_ARLen	(w_DS_ARLen),  
		.DS_ARSize	(w_DS_ARSize), 
		.DS_ARBurst	(w_DS_ARBurst),
		.DS_ARValid	(w_DS_ARValid),
		.DS_ARReady	(w_DS_ARReady)
	);

	Rdata	Rdata_inst(
	    .clk(ACLK), .rst(ARESETn),
	  //M0
		.M0_RID		(RID_M0),  
		.M0_RData	(RDATA_M0),
		.M0_RResp	(RRESP_M0),
		.M0_RLast	(RLAST_M0),
		.M0_RValid	(RVALID_M0),
		.M0_RReady	(RREADY_M0),
	  //M1
		.M1_RID		(RID_M1),  
		.M1_RData	(RDATA_M1),
		.M1_RResp	(RRESP_M1),
		.M1_RLast	(RLAST_M1),
		.M1_RValid	(RVALID_M1),
		.M1_RReady	(RREADY_M1),
	  //S0
		.S0_RID		(RID_S0),  
		.S0_RData	(RDATA_S0),
		.S0_RResp	(RRESP_S0),
		.S0_RLast	(RLAST_S0),
		.S0_RValid	(RVALID_S0),
		.S0_RReady	(RREADY_S0),
	  //S1		
		.S1_RID		(RID_S1),  
		.S1_RData	(RDATA_S1),
		.S1_RResp	(RRESP_S1),
		.S1_RLast	(RLAST_S1),
		.S1_RValid	(RVALID_S1),
		.S1_RReady	(RREADY_S1),
	  //DS		
		.DS_RID		(w_DS_RID),  
		.DS_RData	(w_DS_RData),
		.DS_RResp	(w_DS_RResp),
		.DS_RLast	(w_DS_RLast),
		.DS_RValid	(w_DS_RValid),
		.DS_RReady	(w_DS_RRead)
	);

	Waddr	Waddr_inst(
	    .clk(ACLK), .rst(ARESETn),  
	  //M0
	  //M1
		.M1_AWID	(AWID_M1),   
		.M1_AWAddr	(AWADDR_M1), 
		.M1_AWLen	(AWLEN_M1),  
		.M1_AWSize	(AWSIZE_M1), 
		.M1_AWBurst	(AWBURST_M1),
		.M1_AWValid	(AWVALID_M1),
		.M1_AWReady	(AWREADY_M1),
	  //S0
		.S0_AWID	(AWID_S0),   
		.S0_AWAddr	(AWADDR_S0), 
		.S0_AWLen	(AWLEN_S0),  
		.S0_AWSize	(AWSIZE_S0), 
		.S0_AWBurst	(AWBURST_S0),
		.S0_AWValid	(AWVALID_S0),
		.S0_AWReady	(AWREADY_S0),
	  //S1
		.S1_AWID	(AWID_S1),   
		.S1_AWAddr	(AWADDR_S1), 
		.S1_AWLen	(AWLEN_S1),  
		.S1_AWSize	(AWSIZE_S1), 
		.S1_AWBurst	(AWBURST_S1),
		.S1_AWValid	(AWVALID_S1),
		.S1_AWReady	(AWREADY_S1),
	  //DS
		.DS_AWID	(w_DS_AWID),   
		.DS_AWAddr	(w_DS_AWAddr), 
		.DS_AWLen	(w_DS_AWLen),  
		.DS_AWSize	(w_DS_AWSize), 
		.DS_AWBurst	(w_DS_AWBurst),
		.DS_AWValid	(w_DS_AWValid),
		.DS_AWReady	(w_DS_AWReady) 
	);

	Wdata	Wdata_inst(
        .clk(ACLK), .rst(ARESETn),		
	  //M0
	  //M1
		.M1_WData	(WDATA_M1), 
		.M1_WStrb	(WSTRB_M1), 
		.M1_WLast	(WLAST_M1), 
		.M1_WValid	(WVALID_M1),
		.M1_WReady	(WREADY_M1),
	  //S0
		.S0_WData	(WDATA_S0), 
		.S0_WStrb	(WSTRB_S0), 
		.S0_WLast	(WLAST_S0), 
		.S0_WValid	(WVALID_S0),
		.S0_WReady	(WVALID_S0),
	  //S1
		.S1_WData	(WDATA_S1),  
		.S1_WStrb	(WSTRB_S1),  
		.S1_WLast	(WLAST_S1),  
		.S1_WValid	(WVALID_S1),
		.S1_WReady	(WVALID_S1),
	  //DS
		.DS_WData	(w_DS_WData ),  
		.DS_WStrb	(w_DS_WStrb ),  
		.DS_WLast	(w_DS_WLast ),  
		.DS_WValid	(w_DS_WValid),
		.DS_WReady	(w_DS_WReady),
	  //help signal
		.S0_AWValid	(AWVALID_S0),
		.S1_AWValid	(AWVALID_S1),
		.DS_AWValid	(w_DS_AWValid)
	);

	Wresp	Wresp_inst(
        .clk(ACLK), .rst(ARESETn),		
	  //M0
	  //M1
		.M1_BID		(BID_M1),
		.M1_BResp	(BRESP_M1),
		.M1_BValid	(BVALID_M1), 
		.M1_BReady	(BREADY_M1), 
	  //S0
		.S0_BID		(BID_S0),
		.S0_BResp	(BRESP_S0),
		.S0_BValid	(BVALID_S0), 
		.S0_BReady	(BREADY_S0), 
	  //S1
		.S1_BID		(BID_S1),
		.S1_BResp	(BRESP_S1),
		.S1_BValid	(BVALID_S1), 
		.S1_BReady	(BREADY_S1), 
	  //DS
		.DS_BID		(w_DS_BID),
		.DS_BResp	(w_DS_BResp	),
		.DS_BValid	(w_DS_BValid), 
		.DS_BReady	(w_DS_BReady) 
	);

	DefaultSlave DefaultSlave_inst(
        .ACLK(ACLK), .ARESETn(ARESETn),		
		.DS_AWID	(w_DS_AWID),
		.DS_AWAddr 	(w_DS_AWAddr ),
		.DS_AWLen  	(w_DS_AWLen  ),
		.DS_AWSize 	(w_DS_AWSize ),
		.DS_AWBurst	(w_DS_AWBurst),
		.DS_AWValid	(w_DS_AWValid),
		.DS_AWReady	(w_DS_AWReady),

		.DS_WData 	(w_DS_WData ), 
		.DS_WStrb 	(w_DS_WStrb ),
		.DS_WLast 	(w_DS_WLast ),
		.DS_WValid	(w_DS_WValid),
		.DS_WReady	(w_DS_WReady),	

		.DS_BID		(w_DS_BID	),
		.DS_BResp	(w_DS_BResp	),
		.DS_BValid	(w_DS_BValid),
		.DS_BReady	(w_DS_BReady),		

		.DS_ARID 	(w_DS_ARID 	 ),
		.DS_ARAddr 	(w_DS_ARAddr ),
		.DS_ARLen  	(w_DS_ARLen  ),
		.DS_ARSize 	(w_DS_ARSize ),
		.DS_ARBurst	(w_DS_ARBurst),
		.DS_ARValid	(w_DS_ARValid),
		.DS_ARReady	(w_DS_ARReady),

		.DS_RID		(w_DS_RID	),   
		.DS_RData	(w_DS_RData	), 
		.DS_RResp	(w_DS_RResp	), 
		.DS_RLast	(w_DS_RLast	), 
		.DS_RValid	(w_DS_RValid),
		.DS_RReady	(w_DS_RReady)
	);
endmodule
