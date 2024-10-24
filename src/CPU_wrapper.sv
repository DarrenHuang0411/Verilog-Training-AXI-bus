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
      //R channel - Addr
      //R channel - data
    );

  //----------------------- Parameter -----------------------//
    //CPU-Master1(IM)
      logic     w_IM_WEB;
      logic    [`AXI_DATA_BITS -1:0] w_IM_addr;
      logic     w_IM_IF_instr;
  //----------------------- Main code -----------------------//
    CPU CPU_inst(
        .clk(clk), .rst(rst),
        
        .IM_WEB     (w_IM_WEB),
        .IM_addr    (w_IM_addr),
        .IM_IF_instr(w_IM_IF_instr),
        
        .DM_WEB     (),
        .DM_BWEB    (),
        .DM_addr    (),
        .DM_Din     (),
        .DM_Dout    ()
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

        .M_ARID       (),  
        .M_ARAddr     (),
        .M_ARLen      (), 
        .M_ARSize     (),
        .M_ARBurst    (),
        .M_ARValid    (),
        .M_ARReady    (),
        .M_RID        (),   
        .M_RData      (), 
        .M_RStrb      (), 
        .M_RLast      (), 
        .M_RValid     (),
        .M_RReady     ()

    );

    Master_wrapper Master_wrapper_DM_inst(
        .clk(clk), .rst(rst),
        .Memory_WEB(), 
        .Memory_BWEB(),
        .Memory_Addr(),
        .Memory_Din(),
        .Memory_Dout(),

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

        .M_ARID       (),  
        .M_ARAddr     (),
        .M_ARLen      (), 
        .M_ARSize     (),
        .M_ARBurst    (),
        .M_ARValid    (),
        .M_ARReady    (),
        
        .M_RID        (),   
        .M_RData      (), 
        .M_RStrb      (), 
        .M_RLast      (), 
        .M_RValid     (),
        .M_RReady     ()
    );

    endmodule
