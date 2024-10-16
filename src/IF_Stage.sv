`include "./IF_PC.sv"
//`include "./SRAM_wrapper.sv"

module IF_Stage (
    input   wire clk, rst,
    //F_BranchCtrl
    input   wire    [1:0]               Branch_Ctrl,
    input   wire    [`DATA_WIDTH -1:0]  pc_mux_imm_rs1,
    input   wire    [`DATA_WIDTH -1:0]  pc_mux_imm,
    
    //F_HazardCtrl
    input   wire                        PC_write,
    output  wire    [`DATA_WIDTH -1:0]  o_pc_IM,     
    output  wire    [`DATA_WIDTH -1:0]  O_PC, 
    //instr_mux
    input   logic   [`DATA_WIDTH -1:0]  IM_IF_instr,
    input   logic                       instr_flush_sel,
    output  logic   [`DATA_WIDTH -1:0]  IF_instr_out
);

////wire////
wire    [`DATA_WIDTH -1:0] PC_4;    //F_Mux1
reg     [`DATA_WIDTH -1:0] PC_in;   //F_PC
//F_IM



//------------------- pc+4 adder --------------------//
    assign PC_4     =   O_PC + 32'd4;
    assign o_pc_IM  =   O_PC;  

//------------------ Branch_pc_mux ------------------//
    always_comb begin
        case (Branch_Ctrl)
            2'd1 : PC_in = pc_mux_imm;
            2'd2 : PC_in = pc_mux_imm_rs1; 
            default: PC_in = PC_4;
        endcase     
    end

//------------------ pc_counter ------------------//
    IF_PC IF_PC_inst(
        .clk(clk), .rst(rst),//glo_ctrl
        .PC_write(PC_write),//Ctrl
        .I_PC(PC_in), .O_PC(O_PC) // I/O  
    );

//---------------- instr_flush_mux ----------------//
    assign  IF_instr_out    =   (instr_flush_sel) ? 32'd0 : IM_IF_instr;

endmodule
