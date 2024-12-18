//----------------------- Environment -----------------------//


//------------------------- Module -------------------------//
    module Master_wrapper_PH_DM
    // #(
    //parameter   C_ID  = 4'b0000,
    //  parameter   C_LEN = `AXI_LEN_BITS'd15
    //) 
    (
        input       ACLK, ARESETn,
      //CPU Memory Port 
        input           Memory_WEB, 
        input           Memory_DM_read_sel, 
        input           Memory_DM_write_sel, 
        input           [`DATA_WIDTH -1:0]      Memory_BWEB, // transfer to strb
        input           [`AXI_ADDR_BITS -1:0]   Memory_Addr,
        input           [`AXI_DATA_BITS -1:0]   Memory_Din,
        output  logic   [`DATA_WIDTH -1:0]      Memory_Dout,
        output  logic                           Trans_Stall,
      //AXI Waddr
        output  logic   [`AXI_ID_BITS -1:0]     M_AWID,    
        output  logic   [`AXI_ADDR_BITS -1:0]   M_AWAddr,  
        output  logic   [`AXI_LEN_BITS -1:0]    M_AWLen,   
        output  logic   [`AXI_SIZE_BITS -1:0]   M_AWSize,  
        output  logic   [1:0]                   M_AWBurst, 
        output  logic                           M_AWValid, 
        input                                   M_AWReady,
      //AXI Wdata     
        output  logic   [`AXI_DATA_BITS -1:0]   M_WData,   
        output  logic   [`AXI_STRB_BITS -1:0]   M_WStrb,   
        output  logic                           M_WLast,   
        output  logic                           M_WValid,  
        input                                   M_WReady,
      //AXI Wresp
        input         [`AXI_ID_BITS -1:0]      M_BID,
        input         [1:0]                     M_BResp,
        input                                   M_BValid,
        output  logic                           M_BReady,                   
      //AXI Raddr
        output  logic   [`AXI_ID_BITS -1:0]     M_ARID,    
        output  logic   [`AXI_ADDR_BITS -1:0]   M_ARAddr,  
        output  logic   [`AXI_LEN_BITS -1:0]    M_ARLen,   
        output  logic   [`AXI_SIZE_BITS -1:0]   M_ARSize,  
        output  logic   [1:0]                   M_ARBurst, 
        output  logic                           M_ARValid, 
        input                                   M_ARReady,
      //AXI Rdata   
        input           [`AXI_ID_BITS   -1:0]   M_RID,         
        input           [`AXI_DATA_BITS -1:0]   M_RData,   
        input           [1:0]                   M_RResp,   
        input                                   M_RLast,   
        input                                   M_RValid,  
        output  logic                           M_RReady,
      //helping signal
        input                                   M_RLast_h1,
        input                                   M_RValid_h1,        
        input                                   M_RReady_h1,
        input                                   Rvalid_both,
        input                                   R_W_both                 
    );

  //----------------------- Parameter -----------------------//
    //FSM
    logic   [2:0] S_cur, S_nxt;
    parameter   INITIAL   = 3'd0,
                RADDR     = 3'd1,
                RDATA     = 3'd2,
                WADDR     = 3'd3,
                WDATA     = 3'd4,
                WRESP     = 3'd5;
    //Data register
      logic   [`AXI_DATA_BITS -1:0]  reg_RData;
    //CNT
      logic   [`AXI_LEN_BITS  -1:0]  cnt;
    //Start Signal
      logic   Start_burst_write;      
      logic   Start_burst_read;      
    //LAST Signal 
      logic   W_last, R_last, R_last_h1;     
    //Done Signal 
      logic   Raddr_done, Rdata_done, Waddr_done, Wdata_done, Wresp_done;

    //both valid
      logic   reg_Rvalid_both;
      logic   reg_R_W_both;

      always_ff @(posedge ACLK) begin
          if(!ARESETn)
            reg_Rvalid_both <= 1'b0;
          else begin
            if(reg_Rvalid_both)
              reg_Rvalid_both <=  (M_RLast_h1) ? 1'b0 : 1'b1;
            else
              reg_Rvalid_both <= Rvalid_both;
          end
      end

      always_ff @(posedge ACLK) begin
          if(!ARESETn)
            reg_R_W_both <= 1'b0;
          else begin
            if(reg_R_W_both)
              reg_R_W_both <=  (M_RLast_h1) ? 1'b0 : 1'b1;
            else
              reg_R_W_both <= R_W_both;
          end
      end
  //----------------------- Main Code -----------------------//    
    //------------------------- FSM -------------------------//
      always_ff @(posedge ACLK) begin
          if(!ARESETn)
              S_cur   = INITIAL;
          else
              S_cur   = S_nxt;
      end

      always_comb begin
        case (S_cur)
          INITIAL:  begin
            if(Start_burst_read) begin
              S_nxt   = RADDR;
            end
            else if  (Start_burst_write) begin
              S_nxt   = WADDR;           
            end
            else begin
              S_nxt   = INITIAL;
            end
          end
          RADDR:  S_nxt  = (Raddr_done) ? RDATA   : RADDR; 
          RDATA:  begin
            if(reg_Rvalid_both)  
              S_nxt  = (M_RLast_h1) ? INITIAL : RDATA; 
            else
              S_nxt  = (R_last) ? INITIAL : RDATA;
          end
          WADDR:  S_nxt  = (Waddr_done) ? WDATA   : WADDR; 
          WDATA: 
              S_nxt  = (W_last)     ? WRESP   : WDATA;                

          WRESP:  begin
            if(reg_R_W_both)  
              S_nxt  = (M_RLast_h1) ? INITIAL : WRESP; 
            else 
              S_nxt  = (Wresp_done) ? INITIAL : WRESP;
          end 
          default:  S_nxt  = INITIAL;
        endcase
      end
    //--------------------- Start Burst ---------------------//
      always_comb begin
          case (S_cur)
            INITIAL:  begin
              Start_burst_write   =  (~Memory_WEB) & Memory_DM_write_sel;
              Start_burst_read    =   Memory_WEB & Memory_DM_read_sel;                
            end
            RADDR:  begin
              Start_burst_write   =  1'b0;
              Start_burst_read    =  1'b1;                
            end
            WADDR:  begin
              Start_burst_write   =  1'b1;
              Start_burst_read    =  1'b0;                
            end
            default: begin
              Start_burst_write   =  1'b0;
              Start_burst_read    =  1'b0;                 
            end
          endcase
      end
    //--------------------- Last Signal ---------------------//  
      assign  W_last  = M_WLast & Wdata_done;
      always_comb begin
        if(reg_Rvalid_both || reg_R_W_both)
          R_last  = M_RLast_h1 & Rdata_done;
        else
          R_last  = M_RLast & Rdata_done;
      end
      //assign  R_last  = M_RLast & Rdata_done;  
      logic reg_last;
      // assign  R_last_h1 = M_RLast_h1 & M_RValid_h1 & M_RReady_h1;

      // always_ff @(posedge ACLK or posedge ARESETn) begin
      //     if(!ARESETn)   R_last   <=  1'd0;
      //     else           R_last   <=  reg_last;
      // end


      // always_ff @(posedge ACLK or posedge ARESETn ) begin
      //   if (!ARESETn) begin
      //     reg_last  <=  1'b0;
      //   end else begin
      //     if(R_last_h1)
      //       reg_last  <=  1'b0;
      //     else
      //       reg_last  <=  R_last;
      //   end
      // end
    //--------------------- Done Signal ---------------------//
      assign  Raddr_done  = M_ARValid & M_ARReady; 
      assign  Rdata_done  = M_RValid  & M_RReady;
      assign  Waddr_done  = M_AWValid & M_AWReady;
      assign  Wdata_done  = M_WValid  & M_WReady;
      assign  Wresp_done  = M_BValid & M_BReady;
    //------------------------- CNT -------------------------//
      always_ff @(posedge ACLK) begin
        if (!ARESETn) begin
          cnt   <=  `AXI_LEN_BITS'd0;
        end 
        else begin
          if(W_last)  begin
            cnt   <=  `AXI_LEN_BITS'd0;            
          end
          else if (Wdata_done) begin
            cnt   <=  cnt + `AXI_LEN_BITS'd1;            
          end
          else  begin
            cnt   <=  cnt;
          end
        end
      end
    //---------------------- W-channel ----------------------//
      //Addr
      //assign  M_AWID      = C_ID;
      assign  M_AWID      = 4'b0010;
      //assign  M_AWLen     = C_LEN;
      assign  M_AWLen     = 0;
      assign  M_AWSize    = `AXI_SIZE_BITS'd0;
      assign  M_AWBurst   = `AXI_BURST_INC; 
      assign  M_AWAddr    = Memory_Addr;
      
      always_ff @(posedge ACLK) begin
        if (!ARESETn)
          M_AWValid   <=  1'b0;
        else begin
          case (S_cur)
            INITIAL:  M_AWValid  <= (!Memory_WEB && Start_burst_write) ? 1'b1 : 1'b0;
            WADDR:    M_AWValid  <= (Waddr_done) ? 1'b0 : 1'b1;
            default:  M_AWValid  <=  1'b0;
          endcase          
        end
      end  
      //Data
      assign  M_WStrb   =   {|Memory_BWEB[31:24], |Memory_BWEB[23:16], |Memory_BWEB[15:8], |Memory_BWEB[7:0]};
      assign  M_WLast   =   ((S_cur == WDATA) && (cnt == M_AWLen))  ? 1'b1  : 1'b0; 
      assign  M_WData   =   Memory_Din;
      assign  M_WValid  =   (S_cur == WDATA)  ? 1'b1 : 1'b0;
      //Response
      assign  M_BReady  =   (S_cur == WRESP || S_cur == WDATA)? 1'b1 : 1'b0;
    //---------------------- R-channel ----------------------//
      //Addr
      //assign  M_ARID      = C_ID;
      assign  M_ARID      = 4'b0010;
      //assign  M_ARLen     = C_LEN;
      assign  M_ARLen     = 0;
      assign  M_ARSize    = `AXI_SIZE_BITS'd0;
      assign  M_ARBurst   = `AXI_BURST_INC; 
      assign  M_ARAddr    = Memory_Addr; 

      always_ff @(posedge ACLK) begin
        if (!ARESETn)
          M_ARValid   <=  1'b0;
        else begin
          case (S_cur)
            INITIAL:  M_ARValid  <= (Memory_WEB && Start_burst_read) ? 1'b1 : 1'b0;
            RADDR:    M_ARValid  <= (Raddr_done) ? 1'b0 : 1'b1;
            default:  M_ARValid  <=  1'b0;
          endcase          
        end
      end  
      //Data
      logic [31:0] reg_RData_test;
      always_ff @(posedge ACLK) begin
        if (!ARESETn)
          reg_RData_test   <=  `DATA_WIDTH'b0;
        else begin
          reg_RData_test   <=  (reg_Rvalid_both && Rdata_done)  ? M_RData : reg_RData_test;
        end        
      end
      assign  M_RReady    = (S_cur == RDATA)  ? 1'b1 : 1'b0; 
      // //assign  reg_RData   =  (Rdata_done)  ? M_RData : reg_RData;
      // always_comb begin
      //   if(reg_Rvalid_both)
      //     reg_RData   =  (M_RLast_h1)  ? M_RData : reg_RData;
      //   else
      //     reg_RData   =  (Rdata_done)  ? M_RData : reg_RData;
      // end
    //------------------------- CPU -------------------------//
      //assign  Memory_Dout   = (reg_Rvalid_both) ? reg_RData_test : reg_RData;
      assign  Memory_Dout   =    reg_RData_test;
        



      // always_ff @(posedge ACLK) begin
      //   if(!ARESETn)  begin
      //     Trans_Stall <=  1'b0;
      //   end   
      //   else begin
      always_comb begin
        case (S_cur)
          INITIAL:  begin
            if(Start_burst_write || Start_burst_read)
              Trans_Stall =   ((~Memory_WEB) & Memory_DM_write_sel)|(Memory_WEB & Memory_DM_read_sel);
            else
              Trans_Stall = 1'b0;
          end
          

          RADDR:    Trans_Stall =  1'b1;
          RDATA:      
            //Trans_Stall <=  (R_last) ? 1'b0 : 1'b1;
            begin  
              if(reg_Rvalid_both)
                Trans_Stall =  (M_RLast_h1) ? 1'b0 : 1'b1;
              else
                Trans_Stall =  (R_last) ? 1'b0 : 1'b1;
            end
          WADDR:    Trans_Stall =  1'b1;
          WDATA:    Trans_Stall =  (W_last) ? 1'b0 : 1'b1;
          WRESP:    Trans_Stall =  1'b0;
          default:  Trans_Stall =  1'b0;
        endcase          
        end
      //end

      //assign  Trans_Stall = ((Memory_WEB  == 1'b1) & (~Rdata_done)) |((Memory_WEB  == 1'b0) & (~Wdata_done));
endmodule