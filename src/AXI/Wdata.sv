//--------------------------- Info ---------------------------//
    //Module Name :　Wdata
    //Type        :  
//----------------------- Environment -----------------------//

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
        input                                 DS_WReady,
      //help signal
        input                                 S0_AWValid, 
        input                                 S1_AWValid,
        input                                 DS_AWValid          
    );
  //----------------------- Parameter -----------------------//
    logic       Master_sel;
    //Data register
      logic   [`AXI_DATA_BITS -1:0]  Wdata_done;
      logic                          reg_S0_AWValid;
      logic                          reg_S1_AWValid;
      logic                          reg_DS_AWValid;      

    parameter [1:0] M0 = 4'b0001,
                    M1 = 4'b0010;  

    logic     [2:0] Slave_sel;
    parameter [2:0] S0 = 3'b001,
                    S1 = 3'b010,
                    DS = 3'b100;

    logic     Arb_Dec_Valid;
    logic     Dec_Arb_Ready;

    //--------------------- Done Signal ---------------------//
      assign  Wdata_done  = M1_WValid  & M1_WReady;

  //----------------------- Main Code -----------------------//
    //choose Master
        assign  Arb_Dec_Valid  = M1_WValid;
        assign  M1_WReady  = Dec_Arb_Ready;
    //Slave 0 --> IM 
        assign  S0_WData  = M1_WData;
        assign  S0_WStrb  = M1_WStrb;//
        assign  S0_WLast  = M1_WLast;

    //Slave 1 --> DM 
        assign  S1_WData  = M1_WData;
        assign  S1_WStrb  = M1_WStrb;//
        assign  S1_WLast  = M1_WLast;

    //Default Slave 
    //AW finish & maintain Slave_sel to check
      always_ff @(posedge clk or posedge rst) begin
        if(!rst) begin
          reg_S0_AWValid  <=  1'b0;
          reg_S1_AWValid  <=  1'b0;
          reg_DS_AWValid  <=  1'b0;          
        end
        else begin
          reg_S0_AWValid  <=  (S0_AWValid) ? 1'b1 : ((Wdata_done && M1_WLast) ? 1'b0 : reg_S0_AWValid);
          reg_S1_AWValid  <=  (S1_AWValid) ? 1'b1 : ((Wdata_done && M1_WLast) ? 1'b0 : reg_S1_AWValid);
          reg_DS_AWValid  <=  (DS_AWValid) ? 1'b1 : ((Wdata_done && M1_WLast) ? 1'b0 : reg_DS_AWValid);         
        end
      end
      assign  Slave_sel = {reg_DS_AWValid, reg_S1_AWValid, reg_S0_AWValid};

      always_comb begin
          case (Slave_sel)
            S0: begin
              Dec_Arb_Ready   = S0_WReady;
              S0_WValid       = Arb_Dec_Valid;
              S1_WValid       = 1'b0;
              DS_WValid       = 1'b0;
            end
            S1: begin
              Dec_Arb_Ready  = S1_WReady;                  
              S0_WValid   = 1'b0;
              S1_WValid   = Arb_Dec_Valid;
              DS_WValid   = 1'b0;                  
            end
            DS: begin
              Dec_Arb_Ready  = DS_WReady;                  
              S0_WValid   = 1'b0;
              S1_WValid   = 1'b0;
              DS_WValid   = Arb_Dec_Valid;                    
            end        
            default: begin
                Dec_Arb_Ready  = 1'b0;           
                S0_WValid   = 1'b0;
                S1_WValid   = 1'b0;
                DS_WValid   = 1'b0;                    
            end  
          endcase
      end

    endmodule
