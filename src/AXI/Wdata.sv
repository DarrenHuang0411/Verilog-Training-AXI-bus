//--------------------------- Info ---------------------------//
    //Module Name :　Wdata
    //Type        :  
//----------------------- Environment -----------------------//
    `include ""

//------------------------- Module -------------------------//
    module Wdata (
        input           clk, rst,
      //M0_DATA (not use)
      //M1_DATA
        input   [`AXI_DATA_BITS -1:0]   M1_WData,   
        input   [`AXI_STRB_BITS -1:0]   M1_WStrb,  
        input                           M1_WLast,    
        input                           M1_WValid, 
        output  logic                   M1_WReady,      
      //S0_DATA
        output  logic [`AXI_DATA_BITS -1:0]   S0_WData,   
        output  logic [`AXI_STRB_BITS -1:0]   S0_WStrb,  
        output  logic                         S0_WLast,    
        output  logic                         S0_WValid, 
        input                                 S0_WReady,          
      //S1_DATA  
        output  logic [`AXI_DATA_BITS -1:0]   S1_WData,   
        output  logic [`AXI_STRB_BITS -1:0]   S1_WStrb,  
        output  logic                         S1_WLast,    
        output  logic                         S1_WValid, 
        input                                 S1_WReady,
      //S_Default
        output  logic [`AXI_DATA_BITS -1:0]   DS_WData,   
        output  logic [`AXI_STRB_BITS -1:0]   DS_WStrb,  
        output  logic                         DS_WLast,    
        output  logic                         DS_WValid, 
        input                                 DS_WReady           
    )
  //----------------------- Parameter -----------------------//
    logic     Slave_sel;
    parameter [1:0] S0 = 2'd0,
                    S1 = 2'd1,
                    DS = 2'd2;

    logic     Arib_Dec_Valid;
    logic     Dec_Arib_Ready;
  //----------------------- Main Code -----------------------//
    //choose Master
        assign  Arib_Dec_Valid  = M1_WValid;
    //Slave 0 --> IM 
        assign  S0_WData  = M1_WData;
        assign  S0_WStrb  = M1_WStrb;//
        assign  S0_WLast  = M1_WLast;
    //Slave 1 --> DM 
        assign  S0_WData  = M1_WData;
        assign  S0_WStrb  = M1_WStrb;//
        assign  S0_WLast  = M1_WLast;


      always_comb begin
          case (Slave_sel)
            S0: begin
              Dec_Arib_Ready  = S0_WReady;
              S0_WValid       = Arib_Dec_Valid;
              S1_WValid       = 1'b0;
              DS_WValid       = 1'b0;
            end
            S1: begin
              Dec_Arib_Ready  = S1_WReady;                  
              S0_WValid   = 1'b0;
              S1_WValid   = Arib_Dec_Valid;
              DS_WValid   = 1'b0;                  
            end
            DS: begin
              Dec_Arib_Ready  = DS_WReady;                  
              S0_WValid   = 1'b0;
              S1_WValid   = 1'b0;
              DS_WValid   = Arib_Dec_Valid;                    
            end        
            default: begin
                Dec_Arib_Ready  = 1'b1;//             
                S0_WValid   = 1'b0;
                S1_WValid   = 1'b0;
                DS_WValid   = 1'b0;                    
            end  
          endcase
      end

    endmodule
