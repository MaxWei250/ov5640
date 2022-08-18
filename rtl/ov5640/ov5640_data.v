module ov5640_data (
    input  wire                         ov5640_pclk                ,
    input  wire                         sys_rst_n                  ,
    input  wire                         ov5640_href                ,
    input  wire                         ov5640_vsync               ,
    input  wire        [   7:0]         ov5640_data                ,

    output wire                         ov5640_wr_en               ,
    output wire        [  15:0]         ov5640_data_out             
);

reg                                     ov5640_vsync_reg           ;//用于捕获下降沿
wire                                    pic_flag                   ;//捕获到VSync的高电平，作为帧计数信号
reg                    [   4:0]         cnt_pic                    ;//进行帧计数，因为前十帧是无效的
reg                                     pic_valid                  ;//指明有效帧
reg                    [   7:0]         pic_data_reg            ;//寄存data，用于合成data_out
reg                                     data_flag                  ;//合成flag
reg                                     data_flag_reg              ;//输出标志位
reg                    [  15:0]         data_out_reg               ;
    parameter                           INVAILD_PIC = 4'd10         ;
//*vsync_reg
always @(posedge ov5640_pclk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
        ov5640_vsync_reg <= 1'b0;
    else
        ov5640_vsync_reg <= ov5640_vsync;
end
//*pic_flag cnt_pic pic_valid
assign pic_flag = (ov5640_vsync == 1'b1 && ov5640_vsync_reg == 1'b0) ? 1'b1 : 1'b0;
always @(posedge ov5640_pclk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
        cnt_pic <= 1'b0;
    else if(cnt_pic >= INVAILD_PIC)
        cnt_pic <= INVAILD_PIC;
    else if(pic_flag == 1'b1)
        cnt_pic <= cnt_pic + 1'b1;
end//!
always @(posedge ov5640_pclk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
        pic_valid <= 1'b0;
    else if(pic_flag == 1'b1 && cnt_pic == INVAILD_PIC)
        pic_valid <= 1'b1;
end
always@(posedge ov5640_pclk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        begin
            data_out_reg    <=  16'd0;
            pic_data_reg    <=  8'd0;
            data_flag       <=  1'b0;
        end
    else    if(ov5640_href == 1'b1)
        begin
            data_flag       <=  ~data_flag;
            pic_data_reg    <=  ov5640_data;
            data_out_reg    <=  data_out_reg;
        if(data_flag == 1'b1)
            data_out_reg    <=  {pic_data_reg,ov5640_data};
        else
            data_out_reg    <=  data_out_reg;
        end
    else
        begin
            data_flag       <=  1'b0;
            pic_data_reg    <=  8'd0;
            data_out_reg    <=  data_out_reg;
        end
//*data_flag_reg
always @(posedge ov5640_pclk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
    	data_flag_reg <= 1'b0;
    else
        data_flag_reg <= data_flag;
end
//*out_io
assign  ov5640_data_out = (pic_valid == 1'b1) ? data_out_reg : 16'b0;

//ov5640_wr_en:输出16位图像数据使能
assign  ov5640_wr_en = (pic_valid == 1'b1) ? data_flag_reg : 1'b0;

endmodule  