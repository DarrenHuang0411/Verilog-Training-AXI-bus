module ForwardingUnit (
    
    input   logic   [4:0]   ID_rs1_addr,
    input   logic   [4:0]   ID_rs2_addr,
    input   logic   [4:0]   EXE_rd_addr,
    input   logic   [4:0]   MEM_rd_addr,

    input   wire            EXE_MEM_fwd_write,
    input   wire            MEM_WB_fwd_write,
    input   wire            EXE_MEM_fwd_FP_write,
    input   wire            MEM_WB_fwd_FP_write, 

    output  reg     [1:0]   FWD_rs1_sel,
    output  reg     [1:0]   FWD_rs2_sel,
    output  reg     [1:0]   FWD_rs1_FP_sel,
    output  reg     [1:0]   FWD_rs2_FP_sel
);
    
//------------------- parameter -------------------//    


//------------------- data -------------------//
    always_comb begin
        if      (EXE_MEM_fwd_write && (EXE_rd_addr == ID_rs1_addr)) begin
            FWD_rs1_sel     =   2'b01;
        end
        else if (MEM_WB_fwd_write  && (MEM_rd_addr == ID_rs1_addr)) begin
            FWD_rs1_sel     =   2'b10;
        end
        else begin
            FWD_rs1_sel     =   2'b00;
        end
    end

    always_comb begin
        if      (EXE_MEM_fwd_write && (EXE_rd_addr == ID_rs2_addr)) begin
            FWD_rs2_sel     =   2'b01;         
        end
        else if (MEM_WB_fwd_write  && (MEM_rd_addr == ID_rs2_addr)) begin
            FWD_rs2_sel     =   2'b10;      
        end
        else begin
            FWD_rs2_sel     =   2'b00;       
        end   
    end
    //---------------------------- FP -----------------------------//
    always_comb begin
        if      (EXE_MEM_fwd_FP_write && (EXE_rd_addr == ID_rs1_addr)) begin
            FWD_rs1_FP_sel     =   2'b01;         
        end
        else if (MEM_WB_fwd_FP_write  && (MEM_rd_addr == ID_rs1_addr)) begin
            FWD_rs1_FP_sel     =   2'b10;      
        end
        else begin
            FWD_rs1_FP_sel     =   2'b00;       
        end   
    end

    always_comb begin
        if      (EXE_MEM_fwd_FP_write && (EXE_rd_addr == ID_rs2_addr)) begin
            FWD_rs2_FP_sel     =   2'b01;         
        end
        else if (MEM_WB_fwd_FP_write  && (MEM_rd_addr == ID_rs2_addr)) begin
            FWD_rs2_FP_sel     =   2'b10;      
        end
        else begin
            FWD_rs2_FP_sel     =   2'b00;       
        end   
    end
endmodule
