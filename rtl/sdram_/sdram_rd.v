module sdram_rd (
    input  wire                         sys_clk                    ,
    input  wire                         sys_rst_n                  ,
    input  wire                         init_end                   ,
    input  wire                         rd_en                      ,
    input  wire        [  23:0]         rd_addr                    ,
    input  wire        [  15:0]         rd_data                    ,
    input  wire        [   9:0]         rd_burst_len               ,
    
    output wire                         rd_ack                     ,
    output wire                         rd_end                     ,
    output wire        [  15:0]         rd_sdram_data              ,
    output reg         [   3:0]         read_cmd                     ,
    output reg         [   1:0]         read_ba                      ,
    output reg         [  12:0]         read_addr               
);
reg                    [  15:0]         rd_data_reg                ;
reg                    [   8:0]         rd_state                   ;
reg                    [   4:0]         cnt_clk                    ;


reg                                     cnt_clk_rst                ;
wire                                    trcd_end                   ;
wire                                    tcl_end                    ;
wire                                    trd_end                    ;
wire                                    trp_end                    ;
wire                                    rd_b_end                   ;
parameter               RD_IDLE  =  9'B00000_0001, 
                        RD_ACTIVE=  9'B00000_0010,
                        RD_TRCD  =  9'B00000_0100,
                        READ     =  9'B00000_1000,
                        RD_CL    =  9'B00001_0000,
                        RD_DATA  =  9'B00010_0000,
                        RD_PCH   =  9'b00100_0000,
                        RD_TRP   =  9'b01000_0000,
                        RD_END   =  9'b10000_0000;
parameter   TRP  = 2'D2,
            TCL  = 2'd3,
            TRCD = 2'D2;
parameter   NOP       =   4'b0111,
            PRE_CHA   =   4'B0010,
            ACTIVE    =   4'b0011,
            RD_CMD    =   4'B0101,
            BURST_TER =   4'B0110;
//*rd_data_reg
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
    	rd_data_reg <= 1'b0;
    else
        rd_data_reg <= rd_data;
end
//*state
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
    	rd_state <= RD_IDLE;
    else
    case (rd_state)
        RD_IDLE  :
            if(rd_en == 1'b1)
                rd_state <= RD_ACTIVE;
            else
                rd_state <= rd_state;
        RD_ACTIVE:
            rd_state <= RD_TRCD;
        RD_TRCD  :
            if(trcd_end == 1'b1)
                rd_state <= READ;
            else
                rd_state <= rd_state;
        READ     :
            rd_state <= RD_CL;
        RD_CL    :
            if(tcl_end == 1'b1)
                rd_state <= RD_DATA;
            else
                rd_state <= rd_state;
        RD_DATA  :
            if(trd_end == 1'b1)
                rd_state <= RD_PCH;
            else
                rd_state <= rd_state;
        RD_PCH   :
            rd_state <= RD_TRP;
        RD_TRP   :
            if(trp_end == 1'b1)
                rd_state <= RD_END;
            else
                rd_state <= rd_state;
        RD_END   :
            rd_state <= RD_IDLE;
        default 
            rd_state <= RD_IDLE;
    endcase
end
//*cnt_clk(rst)
always @(*) begin
    case (rd_state)
        RD_ACTIVE,RD_PCH:
            cnt_clk_rst = 1'b0;
        RD_TRCD:
            cnt_clk_rst = (trcd_end == 1'b1) ? 1'b1 : 1'b0;
        RD_DATA:
            cnt_clk_rst = (trd_end == 1'b1 ) ? 1'b1 : 1'b0;
        RD_TRP:
            cnt_clk_rst = (trp_end == 1'b1 ) ? 1'b1 : 1'b0;
        RD_CL:
            cnt_clk_rst = (tcl_end == 1'b1 ) ? 1'b1 : 1'b0;
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
//*//*trcd_end trp_end trd_end tcl_end RD_B_END
assign trcd_end = (cnt_clk == TRCD && rd_state == RD_TRCD   ) ? 1'b1 : 1'b0;
assign trd_end  = (cnt_clk == (rd_burst_len - 1 + TCL) && rd_state == RD_DATA ) ? 1'b1 :1'b0;
assign trp_end  = (cnt_clk == TRP  && rd_state == RD_TRP    ) ? 1'b1 : 1'b0;
assign tcl_end  = (cnt_clk == (TCL - 1) && rd_state == RD_CL) ? 1'B1 : 1'B0;
assign rd_b_end = (cnt_clk == rd_burst_len - TCL-1&& rd_state == RD_DATA) ? 1'b1 : 1'b0;
//*rd_ack   rd_sdram_data rd_end
assign rd_ack = (cnt_clk >= 1'b1 && cnt_clk <= rd_burst_len + 1&&rd_state == RD_DATA) ? 1'B1 : 1'B0;
assign rd_sdram_data = (rd_ack == 1'b1) ? rd_data_reg : 1'b0;
assign rd_end = (rd_state == RD_END) ? 1'b1 : 1'b0;
//*read_cmd read_ba rd_addr
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)begin
        read_cmd <= NOP       ;
        read_ba  <= 2'b11     ;
        read_addr<= 13'h1fff  ;
    end
    else
    case (rd_state)
        RD_IDLE,RD_TRCD,RD_END,RD_TRP,RD_CL:begin
            read_cmd          <= NOP      ;
            read_ba           <= 2'b11    ;
            read_addr   <= 13'h1fff ;
        end  
        RD_ACTIVE:begin
            read_cmd          <= ACTIVE           ;
            read_ba           <= rd_addr[23:22]   ;
            read_addr   <= rd_addr[ 21:9]   ;
        end
        READ:begin
            read_cmd          <= RD_CMD;
            read_ba           <= rd_addr[23:22]   ;
            read_addr   <= {4'd0,rd_addr[ 8:0]}   ;
        end    
        RD_DATA:begin
            if(rd_b_end == 1'b1)
            begin
                read_cmd <= BURST_TER;    
            end
            else
            begin
                read_cmd          <= NOP      ;
                read_ba           <= 2'b11    ;
                read_addr   <= 13'h1fff ;
            end
        end
        RD_PCH:begin
            read_cmd          <= PRE_CHA          ;
            read_ba           <= rd_addr[23:22]   ;
            read_addr   <= 13'H0400         ;
        end
        default begin
            read_cmd          <= NOP      ;
            read_ba           <= 2'b11    ;
            read_addr   <= 13'h1fff ;
        end
    endcase
end
endmodule                                                           //sdram_rd 