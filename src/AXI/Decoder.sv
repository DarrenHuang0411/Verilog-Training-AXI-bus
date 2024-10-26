//--------------------------- Info ---------------------------//
    //Module Name :　Decoder
    //Type        :  
//----------------------- Environment -----------------------//

//------------------------- Module -------------------------//
    module Decoder (
        input   clk, rst,
      //input Info
        input   [`AXI_ADDR_BITS -1:0]   I_Addr,
        input                           I_Valid,
        output  logic                   IB_Ready,
      //output Info 0
        output  logic                   O0_Valid,
        input                           OB0_Ready,    
      //output Info 1       
        output  logic                   O1_Valid,
        input                           OB1_Ready,
      //Default
        output  logic                   ODefault_Valid,
        input                           OBDefault_Ready        
    );


    always_comb begin
        case (I_Addr[31:16])
            `SLAVE1_BASE_ADDR:   begin
                IB_Ready        =   (I_Valid) ? OB0_Ready : 1'b1;
                O0_Valid        =   I_Valid;
                O1_Valid        =   1'b0;
                ODefault_Valid  =   1'b0;
            end
            `SLAVE2_BASE_ADDR:   begin
                IB_Ready        =   (I_Valid) ? OB1_Ready : 1'b1;
                O0_Valid        =   1'b0;
                O1_Valid        =   I_Valid;
                ODefault_Valid  =   1'b0;                              
            end
            default:    begin
                IB_Ready        =   (I_Valid) ? OBDefault_Ready : 1'b1;
                O0_Valid        =   1'b0;
                O1_Valid        =   1'b0;
                ODefault_Valid  =   I_Valid;                                 
            end
        endcase
    end

    endmodule
    