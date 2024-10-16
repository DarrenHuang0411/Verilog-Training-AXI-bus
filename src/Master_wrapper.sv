//----------------------- Environment -----------------------//

//------------------------- Module -------------------------//
    module Master_wrapper (
        input       clock,
        input       rst,
        //inside module
            
        //ouside AXI
        AWID
        AWADDR
        AWLEN
        AWSIZE
        AWBURST
        

    );

  //----------------------- Parameter -----------------------//
    //FSM
        S_cur, S_nxt;


  //------------------------- FSM -------------------------//
    always_ff @(posedge clk or posedge rst) begin
        
    end
    always_comb begin
        
    end
    
  //---------------------- W-channel ----------------------//
    always_ff @( clock ) begin : blockName
        
    end


  //---------------------- R-channel ----------------------//


endmodule