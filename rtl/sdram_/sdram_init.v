module   sdram_init
(
    input  wire                         sys_clk                    ,
    input  wire                         sys_rst_n                  ,

    output reg         [   3:0]         init_cmd                   ,
    output reg         [   1:0]         init_ba                    ,
    output reg         [  12:0]         init_addr                  ,
    output wire                         init_end                    
);
parameter   INIT_IDLE  =  8'B0000_0001,
            INIT_PRE   =  8'B0000_0010,
            INIT_TRP   =  8'B0000_0100,
            INIT_AR    =  8'B0000_1000,
            INIT_TRFC  =  8'B0001_0000,
            INIT_MRS   =  8'B0010_0000,
            INIT_TMRAD =  8'b0100_0000,
            INIT_END   =  8'b1000_0000;
parameter   TRP  = 2'D2,
            TRFC = 3'D7,
            TMRD = 3'D3;
parameter   NOP     =   4'b0111,
            PRE_CHA =   4'B0010,
            A_REF   =   4'B0001,
            LOAD_M  =   4'B0000;
parameter   MAX_200us = 15'D20000;
reg                                     cnt_clk_rst                ;
wire                                    trp_end                    ;
wire                                    trfc_end                   ;
wire                                    tmrd_end                   ;
reg                    [   3:0]         cnt_aref                   ;
reg                    [   8:0]         init_state                 ;
reg                    [  15:0]         cnt_200us                  ;
reg                                     wait_end                   ;
reg                    [   3:0]         cnt_clk                    ;
//*state
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        init_state <= INIT_IDLE;
    else 
    case (init_state)
        INIT_IDLE      :
            if(wait_end == 1'b1)
                init_state <= INIT_PRE;
            else 
                init_state <= init_state;

        INIT_PRE  :
            init_state <= INIT_TRP;
            
        INIT_TRP  :
            if(trp_end == 1'b1)
                init_state <= INIT_AR;
            else
                init_state <= init_state;

        INIT_AR   :
            init_state <= INIT_TRFC;

        INIT_TRFC :
            if(trfc_end == 1'b1)
                begin
                if(cnt_aref == 4'd8)
                    init_state <= INIT_MRS;
                else
                    init_state <= INIT_AR;
                end
            else 
                init_state <= init_state;

        INIT_MRS  :
            init_state <= INIT_TMRAD;

        INIT_TMRAD:
            if(tmrd_end == 1'b1)
                init_state <= INIT_END;
            else
                init_state <= init_state;

        INIT_END  :
            init_state <= init_state;

        default :
            init_state <= INIT_IDLE;
    endcase

//*cnt_200ms wait_end
always @(posedge sys_clk or negedge sys_rst_n) begin
if(sys_rst_n == 1'b0)
	cnt_200us <= 1'b0;
else if(cnt_200us == MAX_200us)
    cnt_200us <= MAX_200us;
else if(init_state == INIT_IDLE)
    cnt_200us <= cnt_200us + 1'B1;
end

always @(posedge sys_clk or negedge sys_rst_n) begin
  if(sys_rst_n == 1'b0)
  	wait_end <= 1'b0;
  else if(cnt_200us == MAX_200us - 1)
      wait_end <= 1'b1;
  else
      wait_end <= 1'b0;
end
//*cnt_clk(rst) trp_end.....
always @(*) begin
    case (init_state)
        INIT_IDLE,INIT_END:
            cnt_clk_rst = 1'B1;
        INIT_PRE,INIT_AR,INIT_MRS:
            cnt_clk_rst = 1'b0;
        INIT_TRP:
            if(cnt_clk == TRP)
                cnt_clk_rst = 1'B1;
            else
                cnt_clk_rst = 1'B0;
        INIT_TRFC:
            if(cnt_clk == TRFC )
                cnt_clk_rst = 1'b1;
            else 
                cnt_clk_rst = 1'b0;
        INIT_TMRAD:
            if(cnt_clk == TMRD )
                cnt_clk_rst = 1'b1;
            else
                cnt_clk_rst = 1'b0;
        default 
            cnt_clk_rst = 1'b1;
    endcase
end
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
    	cnt_clk <= 1'b0;
    else if(cnt_clk_rst == 1'b1)
        cnt_clk <= 1'b0;
    else 
        cnt_clk <= cnt_clk + 1'b1;
end
assign trp_end  = (cnt_clk == TRP  && init_state == INIT_TRP  ) ? 1'b1 : 1'b0;
assign trfc_end = (cnt_clk == TRFC && init_state == INIT_TRFC ) ? 1'b1 : 1'b0;
assign tmrd_end = (cnt_clk == TMRD && init_state == INIT_TMRAD) ? 1'b1 : 1'b0;
//*cnt_aref
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
    	cnt_aref <= 1'b0;
    else if(init_state == INIT_AR)
        cnt_aref <= 1'b1 + cnt_aref;
end
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
    	begin
            init_cmd  =  NOP  ;   
            init_ba   =  2'b11;
            init_addr =  13'h1fff; 
        end
    else if(init_state == INIT_PRE)
        begin
            init_cmd  =  PRE_CHA;
            init_ba   =  2'B11;
            init_addr =  13'h1fff;
        end
    else if(init_state == INIT_AR)
        begin
            init_cmd  =  A_REF;
            init_ba   =  2'B11;
            init_addr =  13'h1fff;
        end
    else if(init_state == INIT_MRS)
        begin
            init_cmd  =  LOAD_M;
            init_ba   =  2'B00;
            init_addr =  {3'd0,1'b0,2'd0,3'b011,1'b0,3'b111};
        end
    else
        begin
            init_cmd  =  NOP  ;   
            init_ba   =  2'b11;
            init_addr =  13'h1fff; 
        end
end
assign init_end = (init_state == INIT_END) ? 1'b1 : 1'b0;

endmodule