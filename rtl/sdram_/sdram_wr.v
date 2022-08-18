module sdram_wr (
    input  wire                         sys_clk                    ,
    input  wire                         sys_rst_n                  ,
    input  wire                         init_end                   ,
    input  wire                         wr_en                      ,
    input  wire        [  23:0]         wr_addr                    ,
    input  wire        [  15:0]         wr_data                    ,
    input  wire        [   9:0]         wr_burst_len               ,

    output wire                         wr_ack                     ,
    output wire                         wr_end                     ,
    output wire        [  15:0]         wr_sdram_data              , 
    output reg         [   3:0]         wr_cmd                     ,
    output reg         [   1:0]         wr_ba                      ,
    output reg         [  12:0]         wr_sdram_addr              ,
    output reg                          wr_sdram_en                
    
);
parameter               WR_IDLE  =  8'B0000_0001,
                        WR_ACTIVE=  8'B0000_0010,
                        WR_TRCD  =  8'B0000_0100,
                        WRITE    =  8'B0000_1000,
                        WR_DATA  =  8'B0001_0000,
                        WR_PCH   =  8'B0010_0000,
                        WR_TRP   =  8'b0100_0000,
                        WR_END   =  8'b1000_0000;  
parameter   TRP  = 2'D2,
            TRCD = 2'D2;
parameter   NOP       =   4'b0111,
            PRE_CHA   =   4'B0010,
            ACTIVE    =   4'b0011,
            WRITE_CMD =   4'B0100,
            BURST_TER =   4'B0110;
reg                    [   7:0]         wr_state                   ;
reg                    [   4:0]         cnt_clk                    ;
reg                                     cnt_clk_rst                ;
wire                                    trcd_end                   ;
wire                                    twr_end                    ;
wire                                    trp_end                    ;
//*state
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
    	wr_state <= WR_IDLE;
    else
    case (wr_state)
        WR_IDLE  :
            if(wr_en == 1'b1 && init_end == 1'b1)
                wr_state <= WR_ACTIVE;
            else
                wr_state <= wr_state;
        WR_ACTIVE:
            wr_state <= WR_TRCD;
        WR_TRCD  :
            if(trcd_end == 1'b1)
                wr_state <= WRITE;
            else 
                wr_state <= wr_state;
        WRITE    :
            wr_state <= WR_DATA;
        WR_DATA  :
            if(twr_end == 1'b1)
                wr_state <= WR_PCH;
            else
                wr_state <= wr_state;
        WR_PCH   :
            wr_state <= WR_TRP;
        WR_TRP   :
            if(trp_end == 1'b1)
                wr_state <= WR_END;
            else
                wr_state <= wr_state;
        WR_END   :
            wr_state <= WR_IDLE;
        default 
            wr_state <= WR_IDLE;
    endcase
end
//*cnt_clk(rst)
always @(*) begin
    case (wr_state)
        WR_ACTIVE,WR_PCH:
            cnt_clk_rst = 1'b0;
        WR_TRCD:
            cnt_clk_rst = (trcd_end == 1'b1) ? 1'b1 : 1'b0;
        WR_DATA:
            cnt_clk_rst = (twr_end == 1'b1 ) ? 1'b1 : 1'b0;
        WR_TRP:
            cnt_clk_rst = (trp_end == 1'b1 ) ? 1'b1 : 1'b0;
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
//*trcd_end trp_end twr_end
assign trcd_end = (cnt_clk == TRCD && wr_state == WR_TRCD   ) ? 1'b1 : 1'b0;
assign twr_end  = (cnt_clk == (wr_burst_len - 1) && wr_state == WR_DATA ) ? 1'b1 : 1'b0;
assign trp_end  = (cnt_clk == TRP  && wr_state == WR_TRP    ) ? 1'b1 : 1'b0;
//*WR_Ack wr_sdram_en wr_data
assign wr_ack = ((wr_state == WRITE) || (wr_state == WR_DATA && cnt_clk <= (wr_burst_len - 2)));
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
    	wr_sdram_en <= 1'b0;
    else 
        wr_sdram_en <= wr_ack;
end
assign wr_sdram_data = (wr_sdram_en == 1'b1) ? wr_data : 1'b0;
//*wr_end
assign wr_end = (wr_state == WR_END) ? 1'b1 : 1'b0;
//*wr_cmd wr_ba wr_addr
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)begin
        wr_cmd <= NOP       ;
        wr_ba  <= 2'b11     ;
        wr_sdram_addr<= 13'h1fff  ;
    end
    else
    case (wr_state)
        WR_IDLE,WR_TRCD,WR_END,WR_TRP:begin
            wr_cmd          <= NOP      ;
            wr_ba           <= 2'b11    ;
            wr_sdram_addr   <= 13'h1fff ;
        end  
        WR_ACTIVE:begin
            wr_cmd          <= ACTIVE           ;
            wr_ba           <= wr_addr[23:22]   ;
            wr_sdram_addr   <= wr_addr[ 21:9]   ;
        end
        WRITE:begin
            wr_cmd          <= WRITE_CMD;
            wr_ba           <= wr_addr[23:22]   ;
            wr_sdram_addr   <= {4'd0,wr_addr[ 8:0]}   ;
        end    
        WR_DATA:begin
            if(twr_end == 1'b1)
            begin
                wr_cmd <= BURST_TER;    
            end
            else
            begin
                wr_cmd          <= NOP      ;
                wr_ba           <= 2'b11    ;
                wr_sdram_addr   <= 13'h1fff ;
            end
        end
        WR_PCH:begin
            wr_cmd          <= PRE_CHA          ;
            wr_ba           <= wr_addr[23:22]   ;
            wr_sdram_addr   <= 13'H0400         ;
        end
        default begin
            wr_cmd          <= NOP      ;
            wr_ba           <= 2'b11    ;
            wr_sdram_addr   <= 13'h1fff ;
        end
    endcase
end
endmodule //sdram_wr