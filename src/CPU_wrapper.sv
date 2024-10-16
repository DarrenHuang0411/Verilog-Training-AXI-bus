//--------------------------- Info ---------------------------//
    //Module Name :　CPU_wrapper
    //Type        :  Master 
//----------------------- Environment -----------------------//
    `include ""
    `include "CPU.sv"

//------------------------- Module -------------------------//
    module CPU_wrapper (
        input   clk,
        input   rst,
      //Write Channel

      //Read Channel

    );

  //----------------------- Parameter -----------------------//


    CPU CPU_inst(
        .clk(clk), .rst(rst),
        
        .IM_WEB(),
        .IM_addr(),
        .IM_IF_instr(),
        
        .DM_WEB(),
        .DM_BWEB(),
        .DM_addr(),
        .DM_Din(),
        .DM_Dout()
    );

    Master_wrapper Master_wrapper_Instr_inst(
        .clk(clk), .rst(rst),

    );

    Master_wrapper Master_wrapper_data_inst(
        .clk(clk), .rst(rst),

    );

    endmodule

