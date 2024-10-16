//--------------------------- Info ---------------------------//
    //Module Name :　Waddr
    //Type        :  
//----------------------- Environment -----------------------//
    `include ""

//------------------------- Module -------------------------//
    module Raddr (
        input           clk, rst,
      //Master 0 --> IM
        input   [`AXI_ID_BITS -1:0]     M0_ARID,    
        input   [`AXI_ADDR_BITS -1:0]   M0_ARAddr,  
        input   [`AXI_LEN_BITS -1:0]    M0_ARLen,   
        input   [`AXI_SIZE_BITS -1:0]   M0_ARSize,  
        input   [1:0]                   M0_ARBurst, 
        input                           M0_ARValid, 
        output  logic                   M0_ARReady,
      //Master 1 --> DM 
        input   [`AXI_ID_BITS -1:0]     M1_ARID,    
        input   [`AXI_ADDR_BITS -1:0]   M1_ARAddr,  
        input   [`AXI_LEN_BITS -1:0]    M1_ARLen,   
        input   [`AXI_SIZE_BITS -1:0]   M1_ARSize,  
        input   [1:0]                   M1_ARBurst, 
        input                           M1_ARValid, 
        output  logic                   M1_ARReady,
      //Slave 0 --> IM 
        output  logic [`AXI_ID_BITS -1:0]     S0_ARID,          
        output  logic [`AXI_ADDR_BITS -1:0]   S0_ARAddr,      
        output  logic [`AXI_LEN_BITS -1:0]    S0_ARLen,        
        output  logic [`AXI_SIZE_BITS -1:0]   S0_ARSize,      
        output  logic [1:0]                   S0_ARBurst,    
        output  logic                         S0_ARValid,    
        input                                 S0_ARReady,     
      //Slave 1 --> DM
        output  logic [`AXI_ID_BITS -1:0]     S1_ARID,      
        output  logic [`AXI_ADDR_BITS -1:0]   S1_ARAddr,      
        output  logic [`AXI_LEN_BITS -1:0]    S1_ARLen,        
        output  logic [`AXI_SIZE_BITS -1:0]   S1_ARSize,      
        output  logic [1:0]                   S1_ARBurst,   
        output  logic                         S1_ARValid,    
        input   logic                         S1_ARReady
      //Default Slave
    );
  //----------------------- Parameter -----------------------//
  //connect Arbiter & Decoder
    wire    Arib_Dec_Valid;
    wire    Dec_Arib_Ready;

  //----------------------- Main Code -----------------------//
    Arbiter Arbiter_inst (
        .clk(clk), .rst(rst),
      //Master 0
        .I0_ID(),
        .I0_Addr(),
        .I0_Len(),
        .I0_Size(),
        .I0_Burst(),
        .I0_Valid(),
        .IB0_Ready(),
      //Master 1
        .I1_ID(),
        .I1_Addr(),
        .I1_Len(),
        .I1_Size(),
        .I1_Burst(),
        .I1_Valid(),   
        .IB1_Ready(),
      //output --> decoder
        .O_IDS(),
        .O_Addr(),
        .O_Len(),
        .O_Size(),
        .O_Burst(),
        .O_Valid(),
        .OB_Ready()
    );

    Decoder Decoder_inst (
        .clk(clk), .rst(rst),
      //from Arbiter    
        .I_Addr     (),
        .I_Valid    (),
        .IB_Ready   (),
      //Slave 0 --> IM 
        .O0_Valid   (),
        .OB0_Ready  (),
      //Slave 1 --> DM
        .O1_Valid   (),
        .OB1_Ready  (),     
      //Slave 1 --> DM
        .ODefault_Valid   (),
        .OBDefault_Ready  ()   
    );
   

    endmodule
