//------------------------- File Info -------------------------//

//------------------------ Environment ------------------------//

//

module EXE_ALU (
//Ctrl
    input        [4:0] ALU_ctrl,
//I/O
    input   wire [`DATA_WIDTH -1:0] rs1,
    input   wire [`DATA_WIDTH -1:0] rs2,
    output  reg  [`DATA_WIDTH -1:0] ALU_out,
    //output  
    output  reg  zeroflag
);
//------------------------- parameter -------------------------//    
    localparam  [4:0]   ALU_add =   5'd0,
                        ALU_sub =   5'd1,
                        ALU_sll =   5'd2,
                        ALU_slt =   5'd3,
                        ALU_sltu=   5'd4,
                        ALU_xor =   5'd5,
                        ALU_srl =   5'd6,
                        ALU_sra =   5'd7,
                        ALU_or  =   5'd8,
                        ALU_and =   5'd9,
    //---------------------- mult -----------------------------// 
                        ALU_mul     =   5'd10,
                        ALU_mulh    =   5'd11,
                        ALU_mulhsu  =   5'd12,
                        ALU_mulhu   =   5'd13,

                        ALU_jalr    =   5'd14, 
    //----------------------- beq -----------------------------// 
                        ALU_beq     =   5'd15,
                        ALU_bne     =   5'd16,
                        ALU_blt     =   5'd17,
                        ALU_bge     =   5'd18,
                        ALU_bltu    =   5'd19,       
                        ALU_bgeu    =   5'd20,

                        ALU_imm     =   5'd21;

    wire signed [`DATA_WIDTH -1:0] s_rs1;
    wire signed [`DATA_WIDTH -1:0] s_rs2;
    wire        [`DATA_WIDTH -1:0] R_add;
    wire signed [`MULT_DATA_WIDTH -1:0] Mult_rd_ss;
    wire signed [`MULT_DATA_WIDTH -1:0] Mult_rd_su;
    wire        [`MULT_DATA_WIDTH -1:0] Mult_rd_uu;

    assign R_add        =   rs1 +   rs2;
    assign s_rs1        =   rs1; //deal with the previous stage
    assign s_rs2        =   rs2;
    assign Mult_rd_ss   =   s_rs1 * s_rs2;
    assign Mult_rd_su   =   s_rs1 * $signed({1'b0, rs2}); // mult_s*u
    assign Mult_rd_uu   =   rs1 * rs2;

//------------------------- Basic -------------------------//
    always_comb begin
        case (ALU_ctrl)
            ALU_add:    ALU_out =   rs1 +   rs2;
            ALU_sub:    ALU_out =   rs1 -   rs2;
            ALU_sll:    ALU_out =   rs1 <<  rs2[4:0];
            ALU_slt:    ALU_out =   (s_rs1 < s_rs2) ? 1 : 0;
            ALU_sltu:   ALU_out =   (rs1 < rs2) ? 32'b1 : 32'b0;
            ALU_xor:    ALU_out =   rs1 ^   rs2;
            ALU_srl:    ALU_out =   rs1 >>  rs2[4:0];
            ALU_sra:    ALU_out =   s_rs1 >>>  rs2[4:0];
            ALU_or :    ALU_out =   rs1 |   rs2;
            ALU_and:    ALU_out =   rs1 &   rs2; 

            ALU_mul   : ALU_out =   Mult_rd_ss[31:0];
            ALU_mulh  : ALU_out =   Mult_rd_ss[63:32];
            ALU_mulhsu: ALU_out =   Mult_rd_su[63:32];
            ALU_mulhu : ALU_out =   Mult_rd_uu[63:32];

            ALU_jalr:   ALU_out =   {R_add[31:1], 1'b0}; //why
            ALU_imm:    ALU_out =   rs2;
            default:    ALU_out =   32'b0;
        endcase  
    end

//----------------------- Basic_beq -----------------------//
    always_comb begin
        case (ALU_ctrl)
            ALU_beq :   zeroflag    =   (rs1 == rs2) ? 1'b1: 1'b0;
            ALU_bne :   zeroflag    =   (rs1 != rs2) ? 1'b1: 1'b0;
            ALU_blt :   zeroflag    =   (s_rs1 <  s_rs2) ? 1'b1: 1'b0;
            ALU_bge :   zeroflag    =   (s_rs1 >= s_rs2) ? 1'b1: 1'b0;
            ALU_bltu:   zeroflag    =   (rs1 <  rs2) ? 1'b1: 1'b0;
            ALU_bgeu:   zeroflag    =   (rs1 >= rs2) ? 1'b1: 1'b0;  
            default:    zeroflag    =   1'b0;
        endcase
    end

endmodule
