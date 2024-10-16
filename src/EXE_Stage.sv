`include "./EXE_ALU_Ctrl.sv"
`include "./EXE_ALU.sv"
`include "./EXE_FP_ALU.sv"

module EXE_Stage (
    //control Signal 
    input   wire [`OP_CODE -1:0]    ALU_op,
    input   wire                    pc_mux_sel,
    input   wire                    ALU_rs2_sel,

    input   wire [1:0]              ID_EXE_rd_sel,
    output  wire [1:0]              EXE_MEM_rd_sel,

    input   wire                    ID_EXE_Din, 
    output  wire                    EXE_MEM_Din,       

    input   wire                    ID_EXE_DM_read, 
    output  wire                    EXE_MEM_DM_read,   

    input   wire                    ID_EXE_DM_write,  
    output  wire                    EXE_MEM_DM_write,

    input   wire                    ID_EXE_WB_data_sel,
    output  wire                    EXE_MEM_WB_data_sel,

    input   wire                    ID_EXE_reg_file_write,
    output  wire                    EXE_MEM_reg_file_write,

    input   wire                    ID_EXE_reg_file_FP_write,
    output  wire                    EXE_MEM_reg_file_FP_write,

    input   wire [1:0]              ForwardA_sel,
    input   wire [1:0]              ForwardB_sel,
    input   wire [1:0]              ForwardA_FP_sel,
    input   wire [1:0]              ForwardB_FP_sel,

    //Data
    input   wire [`DATA_WIDTH -1:0] PC_EXE_in,
    input   wire [`DATA_WIDTH -1:0] EXE_rs1,
    input   wire [`DATA_WIDTH -1:0] EXE_rs2,
    input   wire [`DATA_WIDTH -1:0] WB_rd_data,
    input   wire [`DATA_WIDTH -1:0] MEM_rd_data,
    input   wire [`DATA_WIDTH -1:0] EXE_rs1_FP,
    input   wire [`DATA_WIDTH -1:0] EXE_rs2_FP,
    
    input   wire [`DATA_WIDTH -1:0] EXE_imm, 
    input   wire [`FUNCTION_3 -1:0] EXE_function_3,
    input   wire [`FUNCTION_7 -1:0] EXE_function_7,
    input   wire [4:0]              ID_EXE_rd_addr,    

    output  wire [`DATA_WIDTH -1:0] EXE_PC_imm,
    //
    output  wire [`DATA_WIDTH -1:0] pc_sel_o,
    output  reg                     zeroflag,
    output  reg  [`DATA_WIDTH -1:0] ALU_o,
    output  reg  [`DATA_WIDTH -1:0] ALU_FP_out,
    output  wire [`DATA_WIDTH -1:0] ALU_o_2_immrs1,
    output  reg  [`DATA_WIDTH -1:0] Mux3_ALU,
    output  reg  [`DATA_WIDTH -1:0] Mux_rs2_FP,
    
    output  wire [`FUNCTION_3 -1:0] EXE_MEM_function_3,
    output  wire [4:0]              EXE_MEM_rd_addr
);

//<------------------- parameter ------------------->
    reg  [`DATA_WIDTH -1:0] Mux2_ALU;
    reg  [`DATA_WIDTH -1:0] Mux_rs1_FP;

    wire [`DATA_WIDTH -1:0] Mux4_rs2;
    wire [4:0]              ALU_ctrl;
    wire [`DATA_WIDTH -1:0] Add1_Mux1;
    wire [`DATA_WIDTH -1:0] Add2_Mux1;

//------------------- PC+imm -------------------//
    assign  Add1_Mux1   =   PC_EXE_in   +    EXE_imm;
//------------------- PC+4 -------------------//
    assign  Add2_Mux1   =   PC_EXE_in   +   32'd4;

//--------------- Mux1(PC Select) --------------//
    assign  pc_sel_o        =   (pc_mux_sel)  ?   Add1_Mux1   :   Add2_Mux1;

    assign  EXE_PC_imm      =   Add1_Mux1;
    assign  EXE_MEM_rd_sel  =   ID_EXE_rd_sel;
    assign  EXE_MEM_Din     =   ID_EXE_Din;
    assign  EXE_MEM_DM_read =   ID_EXE_DM_read;
    assign  EXE_MEM_DM_write=   ID_EXE_DM_write;

    assign  EXE_MEM_function_3  =   EXE_function_3;
    assign  EXE_MEM_rd_addr =   ID_EXE_rd_addr;
    assign  EXE_MEM_WB_data_sel =   ID_EXE_WB_data_sel;
    assign  EXE_MEM_reg_file_write  =   ID_EXE_reg_file_write;
    assign  EXE_MEM_reg_file_FP_write  =   ID_EXE_reg_file_FP_write;

//--------------- Mux2 (int_RS1_data) --------------//
    always_comb begin 
        case (ForwardA_sel) //(ForwardA_sel)
            2'd0:   Mux2_ALU    =   EXE_rs1;
            2'd1:   Mux2_ALU    =   MEM_rd_data; 
            2'd2:   Mux2_ALU    =   WB_rd_data;
            default: Mux2_ALU    =  32'd0; 
        endcase    
    end
//--------------- Mux3 (int_RS2_data) --------------//
    always_comb begin 
        case (ForwardB_sel) //(ForwardB_sel)
            2'd0:   Mux3_ALU    =   EXE_rs2;
            2'd1:   Mux3_ALU    =   MEM_rd_data;
            2'd2:   Mux3_ALU    =   WB_rd_data;
            default: Mux3_ALU    =  32'd0; 
        endcase    
    end

////Mux4-->imm_sel
    assign  Mux4_rs2 =  (ALU_rs2_sel) ? Mux3_ALU : EXE_imm; //(ALU_sel)
    assign  ALU_o_2_immrs1 =    ALU_o;
//------------------------- EXE_ALU -------------------------//
    EXE_ALU EXE_ALU_inst(
        .ALU_ctrl(ALU_ctrl),
        .rs1(Mux2_ALU), 
        .rs2(Mux4_rs2),
        .ALU_out(ALU_o), 
        .zeroflag(zeroflag)
    );
//------------------------- EXE_ALU_Ctrl -------------------------//
    EXE_ALU_Ctrl EXE_ALU_Ctrl_inst(
        .ALU_op     (ALU_op),
        .function_3 (EXE_function_3),
        .function_7 (EXE_function_7),
        .ALU_ctrl   (ALU_ctrl)
    );

//--------------- Mux_FP (FP_RS1_data) --------------//
    always_comb begin 
        case (ForwardA_FP_sel) //(ForwardA_sel)
            2'd0:       Mux_rs1_FP  =   EXE_rs1_FP;
            2'd1:       Mux_rs1_FP  =   MEM_rd_data; 
            2'd2:       Mux_rs1_FP  =   WB_rd_data;
            default:    Mux_rs1_FP  =  32'd0; 
        endcase    
    end
//--------------- Mux_FP (FP_RS2_data) --------------//
    always_comb begin 
        case (ForwardB_FP_sel) //(ForwardB_sel)
            2'd0:       Mux_rs2_FP  =   EXE_rs2_FP;
            2'd1:       Mux_rs2_FP  =   MEM_rd_data;
            2'd2:       Mux_rs2_FP  =   WB_rd_data;
            default:    Mux_rs2_FP    =  32'd0; 
        endcase    
    end

//-------------- EXE_FP_ALU -------------------------//
    EXE_FP_ALU EXE_FP_ALU_inst(
        .FP_ALU_ctrl(ALU_ctrl),
        .rs1(Mux_rs1_FP), 
        .rs2(Mux_rs2_FP),
        .ALU_FP_out(ALU_FP_out) 
    );

// //------------------------- EXE_ALU_Ctrl -------------------------//
//     EXE_ALU_Ctrl EXE_ALU_Ctrl_inst(
//         .ALU_op     (ALU_op),
//         .function_3 (EXE_function_3),
//         .function_7 (EXE_function_7),
//         .ALU_ctrl   (ALU_ctrl)
//     );




endmodule
