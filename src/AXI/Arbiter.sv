//--------------------------- Info ---------------------------//
    //Module Name :　CPU_wrapper
    //Type        :  
//----------------------- Environment -----------------------//

//------------------------- Module -------------------------//
    module Arbiter (
        input   clk, rst,
      //input Info 0
        input   [`AXI_ID_BITS -1:0]     I0_ID,
        input   [`AXI_ADDR_BITS -1:0]   I0_Addr,
        input   [`AXI_LEN_BITS -1:0]    I0_Len,
        input   [`AXI_SIZE_BITS -1:0]   I0_Size,
        input   [1:0]                   I0_Burst,
        input                           I0_Valid,
        output  logic                   IB0_Ready,
      //input Info 1
        input   [`AXI_ID_BITS -1:0]     I1_ID,      
        input   [`AXI_ADDR_BITS -1:0]   I1_Addr,  
        input   [`AXI_LEN_BITS -1:0]    I1_Len,   
        input   [`AXI_SIZE_BITS -1:0]   I1_Size,  
        input   [1:0]                   I1_Burst, 
        input                           I1_Valid, 
        output  logic                   IB1_Ready,
      //output Info
        output  logic [`AXI_IDS_BITS -1:0]      O_IDS,
        output  logic [`AXI_ADDR_BITS -1:0]     O_Addr,
        output  logic [`AXI_LEN_BITS -1:0]      O_Len,
        output  logic [`AXI_SIZE_BITS -1:0]     O_Size,
        output  logic [1:0]                     O_Burst,
        output  logic                           O_Valid,
        input                                   OB_Ready
    );
  //----------------------- Parameter -----------------------//
    //FSM
        parameter [1:0] idle    =   2'd0,
                        I0      =   2'd1,
                        I1      =   2'd2;
  //------------------------- FSM -------------------------//
    always_comb begin
      unique if(I0_Valid)
        Master_sel  =   2'd1; 
      else if(I1_Valid)
        Master_sel  =   2'd2;       
      else
        Master_sel  =   2'd0;        
    end
    
    always_comb begin
        case (Master_sel)
            I0: begin
                O_IDS       =   {4'b0000, I0_ID};   
                O_Addr      =   I0_Addr;
                O_Len       =   I0_Len;
                O_Size      =   I0_Size;
                O_Burst     =   I0_Burst;
                O_Valid     =   I0_Valid; 
                IB0_Ready   =   I0_Valid & OB_Ready;
                IB1_Ready   =   1'b0;    
            end
            I1: begin
                O_IDS       =   {4'b0001, I1_ID};
                O_Addr      =   I1_Addr;
                O_Len       =   I1_Len;
                O_Size      =   I1_Size;
                O_Burst     =   I1_Burst;
                O_Valid     =   I1_Valid; 
                IB0_Ready   =   1'b0;   
                IB1_Ready   =   I1_Valid & OB_Ready;                                                              
            end
            default: begin //idle case
                O_IDS       =   `AXI_IDS_BITS'd0;
                O_Addr      =   `AXI_ADDR_BITS'd0;
                O_Len       =   `AXI_LEN_BITS'd0;
                O_Size      =   `AXI_SIZE_BITS'd0;
                O_Burst     =   2'b0;
                O_Valid     =   1'b0;
                IB0_Ready   =   1'b0;   
                IB1_Ready   =   1'b0;                
            end
        endcase
    end

    endmodule
