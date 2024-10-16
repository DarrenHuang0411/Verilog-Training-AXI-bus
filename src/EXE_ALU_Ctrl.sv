//------------------------- File Info -------------------------//

//------------------------ Environment ------------------------//

//
module EXE_ALU_Ctrl (
    input  logic [`OP_CODE -1:0] ALU_op,
    input  logic [`FUNCTION_3 -1:0] function_3,
    input  logic [`FUNCTION_7 -1:0] function_7,
    output logic [4:0] ALU_ctrl
);

//------------------------- parameter -------------------------//
    //Type
    localparam [2:0]    R_type      =   3'b000,
                        I_type      =   3'b001,
                        ADD_type    =   3'b010,// I, S, U(AUIPC), J_type
                        I_JAL_type  =   3'b011,
                        B_type      =   3'b100,
                        U_LUI_type  =   3'b101,
                        F_type      =   3'b110;                      
    //Function
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

                        ALU_mul     =   5'd10,
                        ALU_mulh    =   5'd11,
                        ALU_mulhsu  =   5'd12,
                        ALU_mulhu   =   5'd13,

                        ALU_jalr    =   5'd14,
                                
                        ALU_beq     =   5'd15,
                        ALU_bne     =   5'd16,
                        ALU_blt     =   5'd17,
                        ALU_bge     =   5'd18,
                        ALU_bltu    =   5'd19,
                        ALU_bgeu    =   5'd20,
                                    
                        ALU_imm     =   5'd21,
    //------------------Float Point -----------------------------// 
                        ALU_FP_add  =   5'd22,
                        ALU_FP_sub  =   5'd23;                        

//------------------------- F_type Setting -------------------------//
    wire [4:0] function_5; //F_type
    assign  function_5  =   function_7[6:2];
//-------------------------  -------------------------//
    always_comb begin
        case (ALU_op)
            R_type    : begin
                unique if (function_7  == 7'b0000001) begin //M extension
                    case (function_3)
                        3'b000: ALU_ctrl    =   ALU_mul;
                        3'b001: ALU_ctrl    =   ALU_mulh;
                        3'b010: ALU_ctrl    =   ALU_mulhsu;
                        3'b011: ALU_ctrl    =   ALU_mulhu;
                        default: ALU_ctrl    =   ALU_mul;
                    endcase              
                end 
                else begin
                    case (function_3)
                        3'b000: ALU_ctrl    =   (function_7[5]) ? ALU_sub : ALU_add;
                        3'b001: ALU_ctrl    =   ALU_sll;
                        3'b010: ALU_ctrl    =   ALU_slt;
                        3'b011: ALU_ctrl    =   ALU_sltu;
                        3'b100: ALU_ctrl    =   ALU_xor;
                        3'b101: ALU_ctrl    =   (function_7[5]) ? ALU_sra : ALU_srl;
                        3'b110: ALU_ctrl    =   ALU_or;
                        3'b111: ALU_ctrl    =   ALU_and;
                    endcase
                end
            end
            I_type    :  begin
                case (function_3)
                    3'b000: ALU_ctrl    =   ALU_add;
                    3'b001: ALU_ctrl    =   ALU_sll;
                    3'b010: ALU_ctrl    =   ALU_slt;
                    3'b011: ALU_ctrl    =   ALU_sltu;
                    3'b100: ALU_ctrl    =   ALU_xor;
                    3'b101: ALU_ctrl    =   (function_7[5]) ? ALU_sra : ALU_srl;
                    3'b110: ALU_ctrl    =   ALU_or;
                    3'b111: ALU_ctrl    =   ALU_and;
                endcase                
            end
            ADD_type  : ALU_ctrl    =   ALU_add;  // I, S, U(AUIPC), J_type
            I_JAL_type: ALU_ctrl    =   ALU_jalr;
            B_type    : begin // zeroflag ==> 1: PC+ imm, 0: imm
                case (function_3)
                    3'b000: ALU_ctrl    =   ALU_beq ;
                    3'b001: ALU_ctrl    =   ALU_bne ;
                    3'b100: ALU_ctrl    =   ALU_blt ;
                    3'b101: ALU_ctrl    =   ALU_bge ;
                    3'b110: ALU_ctrl    =   ALU_bltu;
                    3'b111: ALU_ctrl    =   ALU_bgeu;
                    default: ALU_ctrl    =   ALU_beq;
                endcase    
            end
            U_LUI_type: ALU_ctrl    =   ALU_imm;
            F_type    : begin
                case (function_5)
                    5'b00000:   ALU_ctrl    =   ALU_FP_add;
                    5'b00001:   ALU_ctrl    =   ALU_FP_sub;
                    default:    ALU_ctrl    =   ALU_FP_add;
                endcase
            end
            default:    ALU_ctrl    =   ALU_imm;
        endcase
    end
endmodule







