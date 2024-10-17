//--------------------------- Info ---------------------------//
    //Module Name :　DefaultSlave
    //Type        :  
//----------------------- Environment -----------------------//
    `include ""
    `include "CPU.sv"

//------------------------- Module -------------------------//
    module DefaultSlave (
      //W channel - Addr      
        input   DS_AWID ,
        input   DS_AWAddr   ,
        input   DS_AWLen    ,
        input   DS_AWSize   ,
        input   DS_AWBurst  ,
        input   DS_AWValid  ,
        input   DS_AWReady  ,

      //R channel - Addr
        input   DS_ARID ,
        input   DS_ARAddr   ,
        input   DS_ARLen    ,
        input   DS_ARSize   ,
        input   DS_ARBurst  ,
        input   DS_ARValid  ,
        input   DS_ARReady  
    );
  //----------------------- Parameter -----------------------//
    //FSM
      logic     [:0]    S_cur, S_nxt;
      parameter [:0]    ADDR    =   'b00,
                        W_DATA  =   'b01,
                        R_DATA  =   'b10,
                        RESPONSE=   'b11;
  //----------------------- Main Code -----------------------//
    //---------------------    FSM    ---------------------//
        always_ff @(posedge clk or posedge rst) begin
            
        end
    //--------------------- R channel ---------------------//
      //Addr
      


    endmodule