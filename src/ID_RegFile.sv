
module ID_RegFile (
    input   wire    clk, rst,
//Ctrl
    input   wire                        reg_write,
//I/O
    input   wire    [4:0]               rs1_addr,
    input   wire    [4:0]               rs2_addr,
    
    input   wire    [4:0]               rd_addr,
    input   wire    [`DATA_WIDTH -1 :0] rd_data,
    output  wire    [`DATA_WIDTH -1 :0] rs1_data,
    output  wire    [`DATA_WIDTH -1 :0] rs2_data
);
    
//int
    integer i;
//Register Size
    reg [31:0] x_reg[31:0];

//rs1_data rs2_data
    assign  rs1_data    =   x_reg[rs1_addr];
    assign  rs2_data    =   x_reg[rs2_addr];

//R_F 
always_ff @(posedge clk or posedge rst)
    begin
        if(rst) begin
            for ( i = 0; i < 32; i = i +1) begin
                x_reg[i]  <=  32'b0;
            end
        end
        else if (reg_write && rd_addr != 5'b0)
            x_reg[rd_addr]  <=  rd_data;
    end

endmodule
