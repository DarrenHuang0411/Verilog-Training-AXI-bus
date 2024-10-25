//--------------------------- Info ---------------------------//
    //Module Name :　System top module
    //Type        : 
//----------------------- Environment -----------------------//
    `include "../include/AXI_define.svh"
    `include "CPU_wrapper.sv"
    `include "./AXI/AXI.sv"
    `include "SRAM_wrapper.sv"

//------------------------- Module -------------------------//
    module top (
        input   clk,
        input   rst
    );

  //----------------------- Parameter -----------------------//    
    //Master to Bus(Mx2B)
    //W channel - Addr
        logic  [`AXI_ID_BITS -1:0]     M02B_AWID  ; 
        logic  [`AXI_ADDR_BITS -1:0]   M02B_AWAddr ;
        logic  [`AXI_LEN_BITS -1:0]    M02B_AWLen  ;
        logic  [`AXI_SIZE_BITS -1:0]   M02B_AWSize ;
        logic  [1:0]                   M02B_AWBurst;
        logic                          M02B_AWValid;
        logic                          M02B_AWReady;

        logic  [`AXI_ID_BITS -1:0]     M12B_AWID   ;
        logic  [`AXI_ADDR_BITS -1:0]   M12B_AWAddr ;
        logic  [`AXI_LEN_BITS -1:0]    M12B_AWLen  ;
        logic  [`AXI_SIZE_BITS -1:0]   M12B_AWSize ;
        logic  [1:0]                   M12B_AWBurst;
        logic                          M12B_AWValid;
        logic                          M12B_AWReady;
    //W channel - data
        logic  [`AXI_DATA_BITS -1:0]   M02B_WData; 
        logic  [`AXI_STRB_BITS -1:0]   M02B_WStrb; 
        logic                          M02B_WLast; 
        logic                          M02B_WValid;
        logic                          M02B_WReady;

        logic  [`AXI_DATA_BITS -1:0]   M12B_WData; 
        logic  [`AXI_STRB_BITS -1:0]   M12B_WStrb; 
        logic                          M12B_WLast; 
        logic                          M12B_WValid;
        logic                          M12B_WReady;
    //W channel - Response
        logic  [`AXI_ID_BITS  -1:0]    M02B_BID;
        logic  [1:0]                   M02B_BResp;
        logic                          M02B_BValid;
        logic                          M02B_BReady;
        
        logic  [`AXI_ID_BITS  -1:0]    M12B_BID;
        logic  [1:0]                   M12B_BResp;
        logic                          M12B_BValid;
        logic                          M12B_BReady;  
    //R channel - Addr 
        logic  [`AXI_ID_BITS   -1:0]   M02B_ARID;
        logic  [`AXI_ADDR_BITS -1:0]   M02B_ARAddr;
        logic  [`AXI_LEN_BITS  -1:0]   M02B_ARLen;
        logic  [`AXI_SIZE_BITS -1:0]   M02B_ARSize;
        logic  [1:0]                   M02B_ARBurst;
        logic                          M02B_ARValid;
        logic                          M02B_ARReady;
        
        logic  [`AXI_ID_BITS   -1:0]   M12B_ARID;
        logic  [`AXI_ADDR_BITS -1:0]   M12B_ARAddr;
        logic  [`AXI_LEN_BITS  -1:0]   M12B_ARLen;
        logic  [`AXI_SIZE_BITS -1:0]   M12B_ARSize;
        logic  [1:0]                   M12B_ARBurst;
        logic                          M12B_ARValid;
        logic                          M12B_ARReady;    
    //R channel - data
        logic  [`AXI_ID_BITS   -1:0]   M02B_RID;  
        logic  [`AXI_DATA_BITS -1:0]   M02B_RData;
        logic  [1:0]                   M02B_RResp;
        logic                          M02B_RLast;
        logic                          M02B_RValid;
        logic                          M02B_RReady;

        logic  [`AXI_ID_BITS   -1:0]   M12B_RID;  
        logic  [`AXI_DATA_BITS -1:0]   M12B_RData;
        logic  [1:0]                   M12B_RResp;
        logic                          M12B_RLast;
        logic                          M12B_RValid;
        logic                          M12B_RReady;
    //Master to Bus(B2Sx)
    //W channel - Addr
        logic  [`AXI_ID_BITS -1:0]     B2S0_AWID   ; 
        logic  [`AXI_ADDR_BITS -1:0]   B2S0_AWAddr ;
        logic  [`AXI_LEN_BITS -1:0]    B2S0_AWLen  ;
        logic  [`AXI_SIZE_BITS -1:0]   B2S0_AWSize ;
        logic  [1:0]                   B2S0_AWBurst;
        logic                          B2S0_AWValid;
        logic                          B2S0_AWReady;

        logic  [`AXI_ID_BITS -1:0]     B2S1_AWID   ;
        logic  [`AXI_ADDR_BITS -1:0]   B2S1_AWAddr ;
        logic  [`AXI_LEN_BITS -1:0]    B2S1_AWLen  ;
        logic  [`AXI_SIZE_BITS -1:0]   B2S1_AWSize ;
        logic  [1:0]                   B2S1_AWBurst;
        logic                          B2S1_AWValid;
        logic                          B2S1_AWReady;
    //W channel - data
        logic  [`AXI_DATA_BITS -1:0]   B2S0_WData   ; 
        logic  [`AXI_STRB_BITS -1:0]   B2S0_WStrb   ; 
        logic                          B2S0_WLast   ; 
        logic                          B2S0_WValid;
        logic                          B2S0_WReady;

        logic  [`AXI_DATA_BITS -1:0]   B2S1_WData   ; 
        logic  [`AXI_STRB_BITS -1:0]   B2S1_WStrb   ; 
        logic                          B2S1_WLast   ; 
        logic                          B2S1_WValid;
        logic                          B2S1_WReady;
    //W channel - Response
        logic  [`AXI_ID_BITS  -1:0]    B2S0_BID     ;
        logic  [1:0]                   B2S0_BResp   ;
        logic                          B2S0_BValid;
        logic                          B2S0_BReady;
        
        logic  [`AXI_ID_BITS  -1:0]    B2S1_BID     ;
        logic  [1:0]                   B2S1_BResp   ;
        logic                          B2S1_BValid;
        logic                          B2S1_BReady;  
    //R channel - Addr 
        logic  [`AXI_ID_BITS   -1:0]   B2S0_ARID    ;
        logic  [`AXI_ADDR_BITS -1:0]   B2S0_ARAddr  ;
        logic  [`AXI_LEN_BITS  -1:0]   B2S0_ARLen   ;
        logic  [`AXI_SIZE_BITS -1:0]   B2S0_ARSize  ;
        logic  [1:0]                   B2S0_ARBurst;
        logic                          B2S0_ARValid;
        logic                          B2S0_ARReady;
        
        logic  [`AXI_ID_BITS   -1:0]   B2S1_ARID    ;
        logic  [`AXI_ADDR_BITS -1:0]   B2S1_ARAddr  ;
        logic  [`AXI_LEN_BITS  -1:0]   B2S1_ARLen   ;
        logic  [`AXI_SIZE_BITS -1:0]   B2S1_ARSize  ;
        logic  [1:0]                   B2S1_ARBurst;
        logic                          B2S1_ARValid;
        logic                          B2S1_ARReady;    
    //R channel - data
        logic  [`AXI_ID_BITS   -1:0]   B2S0_RID     ;  
        logic  [`AXI_DATA_BITS -1:0]   B2S0_RData   ;
        logic  [1:0]                   B2S0_RResp   ;
        logic                          B2S0_RLast   ;
        logic                          B2S0_RValid;
        logic                          B2S0_RReady;

        logic  [`AXI_ID_BITS   -1:0]   B2S1_RID     ;  
        logic  [`AXI_DATA_BITS -1:0]   B2S1_RData   ;
        logic  [1:0]                   B2S1_RResp   ;
        logic                          B2S1_RLast   ;
        logic                          B2S1_RValid;
        logic                          B2S1_RReady;    

  //----------------------- Main code -----------------------//
    CPU_wrapper CPU_wrapper_inst(
        .clk(clk), .rst(rst),
      //M2B_AW
        .M0_AWID     (M02B_AWID   ),   
        .M0_AWAddr   (M02B_AWAddr ), 
        .M0_AWLen    (M02B_AWLen  ),  
        .M0_AWSize   (M02B_AWSize ), 
        .M0_AWBurst  (M02B_AWBurst),
        .M0_AWValid  (M02B_AWValid),
        .M0_AWReady  (M02B_AWReady),
        .M1_AWID     (M12B_AWID   ),   
        .M1_AWAddr   (M12B_AWAddr ), 
        .M1_AWLen    (M12B_AWLen  ),  
        .M1_AWSize   (M12B_AWSize ), 
        .M1_AWBurst  (M12B_AWBurst),
        .M1_AWValid  (M12B_AWValid),
        .M1_AWReady  (M12B_AWReady),
      //M2B_W
        .M0_WData    (M02B_WData  ), 
        .M0_WStrb    (M02B_WStrb  ), 
        .M0_WLast    (M02B_WLast  ), 
        .M0_WValid   (M02B_WValid ),
        .M0_WReady   (M02B_WReady ), 
        .M1_WData    (M12B_WData  ), 
        .M1_WStrb    (M12B_WStrb  ), 
        .M1_WLast    (M12B_WLast  ), 
        .M1_WValid   (M12B_WValid ),
        .M1_WReady   (M12B_WReady ),
      //M2B_B
        .M0_BID      (M02B_BID    ),
        .M0_BResp    (M02B_BResp  ),
        .M0_BValid   (M02B_BValid ),
        .M0_BReady   (M02B_BReady ),
        .M1_BID      (M12B_BID    ),
        .M1_BResp    (M12B_BResp  ),
        .M1_BValid   (M12B_BValid ),
        .M1_BReady   (M12B_BReady ),
      //M2B_AR
        .M0_ARID     (M02B_ARID   ),
        .M0_ARAddr   (M02B_ARAddr ),
        .M0_ARLen    (M02B_ARLen  ),
        .M0_ARSize   (M02B_ARSize ),
        .M0_ARBurst  (M02B_ARBurst),
        .M0_ARValid  (M02B_ARValid),
        .M0_ARReady  (M02B_ARReady),
        .M1_ARID     (M12B_ARID   ),
        .M1_ARAddr   (M12B_ARAddr ),
        .M1_ARLen    (M12B_ARLen  ),
        .M1_ARSize   (M12B_ARSize ),
        .M1_ARBurst  (M12B_ARBurst),
        .M1_ARValid  (M12B_ARValid),
        .M1_ARReady  (M12B_ARReady),
      //M2B_R
        .M0_RID      (M02B_RID   ),  
        .M0_RData    (M02B_RData ),
        .M0_RResp    (M02B_RResp ),
        .M0_RLast    (M02B_RLast ),
        .M0_RValid   (M02B_RValid),
        .M0_RReady   (M02B_RReady), 
        .M1_RID      (M12B_RID   ),  
        .M1_RData    (M12B_RData ),
        .M1_RResp    (M12B_RResp ),
        .M1_RLast    (M12B_RLast ),
        .M1_RValid   (M12B_RValid),
        .M1_RReady   (M12B_RReady)
    );

    AXI AXI_inst(
        .ACLK(clk), .ARESETn(rst),
      //M2B_AW   
        .AWID_M1     (M12B_AWID   ),
        .AWADDR_M1   (M12B_AWAddr ),
        .AWLEN_M1    (M12B_AWLen  ),
        .AWSIZE_M1   (M12B_AWSize ),
        .AWBURST_M1  (M12B_AWBurst),
        .AWVALID_M1  (M12B_AWValid),
        .AWREADY_M1  (M12B_AWReady),
      //M2B_W
        .WDATA_M1    (M12B_WData  ),
        .WSTRB_M1    (M12B_WStrb  ),
        .WLAST_M1    (M12B_WLast  ),
        .WVALID_M1   (M12B_WValid ),
        .WREADY_M1   (M12B_WReady ),
      //M2B_B
        .BID_M1      (M12B_BID    ),
        .BRESP_M1    (M12B_BResp  ),
        .BVALID_M1   (M12B_BValid ),
        .BREADY_M1   (M12B_BReady ),
      //M2B_AR
        .ARID_M0     (M02B_ARID   ),
        .ARADDR_M0   (M02B_ARAddr ),
        .ARLEN_M0    (M02B_ARLen  ),
        .ARSIZE_M0   (M02B_ARSize ),
        .ARBURST_M0  (M02B_ARBurst),
        .ARVALID_M0  (M02B_ARValid),
        .ARREADY_M0  (M02B_ARReady),  

        .ARID_M1     (M12B_ARID   ),
        .ARADDR_M1   (M12B_ARAddr ),
        .ARLEN_M1    (M12B_ARLen  ),
        .ARSIZE_M1   (M12B_ARSize ),
        .ARBURST_M1  (M12B_ARBurst),
        .ARVALID_M1  (M12B_ARValid),
        .ARREADY_M1  (M12B_ARReady),
      //M2B_R
        .RID_M0      (M02B_RID   ),
        .RDATA_M0    (M02B_RData ),
        .RRESP_M0    (M02B_RResp ),
        .RLAST_M0    (M02B_RLast ),
        .RVALID_M0   (M02B_RValid),
        .RREADY_M0   (M02B_RReady),

        .RID_M1      (M12B_RID   ),
        .RDATA_M1    (M12B_RData ),
        .RRESP_M1    (M12B_RResp ),
        .RLAST_M1    (M12B_RLast ),
        .RVALID_M1   (M12B_RValid),
        .RREADY_M1   (M12B_RReady),
      //B2S_AW
        .AWID_S0    (B2S0_AWID   ),
        .AWADDR_S0  (B2S0_AWAddr ),
        .AWLEN_S0   (B2S0_AWLen  ),
        .AWSIZE_S0  (B2S0_AWSize ),
        .AWBURST_S0 (B2S0_AWBurst),
        .AWVALID_S0 (B2S0_AWValid),
        .AWREADY_S0 (B2S0_AWReady),

        .AWID_S1    (B2S1_AWID   ),
        .AWADDR_S1  (B2S1_AWAddr ),
        .AWLEN_S1   (B2S1_AWLen  ),
        .AWSIZE_S1  (B2S1_AWSize ),
        .AWBURST_S1 (B2S1_AWBurst),
        .AWVALID_S1 (B2S1_AWValid),
        .AWREADY_S1 (B2S1_AWReady),
      //B2S_W        
        .WDATA_S0   (B2S0_WData ),
        .WSTRB_S0   (B2S0_WStrb ),
        .WLAST_S0   (B2S0_WLast ),
        .WVALID_S0  (B2S0_WValid),
        .WREADY_S0  (B2S0_WReady),

        .WDATA_S1   (B2S1_WData ),
        .WSTRB_S1   (B2S1_WStrb ),
        .WLAST_S1   (B2S1_WLast ),
        .WVALID_S1  (B2S1_WValid),
        .WREADY_S1  (B2S1_WReady),
      //B2S_B        
        .BID_S0     (B2S0_BID   ),
        .BRESP_S0   (B2S0_BResp ),
        .BVALID_S0  (B2S0_BValid),
        .BREADY_S0  (B2S0_BReady),

        .BID_S1     (B2S1_BID   ),
        .BRESP_S1   (B2S1_BResp ),
        .BVALID_S1  (B2S1_BValid),
        .BREADY_S1  (B2S1_BReady),
      //B2S_AR        
        .ARID_S0    (B2S0_ARID   ),
        .ARADDR_S0  (B2S0_ARAddr ),
        .ARLEN_S0   (B2S0_ARLen  ),
        .ARSIZE_S0  (B2S0_ARSize ),
        .ARBURST_S0 (B2S0_ARBurst),
        .ARVALID_S0 (B2S0_ARValid),
        .ARREADY_S0 (B2S0_ARReady),
      
        .ARID_S1    (B2S1_ARID   ),
        .ARADDR_S1  (B2S1_ARAddr ),
        .ARLEN_S1   (B2S1_ARLen  ),
        .ARSIZE_S1  (B2S1_ARSize ),
        .ARBURST_S1 (B2S1_ARBurst),
        .ARVALID_S1 (B2S1_ARValid),
        .ARREADY_S1 (B2S1_ARReady),
      //B2S_R         
        .RID_S0     (B2S0_RID   ),
        .RDATA_S0   (B2S0_RData ),
        .RRESP_S0   (B2S0_RResp ),
        .RLAST_S0   (B2S0_RLast ),
        .RVALID_S0  (B2S0_RValid),
        .RREADY_S0  (B2S0_RReady),

        .RID_S1     (B2S1_RID   ),
        .RDATA_S1   (B2S1_RData ),
        .RRESP_S1   (B2S1_RResp ),
        .RLAST_S1   (B2S1_RLast ),
        .RVALID_S1  (B2S1_RValid),
        .RREADY_S1  (B2S1_RReady)
    );

    SRAM_wrapper SRAM_wrapper_IM_inst(
        .CLK(clk),  .RST(rst),
      //B2M_AW
        .S_AWID     (B2S0_AWID   ),    
        .S_AWAddr   (B2S0_AWAddr ),  
        .S_AWLen    (B2S0_AWLen  ),   
        .S_AWSize   (B2S0_AWSize ),  
        .S_AWBurst  (B2S0_AWBurst), 
        .S_AWValid  (B2S0_AWValid), 
        .S_AWReady  (B2S0_AWReady),
      //B2M_W     
        .S_WData    (B2S0_WData ),   
        .S_WStrb    (B2S0_WStrb ),   
        .S_WLast    (B2S0_WLast ),   
        .S_WValid   (B2S0_WValid),  
        .S_WReady   (B2S0_WReady),
      //B2M_B
        .S_BID      (B2S0_BID   ),
        .S_BResp    (B2S0_BResp ),
        .S_BValid   (B2S0_BValid),
        .S_BReady   (B2S0_BReady),           
      //B2M_AR
        .S_ARID     (B2S0_ARID   ),    
        .S_ARAddr   (B2S0_ARAddr ),  
        .S_ARLen    (B2S0_ARLen  ),   
        .S_ARSize   (B2S0_ARSize ),  
        .S_ARBurst  (B2S0_ARBurst), 
        .S_ARValid  (B2S0_ARValid), 
        .S_ARReady  (B2S0_ARReady),
      //B2M_R   
        .S_RID      (B2S0_RID   ),         
        .S_RData    (B2S0_RData ),   
        .S_RResp    (B2S0_RResp ),   
        .S_RLast    (B2S0_RLast ),   
        .S_RValid   (B2S0_RValid),  
        .S_RReady   (B2S0_RReady)
); 

    SRAM_wrapper SRAM_wrapper_DM_inst(
        .CLK(clk),  .RST(rst),
      //B2M_AW
        .S_AWID     (B2S1_AWID   ),    
        .S_AWAddr   (B2S1_AWAddr ),  
        .S_AWLen    (B2S1_AWLen  ),   
        .S_AWSize   (B2S1_AWSize ),  
        .S_AWBurst  (B2S1_AWBurst), 
        .S_AWValid  (B2S1_AWValid), 
        .S_AWReady  (B2S1_AWReady),
      //B2M_W     
        .S_WData    (B2S1_WData ),   
        .S_WStrb    (B2S1_WStrb ),   
        .S_WLast    (B2S1_WLast ),   
        .S_WValid   (B2S1_WValid),  
        .S_WReady   (B2S1_WReady),
      //B2M_B
        .S_BID      (B2S1_BID   ),
        .S_BResp    (B2S1_BResp ),
        .S_BValid   (B2S1_BValid),
        .S_BReady   (B2S1_BReady),           
      //B2M_AR
        .S_ARID     (B2S1_ARID   ),    
        .S_ARAddr   (B2S1_ARAddr ),  
        .S_ARLen    (B2S1_ARLen  ),   
        .S_ARSize   (B2S1_ARSize ),  
        .S_ARBurst  (B2S1_ARBurst), 
        .S_ARValid  (B2S1_ARValid), 
        .S_ARReady  (B2S1_ARReady),
      //B2M_R   
        .S_RID      (B2S0_RID   ),         
        .S_RData    (B2S0_RData ),   
        .S_RResp    (B2S0_RResp ),   
        .S_RLast    (B2S0_RLast ),   
        .S_RValid   (B2S0_RValid),  
        .S_RReady   (B2S0_RReady)
); 

    endmodule

