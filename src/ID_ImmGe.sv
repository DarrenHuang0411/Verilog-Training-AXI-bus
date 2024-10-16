module ID_ImmGe (
    input   wire    [2:0]               Imm_type,
    input   wire    [`DATA_WIDTH -1 :0] Instr_in,
    output  reg     [`DATA_WIDTH -1 :0] Imm_out
);

//param    
    localparam  [2:0]   Imm_I       =   3'b000,
                        Imm_S       =   3'b001,
                        Imm_B       =   3'b010,
                        Imm_U       =   3'b011,
                        Imm_J       =   3'b100;

//logic
    always_comb 
    begin
        case (Imm_type) 
            Imm_S:  Imm_out     =   {{20{Instr_in[31]}} , Instr_in[31:25],Instr_in[11:7]};
            Imm_B: begin 
                    Imm_out     =   {{19{Instr_in[31]}}, 
                                    Instr_in[31], 
                                    Instr_in[7], 
                                    Instr_in[30:25], 
                                    Instr_in[11:8], 1'b0};
            end 
            Imm_U:  Imm_out     =   {Instr_in[31:12], 12'b0};
            Imm_J: begin
                    Imm_out     =   {{11{Instr_in[31]}}, 
                                    Instr_in[31], 
                                    Instr_in[19:12], 
                                    Instr_in[20], 
                                    Instr_in[30:21], 1'b0};
            end
            //Imm_I 
            default: Imm_out     =   {{20{Instr_in[31]}} , Instr_in[31:20]}; 
        endcase        
    end

endmodule