module IF_PC (
    input   wire clk, rst,
//Ctrl
    input   wire PC_write,
//I/O
    input   wire    [`DATA_WIDTH -1:0] I_PC,
    output  reg     [`DATA_WIDTH -1:0] O_PC  
);

always @(posedge clk or posedge rst) 
    begin
        if (rst)
            O_PC <= 32'd0;
        else if(PC_write)
            O_PC <= I_PC;
        else 
            O_PC <= O_PC;
    end

endmodule
