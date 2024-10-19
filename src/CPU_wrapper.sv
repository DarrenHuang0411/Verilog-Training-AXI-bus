//--------------------------- Info ---------------------------//
    //Module Name :　CPU_wrapper
    //Type        :  Master 
//----------------------- Environment -----------------------//
    `include ""
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
        output  logic  [`AXI_ID_BITS   -1:0]   M0_WID,  
        output  logic  [`AXI_DATA_BITS -1:0]   M0_WData, 
        output  logic  [`AXI_STRB_BITS -1:0]   M0_WStrb, 
        output  logic                          M0_WLast, 
        output  logic                          M0_WValid,
        input                                  M0_RReady,     
        //M1
        output  logic  [`AXI_ID_BITS   -1:0]   M1_WID,  
        output  logic  [`AXI_DATA_BITS -1:0]   M1_WData, 
        output  logic  [`AXI_STRB_BITS -1:0]   M1_WStrb, 
        output  logic                          M1_WLast, 
        output  logic                          M1_WValid,
        input                                  M1_RReady,                
      //R channel - Addr
      //R channel - data
    );

  //----------------------- Parameter -----------------------//

    CPU CPU_inst(
        .clk(clk), .rst(rst),
        
        .IM_WEB(),
        .IM_addr(),
        .IM_IF_instr(),
        
        .DM_WEB(),
        .DM_BWEB(),
        .DM_addr(),
        .DM_Din(),
        .DM_Dout()
    );

    Master_wrapper Master_wrapper_IM_inst(
        .clk(clk), .rst(rst),
        .Memory_WEB(), 
        .Memory_BWEB(),
        .Memory_Addr(),
        .Memory_Din(),
        .Memory_Dout(),

        .M_AWID(),  
        .M_AWAddr(),
        .M_AWLen(), 
        .M_AWSize(),
        .M_AWBurst(),
        .M_AWValid(),
        .M_AWReady(),
        .M_WData(), 
        .M_WStrb(), 
        .M_WLast(), 
        .M_WValid(),
        .M_WReady(),
        .M_ARID(),  
        .M_ARAddr(),
        .M_ARLen(), 
        .M_ARSize(),
        .M_ARBurst(),
        .M_ARValid(),
        .M_ARReady(),
        .M_RID(),   
        .M_RData(), 
        .M_RStrb(), 
        .M_RLast(), 
        .M_RValid(),
        .M_RReady()

    );

    Master_wrapper Master_wrapper_DM_inst(
        .clk(clk), .rst(rst),
        .Memory_WEB(), 
        .Memory_BWEB(),
        .Memory_Addr(),
        .Memory_Din(),
        .Memory_Dout(),

        .M_AWID(),  
        .M_AWAddr(),
        .M_AWLen(), 
        .M_AWSize(),
        .M_AWBurst(),
        .M_AWValid(),
        .M_AWReady(),
        .M_WData(), 
        .M_WStrb(), 
        .M_WLast(), 
        .M_WValid(),
        .M_WReady(),
        .M_ARID(),  
        .M_ARAddr(),
        .M_ARLen(), 
        .M_ARSize(),
        .M_ARBurst(),
        .M_ARValid(),
        .M_ARReady(),
        .M_RID(),   
        .M_RData(), 
        .M_RStrb(), 
        .M_RLast(), 
        .M_RValid(),
        .M_RReady()

    );

    endmodule
