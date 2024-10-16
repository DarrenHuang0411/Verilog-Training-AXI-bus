//--------------------------- Info ---------------------------//
    //Module Name :　Waddr
    //Type        :  
//----------------------- Environment -----------------------//
    `include ""

//------------------------- Module -------------------------//
    module Raddr (
        input           clk, rst,

    );


    Arbiter Arbiter_inst (

    );

    Decoder Decoder_inst(
        .clk(clk), .rst(rst),
        .I_Addr(),
        
    );

    endmodule
