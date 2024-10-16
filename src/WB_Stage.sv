module WB_Stage (
    input   wire                    data_sel,
    input   wire [`DATA_WIDTH -1:0] WB_rd_dir,      //rd
    input   wire [`DATA_WIDTH -1:0] WB_rd_DM,       //DM
    output  reg  [`DATA_WIDTH -1:0] WB_rd_data
);

//wire    WB_Mux_Ctrl;

////WB_Mux////
//assign  WB_Mux_Ctrl =   reg_Ctrl;
    assign  WB_rd_data  =   (data_sel) ? WB_rd_DM : WB_rd_dir;   

endmodule
