module MEM_Stage (
    input   wire                        clk,  
    input   wire                        rst, 
    //------------------- Ctrl sig reg -----------------------//
    input   logic [1:0]                 MEM_rd_sel,
    input   logic                       MEM_Din_sel,
    input   logic                       MEM_DMread_sel, 
    input   logic                       MEM_DMwrite_sel,
    input   logic                       EXE_MEM_WB_data_sel,
    input   logic                       EXE_MEM_reg_file_write,
    input   logic                       EXE_MEM_reg_file_FP_write,
    output  logic                       MEM_WB_data_sel,
    output  logic                       MEM_WB_reg_file_write,
    output  logic                       MEM_WB_reg_file_FP_write,
    //----------------------- MEM_I/O -----------------------//
    input   wire  [`DATA_WIDTH -1:0]    MEM_pc,
    input   wire  [`DATA_WIDTH -1:0]    MEM_ALU,
    input   wire  [`DATA_WIDTH -1:0]    MEM_ALU_FP,
    input   wire  [`DATA_WIDTH -1:0]    MEM_csr,
    input   wire  [4:0]                 EXE_MEM_rd_addr,
    output  wire  [4:0]                 MEM_WB_rd_addr,
    //------------------------ Data ------------------------//  
    input   logic [`FUNCTION_3 -1:0]    EXE_funct3,
    input   logic [`DATA_WIDTH -1:0]    EXE_rs2_data,
    input   logic [`DATA_WIDTH -1:0]    EXE_rs2_FP_data,      
    output  logic  [`DATA_WIDTH -1:0]   MEM_rd_data,

    //------------------------- DM -------------------------//    
    output  logic                       chip_select,
    output  logic                       SRAM_web,
    //------------------------- SW -------------------------// 
    output  logic [`DATA_WIDTH -1:0]    w_eb,
    output  logic [`DATA_WIDTH -1:0]    DM_in,

    //------------------------- LW -------------------------//     
    input   logic [`DATA_WIDTH -1:0]    DM_out,
    output  logic [`DATA_WIDTH -1:0]    DM_out_2_reg
);
    
    //wire [:] MEM_rd_src;

//----------------------- rd_sel -----------------------//
    assign  chip_select     = ~(MEM_DMread_sel | MEM_DMwrite_sel);
    assign  MEM_WB_rd_addr  =  EXE_MEM_rd_addr;
    assign  MEM_WB_data_sel = EXE_MEM_WB_data_sel;
    assign  MEM_WB_reg_file_write = EXE_MEM_reg_file_write;
    assign  MEM_WB_reg_file_FP_write = EXE_MEM_reg_file_FP_write;

    always_comb begin
        case (MEM_rd_sel)
            2'b00:  MEM_rd_data =   MEM_ALU;
            2'b01:  MEM_rd_data =   MEM_pc;
            2'b10:  MEM_rd_data =   MEM_ALU_FP;
            2'b11:  MEM_rd_data =   MEM_csr;
            default: MEM_rd_data    =   MEM_ALU;
        endcase
    end
//----------------------- R/W for WEB -----------------------//
    always_comb begin
        SRAM_web    =   1'b0;           
        if (MEM_DMread_sel)
            SRAM_web    =   1'b1;
        else if (MEM_DMwrite_sel)
            SRAM_web    =   1'b0;
    end

//------------------------ SW -------------------------//
    //---------------------- En -----------------------//
    always_comb begin
        //active low
        w_eb    =   32'hffff_ffff;//4'b1111;
        if(MEM_DMwrite_sel) begin
            case (EXE_funct3)
                3'b000:   w_eb[{MEM_ALU[1:0],3'b0} +: 8]  =    8'b0;    //SB 
                3'b001:   w_eb[{MEM_ALU[1]  ,4'b0} +:16]  =   16'b0;    //SH
                3'b010:   w_eb                            =   32'b0; //SW
                default:  w_eb                            =   32'b0;
            endcase
        end
    end
    //--------------------- Data ----------------------//
    always_comb begin
        //--------------- DM_in reset -----------------//
        DM_in   =   32'd0;
        case (EXE_funct3)
            3'b000:   DM_in[{MEM_ALU[1:0],3'b0} +: 8]     =   EXE_rs2_data[7:0];    //SB (0~3)
            3'b001:   DM_in[{MEM_ALU[1],4'b0} +: 16]      =   EXE_rs2_data[15:0];   //SH
            3'b010:   DM_in     =   (MEM_Din_sel) ? EXE_rs2_FP_data : EXE_rs2_data;         //SW
            default:  DM_in                                 =   32'd0;
        endcase
    end

//------------------------ LW -------------------------//
    //---------------------- En -----------------------//
    //directly 
    //delay 1 cycle (add)
    //--------------------- data ----------------------//
    always_comb begin
        DM_out_2_reg      =   32'd0;
        //--------------- DM_out reset -----------------//
        case (EXE_funct3)
            3'b000:   DM_out_2_reg      =   {{24{DM_out[7]}} , DM_out[7:0]};    //LB(signed)
            3'b001:   DM_out_2_reg      =   {{16{DM_out[7]}} , DM_out[15:0]};   //LH
            3'b010:   DM_out_2_reg      =   DM_out;   //LW
            3'b100:   DM_out_2_reg      =   {24'd0 , DM_out[7:0]};
            3'b101:   DM_out_2_reg      =   {16'd0 , DM_out[15:0]};
            default:  DM_out_2_reg      =   32'd0;
        endcase
    end

endmodule
