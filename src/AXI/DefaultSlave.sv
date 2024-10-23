//--------------------------- Info ---------------------------//
    //Module Name :　DefaultSlave
    //Type        :  
//----------------------- Environment -----------------------//

//------------------------- Module -------------------------//
    module DefaultSlave (
        input   ACLK, ARESETn,
      //W channel - Addr      
        input   [`AXI_ID_BITS -1:0]           DS_AWID ,
        input   [`AXI_ADDR_BITS -1:0]         DS_AWAddr ,
        input   [`AXI_LEN_BITS -1:0]          DS_AWLen    ,
        input   [`AXI_SIZE_BITS -1:0]         DS_AWSize   ,
        input   [1:0]                         DS_AWBurst  ,
        input                                 DS_AWValid  ,
        output  logic                         DS_AWReady  ,
      //W channel - data
        input   [`AXI_DATA_BITS -1:0]         DS_WData ,
        input   [`AXI_STRB_BITS -1:0]         DS_WStrb   ,
        input                                 DS_WLast   ,
        input                                 DS_WValid  ,
        output  logic                         DS_WReady  ,
      //W channel - Resp   
        output  logic [`AXI_IDS_BITS -1:0]    DS_BID,
        output  logic [1:0]                   DS_BResp,
        output  logic                         DS_BValid,
        input                                 DS_BReady,             
      //R channel - Addr
        input   [`AXI_IDS_BITS -1:0]          DS_ARID ,
        input   [`AXI_ADDR_BITS -1:0]         DS_ARAddr   ,
        input   [`AXI_LEN_BITS -1:0]          DS_ARLen    ,
        input   [`AXI_SIZE_BITS -1:0]         DS_ARSize   ,
        input   [1:0]                         DS_ARBurst  ,
        input                                 DS_ARValid  ,
        output  logic                         DS_ARReady,  
      //R channel - data
        output  logic [`AXI_IDS_BITS   -1:0]  DS_RID,         
        output  logic [`AXI_DATA_BITS -1:0]   DS_RData,   
        output  logic [1:0]                   DS_RResp,   
        output  logic                         DS_RLast,   
        output  logic                         DS_RValid,  
        input                                 DS_RReady       
    );
  //----------------------- Parameter -----------------------//
    //FSM
      logic     [1:0]   S_cur, S_nxt;
      parameter [1:0]   SADDR   =   2'd0,
                        RDATA   =   2'd1,
                        WDATA   =   2'd2,
                        WRESP   =   2'd3;
    //Data register
      logic   [`AXI_LEN_BITS -1:0]  reg_ARLen;
  //----------------------- Main Code -----------------------//
    //---------------------    FSM    ---------------------//
        always_ff @(posedge clk or posedge rst) begin
            if (rst)   S_cur <=  SADDR;
            else       S_cur <=  S_nxt;
        end
        
        always_comb begin
          case (S_cur)
            SADDR:  begin
              unique if(Raddr_done)
                S_nxt = RDATA;
              else if(Waddr_done)
                S_nxt = WDATA;
              else
                S_nxt = SADDR;
            end
            RDATA:  begin
              if(Rdata_done)
                S_nxt = SADDR;
              else
                S_nxt = RDATA;             
            end
            WDATA:  begin
              if(Wdata_done && DS_WLast)
                S_nxt = WRESP;
              else
                S_nxt = WDATA;                  
            end
            WRESP:  begin
              if(Wresp_done)
                S_nxt = SADDR;
              else
                S_nxt = WRESP;                  
            end
            default:   S_nxt = SADDR;
          endcase
        end

    //--------------------- Done Signal ---------------------//
      assign  Raddr_done  = DS_ARValid & DS_ARReady; 
      assign  Rdata_done  = DS_RValid  & DS_RReady;
      assign  Waddr_done  = DS_AWValid & DS_AWReady;
      assign  Wdata_done  = DS_WValid  & DS_WReady;
      assign  Wresp_done  = DS_BValid  & DS_BReady;        
    //--------------------- W channel ---------------------// 
      //Addr
        assign  DS_AWReady =  (DS_AWValid)  ? 1'b1  : 1'b0;   
      //Data
        assign  DS_WReady = ((S_cur == WDATA) && DS_WValid) ? 1'b1  :   1'b0;
      //Response
        assign  DS_BID    = `AXI_IDS_BITS'd0;
        assign  DS_BResp  = `AXI_RESP_DECERR;
        assign  DS_BValid = (S_cur == WRESP)  ? 1'b1  : 1'b0;
    //--------------------- R channel ---------------------//
      //Addr
        //ARID not need to store
        always_ff @(posedge ACLK or posedge ARESETn) begin
          if (ARESETn)  reg_ARLen <=  `AXI_LEN_BITS'd0;
          else          reg_ARLen <=  (Raddr_done)  ? DS_ARLen  : reg_ARLen;
        end
        assign  DS_ARReady =  (DS_ARValid)  ? 1'b1  : 1'b0;       
      //Data
        always_ff @(posedge ACLK or posedge ARESETn) begin
          if (ARESETn)  DS_RID    <=  `AXI_IDS_BITS'd0;
          else          DS_RID    <=  (Raddr_done)  ? DS_ARID  : DS_RID;          
        end
        assign  DS_RData  = `AXI_DATA_BITS'd0;
        assign  DS_RResp  = `AXI_RESP_DECERR;
        //(reg_arlen use)
        assign  DS_RLast  = 1'b1;
    endmodule