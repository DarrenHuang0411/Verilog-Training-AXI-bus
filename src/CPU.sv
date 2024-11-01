//----------------------- Environment -----------------------//
    `include "IF_Stage.sv"
    `include "ID_Stage.sv"
    `include "EXE_Stage.sv"
    `include "MEM_Stage.sv"
    `include "WB_Stage.sv"

    `include "SRAM_wrapper.sv"
    `include "Branch_Ctrl.sv"
    `include "Hazard_Ctrl.sv"
    `include "ForwardingUnit.sv"
    `include "CSR.sv"

module CPU (
    input clk,
    input rst,
  //IM     
    output logic    IM_WEB,
    output logic    [`AXI_DATA_BITS -1:0] IM_addr,
    input           [`DATA_WIDTH -1:0]    IM_IF_instr,
    input           IM_Trans_Stall,
  //DM  
    output logic    DM_WEB,
    output logic    DM_read_sel,
    output logic    DM_write_sel,
    output logic    [`DATA_WIDTH -1:0] DM_BWEB,
    output logic    [`AXI_ADDR_BITS -1:0] DM_addr,
    output logic    [`AXI_DATA_BITS -1:0] DM_Din,
    input           [`AXI_DATA_BITS -1:0] DM_Dout,
    input           DM_Trans_Stall
);

//------------------- parameter -------------------//    
    // (temp.) IF_OUT
    wire    [`DATA_WIDTH -1:0]  IF_IM_pc;
    //////////////////////////////////////////////////
    wire    [1:0]               BC_IF_branch_sel;
    wire    [`DATA_WIDTH -1:0]  EXE_IF_ALU_o;
    wire    [`DATA_WIDTH -1:0]  EXE_IF_pc_imm;
    wire                        HAZ_IF_pc_w;
    wire                        HAZ_IF_instr_flush;
    wire                        wire_HAZ_IF_ID_reg_write;
    wire                        wire_HAZ_ID_EXE_reg_write;
    wire                        wire_HAZ_EXE_MEM_reg_write;
    wire                        wire_HAZ_Stall;  
    wire                        wire_HAZ_MEM_WB_reg_write;      
    wire                        wire_ctrl_sig_flush;
    wire                        wire_HAZ_CSR_lw_use;

    wire    [1:0]               FWD_EXE_rs1_sel;
    wire    [1:0]               FWD_EXE_rs2_sel;
    wire    [1:0]               FWD_EXE_rs1_FP_sel;
    wire    [1:0]               FWD_EXE_rs2_FP_sel;
    ///////////////////////////////////////////////////
    wire                        EXE_Bctrl_zeroflag;
    wire                        MEM_DM_CS;

    wire    [`DATA_WIDTH-1:0]   DM_write_enable;
//------------------- Stage Reg -------------------//
  //--------------- IF-ID Register --------------//
    reg [`DATA_WIDTH -1:0]  IF_ID_pc;
    reg [`DATA_WIDTH -1:0]  IF_ID_instr;
    wire [`DATA_WIDTH -1:0]  wire_IF_ID_pc;
    wire [`DATA_WIDTH -1:0]  wire_IF_ID_instr;

  //------------- ID-EXE Register --------------//
    reg [`DATA_WIDTH -1:0]  ID_EXE_pc_in;
    reg [`DATA_WIDTH -1:0]  ID_EXE_rs1;
    reg [`DATA_WIDTH -1:0]  ID_EXE_rs2;
    reg [`DATA_WIDTH -1:0]  ID_EXE_rs1_FP;
    reg [`DATA_WIDTH -1:0]  ID_EXE_rs2_FP;

    reg [`FUNCTION_3 -1:0]  ID_EXE_function3;
    reg [`FUNCTION_7 -1:0]  ID_EXE_function7;
    reg [4:0]               ID_EXE_rs1_addr;
    reg [4:0]               ID_EXE_rs2_addr;
    reg [4:0]               ID_EXE_rd_addr;
    reg [`DATA_WIDTH -1:0]  ID_EXE_imm;

    wire [`DATA_WIDTH -1:0]  wire_ID_EXE_pc_in;
    wire [`DATA_WIDTH -1:0]  wire_ID_EXE_rs1;
    wire [`DATA_WIDTH -1:0]  wire_ID_EXE_rs2;
    wire [`DATA_WIDTH -1:0]  wire_ID_EXE_rs1_FP;
    wire [`DATA_WIDTH -1:0]  wire_ID_EXE_rs2_FP;

    wire [`FUNCTION_3 -1:0]  wire_ID_EXE_function3    ;
    wire [`FUNCTION_7 -1:0]  wire_ID_EXE_function7    ;
    wire [4:0]               wire_ID_EXE_rs1_addr     ;
    wire [4:0]               wire_ID_EXE_rs2_addr     ;
    wire [4:0]               wire_ID_EXE_rd_addr      ;
    wire [`DATA_WIDTH -1:0]  wire_ID_EXE_imm          ;
    //------------- Ctrl sig reg -------------//
      reg [`OP_CODE -1:0]   ID_EXE_ALU_Ctrl_op;
      reg                   ID_EXE_pc_mux;          // final --> EXE
      reg                   ID_EXE_ALU_rs2_sel;
      reg [1:0]             ID_EXE_branch_signal;
      reg [1:0]             ID_EXE_rd_sel;          // final --> MEM
      reg                   ID_EXE_Din_sel;         // final --> MEM
      reg                   ID_EXE_DM_read;         // final --> MEM
      reg                   ID_EXE_DM_write;        // final --> MEM
      reg                   ID_EXE_WB_data_sel   ;
      reg                   ID_EXE_reg_file_write;
      reg                   ID_EXE_reg_file_FP_write;

      wire [2:0]            wire_ID_EXE_ALU_Ctrl_op  ;
      wire                  wire_ID_EXE_pc_mux       ;
      wire                  wire_ID_EXE_ALU_rs2_sel  ;
      wire [1:0]            wire_ID_EXE_branch_signal;
      wire [1:0]            wire_ID_EXE_rd_sel       ;
      wire                  wire_ID_EXE_Din_sel      ;      
      wire                  wire_ID_EXE_DM_read      ;
      wire                  wire_ID_EXE_DM_write     ;
      wire                  wire_ID_EXE_WB_data_sel   ;
      wire                  wire_ID_EXE_reg_file_write;
      wire                  wire_ID_EXE_reg_file_FP_write;

  //------------- EXE-MEM Register --------------//
    reg [`DATA_WIDTH -1:0]  EXE_MEM_PC;
    reg [`DATA_WIDTH -1:0]  EXE_MEM_ALU_o;
    reg [`DATA_WIDTH -1:0]  EXE_MEM_ALU_FP_o;
    reg [`DATA_WIDTH -1:0]  EXE_MEM_rs2_data;
    reg [`DATA_WIDTH -1:0]  EXE_MEM_rs2_FP_data;
    reg [`FUNCTION_3 -1:0]  EXE_MEM_function_3;
    reg [4:0]               EXE_MEM_rd_addr;
    reg [`DATA_WIDTH -1:0]  EXE_MEM_csr_rd ;

    wire [`DATA_WIDTH -1:0]  wire_EXE_MEM_PC         ;
    wire [`DATA_WIDTH -1:0]  wire_EXE_MEM_ALU_o      ;
    wire [`DATA_WIDTH -1:0]  wire_EXE_MEM_ALU_FP_o   ;    
    wire [`DATA_WIDTH -1:0]  wire_EXE_MEM_rs2_data   ;
    wire [`DATA_WIDTH -1:0]  wire_EXE_MEM_rs2_FP_data;
    wire [`FUNCTION_3 -1:0]  wire_EXE_MEM_function_3 ;
    wire [4:0]               wire_EXE_MEM_rd_addr    ;
    wire [`DATA_WIDTH -1:0]  wire_EXE_MEM_csr_rd     ;

    wire [`DATA_WIDTH -1:0] MEM_DM_Din;
    //------------- Ctrl sig reg -------------//
      reg  [1:0]            EXE_MEM_rd_sel;         // final --> MEM
      reg                   EXE_MEM_Din_sel;        // final --> MEM      
      reg                   EXE_MEM_DM_read;        // final --> MEM
      reg                   EXE_MEM_DM_write;       // final --> MEM
      reg                   EXE_MEM_data_sel;       // final --> WB
      reg                   EXE_MEM_reg_file_write; // final --> WB --> RF
      reg                   EXE_MEM_reg_file_FP_write;

      wire  [1:0]           wire_EXE_MEM_rd_sel;  
      wire                  wire_EXE_MEM_Din_sel;        
      wire                  wire_EXE_MEM_DM_read;    
      wire                  wire_EXE_MEM_DM_write;   
      wire                  wire_EXE_MEM_data_sel;
      wire                  wire_EXE_MEM_reg_file_write;
      wire                  wire_EXE_MEM_reg_file_FP_write;
  //------------- MEM-WB Register  --------------//
    reg  [`DATA_WIDTH -1:0]  MEM_WB_rd_dir;
    reg  [`DATA_WIDTH -1:0]  MEM_WB_rd_DM;
    reg  [4:0]               MEM_WB_rd_addr;   
    wire [`DATA_WIDTH -1:0]  DM_MEM_Dout;
    wire                     SRAM_web;  
    wire [`DATA_WIDTH -1:0]  wire_MEM_WB_rd_dir;
    wire [`DATA_WIDTH -1:0]  wire_MEM_WB_rd_DM;
    wire [4:0]               wire_MEM_WB_rd_addr;   

    //------------- Ctrl sig reg -------------//
      reg                    MEM_WB_data_sel; //final --> WB
      wire                   wire_MEM_WB_data_sel;

      reg                    MEM_WB_reg_file_write;
      wire                   wire_MEM_WB_reg_file_write;

      reg                    MEM_WB_reg_file_FP_write;
      wire                   wire_MEM_WB_reg_file_FP_write;
  //------------- WB wire/reg -------------------//
    wire [`DATA_WIDTH -1:0]  WB_rd_data;

//------------------- IF_Stage -------------------//
    IF_Stage IF_Stage_inst(
        .clk(clk), .rst(rst),
        .Branch_Ctrl      (BC_IF_branch_sel),
        .pc_mux_imm_rs1   (EXE_IF_ALU_o),
        .pc_mux_imm       (EXE_IF_pc_imm),
        .PC_write         (HAZ_IF_pc_w),
        .O_PC             (wire_IF_ID_pc),
        .o_pc_IM          (IF_IM_pc),              
        .IM_IF_instr      (IM_IF_instr),
        .instr_flush_sel  (HAZ_IF_instr_flush),
        .IF_instr_out     (wire_IF_ID_instr)
    );


    assign  IM_WEB    =   1'b1; // read mode
    assign  IM_addr   =   IF_IM_pc;

    // SRAM_wrapper IM1(
    //     .CLK(~clk), .RST(rst),
    //     .CEB(1'b0),
    //     .WEB(1'b1),
    //     // .OE(1'b1),
    //     .BWEB(32'hffff_ffff),
    //     // .WEB(4'b1111),
    //     .A(IF_IM_pc[15:2]),
    //     .DI(32'd0),
    //     .DO(IM_IF_instr)
    // );

//------------------- ID_Stage -------------------//
    ID_Stage ID_Stage_inst(
        .clk(clk), .rst(rst),
        
        .instr          (IF_ID_instr),
        .reg_rd_adddr   (MEM_WB_rd_addr),
        .reg_rd_data    (WB_rd_data),
        .reg_write      (MEM_WB_reg_file_write),
        .reg_FP_write   (MEM_WB_reg_file_FP_write),

        .rs1_data       (wire_ID_EXE_rs1),
        .rs2_data       (wire_ID_EXE_rs2),
        .rs1_FP_data    (wire_ID_EXE_rs1_FP),
        .rs2_FP_data    (wire_ID_EXE_rs2_FP),

        .funct3         (wire_ID_EXE_function3),
        .funct7         (wire_ID_EXE_function7),
        .rs1_addr       (wire_ID_EXE_rs1_addr),
        .rs2_addr       (wire_ID_EXE_rs2_addr),
        .rd_addr        (wire_ID_EXE_rd_addr),
        .imm_o          (wire_ID_EXE_imm),

    //------------ Control Signal ------------//
        .ALU_Ctrl_op    (wire_ID_EXE_ALU_Ctrl_op),
        .EXE_pc_sel     (wire_ID_EXE_pc_mux),        //final --> exe
        .ALU_rs2_sel    (wire_ID_EXE_ALU_rs2_sel),   //final --> exe
        .branch_signal  (wire_ID_EXE_branch_signal), //final --> B ctrl     
        .MEM_rd_sel     (wire_ID_EXE_rd_sel),        //final --> mem
        .MEM_Din_sel    (wire_ID_EXE_Din_sel),       //final --> mem
        .MEM_DM_read    (wire_ID_EXE_DM_read),       //final --> mem
        .MEM_DM_write   (wire_ID_EXE_DM_write),      //final --> mem
        
        .WB_data_sel    (wire_ID_EXE_WB_data_sel),
        .reg_file_write (wire_ID_EXE_reg_file_write),
        .reg_file_FP_write (wire_ID_EXE_reg_file_FP_write),

        .in_pc          (IF_ID_pc),
        .out_pc         (wire_ID_EXE_pc_in)
    );

//------------------- EXE_Stage -------------------//
    EXE_Stage EXE_Stage(
      //control Signal 
        .ALU_op         (ID_EXE_ALU_Ctrl_op),
        .pc_mux_sel     (ID_EXE_pc_mux),
        .ALU_rs2_sel    (ID_EXE_ALU_rs2_sel),   //final --> exe

        .ID_EXE_rd_sel  (ID_EXE_rd_sel),
        .EXE_MEM_rd_sel (wire_EXE_MEM_rd_sel),

        .ID_EXE_Din     (ID_EXE_Din_sel), 
        .EXE_MEM_Din    (wire_EXE_MEM_Din_sel),

        .ID_EXE_DM_read (ID_EXE_DM_read), 
        .EXE_MEM_DM_read(wire_EXE_MEM_DM_read),

        .ID_EXE_DM_write (ID_EXE_DM_write), 
        .EXE_MEM_DM_write(wire_EXE_MEM_DM_write),

        .ID_EXE_WB_data_sel (ID_EXE_WB_data_sel),
        .EXE_MEM_WB_data_sel(wire_EXE_MEM_data_sel),
        
        .ID_EXE_reg_file_write (ID_EXE_reg_file_write),
        .EXE_MEM_reg_file_write(wire_EXE_MEM_reg_file_write),

        .ID_EXE_reg_file_FP_write (ID_EXE_reg_file_FP_write),
        .EXE_MEM_reg_file_FP_write(wire_EXE_MEM_reg_file_FP_write),

        .ForwardA_sel   (FWD_EXE_rs1_sel),
        .ForwardB_sel   (FWD_EXE_rs2_sel),//revise
        .ForwardA_FP_sel   (FWD_EXE_rs1_FP_sel),
        .ForwardB_FP_sel   (FWD_EXE_rs2_FP_sel),//revise
      //Data
        .PC_EXE_in      (ID_EXE_pc_in),
        .EXE_rs1        (ID_EXE_rs1),
        .EXE_rs2        (ID_EXE_rs2),
        .WB_rd_data     (WB_rd_data),
        .MEM_rd_data    (wire_MEM_WB_rd_dir), //Focus
        .EXE_rs1_FP     (ID_EXE_rs1_FP),
        .EXE_rs2_FP     (ID_EXE_rs2_FP),    

        .EXE_imm        (ID_EXE_imm), 
        .EXE_function_3 (ID_EXE_function3),
        .EXE_function_7 (ID_EXE_function7),
        .ID_EXE_rd_addr (ID_EXE_rd_addr),
        
        .EXE_PC_imm     (EXE_IF_pc_imm),

        .pc_sel_o       (wire_EXE_MEM_PC),
        .zeroflag       (EXE_Bctrl_zeroflag),
        .ALU_o          (wire_EXE_MEM_ALU_o),
        .ALU_FP_out     (wire_EXE_MEM_ALU_FP_o),
        .ALU_o_2_immrs1 (EXE_IF_ALU_o),
        .Mux3_ALU       (wire_EXE_MEM_rs2_data),
        .Mux_rs2_FP     (wire_EXE_MEM_rs2_FP_data),

        .EXE_MEM_function_3 (wire_EXE_MEM_function_3),
        .EXE_MEM_rd_addr(wire_EXE_MEM_rd_addr)
    );

//------------------- MEM_Stage -------------------//
    MEM_Stage MEM_Stage_inst(
        .clk(clk),  
        .rst(rst), 
        //----------------- Ctrl sig reg ----------------------//
        .MEM_rd_sel       (EXE_MEM_rd_sel),
        .MEM_Din_sel      (EXE_MEM_Din_sel),
        .MEM_DMread_sel   (EXE_MEM_DM_read), 
        .MEM_DMwrite_sel  (EXE_MEM_DM_write),
        .EXE_MEM_WB_data_sel (EXE_MEM_data_sel),
        .EXE_MEM_reg_file_write (EXE_MEM_reg_file_write),
        .EXE_MEM_reg_file_FP_write (EXE_MEM_reg_file_FP_write),
        .MEM_WB_data_sel  (wire_MEM_WB_data_sel),
        .MEM_WB_reg_file_write (wire_MEM_WB_reg_file_write),
        .MEM_WB_reg_file_FP_write (wire_MEM_WB_reg_file_FP_write),
        //----------------------- MEM_I/O -----------------------//
        .MEM_pc           (EXE_MEM_PC),
        .MEM_ALU          (EXE_MEM_ALU_o),
        .MEM_ALU_FP       (EXE_MEM_ALU_FP_o),
        .MEM_csr          (EXE_MEM_csr_rd),
        .EXE_MEM_rd_addr  (EXE_MEM_rd_addr),
        .MEM_WB_rd_addr   (wire_MEM_WB_rd_addr),
        //------------------------ Data ------------------------//  
        .EXE_funct3       (EXE_MEM_function_3),
        .EXE_rs2_data     (EXE_MEM_rs2_data),   
        .EXE_rs2_FP_data  (EXE_MEM_rs2_FP_data),  
        .MEM_rd_data      (wire_MEM_WB_rd_dir),

        //------------------------- DM -------------------------//    
        .chip_select      (MEM_DM_CS),
        .SRAM_web         (SRAM_web),
        //------------------------- SW -------------------------// 
        .w_eb             (DM_write_enable),
        .DM_in            (MEM_DM_Din),

        //------------------------- LW -------------------------//     
        .DM_out           (DM_MEM_Dout),
        .DM_out_2_reg     (wire_MEM_WB_rd_DM)
    );

    // DM1
        assign  DM_WEB          =   SRAM_web;
        assign  DM_read_sel     =   EXE_MEM_DM_read;
        assign  DM_write_sel    =   EXE_MEM_DM_write;        
        assign  DM_BWEB         =   DM_write_enable;
        assign  DM_addr         =   EXE_MEM_ALU_o;
        //{15'd0, 1'b1, 2'd0, EXE_MEM_ALU_o[15:2]};
        assign  DM_Din  =   MEM_DM_Din;
        assign  DM_MEM_Dout =   DM_Dout;
    // SRAM_wrapper DM1(
    //     .CLK    (~clk), .RST(rst),
    //     .CEB    (MEM_DM_CS), // Chip Enable
    //     .WEB    (SRAM_web),
    //     .BWEB   (DM_write_enable),
    //     //.OE (EXE_MEM_DM_read),
    //     //.WEB(DM_write_enable),
    //     .A      (EXE_MEM_ALU_o[15:2]),
    //     .DI     (MEM_DM_Din), 
    //     .DO     (DM_MEM_Dout)
    // );

//------------------- WB_Stage -------------------//
    WB_Stage WB_Stage_inst(
        .data_sel       (MEM_WB_data_sel),

        .WB_rd_dir      (MEM_WB_rd_dir),
        .WB_rd_DM       (MEM_WB_rd_DM),
        .WB_rd_data     (WB_rd_data)
    );

//--------------- Branch Control -----------------//
    Branch_Ctrl Branch_Ctrl_inst(
        .zeroflag       (EXE_Bctrl_zeroflag),
        .branch_signal  (ID_EXE_branch_signal),
        .branch_sel     (BC_IF_branch_sel)
    );

//---------------- Hazard Control -----------------//
    Hazard_Ctrl Hazard_Ctrl_inst(
        .branch_sel         (BC_IF_branch_sel),
        .EXE_read           (ID_EXE_DM_read),

        .ID_rs1_addr        (wire_ID_EXE_rs1_addr),
        .ID_rs2_addr        (wire_ID_EXE_rs2_addr),
        .EXE_rd_addr        (wire_EXE_MEM_rd_addr),
        
        .IM_Trans_Stall     (IM_Trans_Stall),
        .DM_Trans_Stall     (DM_Trans_Stall),
        //.Stall_both         (wire_HAZ_Stall),
        .pc_write           (HAZ_IF_pc_w),  
        .instr_flush        (HAZ_IF_instr_flush),
        .IF_ID_reg_write    (wire_HAZ_IF_ID_reg_write),
        .ID_EXE_reg_write   (wire_HAZ_ID_EXE_reg_write),
        .EXE_MEM_reg_write  (wire_HAZ_EXE_MEM_reg_write),
        .MEM_WB_reg_write   (wire_HAZ_MEM_WB_reg_write),
        .ctrl_sig_flush     (wire_ctrl_sig_flush),
        .lw_use             (wire_HAZ_CSR_lw_use),
        .Hazard_Stall       (wire_HAZ_Stall)
    );

//--------------- Forwarding Unit -----------------//
    ForwardingUnit ForwardingUnit_inst(
       .ID_rs1_addr          (ID_EXE_rs1_addr),
       .ID_rs2_addr          (ID_EXE_rs2_addr),
       .EXE_rd_addr          (EXE_MEM_rd_addr),
       .MEM_rd_addr          (MEM_WB_rd_addr),

       .EXE_MEM_fwd_write    (EXE_MEM_reg_file_write),
       .MEM_WB_fwd_write     (MEM_WB_reg_file_write),
       .EXE_MEM_fwd_FP_write (EXE_MEM_reg_file_FP_write),
       .MEM_WB_fwd_FP_write  (MEM_WB_reg_file_FP_write), 

       .FWD_rs1_sel          (FWD_EXE_rs1_sel),
       .FWD_rs2_sel          (FWD_EXE_rs2_sel),
       .FWD_rs1_FP_sel       (FWD_EXE_rs1_FP_sel),
       .FWD_rs2_FP_sel       (FWD_EXE_rs2_FP_sel)    
    );

//------------------- CSR --------------------------//
    CSR CSR_inst(
        .clk(clk), .rst(rst),
        .CSR_op         (ID_EXE_ALU_Ctrl_op),
        .function_3     (ID_EXE_function3),
        .rs1            (ID_EXE_rs1),
        .imm_csr        (ID_EXE_imm),

        .HAZ_Stall      (wire_HAZ_Stall),
        .lw_use         (wire_HAZ_CSR_lw_use),
        .branch         (BC_IF_branch_sel),
        .csr_rd_data    (wire_EXE_MEM_csr_rd)
    );

//--------------- register_reset -----------------//
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            IF_ID_pc                <=  0;
            IF_ID_instr             <=  0;
        end 
        else begin
            if(wire_HAZ_IF_ID_reg_write) begin
                IF_ID_pc                <= wire_IF_ID_pc;
                IF_ID_instr             <= (HAZ_IF_instr_flush) ? 32'b0 : wire_IF_ID_instr;    
            end
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            ID_EXE_pc_in            <=  0;
            ID_EXE_rs1              <=  0;   
            ID_EXE_rs2              <=  0;
            ID_EXE_rs1_FP           <=  0;
            ID_EXE_rs2_FP           <=  0;

            ID_EXE_function3        <=  0;
            ID_EXE_function7        <=  0;
            ID_EXE_rs1_addr         <=  0;
            ID_EXE_rs2_addr         <=  0;
            ID_EXE_rd_addr          <=  0;
            ID_EXE_imm              <=  0;
            ID_EXE_ALU_Ctrl_op      <=  0;
            ID_EXE_pc_mux           <=  0;
            ID_EXE_ALU_rs2_sel      <=  0;
            ID_EXE_branch_signal    <=  0;
            ID_EXE_rd_sel           <=  0;
            ID_EXE_Din_sel          <=  0;
            ID_EXE_DM_read          <=  0;
            ID_EXE_DM_write         <=  0;
            ID_EXE_WB_data_sel      <=  0;
            ID_EXE_reg_file_write   <=  0;
            ID_EXE_reg_file_FP_write<=  0;
        end 
        // else if (wire_ctrl_sig_flush) begin
        //     ID_EXE_branch_signal        <=  1'b0 ;   
        //     ID_EXE_DM_read              <=  1'b0 ;
        //     ID_EXE_DM_write             <=  1'b0 ; 
        //     ID_EXE_reg_file_write       <=  1'b0 ;   
        //     ID_EXE_reg_file_FP_write    <=  1'b0 ;                                   
        // end
        else if (wire_HAZ_ID_EXE_reg_write)begin
            ID_EXE_pc_in            <= wire_ID_EXE_pc_in;
            ID_EXE_rs1              <= wire_ID_EXE_rs1;
            ID_EXE_rs2              <= wire_ID_EXE_rs2;
            ID_EXE_rs1_FP           <= wire_ID_EXE_rs1_FP;
            ID_EXE_rs2_FP           <= wire_ID_EXE_rs2_FP;

            ID_EXE_function3        <= wire_ID_EXE_function3    ;
            ID_EXE_function7        <= wire_ID_EXE_function7    ;
            ID_EXE_rs1_addr         <= wire_ID_EXE_rs1_addr     ;
            ID_EXE_rs2_addr         <= wire_ID_EXE_rs2_addr     ;
            ID_EXE_rd_addr          <= wire_ID_EXE_rd_addr      ;
            ID_EXE_imm              <= wire_ID_EXE_imm          ;
            ID_EXE_ALU_Ctrl_op      <= wire_ID_EXE_ALU_Ctrl_op  ;
            ID_EXE_pc_mux           <= wire_ID_EXE_pc_mux       ;
            ID_EXE_ALU_rs2_sel      <= wire_ID_EXE_ALU_rs2_sel  ;
            ID_EXE_branch_signal    <= (wire_ctrl_sig_flush)? 2'b0 : wire_ID_EXE_branch_signal;
            ID_EXE_rd_sel           <= wire_ID_EXE_rd_sel       ;
            ID_EXE_Din_sel          <= wire_ID_EXE_Din_sel       ;
            ID_EXE_DM_read          <= (wire_ctrl_sig_flush)? 1'b0 :wire_ID_EXE_DM_read;
            ID_EXE_DM_write         <= (wire_ctrl_sig_flush)? 1'b0 :wire_ID_EXE_DM_write;   
            ID_EXE_WB_data_sel      <= wire_ID_EXE_WB_data_sel  ;
            ID_EXE_reg_file_write   <= (wire_ctrl_sig_flush)? 1'b0 :wire_ID_EXE_reg_file_write;   
            ID_EXE_reg_file_FP_write<= (wire_ctrl_sig_flush)? 1'b0 :wire_ID_EXE_reg_file_FP_write;  
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            EXE_MEM_PC                <=    0;                 
            EXE_MEM_ALU_o             <=    0;
            EXE_MEM_ALU_FP_o          <=    0;                                     
            EXE_MEM_rs2_data          <=    0; 
            EXE_MEM_rs2_FP_data       <=    0;                         
            EXE_MEM_function_3        <=    0;                                    
            EXE_MEM_rd_addr           <=    0;                     
            EXE_MEM_csr_rd            <=    0;  
              
            EXE_MEM_rd_sel            <=    0; 
            EXE_MEM_Din_sel           <=    0;          
            EXE_MEM_DM_read           <=    0;                  
            EXE_MEM_DM_write          <=    0;                  
            EXE_MEM_data_sel          <=    0;  
            EXE_MEM_reg_file_write    <=    0;
            EXE_MEM_reg_file_FP_write <=    0;                            
        end 
        // else if(wire_HAZ_Stall_Both) begin
        //     EXE_MEM_DM_read           <=    0;
        //     EXE_MEM_DM_write          <=    0;
        // end
        else if(wire_HAZ_EXE_MEM_reg_write) begin
            EXE_MEM_PC                <=    wire_EXE_MEM_PC         ;                 
            EXE_MEM_ALU_o             <=    wire_EXE_MEM_ALU_o      ; 
            EXE_MEM_ALU_FP_o          <=    wire_EXE_MEM_ALU_FP_o   ;                                               
            EXE_MEM_rs2_data          <=    wire_EXE_MEM_rs2_data   ;
            EXE_MEM_rs2_FP_data       <=    wire_EXE_MEM_rs2_FP_data;                                     
            EXE_MEM_function_3        <=    wire_EXE_MEM_function_3 ;                                    
            EXE_MEM_rd_addr           <=    wire_EXE_MEM_rd_addr    ; 
            EXE_MEM_csr_rd            <=    wire_EXE_MEM_csr_rd     ;  
            
            EXE_MEM_rd_sel            <=    wire_EXE_MEM_rd_sel; 
            EXE_MEM_Din_sel           <=    wire_EXE_MEM_Din_sel;                               
            EXE_MEM_DM_read           <=    wire_EXE_MEM_DM_read;                      
            EXE_MEM_DM_write          <=    wire_EXE_MEM_DM_write;                     
            EXE_MEM_data_sel          <=    wire_EXE_MEM_data_sel;  
            EXE_MEM_reg_file_write    <=    wire_EXE_MEM_reg_file_write;    
            EXE_MEM_reg_file_FP_write <=    wire_EXE_MEM_reg_file_FP_write;                                               
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            MEM_WB_rd_dir             <=   0;     
            MEM_WB_rd_DM              <=   0; 
            MEM_WB_rd_addr            <=   0; 
            
            MEM_WB_data_sel           <=   0;   
            MEM_WB_reg_file_write     <=   0;
            MEM_WB_reg_file_FP_write  <=   0;
        end 
        else if (wire_HAZ_MEM_WB_reg_write) begin
            MEM_WB_rd_dir             <=   wire_MEM_WB_rd_dir;      
            MEM_WB_rd_DM              <=   wire_MEM_WB_rd_DM;       
            MEM_WB_rd_addr            <=   wire_MEM_WB_rd_addr;
            
            MEM_WB_data_sel           <=   wire_MEM_WB_data_sel; 
            MEM_WB_reg_file_write     <=   wire_MEM_WB_reg_file_write;
            MEM_WB_reg_file_FP_write  <=   wire_MEM_WB_reg_file_FP_write;
        end        
    end
endmodule
