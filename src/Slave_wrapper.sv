//--------------------------- Info ---------------------------//
    //Module Name :　Slave_wrapper
    //Type        :  
//----------------------- Environment -----------------------//
    `include ""

//------------------------- Module -------------------------//
    module Slave_wrapper (
      ports
    );

  //----------------------- Parameter -----------------------//
    //FSM
    logic   [1:0] S_cur, S_nxt;
    parameter   SADDR     = 2'd0,
                RDATA     = 2'd1,
                WDATA     = 2'd2,
                WRESP     = 2'd3;
    //Last Signal
    logic   W_last, R_last;
    //Done Signal 
    logic   Raddr_done, Rdata_done, Waddr_done, Wdata_done, Wresp_done;
  //------------------------- FSM -------------------------//
    always_ff @(posedge clk or posedge ARSTN) begin
        if(!ARSTN)
            S_cur   = INITIAL;
        else
            S_cur   = S_nxt;
    end

    always_comb begin
      case (S_cur)
        SADDR:  begin
          if (Waddr_done && Wdata_done) begin
            
          end 
          else if () begin
            
          end
        end          
        S_nxt  = (Raddr_done) ? RDATA   : RADDR; 
        RDATA:  S_nxt  = (Rdata_done) ? INITIAL : RDATA; 
        WDATA:  S_nxt  = (Wdata_done) ? WRESP   : WDATA; 
        WRESP:  S_nxt  = (Wresp_done) ? INITIAL : WRESP; 
        default:  S_nxt  = INITIAL;
      endcase
    end    

  //--------------------- Done Signal ---------------------//
    assign  Raddr_done  = M_ARValid & M_ARReady; 
    assign  Rdata_done  = M_RValid  & M_RReady;
    assign  Waddr_done  = M_AWValid & M_AWReady;
    assign  Wdata_done  = M_WValid  & M_WReady;
    assign  Wresp_done  = M_ARValid & M_ARReady;
  //---------------------- W-channel ----------------------//


  //---------------------- R-channel ----------------------// 

    endmodule
