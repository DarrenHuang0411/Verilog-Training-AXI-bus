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

<<<<<<< Updated upstream
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
=======
    logic DM_stall;
    always_ff @(posedge ACLK or posedge ARESETn)begin
      if(~ARESETn)begin
        DM_stall <= 0;
      end
      else begin
        DM_stall <= (~w_IM_Trans_Stall)? 1'b0 : ((w_IM_Trans_Stall & ~w_DM_Trans_Stall)? 1'b1 : DM_stall);
      end
    end




    Master_wrapper #(
      .C_ID   (4'b0001),
      .C_LEN  (`AXI_LEN_BITS'd0)
    ) Master_wrapper_IM_inst (
        .ACLK(ACLK), .ARESETn(adj_ARESETn),
      //CPU-Master
        .Memory_WEB   (w_IM_WEB), 
        .Memory_DM_read_sel    (1'b1),
        .Memory_DM_write_sel   (1'b0),        
        .Memory_BWEB  (32'hffff_ffff),
        .Memory_Addr  (w_IM_addr),
        .Memory_Din   (`AXI_DATA_BITS'b0),
        .Memory_Dout  (w_IM_IF_instr),
        .Trans_Stall  (w_IM_Trans_Stall),
      //Master
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
      //B
        .M_BID        (M0_BID   ), 
        .M_BResp      (M0_BResp ),
        .M_BValid     (M0_BValid),
        .M_BReady     (M0_BReady),
      //AR
        .M_ARID       (M0_ARID   ),  
        .M_ARAddr     (M0_ARAddr ),
        .M_ARLen      (M0_ARLen  ), 
        .M_ARSize     (M0_ARSize ),
        .M_ARBurst    (M0_ARBurst),
        .M_ARValid    (M0_ARValid),
        .M_ARReady    (M0_ARReady),

        .M_RID        (M0_RID    ),   
        .M_RData      (M0_RData  ), 
        .M_RResp      (M0_RResp  ), 
        .M_RLast      (M0_RLast  ), 
        .M_RValid     (M0_RValid ),
        .M_RReady     (M0_RReady )
    );

    Master_wrapper #(
      .C_ID   (4'b0010),
      .C_LEN  (`AXI_LEN_BITS'd0)
    ) Master_wrapper_DM_inst(
        .ACLK(ACLK), .ARESETn(adj_ARESETn),
      //CPU-Master
        .Memory_WEB   (w_DM_WEB  ), 
        .Memory_DM_read_sel    (w_DM_read_sel & ~DM_stall),
        .Memory_DM_write_sel   (w_DM_write_sel & ~DM_stall),          
        .Memory_BWEB  (w_DM_BWEB ),
        .Memory_Addr  (w_DM_addr ),
        .Memory_Din   (w_DM_Din  ),
        .Memory_Dout  (w_DM_Dout ),
        .Trans_Stall  (w_DM_Trans_Stall),
>>>>>>> Stashed changes

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
