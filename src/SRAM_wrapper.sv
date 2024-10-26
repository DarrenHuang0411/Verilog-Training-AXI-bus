//--------------------------- Info ---------------------------//
    //Module Name :　SRAM_wrapper
    //Type        : 
//----------------------- Environment -----------------------//
    `include "Slave_wrapper.sv"

//------------------------- Module -------------------------//

module SRAM_wrapper (
    input   CLK, RST,
  //AXI Waddr
    input  [`AXI_IDS_BITS -1:0]         S_AWID,    
    input  [`AXI_ADDR_BITS -1:0]        S_AWAddr,  
    input  [`AXI_LEN_BITS -1:0]         S_AWLen,   
    input  [`AXI_SIZE_BITS -1:0]        S_AWSize,  
    input  [1:0]                        S_AWBurst, 
    input                               S_AWValid, 
    output  logic                       S_AWReady,
  //AXI Wdata     
    input  [`AXI_DATA_BITS -1:0]        S_WData,   
    input  [`AXI_STRB_BITS -1:0]        S_WStrb,   
    input                               S_WLast,   
    input                               S_WValid,  
    output  logic                       S_WReady,
  //AXI Wresp
    output  logic [`AXI_IDS_BITS -1:0]  S_BID,
    output  logic [1:0]                 S_BResp,
    output  logic                       S_BValid,
    input                               S_BReady,           
  //AXI Raddr
    input  [`AXI_IDS_BITS -1:0]         S_ARID,    
    input  [`AXI_ADDR_BITS -1:0]        S_ARAddr,  
    input  [`AXI_LEN_BITS -1:0]         S_ARLen,   
    input  [`AXI_SIZE_BITS -1:0]        S_ARSize,  
    input  [1:0]                        S_ARBurst, 
    input                               S_ARValid, 
    output  logic                       S_ARReady,
  //AXI Rdata   
    output  logic [`AXI_IDS_BITS  -1:0] S_RID,         
    output  logic [`AXI_DATA_BITS -1:0] S_RData,   
    output  logic [1:0]                 S_RResp,   
    output  logic                       S_RLast,   
    output  logic                       S_RValid,  
    input                               S_RReady

);

  //----------------------- Parameter -----------------------//
    logic                         w_CEB;
    logic                         w_WEB;
    logic   [`AXI_DATA_BITS -1:0] w_BWEB;
    logic   [`MEM_ADDR_LEN:0]     w_A;   
    logic   [`AXI_DATA_BITS -1:0] w_DI;   
    logic   [`AXI_DATA_BITS -1:0] w_DO;  

  //----------------------- Main Code -----------------------//  
    //Slave_wrapper
    Slave_wrapper Slave_wrapper_inst(
      .ACLK(CLK), .ARESETn(RST),
    //W channel - Addr  
      .S_AWID     (S_AWID   ),
      .S_AWAddr   (S_AWAddr ),
      .S_AWLen    (S_AWLen  ),
      .S_AWSize   (S_AWSize ),
      .S_AWBurst  (S_AWBurst),
      .S_AWValid  (S_AWValid),
      .S_AWReady  (S_AWReady),

      .S_WData    (S_WData  ),
      .S_WStrb    (S_WStrb  ),
      .S_WLast    (S_WLast  ),
      .S_WValid   (S_WValid ),
      .S_WReady   (S_WReady ),

      .S_BID      (S_BID    ),
      .S_BResp    (S_BResp  ),
      .S_BValid   (S_BValid ),
      .S_BReady   (S_BReady ),

      .S_ARID     (S_ARID   ),
      .S_ARAddr   (S_ARAddr ),
      .S_ARLen    (S_ARLen  ),
      .S_ARSize   (S_ARSize ),
      .S_ARBurst  (S_ARBurst),
      .S_ARValid  (S_ARValid),
      .S_ARReady  (S_ARReady),

      .S_RID      (S_RID    ),
      .S_RData    (S_RData  ),
      .S_RResp    (S_RResp  ),
      .S_RLast    (S_RLast  ),
      .S_RValid   (S_RValid ),
      .S_RReady   (S_RReady ),

      .CEB        (w_CEB    ),
      .WEB        (w_WEB    ),
      .BWEB       (w_BWEB   ),
      .A          (w_A      ),
      .DI         (w_DI     ),
      .DO         (w_DO     )
    );
    //SRAM
    TS1N16ADFPCLLLVTA512X45M4SWSHOD i_SRAM (
      .SLP      (1'b0),
      .DSLP     (1'b0),
      .SD       (1'b0),
      .PUDELAY  (),
      .CLK      (CLK),
      .CEB      (w_CEB),
      .WEB      (w_WEB),
      .A        (w_A),
      .D        (w_DI),
      .BWEB     (w_BWEB),
      .RTSEL    (2'b01),
      .WTSEL    (2'b01),
      .Q        (w_Do)
);


endmodule
