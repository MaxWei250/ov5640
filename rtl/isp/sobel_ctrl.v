module      sobel_ctrl
(
    input  wire                         sys_clk                    ,
    input  wire                         sys_rst_n                  ,
    input  wire                         pi_flag                    ,
    input  wire        [   7:0]         pi_data                    ,

    output reg         [   7:0]         po_data                    ,
    output reg                          po_flag                     
);

    parameter                           CNT_COL_MAX = 10'd99        ,
                                        CNT_ROW_MAX = 10'd99;
    parameter                           THR = 8'b0000_1100;
    parameter                           BLACK = 8'b0000_0000,
                                        WHITE = 8'B1111_1111;
wire                   [   7:0]         dout1                      ;
wire                   [   7:0]         dout2                      ;

reg                    [   9:0]         cnt_col                    ;
reg                    [   9:0]         cnt_row                    ;
reg                                     wr_en1                     ;
reg                    [   7:0]         wr_data1                   ;
reg                                     wr_en2                     ;
reg                    [   7:0]         wr_data2                   ;
reg                                     dout_flag                  ;
reg                                     rd_en                      ;
reg                    [   9:0]         cnt_rd                     ;
reg                    [   7:0]         dout1_reg                  ;
reg                    [   7:0]         dout2_reg                  ;
reg                    [   7:0]         pi_data_reg                ;
reg                                     rd_en_reg1                 ;
reg                                     rd_en_reg2                 ;
reg                    [   7:0]         a1                         ;
reg                    [   7:0]         b1                         ;
reg                    [   7:0]         c1                         ;
reg                    [   7:0]         a2                         ;
reg                    [   7:0]         b2                         ;
reg                    [   7:0]         c2                         ;
reg                    [   7:0]         a3                         ;
reg                    [   7:0]         b3                         ;
reg                    [   7:0]         c3                         ;
reg                                     gx_gy_flag                 ;
reg                                     gxy_flag                   ;
reg                    [   8:0]         gx                         ;
reg                    [   8:0]         gy                         ;
reg                    [   8:0]         gxy                        ;
reg                                     com_flag                   ;
//cnt_col
always@(posedge sys_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_col <= 10'd0;
    else if(pi_flag == 1'b1 && cnt_col == CNT_COL_MAX)
        cnt_col <= 10'b0;
    else if(pi_flag == 1'b1)
        cnt_col <= cnt_col + 1'b1;
    else
        cnt_col <= cnt_col;
//cnt_row
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
        cnt_row <= 10'd0;
    else if(cnt_col == CNT_COL_MAX && pi_flag == 1'b1 && cnt_row == CNT_ROW_MAX)
        cnt_row <= 1'b0;
    else if(pi_flag == 1'b1 && cnt_col == CNT_COL_MAX)
        cnt_row <= cnt_row + 1'b1;
    else
        cnt_row <= cnt_row;
end
//wr_en1
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n== 1'b0)
        wr_en1 <= 1'b0;
    else if(cnt_row == 1'b0 && pi_flag == 1'b1)
        wr_en1 <= 1'b1;
    else
        wr_en1 <= dout_flag;
end
//wr_data1
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
        wr_data1 <= 8'd0;
    else if(cnt_row == 1'b0 && pi_flag == 1'b1)
        wr_data1 <= pi_data;
    else if(dout_flag == 1'b1)
        wr_data1 <= dout2;
    else 
        wr_data1 <= wr_data1;
end        
//wr_en2
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
        wr_en2 <= 1'b0;
    else if(cnt_row >= 1'b1 && cnt_row <= (CNT_ROW_MAX - 1'B1) && pi_flag == 1'b1)
        wr_en2 <= 1'b1;
    else 
        wr_en2 <= 1'b0;
end
//wr_data2
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
        wr_data2 <= 8'd0;
    else if(cnt_row >= 1'b1 && cnt_row <= (CNT_ROW_MAX - 1'b1) && pi_flag == 1'b1)
        wr_data2 <= pi_data;
    else 
        wr_data2 <= wr_data2;
end        
//rd_en
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
        rd_en <= 1'b0;
    else if(cnt_row > 1'b1 && pi_flag == 1'b1)
        rd_en <= 1'b1;
    else 
        rd_en <= 1'b0;
end

//dout_flag
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
        dout_flag <= 1'b0;
    else if(wr_en2== 1'b1 && rd_en == 1'b1)
        dout_flag <= 1'b1;
    else 
        dout_flag <= 1'b0;
end
//cnt_rd
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
        cnt_rd <= 10'd0;
    else if(cnt_rd == CNT_COL_MAX && rd_en == 1'b1)
        cnt_rd <= 10'd0;
    else if(rd_en == 1'b1)
        cnt_rd <= cnt_rd + 1'b1;
    else
        cnt_rd <= cnt_rd;
end
//rd_en_reg
always @(posedge sys_clk or negedge sys_rst_n) begin
    if (sys_rst_n == 1'b0) begin
        rd_en_reg1 <= 1'b0;
    end
    else if(rd_en == 1'b1)
    begin
        rd_en_reg1 <= 1'b1;
    end
    else
        rd_en_reg1 <= 1'b0;
end
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
        rd_en_reg2 <= 1'b0;
    else if(rd_en_reg1 == 1'b1)
        rd_en_reg2 <= 1'b1;
    else
        rd_en_reg2 <= 1'b0;
end
//data_reg
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
    begin
          dout1_reg <= 1'b0;
          dout2_reg <= 1'b0;
          pi_data_reg <= 1'b0;
    end
    else if(rd_en_reg1 == 1'b1)
    begin
        dout1_reg <= dout1;
        dout2_reg <= dout2;
        pi_data_reg <= pi_data;
    end
    else begin
        dout1_reg <= dout1_reg;
        dout2_reg <= dout2_reg;
        pi_data_reg <=pi_data_reg;
    end
end
//matrix_data
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
    begin
        a1 <= 1'b0;
        b1 <= 1'b0;
        c1 <= 1'b0;
        a2 <= 1'b0;
        b2 <= 1'b0;
        c2 <= 1'b0;
        a3 <= 1'b0;
        b3 <= 1'b0;
        c3 <= 1'b0;
    end   
    else if(rd_en_reg2 == 1'b1)
    begin
        a1 <= a2;
        b1 <= b2;
        c1 <= c2;
        a2 <= a3;
        b2 <= b3;
        c2 <= c3;
        a3 <= dout1_reg;
        b3 <= dout2_reg;
        c3 <= pi_data_reg;
    end
    else begin
        a1 <= a1;
        b1 <= b1;
        c1 <= c1;
        a2 <= a2;
        b2 <= b2;
        c2 <= c2;
        a3 <= a3;
        b3 <= b3;
        c3 <= c3;
    end
end
//gx_gy_flag
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
        gx_gy_flag <= 1'b0;
    else if(rd_en_reg2 == 1'b1 && ( ~(cnt_rd == 1'b1) ) && (~(cnt_rd == 2'd2)))
        gx_gy_flag <= 1'b1;
    else 
        gx_gy_flag <= 1'b0;
end
//gx gy
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)   
        gx <= 1'b0;
    else if(gx_gy_flag == 1'b1 )
        gx <= (a3 - a1) + ((b3 - b1) << 1) + (c3 - c1);
    else
        gx <= gx;
end
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
        gy <= 1'b0;
    else if(gx_gy_flag == 1'b1)
        gy <= (a1 - c1) + ((a2 - c2) << 1) + (a3 - c3);
    else
        gy <= gy;
end
//gxy
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
        gxy_flag <= 1'b0;
    else if(gx_gy_flag == 1'b1)
        gxy_flag <= 1'b1;
    else
        gxy_flag <= 1'b0;
end
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
        gxy <= 1'b0;
    else if(gxy_flag == 1'b1 && gx[8] == 1'b1 && gy[8] == 1'b1)
        gxy <= (~gx[7:0] + 1'b1) + (~gy[7:0] + 1'b1);
    else if(gxy_flag == 1'b1 && gx[8] == 1'b0 && gy[8] == 1'b1)
        gxy <= gx[7:0] + (~gy[7:0] + 1'b1);
    else if(gx[8] == 1'b1 && gy[8] == 1'b0 && gxy_flag == 1'b1)
        gxy <= (~gx[7:0] + 1'b1) + gy[7:0];
    else if(gx[8] == 1'b0 && gy[8] == 1'b0 && gxy_flag == 1'b1)
        gxy <= gx[7:0] + gy[7:0];
    else
        gxy <= gxy;
end
//compare
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
        com_flag <= 1'b0;
    else if(gxy_flag == 1'b1)
        com_flag <= 1'b1;
    else
        com_flag <= 1'b0;
end
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
        po_data <= 1'b0;
    else if(com_flag == 1'b1 && gxy > THR)
        po_data <= BLACK;
    else if(com_flag == 1'b1)
        po_data <= WHITE;

end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
        po_flag <= 1'b0;
    else if(com_flag == 1'b1)
        po_flag <= 1'b1;
    else
        po_flag <= 1'b0;
end
fifo    fifo_inst1 (
    .clock                             (sys_clk                   ),
    .data                              (wr_data1                  ),
    .rdreq                             (rd_en                     ),
    .wrreq                             (wr_en1                    ),
    .q                                 (dout1                     ) 
);

fifo    fifo_inst2 (
    .clock                             (sys_clk                   ),
    .data                              (wr_data2                  ),
    .rdreq                             (rd_en                     ),
    .wrreq                             (wr_en2                    ),
    .q                                 (dout2                     ) 
);
endmodule