module Hazard_Ctrl (
    input          [1:0] branch_sel,
    input                EXE_read,

    input          [4:0] ID_rs1_addr,
    input          [4:0] ID_rs2_addr,
    input          [4:0] EXE_rd_addr,

    output  reg           instr_flush,
    output  reg           ctrl_sig_flush,

    input                 IM_Trans_Stall,
    input                 DM_Trans_Stall,
    output  reg           Stall_both,  //Master & also for CSR
    output  reg           pc_write,  
    output  reg           IF_ID_reg_write,
    output  reg           ID_EXE_reg_write,  
    output  reg           EXE_MEM_reg_write,    
    output  reg           MEM_WB_reg_write,  
    output  wire          lw_use,  // for CSR
    output  logic         Hazard_Stall
);

assign  lw_use          =   EXE_read && ((EXE_rd_addr == ID_rs1_addr)||(EXE_rd_addr== ID_rs2_addr));
assign  Hazard_Stall    =   IM_Trans_Stall || DM_Trans_Stall;

//------------------- parameter -------------------//    
    always_comb begin
        if (IM_Trans_Stall && DM_Trans_Stall) begin
            Stall_both          =   1'b1;
        end 
        else begin
            Stall_both          =   1'b0;            
        end
    end

    always_comb begin
        if(IM_Trans_Stall || DM_Trans_Stall) begin
            instr_flush         =   1'b0;
            ctrl_sig_flush      =   1'b0;       
            pc_write            =   1'b0;
            IF_ID_reg_write     =   1'b0; 
            ID_EXE_reg_write    =   1'b0;
            EXE_MEM_reg_write   =   1'b0;
            MEM_WB_reg_write    =   1'b0;       
        end
        else if(branch_sel != 2'b00) begin //PC_4 ==> 2'b00
            instr_flush         =   1'b1;
            ctrl_sig_flush      =   1'b1;            
            pc_write            =   1'b1;
            IF_ID_reg_write     =   1'b1;
            ID_EXE_reg_write    =   1'b1;
            EXE_MEM_reg_write   =   1'b1;
            MEM_WB_reg_write    =   1'b1;                
        end
        else if(EXE_read && ((EXE_rd_addr == ID_rs1_addr)||(EXE_rd_addr== ID_rs2_addr))) begin //lw_use
            instr_flush         =   1'b0;
            ctrl_sig_flush      =   1'b1;
            pc_write            =   1'b0;
            IF_ID_reg_write     =   1'b0;
            ID_EXE_reg_write    =   1'b1;
            EXE_MEM_reg_write   =   1'b1;
            MEM_WB_reg_write    =   1'b1;              
        end
        //compare exe 
        // else if(EXE_read && ((EXE_rd_addr == ID_rs1_addr)||(EXE_rd_addr== ID_rs2_addr))) begin //lw_use_for_FP
        //     pc_write        =   1'b0;
        //     instr_flush     =   1'b0;
        //     IF_ID_reg_write =   1'b0;
        //     ctrl_sig_flush  =   1'b1;
        // end
        else begin
            instr_flush         =   1'b0;   
            ctrl_sig_flush      =   1'b0;
            pc_write            =   1'b1;
            IF_ID_reg_write     =   1'b1;  
            ID_EXE_reg_write    =   1'b1;
            EXE_MEM_reg_write   =   1'b1;
            MEM_WB_reg_write    =   1'b1;                        
        end
    end

endmodule   // load use