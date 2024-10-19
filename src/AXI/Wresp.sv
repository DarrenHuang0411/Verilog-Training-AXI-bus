//--------------------------- Info ---------------------------//
    //Module Name :　Wresp
    //Type        :  
//----------------------- Environment -----------------------//
    `include ""

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

  //----------------------- Main Code -----------------------//      

    always_comb begin
      
    end

    endmodule