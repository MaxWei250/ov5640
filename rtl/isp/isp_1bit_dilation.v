module isp_1bit_dilation (
    input  wire                         sys_clk                    ,
    input  wire                         sys_rst_n                  ,

    input  wire                         wr_en                      ,
    input  wire                         img_1bit_in                ,

    output reg                          dilation_wr_en             ,
    output wire                         img_1bit_out               ,
    output wire        [  15:0]         dilation_data               
);
wire                                    matrix_p11, matrix_p12, matrix_p13;//3X3 Matrix output
wire                                    matrix_p21, matrix_p22, matrix_p23;
wire                                    matrix_p31, matrix_p32, matrix_p33;
wire                                    matrix_wr_en_out           ;
reg                    [   1:0]         wr_en_dly                  ;
reg                                     post_img_Bit1,	post_img_Bit2,	post_img_Bit3,post_img_Bit4;
matrix3_3_generate_1bit u_matrix3_3_generate_1bit(
    .sys_clk                           (sys_clk                   ),
    .sys_rst_n                         (sys_rst_n                 ),
    .wr_en                             (wr_en                     ),
    .img_1bit                          (img_1bit_in               ),
    .martrix_wr_en                     (matrix_wr_en_out          ),
    .matrix_p11                        (matrix_p11                ),
    .matrix_p12                        (matrix_p12                ),
    .matrix_p13                        (matrix_p13                ),
    .matrix_p21                        (matrix_p21                ),
    .matrix_p22                        (matrix_p22                ),
    .matrix_p23                        (matrix_p23                ),
    .matrix_p31                        (matrix_p31                ),
    .matrix_p32                        (matrix_p32                ),
    .matrix_p33                        (matrix_p33                ) 
);
//Step1
always@(posedge sys_clk or negedge sys_rst_n)
begin
    if(!sys_rst_n)
        begin
        post_img_Bit1 <= 1'b0;
        post_img_Bit2 <= 1'b0;
        post_img_Bit3 <= 1'b0;
        end
    else
        begin
        post_img_Bit1 <= matrix_p11 & matrix_p12 & matrix_p13;
        post_img_Bit2 <= matrix_p21 & matrix_p22 & matrix_p23;
        post_img_Bit3 <= matrix_p21 & matrix_p32 & matrix_p33;
        end
end

//Step 2
always@(posedge sys_clk or negedge sys_rst_n)
begin
    if(!sys_rst_n)
        post_img_Bit4 <= 1'b0;
    else
        post_img_Bit4 <= post_img_Bit1 & post_img_Bit2 & post_img_Bit3;
end
assign img_1bit_out = dilation_wr_en ? post_img_Bit4 : 1'b0;
assign dilation_data = img_1bit_out ? 16'hffff : 16'h0000;
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)begin
        wr_en_dly[0]  <= 1'b0;
        wr_en_dly[1]  <= 1'b0;
        dilation_wr_en <= 1'b0;
    end
    else begin
        wr_en_dly[0]  <= wr_en;
        wr_en_dly[1]  <= wr_en_dly[0];
        dilation_wr_en <= wr_en_dly[1];
    end
end
endmodule                                                           //isp_1bit_dilation