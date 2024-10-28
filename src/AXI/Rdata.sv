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
        input         [`AXI_IDS_BITS  -1:0]   S0_RID,       
        input         [`AXI_DATA_BITS -1:0]   S0_RData,   
        input         [1:0]                   S0_RResp,  
        input                                 S0_RLast,    
        input                                 S0_RValid, 
        output  logic                         S0_RReady,          
      //S1_DATA 
        input         [`AXI_IDS_BITS  -1:0]   S1_RID,        
        input         [`AXI_DATA_BITS -1:0]   S1_RData,   
        input         [1:0]                   S1_RResp,  
        input                                 S1_RLast,    
        input                                 S1_RValid, 
        output  logic                         S1_RReady,   
      //S_Default
        input         [`AXI_IDS_BITS  -1:0]   DS_RID,       
        input         [`AXI_DATA_BITS -1:0]   DS_RData,   
        input         [1:0]                   DS_RResp,  
        input                                 DS_RLast,    
        input                                 DS_RValid, 
        output  logic                         DS_RReady         
    );
  //----------------------- Parameter -----------------------//
    logic   [`AXI_ID_BITS   -1:0]   O_ID;
    logic   [`AXI_DATA_BITS -1:0]   O_Data;
    logic   [1:0]                   O_Resp;
    logic                           O_Last;
    
    logic     [2:0] Slave_sel;             
    parameter [2:0] S0  =   3'b001,
                    S1  =   3'b010,
                    DS  =   3'b100;  
    logic     [3:0] Master_sel;
    parameter [3:0] M0 = 4'b0001,
                    M1 = 4'b0010;  
    
    logic     Dec_Arib_Valid;
    logic     Arib_Dec_Ready;
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
                O_Resp      =   S0_RResp;
                O_Last      =   S0_RLast; 
                Dec_Arib_Valid  =    S0_RValid;
                S0_RReady   =   Arib_Dec_Ready;
                S1_RReady   =   1'b0;
                DS_RReady   =   1'b0;                                          
            end
            S1: begin
                Master_sel  =   S1_RID[7:4];   
                O_ID        =   S1_RID[3:0];  
                O_Data      =   S1_RData;
                O_Resp      =   S1_RResp;
                O_Last      =   S1_RLast;
                Dec_Arib_Valid  =    S1_RValid;   
                S0_RReady   =   1'b0;
                S1_RReady   =   Arib_Dec_Ready;
                DS_RReady   =   1'b0;                                                
            end
            DS: begin
                Master_sel  =   DS_RID[7:4];
                O_ID        =   DS_RID[3:0];  
                O_Data      =   DS_RData;
                O_Resp      =   DS_RResp;
                O_Last      =   DS_RLast;   
                Dec_Arib_Valid  =    DS_RValid;                   
                S0_RReady   =   1'b0;
                S1_RReady   =   1'b0;
                DS_RReady   =   Arib_Dec_Ready;                                                   
            end 
            default: begin
                Master_sel  =   `AXI_ID_BITS'd0;
                O_ID        =   `AXI_ID_BITS'd0;  
                O_Data      =   `AXI_IDS_BITS'd0; 
                O_Resp      =   2'b0;
                O_Last      =   1'b0; 
                Dec_Arib_Valid  =    1'b0;                  
                S0_RReady   =   1'b0;
                S1_RReady   =   1'b0;
                DS_RReady   =   1'b0;                                       
            end
        endcase
    end

    assign  M0_RID      =   O_ID;
    assign  M0_RData    =   O_Data;
    assign  M0_RResp    =   O_Resp;
    assign  M0_RLast    =   O_Last;

    assign  M1_RID      =   O_ID;
    assign  M1_RData    =   O_Data;
    assign  M1_RResp    =   O_Resp;
    assign  M1_RLast    =   O_Last;    

    always_comb begin
        case (Master_sel)
            M0: begin
                Arib_Dec_Ready  =   M0_RReady;
                M0_RValid       =   Dec_Arib_Valid;
                M1_RValid       =   1'b0;
            end
            M1: begin
                Arib_Dec_Ready  =   M1_RReady;                         
                M0_RValid       =   1'b0;
                M1_RValid       =   Dec_Arib_Valid;               
            end
            default: begin
                Arib_Dec_Ready  = 1'b0;        
                M0_RValid       = 1'b0;
                M1_RValid       = 1'b0;               
            end  
        endcase
    end

    endmodule
