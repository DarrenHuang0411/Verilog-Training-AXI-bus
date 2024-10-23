//--------------------------- Info ---------------------------//
    //Module Name :　Rdata
    //Type        :  
//----------------------- Environment -----------------------//

//------------------------- Module -------------------------//
    module Rdata (
        input           clk, rst,
      //M0_DATA
        output  logic [`AXI_ID_BITS   -1:0]   M0_RID,  
        output  logic [`AXI_DATA_BITS -1:0]   M0_RData, 
        output  logic [1:0]                   M0_RResp, 
        output  logic                         M0_RLast, 
        output  logic                         M0_RValid,
        input                                 M0_RReady,
      //M1_DATA
        output  logic [`AXI_ID_BITS   -1:0]   M1_RID,  
        output  logic [`AXI_DATA_BITS -1:0]   M1_RData,   
        output  logic [1:0]                   M1_RResp,  
        output  logic                         M1_RLast,    
        output  logic                         M1_RValid, 
        input                                 M1_RReady,      
      //S0_DATA
        input         [`AXI_ID_BITS   -1:0]   S0_RID,       
        input         [`AXI_DATA_BITS -1:0]   S0_RData,   
        input         [1:0]                   S0_RResp,  
        input                                 S0_RLast,    
        input                                 S0_RValid, 
        output  logic                         S0_RReady,          
      //S1_DATA 
        input         [`AXI_ID_BITS   -1:0]   S1_RID,        
        input         [`AXI_DATA_BITS -1:0]   S1_RData,   
        input         [1:0]                   S1_RResp,  
        input                                 S1_RLast,    
        input                                 S1_RValid, 
        output  logic                         S1_RReady,   
      //S_Default
        input         [`AXI_ID_BITS   -1:0]   DS_RID,       
        input         [`AXI_DATA_BITS -1:0]   DS_RData,   
        input         [1:0]                   DS_RResp,  
        input                                 DS_RLast,    
        input                                 DS_RValid, 
        output  logic                         DS_RReady         
    );
  //----------------------- Parameter -----------------------//
    logic   [`AXI_ID_BITS   -1:0]   O_ID;
    logic   [`AXI_DATA_BITS -1:0]   O_Data;
    logic   [`AXI_STRB_BITS -1:0]   O_Strb;
    logic                           O_Last;
    
    logic       Slave_sel;             
    parameter [1:0] S0  =   3'b001,
                    S1  =   3'b010,
                    DS  =   3'b100;  
    logic       Master_sel;
    parameter [1:0] M0 = 4'b0001,
                    M1 = 4'b0010;  
  //----------------------- Main Code -----------------------//
    always_comb begin
        unique if (DS_RValid) 
            Slave_sel   =   3'b100;
        else if(S1_RValid)
            Slave_sel   =   3'b010;
        else if(S0_RValid)
            Slave_sel   =   3'b001;
        else
            Slave_sel   =   3'b000;
    end

    always_comb begin
        case (Slave_sel)
            S0: begin
                Master_sel  =   S0_RID[7:4];
                O_ID        =   S0_RID[3:0];  
                O_Data      =   S0_RData;
                O_Strb      =   S0_RStrb;
                O_Last      =   S0_RLast;                
            end
            S1: begin
                Master_sel  =   S1_RID[7:4];   
                O_ID        =   S1_RID[3:0];  
                O_Data      =   S1_RData;
                O_Strb      =   S1_RStrb;
                O_Last      =   S1_RLast;                                  
            end
            DS: begin
                Master_sel  =   DS_RID[7:4];
                O_ID        =   DS_RID[3:0];  
                O_Data      =   DS_RData;
                O_Strb      =   DS_RStrb;
                O_Last      =   DS_RLast;                                     
            end 
            default: begin
                Master_sel  =   `AXI_ID_BITS'd0;
                O_ID        =   `AXI_ID_BITS'd0;  
                O_Data      =   `AXI_IDS_BITS'd0; 
                O_Strb      =   2'd0;
                O_Last      =   1'b0;                    
            end
        endcase
    end

    assign  M0_RID      =   O_ID;
    assign  M0_RData    =   O_Data;
    assign  M0_RStrb    =   O_Strb;
    assign  M0_RLast    =   O_Last;

    assign  M1_RID      =   O_ID;
    assign  M1_RData    =   O_Data;
    assign  M1_RStrb    =   O_Strb;
    assign  M1_RLast    =   O_Last;    

    always_comb begin
        case (Master_sel)
            M0: begin
                Dec_Arib_Ready  =   S0_WReady;
                M0_RValid       =   Arib_Dec_Valid;
                M1_RValid       =   1'b0;
            end
            M1: begin
                Dec_Arib_Ready  = S1_WReady;                             
                M0_RValid       = 1'b0;
                M1_RValid       = Arib_Dec_Valid;               
            end
            default: begin
                Dec_Arib_Ready  = 1'b0;//             
                M0_RValid       = 1'b0;
                M1_RValid       = 1'b0;               
            end  
        endcase
    end

    endmodule
