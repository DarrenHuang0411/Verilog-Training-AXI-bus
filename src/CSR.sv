

module CSR (
  input  clk, rst,
  input           [`OP_CODE -1:0]     CSR_op,
  input           [`FUNCTION_3 -1:0]  function_3,
  input           [`DATA_WIDTH -1:0]  rs1,
  input           [`DATA_WIDTH -1:0]  imm_csr,

  input                               HAZ_Stall,
  input                               lw_use,
  input           [1:0]               branch,
  output logic    [`DATA_WIDTH -1:0]  csr_rd_data
);

  localparam [`OP_CODE -1:0]  CSR_type  = 3'b111;

  localparam [2:0]            CSRRW     = 3'b001,
                              CSRRS     = 3'b010,
                              CSRRC     = 3'b011,
                              CSRRWI    = 3'b101,
                              CSRRSI    = 3'b110,
                              CSRRCI    = 3'b111;

  reg   [`DATA_WIDTH -1 :0]    csr_status_reg;
  reg   [`CSR_REG_WIDTH -1 :0] count_instret;
  reg   [`CSR_REG_WIDTH -1 :0] count_cycle;

  logic [1:0] count_adjust;
//----------------------- count instr -----------------------// 
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            count_cycle     <=  `CSR_REG_WIDTH'd0;
        end
        else begin
            count_cycle     <=  count_cycle + 1;
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            count_adjust     <=  2'd0;
        end
        else begin
          if (count_adjust == 2'd2 || HAZ_Stall) begin
            count_adjust     <=   count_adjust;
          end 
          else begin
            count_adjust     <=   count_adjust + 1;
          end
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            count_instret   <=  `CSR_REG_WIDTH'd0;
        end
        else begin
            if(count_adjust >= 2'd2 && !HAZ_Stall) begin
              if(lw_use) 
                count_instret   <=  count_instret;
              else if(|branch)
                count_instret   <=  count_instret - 1;
              else
                count_instret   <=  count_instret + 1;  
            end
        end
    end
//---------------------------- rd ----------------------------//
    always_comb begin
        if(|rs1)
          csr_rd_data = imm_csr;
        else begin
          case (imm_csr[11:0])
            12'hc82:  csr_rd_data  =  count_instret[63:32];
            12'hc02:  csr_rd_data  =  count_instret[31:0];
            12'hc80:  csr_rd_data  =  count_cycle[63:32];
            12'hc00:  csr_rd_data  =  count_cycle[31:0];
            default:  csr_rd_data  =  32'd0;
          endcase
        end
    end

    always_ff @( posedge clk or posedge rst) begin
        if(rst)
          csr_status_reg  <=  32'd0;
        else if (|rs1) begin
          case (function_3)
            CSRRW  :    csr_status_reg  <=  rs1;
            CSRRS  :    csr_status_reg  <=  csr_status_reg | rs1;
            CSRRC  :    csr_status_reg  <=  csr_status_reg & (~rs1);
            CSRRWI :    csr_status_reg  <=  rs1;
            CSRRSI :    csr_status_reg  <=  csr_status_reg | rs1;
            CSRRCI :    csr_status_reg  <=  csr_status_reg | (~rs1);
            default:    csr_status_reg  <=  csr_status_reg; 
          endcase                
        end
    end

endmodule