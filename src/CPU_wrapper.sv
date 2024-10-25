//--------------------------- Info ---------------------------//
    //Module Name :　CPU_wrapper
    //Type        :  Master 
//----------------------- Environment -----------------------//
    `include "CPU.sv"

//------------------------- Module -------------------------//
    module CPU_wrapper (
        input   clk, rst,
      //W channel - Addr
        //M0
        output  logic  [`AXI_ID_BITS -1:0]     M0_AWID,    
        output  logic  [`AXI_ADDR_BITS -1:0]   M0_AWAddr,  
        output  logic  [`AXI_LEN_BITS -1:0]    M0_AWLen,   
        output  logic  [`AXI_SIZE_BITS -1:0]   M0_AWSize,  
        output  logic  [1:0]                   M0_AWBurst, 
        output  logic                          M0_AWValid, 
        input                                  M0_AWReady,     
        //M1
        output  logic  [`AXI_ID_BITS -1:0]     M1_AWID,    
        output  logic  [`AXI_ADDR_BITS -1:0]   M1_AWAddr,  
        output  logic  [`AXI_LEN_BITS -1:0]    M1_AWLen,   
        output  logic  [`AXI_SIZE_BITS -1:0]   M1_AWSize,  
        output  logic  [1:0]                   M1_AWBurst, 
        output  logic                          M1_AWValid, 
        input                                  M1_AWReady,               
      //W channel - data
        //M0
        output  logic  [`AXI_DATA_BITS -1:0]   M0_WData, 
        output  logic  [`AXI_STRB_BITS -1:0]   M0_WStrb, 
        output  logic                          M0_WLast, 
        output  logic                          M0_WValid,
        input                                  M0_WReady,     
        //M1
        output  logic  [`AXI_DATA_BITS -1:0]   M1_WData, 
        output  logic  [`AXI_STRB_BITS -1:0]   M1_WStrb, 
        output  logic                          M1_WLast, 
        output  logic                          M1_WValid,
        input                                  M1_WReady,  
      //W channel - Response
        //M0
        input          [`AXI_ID_BITS  -1:0]    M0_BID,
        input          [1:0]                   M0_BResp,
        input                                  M0_BValid,
        output  logic                          M0_BReady,  
        //M1
        input          [`AXI_ID_BITS  -1:0]    M_BID,
        input          [1:0]                   M_BResp,
        input                                  M_BValid,
        output  logic                          M_BReady,                                 
      //R channel - Addr
        //M0
        output  logic  [`AXI_ID_BITS   -1:0]   M0_ARID,
        output  logic  [`AXI_ADDR_BITS -1:0]   M0_ARAddr,
        output  logic  [`AXI_LEN_BITS  -1:0]   M0_ARLen,
        output  logic  [`AXI_SIZE_BITS -1:0]   M0_ARSize,
        output  logic  [1:0]                   M0_ARBurst,
        output  logic                          M0_ARValid,
        input                                  M0_ARReady,
        //M1
        output  logic  [`AXI_ID_BITS   -1:0]   M1_ARID,
        output  logic  [`AXI_ADDR_BITS -1:0]   M1_ARAddr,
        output  logic  [`AXI_LEN_BITS  -1:0]   M1_ARLen,
        output  logic  [`AXI_SIZE_BITS -1:0]   M1_ARSize,
        output  logic  [1:0]                   M1_ARBurst,
        output  logic                          M1_ARValid,
        input                                  M1_ARReady,
      //R channel - data
        //M0
        input          [`AXI_ID_BITS   -1:0]   M0_RID,  
        input          [`AXI_DATA_BITS -1:0]   M0_RData,
        input          [1:0]                   M0_RResp,
        input                                  M0_RLast,
        input                                  M0_RValid,
        output  logic                          M0_RReady,        
        //M
        input          [`AXI_ID_BITS   -1:0]   M1_RID,  
        input          [`AXI_DATA_BITS -1:0]   M1_RData,
        input          [1:0]                   M1_RResp,
        input                                  M1_RLast,
        input                                  M1_RValid,
        output  logic                          M1_RReady
    );

  //----------------------- Parameter -----------------------//
    //CPU-Master1(IM)
      logic     w_IM_WEB;
      logic     [`AXI_DATA_BITS -1:0] w_IM_addr;
      logic     w_IM_IF_instr;
    //CPU-Master2(DM)    
      logic     w_DM_WEB;
      logic     [`DATA_WIDTH    -1:0] w_DM_BWEB;
      logic     [`AXI_DATA_BITS -1:0] w_DM_addr;
      logic     [`AXI_DATA_BITS -1:0] w_DM_Din;
      logic     [`AXI_DATA_BITS -1:0] w_DM_Dout;
  //----------------------- Main code -----------------------//
    CPU CPU_inst(
        .clk(clk), .rst(rst),
        
        .IM_WEB     (w_IM_WEB),
        .IM_addr    (w_IM_addr),
        .IM_IF_instr(w_IM_IF_instr),
        
        .DM_WEB     (w_DM_WEB),
        .DM_BWEB    (w_DM_BWEB),
        .DM_addr    (w_DM_addr),
        .DM_Din     (w_DM_Din),
        .DM_Dout    (w_DM_Dout)
    );

    Master_wrapper Master_wrapper_IM_inst(
      //CPU-Master
        .clk(clk), .rst(rst),
        .Memory_WEB   (w_IM_WEB), 
        .Memory_BWEB  (32'hffff_ffff),
        .Memory_Addr  (w_IM_addr),
        .Memory_Din   (`AXI_DATA_BITS'b0),
        .Memory_Dout  (w_IM_IF_instr),
      //Master_AXI
        .M_AWID       (M0_AWID   ),  
        .M_AWAddr     (M0_AWAddr ),
        .M_AWLen      (M0_AWLen  ), 
        .M_AWSize     (M0_AWSize ),
        .M_AWBurst    (M0_AWBurst),
        .M_AWValid    (M0_AWValid),
        .M_AWReady    (M0_AWReady),

        .M_WData      (M0_WData  ), 
        .M_WStrb      (M0_WStrb  ), 
        .M_WLast      (M0_WLast  ), 
        .M_WValid     (M0_WValid ),
        .M_WReady     (M0_wReady ),

        .M_ARID       (M0_ARID   ),  
        .M_ARAddr     (M0_ARAddr ),
        .M_ARLen      (M0_ARLen  ), 
        .M_ARSize     (M0_ARSize ),
        .M_ARBurst    (M0_ARBurst),
        .M_ARValid    (M0_ARValid),
        .M_ARReady    (M0_ARReady),

        .M_RID        (M1_RID    ),   
        .M_RData      (M1_RData  ), 
        .M_RResp      (M1_RResp  ), 
        .M_RLast      (M1_RLast  ), 
        .M_RValid     (M1_RValid ),
        .M_RReady     (M1_RReady )

    );

    Master_wrapper Master_wrapper_DM_inst(
        .clk(clk), .rst(rst),
        .Memory_WEB   (w_DM_WEB  ), 
        .Memory_BWEB  (w_DM_BWEB ),
        .Memory_Addr  (w_DM_addr ),
        .Memory_Din   (w_DM_Din  ),
        .Memory_Dout  (w_DM_Dout ),

        .M_AWID       (M1_AWID   ),  
        .M_AWAddr     (M1_AWAddr ),
        .M_AWLen      (M1_AWLen  ), 
        .M_AWSize     (M1_AWSize ),
        .M_AWBurst    (M1_AWBurst),
        .M_AWValid    (M1_AWValid),
        .M_AWReady    (M1_AWReady),

        .M_WData      (M1_WData  ), 
        .M_WStrb      (M1_WStrb  ), 
        .M_WLast      (M1_WLast  ), 
        .M_WValid     (M1_WValid ),
        .M_WReady     (M1_wReady ),



        .M_ARID       (M1_ARID   ),  
        .M_ARAddr     (M1_ARAddr ),
        .M_ARLen      (M1_ARLen  ), 
        .M_ARSize     (M1_ARSize ),
        .M_ARBurst    (M1_ARBurst),
        .M_ARValid    (M1_ARValid),
        .M_ARReady    (M1_ARReady),
        
        .M_RID        (M1_RID    ),   
        .M_RData      (M1_RData  ), 
        .M_RResp      (M1_RResp  ), 
        .M_RLast      (M1_RLast  ), 
        .M_RValid     (M1_RValid ),
        .M_RReady     (M1_RReady )
    );

    endmodule
