//--------------------------- Info ---------------------------//
    //Module Name :　Waddr
    //Type        :  
//----------------------- Environment -----------------------//

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
        input   logic                         S1_ARReady,
      //Default Slave
        output  logic [`AXI_ID_BITS -1:0]     DS_ARID,      
        output  logic [`AXI_ADDR_BITS -1:0]   DS_ARAddr,      
        output  logic [`AXI_LEN_BITS -1:0]    DS_ARLen,        
        output  logic [`AXI_SIZE_BITS -1:0]   DS_ARSize,      
        output  logic [1:0]                   DS_ARBurst,   
        output  logic                         DS_ARValid,    
        input   logic                         DS_ARReady
    );
  //----------------------- Parameter -----------------------//
    //Arbiter Output        
        logic   [`AXI_ID_BITS -1:0]     O_IDS;  
        logic   [`AXI_ADDR_BITS -1:0]   O_Addr; 
        logic   [`AXI_LEN_BITS -1:0]    O_Len;  
        logic   [`AXI_SIZE_BITS -1:0]   O_Size; 
        logic   [1:0]                   O_burst;
    //connect Arbiter & Decoder
        logic                           Arb_Dec_Valid;
        logic                           Dec_Arb_Ready;

  //----------------------- Main Code -----------------------//
    Arbiter Arbiter_inst (
        .clk(clk), .rst(rst),
      //Master 0 --> IM
        .I0_ID      (M0_ARID),
        .I0_Addr    (M0_ARAddr),
        .I0_Len     (M0_ARLen),
        .I0_Size    (M0_ARLen),
        .I0_Burst   (M0_ARBurst),
        .I0_Valid   (M0_ARValid),
        .IB0_Ready  (M0_ARReady),
      //Master 1 --> DM
        .I1_ID      (M1_ARID),
        .I1_Addr    (M1_ARAddr),
        .I1_Len     (M1_ARLen),
        .I1_Size    (M1_ARSize),
        .I1_Burst   (M1_ARBurst),
        .I1_Valid   (M1_ARValid),   
        .IB1_Ready  (M1_ARReady),
      //output info --> to all slave
        .O_IDS  (O_IDS),
        .O_Addr (O_Addr),
        .O_Len  (O_Len),
        .O_Size (O_Size),
        .O_Burst(O_Burst),
      //output handshake
        .O_Valid(Arb_Dec_Valid),
        .OB_Ready(Dec_Arb_Ready)
    );
    //Slave 0 --> IM 
        assign  S0_ARID     =   O_IDS;     
        assign  S0_ARAddr   =   O_Addr;  
        assign  S0_ARLen    =   O_Len;  
        assign  S0_ARSize   =   O_Size; 
        assign  S0_ARBurst  =   O_burst;
    //Slave 1 --> DM 
        assign  S1_ARID     =   O_IDS;    
        assign  S1_ARAddr   =   O_Addr;
        assign  S1_ARLen    =   O_Len;
        assign  S1_ARSize   =   O_Size;
        assign  S1_ARBurst  =   O_Burst;

    Decoder Decoder_inst (
        .clk(clk), .rst(rst),
      //from Arbiter    
        .I_Addr     (O_Addr),
        .I_Valid    (Arb_Dec_Valid),
        .IB_Ready   (Dec_Arb_Ready),
      //Slave 0 --> IM 
        .O0_Valid   (S0_ARValid),
        .OB0_Ready  (S0_ARReady),
      //Slave 1 --> DM
        .O1_Valid   (S1_ARValid),
        .OB1_Ready  (S1_ARReady),     
      //Default Slave 
        .ODefault_Valid   (DS_ARValid),
        .OBDefault_Ready  (DS_ARReady)   
    );
   
    endmodule
