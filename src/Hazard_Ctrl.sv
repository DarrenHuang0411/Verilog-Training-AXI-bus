module Hazard_Ctrl (
    input   logic   [1:0] branch_sel,
    input   logic         EXE_read,

    input   logic   [4:0] ID_rs1_addr,
    input   logic   [4:0] ID_rs2_addr,
    input   logic   [4:0] EXE_rd_addr,

    output  reg           pc_write,  
    output  reg           instr_flush,
    output  reg           IF_ID_reg_write,
    output  reg           ctrl_sig_flush,

    output  wire          lw_use  // for CSR
);

assign  lw_use  =   EXE_read && ((EXE_rd_addr == ID_rs1_addr)||(EXE_rd_addr== ID_rs2_addr));

//------------------- parameter -------------------//    

    always_comb begin
        if(branch_sel != 2'b00) begin //PC_4 ==> 2'b00
            pc_write        =   1'b1;
            instr_flush     =   1'b1;
            IF_ID_reg_write =   1'b1;
            ctrl_sig_flush  =   1'b1;            
        end
        else if(EXE_read && ((EXE_rd_addr == ID_rs1_addr)||(EXE_rd_addr== ID_rs2_addr))) begin //lw_use
            pc_write        =   1'b0;
            instr_flush     =   1'b0;
            IF_ID_reg_write =   1'b0;
            ctrl_sig_flush  =   1'b1;
        end
        //compare exe 
        // else if(EXE_read && ((EXE_rd_addr == ID_rs1_addr)||(EXE_rd_addr== ID_rs2_addr))) begin //lw_use_for_FP
        //     pc_write        =   1'b0;
        //     instr_flush     =   1'b0;
        //     IF_ID_reg_write =   1'b0;
        //     ctrl_sig_flush  =   1'b1;
        // end
        else begin
            pc_write        =   1'b1;
            instr_flush     =   1'b0;   
            IF_ID_reg_write =   1'b1;          
            ctrl_sig_flush  =   1'b0;
        end
    end

endmodule   // load use