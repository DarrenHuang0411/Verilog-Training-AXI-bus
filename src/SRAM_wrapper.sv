//--------------------------- Info ---------------------------//
    //Module Name :　SRAM_wrapper
    //Type        : 
//----------------------- Environment -----------------------//
    `include "Slave_wrapper.sv"
    `include "../include/AXI_define.svh"
    `include "../include/CPU_define.svh"
//------------------------- Module -------------------------//

module SRAM_wrapper(
    input   ACLK, ARESETn,
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

      // logic     adj_ARESETn;
      // always_ff @(posedge ACLK) begin
      //   if(!ARESETn)
      //     adj_ARESETn <=  1'b0;
      //   else
      //     adj_ARESETn <=  1'b1;
      // end
  //----------------------- Parameter -----------------------//
    logic     [1:0]             S_cur;
    parameter [1:0]   SADDR     = 2'd0,
                      RDATA     = 2'd1,
                      WDATA     = 2'd2,
                      WRESP     = 2'd3;

    logic                         CEB;
    logic                         WEB;
    logic   [`AXI_DATA_BITS -1:0] BWEB;
    logic   [`MEM_ADDR_LEN  -1:0] A;   
    logic   [`AXI_DATA_BITS -1:0] DI;   
    logic   [`AXI_DATA_BITS -1:0] DO;  

  //----------------------- Main Code -----------------------//  
    //Slave_wrapper
    Slave_wrapper Slave_wrapper_inst(
      .ACLK(ACLK), .ARESETn(ARESETn),
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

      //.CEB        (CEB    ),
      .WEB        (WEB    ),
      .BWEB       (BWEB   ),
      .A          (A      ),
      .DI         (DI     ),
      .DO         (DO     ),
      .S_cur      (S_cur)
    );
    
    always_comb begin
      CEB   =   1'b1;            
      if(S_cur == RDATA || S_cur == WDATA) begin
          CEB   =   1'b0;                 
      end
      else if (S_cur == SADDR) begin
          CEB   =   1'b0;            
      end 
    end

    //SRAM
    TS1N16ADFPCLLLVTA512X45M4SWSHOD i_SRAM (
      .SLP      (1'b0),
      .DSLP     (1'b0),
      .SD       (1'b0),
      .PUDELAY  (),
      .CLK      (ACLK),
      .CEB      (CEB),
      .WEB      (WEB),
      .A        (A),
      .D        (DI),
      .BWEB     (BWEB),
      .RTSEL    (2'b01),
      .WTSEL    (2'b01),
      .Q        (DO)
);


endmodule
