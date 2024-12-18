//--------------------------- Info ---------------------------//
    //Module Name :　Waddr
    //Type        :  
//----------------------- Environment -----------------------//
`include "../../include/CPU_define.svh"
`include "../../include/AXI_define.svh"
//------------------------- Module -------------------------//
    module Waddr (
        input           clk, rst,
      //Master 0 --> IM (only read data)
      //Master 1 --> DM 
        input   [`AXI_ID_BITS -1:0]     M1_AWID,    
        input   [`AXI_ADDR_BITS -1:0]   M1_AWAddr,  
        input   [`AXI_LEN_BITS -1:0]    M1_AWLen,   
        input   [`AXI_SIZE_BITS -1:0]   M1_AWSize,  
        input   [1:0]                   M1_AWBurst, 
        input                           M1_AWValid, 
        output  logic                   M1_AWReady,
      //Slave 0 --> IM 
        output  logic [`AXI_IDS_BITS -1:0]    S0_AWID,          
        output  logic [`AXI_ADDR_BITS -1:0]   S0_AWAddr,      
        output  logic [`AXI_LEN_BITS -1:0]    S0_AWLen,        
        output  logic [`AXI_SIZE_BITS -1:0]   S0_AWSize,      
        output  logic [1:0]                   S0_AWBurst,    
        output  logic                         S0_AWValid,    
        input                                 S0_AWReady,     
      //Slave 1 --> DM
        output  logic [`AXI_IDS_BITS -1:0]    S1_AWID,      
        output  logic [`AXI_ADDR_BITS -1:0]   S1_AWAddr,      
        output  logic [`AXI_LEN_BITS -1:0]    S1_AWLen,        
        output  logic [`AXI_SIZE_BITS -1:0]   S1_AWSize,      
        output  logic [1:0]                   S1_AWBurst,   
        output  logic                         S1_AWValid,    
        input   logic                         S1_AWReady,
      //Default Slave
        output  logic [`AXI_IDS_BITS -1:0]    DS_AWID,      
        output  logic [`AXI_ADDR_BITS -1:0]   DS_AWAddr,      
        output  logic [`AXI_LEN_BITS -1:0]    DS_AWLen,        
        output  logic [`AXI_SIZE_BITS -1:0]   DS_AWSize,      
        output  logic [1:0]                   DS_AWBurst,   
        output  logic                         DS_AWValid,    
        input   logic                         DS_AWReady    
    );
  //----------------------- Parameter -----------------------//
    //M0 (not use --> prevent logic)
        logic                           M0_AWReady; 
    //Arbiter Output        
        logic   [`AXI_IDS_BITS -1:0]    O_IDS;  
        logic   [`AXI_ADDR_BITS -1:0]   O_Addr; 
        logic   [`AXI_LEN_BITS -1:0]    O_Len;  
        logic   [`AXI_SIZE_BITS -1:0]   O_Size; 
        logic   [1:0]                   O_Burst;
    //connect Arbiter & Decoder
        logic   Arb_Dec_Valid;
        logic   Dec_Arb_Ready;

  //----------------------- Main Code -----------------------//
    Arbiter Arbiter_inst (
        .clk(clk), .rst(rst),
      //Master 0 --> IM (only read data)
        .I0_ID(`AXI_ID_BITS'd0),
        .I0_Addr(`AXI_ADDR_BITS'd0),
        .I0_Len(`AXI_LEN_BITS'd0),
        .I0_Size(`AXI_SIZE_BITS'd0),
        .I0_Burst(2'd0),
        .I0_Valid(1'd0),
        .IB0_Ready(M0_AWReady),
      //Master 1 --> DM
        .I1_ID    (M1_AWID),   
        .I1_Addr  (M1_AWAddr), 
        .I1_Len   (M1_AWLen),  
        .I1_Size  (M1_AWSize),
        .I1_Burst (M1_AWBurst),    
        .I1_Valid (M1_AWValid),    
        .IB1_Ready(M1_AWReady),   
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
        assign  S0_AWID     =   O_IDS;     
        assign  S0_AWAddr   =   O_Addr;  
        assign  S0_AWLen    =   O_Len;  
        assign  S0_AWSize   =   O_Size; 
        assign  S0_AWBurst  =   O_Burst;
    //Slave 1 --> DM 
        assign  S1_AWID     =   O_IDS;    
        assign  S1_AWAddr   =   O_Addr;
        assign  S1_AWLen    =   O_Len;
        assign  S1_AWSize   =   O_Size;
        assign  S1_AWBurst  =   O_Burst;
    //Default Slave
        assign  DS_AWID     =   O_IDS;    
        assign  DS_AWAddr   =   O_Addr;
        assign  DS_AWLen    =   O_Len;
        assign  DS_AWSize   =   O_Size;
        assign  DS_AWBurst  =   O_Burst;

    Decoder Decoder_inst (
        .clk(clk), .rst(rst),
      //from Arbiter    
        .I_Addr     (O_Addr),
        .I_Valid    (Arb_Dec_Valid),
        .IB_Ready   (Dec_Arb_Ready),
      //Slave 0 --> IM 
        .O0_Valid   (S0_AWValid),
        .OB0_Ready  (S0_AWReady),
      //Slave 1 --> DM
        .O1_Valid   (S1_AWValid),
        .OB1_Ready  (S1_AWReady),     
      //Slave 1 --> DM
        .ODefault_Valid   (DS_AWValid),
        .OBDefault_Ready  (DS_AWReady)   
    );

    endmodule
