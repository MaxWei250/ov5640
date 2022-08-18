module sdram_aref (
    input  wire                         sys_clk                    ,
    input  wire                         sys_rst_n                  ,
    input  wire                         init_end                   ,
    input  wire                         aref_en                    ,

    output reg                          aref_req                   ,
    output reg         [   3:0]         aref_cmd                   ,
    output wire        [   1:0]         aref_ba                    ,
    output wire        [  12:0]         aref_addr                  ,
    output wire                         aref_end                    
);
parameter   CNT_REF_MAX = 13'd750;
parameter   AREF_IDLE   = 3'B000,
            AREF_PCH    = 3'B001,
            AREF_TRP    = 3'B011,
            AREF_REF    = 3'B010,
            AREF_TRF    = 3'B110,
            AREF_END    = 3'B111;
parameter   TRP  = 2'D2,
            TRFC = 3'D7;
parameter   NOP     =   4'b0111,
            PRE_CHA =   4'B0010,
            A_REF   =   4'B0001;
wire                                    trf_end                    ;
wire                                    trp_end                    ;
wire                                    aref_ack                   ;

reg                                    cnt_clk_rst                ;
reg                    [   3:0]         aref_state                 ;
reg                    [  12:0]         cnt_ref                    ;
reg                    [   3:0]         cnt_clk                    ;
reg                    [   1:0]         cnt_aref                   ;
//*STATE
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
    	aref_state <= AREF_IDLE;
    else 
        case (aref_state) 
        AREF_IDLE:
            if(aref_en == 1'b1)
                aref_state <= AREF_PCH;
            else
                aref_state <= AREF_IDLE;
        AREF_PCH :
            aref_state <= AREF_TRP;
        AREF_TRP :
            if(trp_end == 1'b1)
                aref_state <= AREF_REF;
            else
                aref_state <= aref_state;
        AREF_REF :
            aref_state <= AREF_TRF;
        AREF_TRF :
            if(trf_end == 1'b1)
                if(cnt_aref == 2'd2)
                    aref_state <= AREF_END;
                else
                    aref_state <= AREF_REF;
            else
                aref_state <= aref_state;
        AREF_END :
            aref_state <= AREF_IDLE;
        default 
            aref_state <= AREF_IDLE;
        endcase
end
//*cnt_ref aref_req
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
    	cnt_ref <= 1'b0;
    else if(cnt_ref == CNT_REF_MAX - 1)
        cnt_ref <= 1'b0;
    else if(init_end == 1'b1)
        cnt_ref <= cnt_ref + 1'b1;
    else
        cnt_ref <= cnt_ref;
end
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
    	aref_req <= 1'b0;
    else if(cnt_ref == CNT_REF_MAX - 1)
        aref_req <= 1'b1;
    else if(aref_ack == 1'b1)
        aref_req <= 1'b0;
    else
        aref_req <= aref_req;
end
assign aref_ack = (aref_state == AREF_PCH) ? 1'B1 : 1'B0;
//*cnt_clk(rst)
always @(*) begin
    case (aref_state)
        AREF_IDLE,AREF_END:
            cnt_clk_rst = 1'B1;
        AREF_TRP:
            if(cnt_clk == TRP)
                cnt_clk_rst = 1'B1;
        AREF_TRF:
            if(cnt_clk == TRFC )
                cnt_clk_rst = 1'b1;
        default 
            cnt_clk_rst = 1'b0;
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
//*trp(rf)_end
assign trp_end  = (cnt_clk == TRP  && aref_state == AREF_TRP  ) ? 1'b1 : 1'b0;
assign trf_end  = (cnt_clk == TRFC && aref_state == AREF_TRF  ) ? 1'b1 : 1'b0;
//*cnt_aref
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
    	cnt_aref <= 1'b0;
    else if(aref_state == AREF_IDLE)
        cnt_aref <= 1'b0;
    else if(aref_state == AREF_REF)
        cnt_aref <= cnt_aref + 1'b1;
end
//*output signal
assign aref_ba = 2'b11;
assign aref_addr = 13'h1fff;
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
    	aref_cmd <= NOP;
    else
        case (aref_state)
        AREF_IDLE,AREF_TRP ,AREF_TRF ,AREF_END :
            aref_cmd <= NOP;
        AREF_PCH :
            aref_cmd <= PRE_CHA;
        AREF_REF :
            aref_cmd <= A_REF;
        endcase
end
assign aref_end = (aref_state == AREF_END) ? 1'b1 : 1'b0;
endmodule                                                           //sdram_aref