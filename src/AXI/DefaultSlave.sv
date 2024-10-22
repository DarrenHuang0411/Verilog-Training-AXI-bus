//--------------------------- Info ---------------------------//
    //Module Name :　DefaultSlave
    //Type        :  
//----------------------- Environment -----------------------//
    `include ""
    `include "CPU.sv"

//------------------------- Module -------------------------//
    module DefaultSlave (
      //W channel - Addr      
        input   [`AXI_ID_BITS -1:0]     DS_AWID ,
        input   [`AXI_ADDR_BITS -1:0]   DS_AWAddr ,
        input   [`AXI_LEN_BITS -1:0]    DS_AWLen    ,
        input   [`AXI_SIZE_BITS -1:0]   DS_AWSize   ,
        input   [1:0]                   DS_AWBurst  ,
        input                           DS_AWValid  ,
        output  logic                   DS_AWReady  ,
      //W channel - data
        input   [`AXI_DATA_BITS -1:0]   DS_WData ,
        input   [`AXI_STRB_BITS -1:0]   DS_WStrb   ,
        input                           DS_WLast   ,
        input                           DS_WValid  ,
        output  logic                   DS_WReady  ,
      //R channel - Addr
        input   DS_ARID ,
        input   DS_ARAddr   ,
        input   DS_ARLen    ,
        input   DS_ARSize   ,
        input   DS_ARBurst  ,
        input   DS_ARValid  ,
        input   DS_ARReady  
      //R channel - data
    );
  //----------------------- Parameter -----------------------//
    //FSM
      logic     [:0]    S_cur, S_nxt;
      parameter [:0]    ADDR    =   'd0,
                        W_DATA  =   'd1,
                        R_DATA  =   'd2,
                        RESPONSE=   'd3;
  //----------------------- Main Code -----------------------//
    //---------------------    FSM    ---------------------//
        always_ff @(posedge clk or posedge rst) begin
            if (rst)   S_cur <=  2'd0;
            else       S_cur <=  S_nxt;
        end
    //--------------------- W channel ---------------------// 
      //Addr
        assign  DS_AWReady =  (DS_AWValid)  ? 1'b1  : 1'b0;   
      //Data

      //Response
    //--------------------- R channel ---------------------//
      //Addr
        assign  DS_ARReady =  (DS_AWValid)  ? 1'b1  : 1'b0;      


    endmodule