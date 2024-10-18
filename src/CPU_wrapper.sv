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
        input          [`AXI_ID_BITS   -1:0]   M0_WID,  
        input          [`AXI_DATA_BITS -1:0]   M0_WData, 
        input          [`AXI_STRB_BITS -1:0]   M0_WStrb, 
        input                                  M0_WLast, 
        input                                  M0_WValid,
        output  logic                          M0_RReady,        
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

    Master_wrapper Master_wrapper_Instr_inst(
        .clk(clk), .rst(rst),

    );

    Master_wrapper Master_wrapper_data_inst(
        .clk(clk), .rst(rst),

    );

    endmodule

