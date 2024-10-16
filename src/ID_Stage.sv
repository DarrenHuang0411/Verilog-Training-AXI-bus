`include "./ID_RegFile.sv"
`include "./ID_FP_RegFile.sv"
`include "./ControlUnit.sv"
`include "./ID_ImmGe.sv"

module ID_Stage (
  input   wire clk, rst,

  input   wire    [`DATA_WIDTH -1:0]  instr,
  input   wire    [4:0]               reg_rd_adddr,
  input   wire    [`DATA_WIDTH -1:0]  reg_rd_data,
  input   wire                        reg_write,
  input   wire                        reg_FP_write,

  output  wire    [`DATA_WIDTH -1:0]  rs1_data,
  output  wire    [`DATA_WIDTH -1:0]  rs2_data,

  output  wire    [`DATA_WIDTH -1:0]  rs1_FP_data,
  output  wire    [`DATA_WIDTH -1:0]  rs2_FP_data,

  output  wire    [`FUNCTION_3 -1:0]  funct3,
  output  wire    [`FUNCTION_7 -1:0]  funct7,
  output  wire    [4:0]               rs1_addr,
  output  wire    [4:0]               rs2_addr,
  output  wire    [4:0]               rd_addr,
  output  wire    [`DATA_WIDTH -1:0]  imm_o,

  //------------ Control Signal ------------//
    output  wire    [2:0]             ALU_Ctrl_op,  
    output  wire                      EXE_pc_sel,   //final --> exe
    output  wire                      ALU_rs2_sel,  //final --> exe
    output  wire    [1:0]             branch_signal,//final --> B ctrl 
    output  wire    [1:0]             MEM_rd_sel,   //final --> mem
    output  wire                      MEM_Din_sel,  //final --> mem
    output  wire                      MEM_DM_read,  //final --> mem
    output  wire                      MEM_DM_write, //final --> mem
    output  wire                      reg_file_write,
    output  wire                      reg_file_FP_write,
    output  wire                      WB_data_sel,
  //
  input   wire    [`DATA_WIDTH -1:0]  in_pc,
  output  wire    [`DATA_WIDTH -1:0]  out_pc
);

//-------------------- reg/connect -------------------//
    wire [`OP_CODE -1:0] opcode;
    wire [4:0]           regf_rs1_addr;
    wire [4:0]           regf_rs2_addr;
    wire [2:0]           ImmGe;

//------------------------ data -----------------------//
  assign  opcode          = instr[6:0];
  assign  regf_rs1_addr   = instr[19:15];
  assign  regf_rs2_addr   = instr[24:20];
  assign  out_pc          = in_pc;
  assign  funct7          = instr[31:25];
  assign  rs2_addr        = instr[24:20];
  assign  rs1_addr        = instr[19:15];
  assign  funct3          = instr[14:12];
  assign  rd_addr         = instr[11:7];

//------------------- Control_Unit -------------------//
    ControlUnit ControlUnit_inst(
        .opcode         (opcode),
        .Imm_type       (ImmGe),
        .ALU_Ctrl_op    (ALU_Ctrl_op),
        .EXE_pc_sel     (EXE_pc_sel),
        .ALU_rs2_sel    (ALU_rs2_sel),
        .branch_signal  (branch_signal),
        .MEM_rd_sel     (MEM_rd_sel),
        .Din_sel        (MEM_Din_sel),
        .DM_read        (MEM_DM_read),
        .DM_write       (MEM_DM_write),
        .reg_file_write (reg_file_write),
        .reg_file_FP_write (reg_file_FP_write),
        .WB_data_sel    (WB_data_sel)
    );

//------------------ Register File -------------------//
    ID_RegFile  ID_RegFile_inst(
        .clk(~clk), .rst(rst),
        .reg_write      (reg_write),//Ctrl

        .rs1_addr       (regf_rs1_addr), 
        .rs2_addr       (regf_rs2_addr), 

        .rd_addr        (reg_rd_adddr),
        .rd_data        (reg_rd_data),        
        .rs1_data       (rs1_data),
        .rs2_data       (rs2_data)
    );

    ID_FP_RegFile  ID_FP_RegFile_inst(
        .clk(~clk), .rst(rst),
        .reg_write      (reg_FP_write),//Ctrl

        .rs1_addr       (regf_rs1_addr), 
        .rs2_addr       (regf_rs2_addr), 

        .rd_addr        (reg_rd_adddr),
        .rd_data        (reg_rd_data),        
        .rs1_FP_data    (rs1_FP_data),
        .rs2_FP_data    (rs2_FP_data)
    );


//---------------- Immediate_Generator ----------------//
    ID_ImmGe  ID_ImmGe_inst(
        .Imm_type   (ImmGe),
        .Instr_in   (instr),
        .Imm_out    (imm_o)
    );

endmodule
