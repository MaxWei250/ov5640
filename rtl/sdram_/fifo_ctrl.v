module fifo_ctrl (                                                  //在原有基础上增加乒乓操作
    //sys 
    input  wire                         sys_clk                    ,
    input  wire                         sys_rst_n                  ,
    //wr_fifo read_rx
    input  wire                         wr_fifo_wr_clk             ,//wr fifo clk
    input  wire                         wr_fifo_wr_req             ,//wr fifo req
    input  wire        [  15:0]         wr_fifo_wr_data            ,
    input  wire        [  23:0]         sdram_wr_b_addr            ,
    input  wire        [  23:0]         sdram_wr_e_addr            ,//2 bit bank addr,13bit row addr,9bit column addr
    input  wire        [   9:0]         sdram_wr_burst_len         ,
    input  wire                         wr_rst                     ,
    //write_sdram
    input  wire                         sdram_wr_ack               ,
    output reg         [  23:0]         sdram_wr_addr              ,//wr sdram addr
    output wire        [  15:0]         sdram_wr_data              ,//wr sdram data
    output reg                          sdram_wr_req               ,
    //read fifo
    input  wire                         rd_fifo_rd_clk             ,
    input  wire                         rd_fifo_rd_req             ,
    input  wire        [  23:0]         sdram_rd_b_addr            ,
    input  wire        [  23:0]         sdram_rd_e_addr            ,
    input  wire        [   9:0]         sdram_rd_burst_len         ,
    input  wire                         read_valid                 ,
    input  wire                         init_end                   ,//sdram init end signal
    output wire        [  15:0]         rd_fifo_data               ,
    output wire        [   9:0]         rd_fifo_num                ,
    input  wire                         pingpang_en                ,
    input  wire                         rd_rst                     ,
    //wr_tx
    input  wire        [  15:0]         sdram_rd_data              ,
    input  wire                         sdram_rd_ack               ,
    output reg         [  23:0]         sdram_rd_addr              ,
    output reg                          sdram_rd_req                
);
reg                                     wr_ack_reg                 ;
reg                                     rd_ack_reg                 ;
reg                                     bank_en                    ;//bank addr shift en signal
reg                                     bank_flag                  ;//bank addr shift flag

wire                   [   9:0]         wr_fifo_num                ;
wire                                    wr_ack_fall                ;
wire                                    rd_ack_fall                ;

//*reg and fall
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
        wr_ack_reg <= 1'b0;
    else
        wr_ack_reg <= sdram_wr_ack;
end
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
        rd_ack_reg <= 1'b0;
    else
        rd_ack_reg <= sdram_rd_ack;
end
assign wr_ack_fall = (wr_ack_reg & (~sdram_wr_ack));
assign rd_ack_fall = (rd_ack_reg & (~sdram_rd_ack));
//*bank_en bank_flag
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
    	begin
            bank_en <= 1'b0;
            bank_flag <= 1'b0;
        end
    else if(wr_ack_fall == 1'b1 && pingpang_en == 1'b1)
        begin
            if (sdram_wr_addr[21:0] < (sdram_wr_e_addr - sdram_wr_burst_len)) begin
                bank_en <= bank_en;
                bank_flag <= bank_flag;
            end
            //wr addr 到达末尾地址
            else begin
                bank_en <= 1'b1;
                bank_flag <= ~bank_flag;
            end
        end
end
//*sdram_wr_addr rd_addr
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
        sdram_wr_addr <= 24'd0;
    else if(wr_rst == 1'b1)
        sdram_wr_addr <= sdram_wr_b_addr;
    else if(wr_ack_fall == 1'b1)begin  //一次突发写结束，更改地址
        //使用乒乓操作，当地址未到达末地址，地址累加
        if(pingpang_en == 1'b1 && (sdram_wr_addr[21:0] < (sdram_wr_e_addr - sdram_wr_burst_len)))
            sdram_wr_addr <= sdram_wr_addr + sdram_wr_burst_len;
            //不适用乒乓操作，当地址未到末地址，地址累加
        else if(sdram_wr_addr < (sdram_wr_e_addr - sdram_wr_burst_len))
            sdram_wr_addr <= sdram_wr_addr + sdram_wr_burst_len;
        else
            sdram_wr_addr <= sdram_wr_b_addr;
    end
    else if(bank_en ==1'b1) begin
        if(bank_flag == 1'b0)
            sdram_wr_addr <= {2'b00,sdram_wr_b_addr[21:0]};
        else
            sdram_wr_addr <= {2'b01,sdram_wr_b_addr[21:0]};
    end
end
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
        sdram_rd_addr <= 24'd0;
    else if(rd_rst == 1'b1)
        sdram_rd_addr <= sdram_rd_b_addr;
    else if(rd_ack_fall == 1'b1)begin //一次突发读结束
        if(pingpang_en == 1'b1) begin
            if(sdram_rd_addr[21:0] < (sdram_rd_e_addr - sdram_rd_burst_len))
                sdram_rd_addr <= sdram_rd_addr + sdram_rd_burst_len;
            else
                if(bank_flag == 1'b0)
                    sdram_rd_addr <= {2'b01,sdram_rd_b_addr[21:0]};
                else
                    sdram_rd_addr <= {2'b00,sdram_rd_b_addr[21:0]};
        end
        else if(sdram_rd_addr < (sdram_rd_e_addr - sdram_rd_burst_len))
            sdram_rd_addr <= sdram_rd_addr + sdram_rd_burst_len;
        else
            sdram_rd_addr <= sdram_rd_b_addr;
    end
end
//*wr_req rd_req
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
        begin
            sdram_wr_req <= 1'b0;
            sdram_rd_req <= 1'b0;
        end
    else if(init_end == 1'b1)
        begin
            //wr fifo data to wr sdram adequately
            if(wr_fifo_num >= sdram_wr_burst_len)
                begin
                    sdram_wr_req <= 1'b1;
                    sdram_rd_req <= 1'b0;
                end
            else if(rd_fifo_num < sdram_rd_burst_len && read_valid == 1'b1)
                begin
                    sdram_wr_req <= 1'b0;
                    sdram_rd_req <= 1'b1;
                end
            else
                begin
                    sdram_wr_req <= 1'b0;
                    sdram_rd_req <= 1'b0;
                end
        end
    else
        begin
            sdram_wr_req <= 1'b0;
            sdram_rd_req <= 1'b0;
        end
end
fifo_data wr_fifo(
    //user
    .data                              (wr_fifo_wr_data           ),//写入fifo的数据
    .wrclk                             (wr_fifo_wr_clk            ),
    .wrreq                             (wr_fifo_wr_req            ),
    //sdram
    .rdclk                             (sys_clk                   ),
    .rdreq                             (sdram_wr_ack              ),
    .q                                 (sdram_wr_data             ),//写入sdram的数据

    .aclr                              (wr_rst ||~sys_rst_n       ),
    .rdusedw                           (wr_fifo_num               ),
    .wrusedw                           (                          ) 
);
fifo_data rd_fifo(
    //user
    .data                              (sdram_rd_data             ),//读出sdram的数据
    .wrclk                             (sdram_rd_ack              ),
    .wrreq                             (wr_fifo_wr_req            ),
    //sdram
    .rdclk                             (rd_fifo_rd_clk            ),
    .rdreq                             (rd_fifo_rd_req            ),
    .q                                 (rd_fifo_data              ),//读数据，传出

    .aclr                              (rd_rst ||~sys_rst_n       ),
    .rdusedw                           (                          ),
    .wrusedw                           (rd_fifo_num               ) 
);

endmodule