module sobel_isp (
    input  wire                         sys_clk                    ,
    input  wire                         sys_rst_n                  ,
    input  wire                         wr_en                      ,
    input  wire        [   7:0]         img_Y                      ,

    output reg         [  15:0]         sobel_data                 ,
    output wire                         sobel_wr_en                ,
    output reg                          sobel_1bit                  
);
    parameter                           THR = 8'b001_1011         ;
    parameter                           BLACK = 16'b0000_0000_0000_0000,
                                        WHITE = 16'B1111_1111_1111_1111;
//reg define 
reg                    [   9:0]         Gx_temp2                   ;//第三列值
reg                    [   9:0]         Gx_temp1                   ;//第一列值
reg                    [   9:0]         Gx_data                    ;//x方向的偏导数
reg                    [   9:0]         Gy_temp1                   ;//第一行值
reg                    [   9:0]         Gy_temp2                   ;//第三行值
reg                    [   9:0]         Gy_data                    ;//y方向的偏导数
reg                    [  20:0]         Gxy_square                 ;
wire                   [  10:0]         Gxy_sqrt                   ;
reg                    [   4:0]         wr_en_dly                  ;
//输出3X3 矩阵
wire                   [   7:0]         matrix_p11                 ;
wire                   [   7:0]         matrix_p12                 ;
wire                   [   7:0]         matrix_p13                 ;
wire                   [   7:0]         matrix_p21                 ;
wire                   [   7:0]         matrix_p22                 ;
wire                   [   7:0]         matrix_p23                 ;
wire                   [   7:0]         matrix_p31                 ;
wire                   [   7:0]         matrix_p32                 ;
wire                   [   7:0]         matrix_p33                 ;

wire                                    matrix_wr_en               ;
wire                                    sobel_en                   ;

assign sobel_wr_en = wr_en_dly[4];
matrix3_3_generate_8bit u_matrix3_3_generate_8bit(
    .sys_clk                           (sys_clk                   ),
    .sys_rst_n                         (sys_rst_n                 ),
    .wr_en                             (wr_en                     ),
    .img_Y                             (img_Y                     ),
    .matrix_wr_en                      (matrix_wr_en              ),
    .matrix_p11                        (matrix_p11                ),
    .matrix_p12                        (matrix_p12                ),
    .matrix_p13                        (matrix_p13                ),
    .matrix_p21                        (matrix_p21                ),
    .matrix_p22                        (matrix_p22                ),
    .matrix_p23                        (matrix_p23                ),
    .matrix_p31                        (matrix_p31                ),
    .matrix_p32                        (matrix_p32                ),
    .matrix_p33                        (matrix_p33                ),
    .sobel_en                          (sobel_en                  ) 
);
//Sobel 算子
//         Gx                  Gy                  像素点
// [   -1  0   +1  ]   [   +1  +2   +1 ]     [   P11  P12   P13 ]
// [   -2  0   +2  ]   [   0   0    0  ]     [   P21  P22   P23 ]
// [   -1  0   +1  ]   [   -1  -2   -1 ]     [   P31  P32   P33 ]

//Step 1 计算x方向的偏导数
always@(posedge sys_clk or negedge sys_rst_n)begin
    if(!sys_rst_n)begin
        Gy_temp1 <= 10'd0;
        Gy_temp2 <= 10'd0;
        Gy_data <=  10'd0;
    end
    else if(sobel_en == 1'b1) begin
        Gy_temp1 <= matrix_p13 + (matrix_p23 << 1) + matrix_p33;
        Gy_temp2 <= matrix_p11 + (matrix_p21 << 1) + matrix_p31;
        Gy_data <= (Gy_temp1 >= Gy_temp2) ? Gy_temp1 - Gy_temp2 : (Gy_temp2 - Gy_temp1);//确保结果是正数
    end
end
//Step 2 计算y方向的偏导数
always@(posedge sys_clk or negedge sys_rst_n)begin
    if(!sys_rst_n)begin
        Gx_temp1 <= 10'd0;
        Gx_temp2 <= 10'd0;
        Gx_data <=  10'd0;
    end
    else if(sobel_en == 1'b1) begin
        Gx_temp1 <= matrix_p11 + (matrix_p12 << 1) + matrix_p13;
        Gx_temp2 <= matrix_p31 + (matrix_p32 << 1) + matrix_p33;
        Gx_data <= (Gx_temp1 >= Gx_temp2) ? Gx_temp1 - Gx_temp2 : (Gx_temp2 - Gx_temp1);
    end
end
//Step 3 计算平方和
always@(posedge sys_clk or negedge sys_rst_n)begin
    if(!sys_rst_n)
        Gxy_square <= 21'd0;
    else if(sobel_en == 1'b1)
        Gxy_square <= Gx_data * Gx_data + Gy_data * Gy_data;
end
//Step 4 开平方（梯度向量的大小）
sqrt u_sqrt(
    .radical                           (Gxy_square                ),
    .q                                 (Gxy_sqrt                  ),
    .remainder                         (                          ) 
);
//step5：与设置阈值比较
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)begin
        sobel_data <= 16'd0;
        sobel_1bit <= 1'b0;
    end     
    else if(Gxy_sqrt >= THR && sobel_en == 1'b1)begin
        sobel_data <= BLACK;
        sobel_1bit <= 1'd0;
    end
    else begin
        sobel_data <= WHITE;  
        sobel_1bit <= 1'd1;      
    end
end

always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
        wr_en_dly <= 1'b0;
    else
        wr_en_dly <= {wr_en_dly[3:0],wr_en};
end
endmodule                                                           //sobel_isp