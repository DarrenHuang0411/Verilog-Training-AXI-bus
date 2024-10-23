//--------------------------- Info ---------------------------//
    //Module Name :　Slave_wrapper
    //Type        :  
//----------------------- Environment -----------------------//
    `include ""

//------------------------- Module -------------------------//
    module Slave_wrapper (
        input   ACLK, ARESETn,
      //AXI Waddr
        input  [`AXI_IDS_BITS -1:0]    S_AWID,    
        input  [`AXI_ADDR_BITS -1:0]   S_AWAddr,  
        input  [`AXI_LEN_BITS -1:0]    S_AWLen,   
        input  [`AXI_SIZE_BITS -1:0]   S_AWSize,  
        input  [1:0]                   S_AWBurst, 
        input                          S_AWValid, 
        output  logic                  S_AWReady,
      //AXI Wdata     
        input  [`AXI_DATA_BITS -1:0]   S_WData,   
        input  [`AXI_STRB_BITS -1:0]   S_WStrb,   
        input                          S_WLast,   
        input                          S_WValid,  
        output  logic                  S_WReady,
      //AXI Wresp
        output  logic [`AXI_IDS_BITS -1:0]  S_BID,
        output  logic [1:0]                 S_BResp,
        output  logic                       S_BValid,
        input                               S_BReady,           
      //AXI Raddr
        input  [`AXI_IDS_BITS -1:0]    S_ARID,    
        input  [`AXI_ADDR_BITS -1:0]   S_ARAddr,  
        input  [`AXI_LEN_BITS -1:0]    S_ARLen,   
        input  [`AXI_SIZE_BITS -1:0]   S_ARSize,  
        input  [1:0]                   S_ARBurst, 
        input                          S_ARValid, 
        output  logic                  S_ARReady,
      //AXI Rdata   
        output  logic [`AXI_IDS_BITS   -1:0]  S_RID,         
        output  logic [`AXI_DATA_BITS -1:0]   S_RData,   
        output  logic [1:0]                   S_RResp,   
        output  logic                         S_RLast,   
        output  logic                         S_RValid,  
        input                                 S_RReady,
      //To Memory  
        output  logic [`DATA_WIDTH    -1:0]   BWEB,
        output  logic [`DATA_WIDTH    -1:0]   DI,
        input         [`DATA_WIDTH    -1:0]   DO,

    );

  //----------------------- Parameter -----------------------//
    //FSM
      logic     [1:0]   S_cur, S_nxt;
      parameter [1:0]   SADDR     = 2'd0,
                        RDATA     = 2'd1,
                        WDATA     = 2'd2,
                        WRESP     = 2'd3;
    //CNT
      logic   [`AXI_LEN_BITS -1:0]  cnt;
    //Data register
      logic   [`AXI_IDS_BITS -1:0]  reg_ARID , reg_AWID;
      logic   [`MEM_ADDR_LEN -1:0]  reg_ARAddr, reg_AWAddr; 
      logic   [`AXI_LEN_BITS -1:0]  reg_ARLen, reg_AWLen;
      logic   [`AXI_DATA_BITS-1:0]
    //Last Signal
      logic   W_last, R_last;
    //Done Signal 
      logic   Raddr_done, Rdata_done, Waddr_done, Wdata_done, Wresp_done;
  //----------------------- Main Code -----------------------//
    //------------------------- FSM -------------------------//
      always_ff @(posedge clk or posedge ARSTN) begin
          if(!ARSTN)  S_cur <=  SADDR;
          else        S_cur <=  S_nxt;
      end

      always_comb begin
        case (S_cur)
          SADDR:  begin
            // unique if (Waddr_done && Wdata_done) begin
            //   S_nxt = WRESP;
            // end 
            // else 
            unique if (Waddr_done) begin
              S_nxt = WDATA;
            end
            else if (Raddr_done) begin
              S_nxt = RDATA; 
            end
            else begin
              S_nxt = SADDR;            
            end
          end          
          //S_nxt  = (Raddr_done) ? RDATA   : RADDR; 
          RDATA:  S_nxt  = (R_last)     ? SADDR   : RDATA; 
          WDATA:  S_nxt  = (W_last)     ? WRESP   : WDATA; 
          WRESP:  S_nxt  = (Wresp_done) ? SADDR   : WRESP; 
          default:  S_nxt  = INITIAL;
        endcase
      end 
    //--------------------- Last Signal ---------------------//  
      assign  W_last  = S_WLast & Wdata_done;
      assign  R_last  = S_RLast & Rdata_done;  
    //--------------------- Done Signal ---------------------//
      assign  Raddr_done  = M_ARValid & M_ARReady; 
      assign  Rdata_done  = M_RValid  & M_RReady;
      assign  Waddr_done  = M_AWValid & M_AWReady;
      assign  Wdata_done  = M_WValid  & M_WReady;
      assign  Wresp_done  = M_BValid  & M_BReady;
    //------------------------- CNT -------------------------//
        always_ff @(posedge clk or posedge rst) begin
          if (rst) begin
            cnt   <=  `AXI_LEN_BITS'd0;
          end 
          else begin
            if(R_last || W_last)  begin
              cnt   <=  `AXI_LEN_BITS'd0;            
            end
            else if (Rdata_done || Wdata_done) begin
              cnt   <=  cnt + `AXI_LEN_BITS'd1;            
            end
            else  begin
              cnt   <=  cnt;
            end
          end
        end
    //----------------- W-channel (priority) -----------------//
      //Addr
        always_ff @(posedge clk or posedge rst) begin
          if(rst)   reg_AWID     <=  `MEM_ADDR_LEN'd0;
          else      reg_AWID     <=  (Waddr_done)  ? S_AWID : reg_AWID;
        end   

        always_ff @(posedge clk or posedge rst) begin
          if(rst)   reg_AWAddr   <=  `MEM_ADDR_LEN'd0;
          else      reg_AWAddr   <=  (Waddr_done)  ? S_AWAddr[15:2] : reg_AWAddr;
        end   
        
        always_ff @(posedge clk or posedge rst) begin
          if(rst)   reg_AWLen   <=  `AXI_LEN_BITS'd0;
          else      reg_AWLen   <=  (Waddr_done)  ? S_AWLen : reg_AWLen;
        end
        //awsize
        //awburst
        always_comb begin
          case (S_cur)
            SADDR:      S_AWReady   =   1'b1;
            WRESP:      S_AWReady   =   Wdata_done;  
            default:    S_AWReady   =   1'b0;
          endcase
        end
      //Data
        //Wdata(MEM)
        //Wstrb(MEM)
        //WLast(Last Signal)
        assign  S_WReady  = (S_cur == WDATA)  ? 1'b1  : 1'b0;       
      //Resp
        assign  S_BID     = reg_AWID; 
        assign  S_BResp   = `AXI_RESP_OKAY;
        assign  S_BValid  = (S_cur == WRESP)  ? 1'b1  : 1'b0;  
    //---------------------- R-channel ----------------------// 
      //Addr
        always_ff @(posedge clk or posedge rst) begin
          if(rst)   reg_ARID   <=  `AXI_LEN_BITS'd0;
          else      reg_ARID   <=  (Raddr_done)  ? S_ARID : reg_ARID;
        end

        always_ff @(posedge clk or posedge rst) begin
          if(rst)   reg_ARAddr   <=  `MEM_ADDR_LEN'd0;
          else      reg_ARAddr   <=  (Raddr_done)  ? S_ARAddr[15:2] : reg_ARAddr;
        end
          
        always_ff @(posedge clk or posedge rst) begin
          if(rst)   reg_ARLen   <=  `AXI_LEN_BITS'd0;
          else      reg_ARLen   <=  (Raddr_done)  ? S_ARLen : reg_ARLen;
        end
        //Rsize
        //Rburst
        always_comb begin
          case (S_cur)
            SADDR:      S_ARReady   =   ~S_AWValid;
            WRESP:      S_ARReady   =   1'b0;  
            default:    S_ARReady   =   1'b0;
          endcase
        end
      //data
        assign  S_RID     = reg_ARID;
        //Data problem (need t solve)
        assign  S_RData   = DO;

        assign  S_RResp   = `AXI_RESP_OKAY;
        assign  S_RLast   = (cnt == reg_ARLen)  ? 1'b1  : 1'b0;    
        assign  S_RValid  = (S_cur == RDATA)    ? 1'b1  : 1'b0;   
    //----------------------- Memory -----------------------//   
        always_comb begin
          if (S_cur == SADDR) begin
              CEB   =   S_AWValid | S_ARValid;            
          end 
          else begin
              CEB   =   1'b0;  
          end
        end
        //WEB

        assign  BWEB      = {S_WStrb,S_WStrb,S_WStrb,S_WStrb};
          
        always_comb begin
          case (S_cur)
            SADDR:  A = (Waddr_done)  ? S_AWAddr[15:2]  :  S_ARAddr[15:2];
            RDATA:  A = reg_ARAddr;
            WDATA:  A = reg_AWAddr;
            default: 
          endcase
        end
        assign  DI        = S_WData;

    endmodule
