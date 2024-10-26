//--------------------------- Info ---------------------------//
    //Module Name :　Wresp
    //Type        :  
//----------------------- Environment -----------------------//

//------------------------- Module -------------------------//
    module Wresp (
        input   clk, rst,
      //M0_resp (not use)
      //M1_resp
      output  logic [`AXI_ID_BITS -1:0]   M1_BID,   
      output  logic [1:0]                 M1_BResp,   
      output  logic                       M1_BValid,    
      input                               M1_BReady,    
      //S0_resp
      input         [`AXI_IDS_BITS -1:0]  S0_BID,   
      input         [1:0]                 S0_BResp,   
      input                               S0_BValid,    
      output  logic                       S0_BReady,    
      //S1_resp
      input         [`AXI_IDS_BITS -1:0]  S1_BID,   
      input         [1:0]                 S1_BResp,   
      input                               S1_BValid,    
      output  logic                       S1_BReady,    
      //DS_resp
      input         [`AXI_IDS_BITS -1:0]  DS_BID,   
      input         [1:0]                 DS_BResp,   
      input                               DS_BValid,    
      output  logic                       DS_BReady      
    );
  //----------------------- Parameter -----------------------//
    logic   [`AXI_ID_BITS   -1:0]   O_ID;
    logic   [1:0]                   O_Resp;
    logic                           O_Valid;
    logic                           O_Ready;

    logic       Slave_sel;             
    parameter [1:0] S0  =   3'b001,
                    S1  =   3'b010,
                    DS  =   3'b100;  
    logic       Master_sel;
    parameter [1:0] M0 = 4'b0001,
                    M1 = 4'b0010;  

  //----------------------- Main Code -----------------------//      
    always_comb begin
        unique if (DS_BValid) 
            Slave_sel   =   3'b100;
        else if(S1_BValid)
            Slave_sel   =   3'b010;
        else if(S0_BValid)
            Slave_sel   =   3'b001;
        else
            Slave_sel   =   3'b000;      
    end
    //Exchange Slave
    always_comb begin
        case (Slave_sel)
          S0: begin
            Master_sel    = S0_BID[7:4];
            O_ID          = S0_BID[3:0];  
            O_Resp        = S0_BResp;
            O_Valid       = S0_BValid;
            S0_BReady     = O_Ready;         
          end
          S1: begin
            Master_sel    = S1_BID[7:4];
            O_ID          = S1_BID[3:0];  
            O_Resp        = S1_BResp; 
            O_Valid       = S1_BValid;                          
            S1_BReady     = O_Ready;            
          end
          DS: begin
            Master_sel    = DS_BID[7:4];
            O_ID          = DS_BID[3:0];  
            O_Resp        = DS_BResp; 
            O_Valid       = DS_BValid;                          
            DS_BReady     = O_Ready;            
          end
          default: begin
            Master_sel    = `AXI_ID_BITS'd0;
            O_ID          = `AXI_ID_BITS'd0;  
            O_Resp        = 2'd0;   
            O_Valid       = 1'd0;                         
            DS_BReady     = 1'd0;
          end
        endcase
    end
    //Exchange (Master)
    assign  M1_BID      =   O_ID;
    assign  M1_BResp    =   O_Resp;  
    assign  M1_BValid   =   O_Valid;
    assign  O_Ready     =   M1_BReady;

    endmodule