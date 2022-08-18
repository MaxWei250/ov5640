`timescale 1ns/1ns  

module  tb_ov5640_top (); //请输入模块名称
parameter   H_VALID = 10'd640 , //行有效数据
            H_TOTAL = 10'd784 ; //行扫描周期
parameter   V_SYNC = 10'd4 , //场同步
            V_BACK = 10'd18 , //场时序后沿
            V_VALID = 10'd480 , //场有效数据
            V_FRONT = 10'd8 , //场时序前沿
            V_TOTAL = 10'd510 ; //场扫描周期

reg                                     sys_clk                    ;
reg                                     ov5640_pclk                ;
reg                                     sys_rst_n                  ;
reg                    [   7:0]         ov5640_data                ;
reg                    [  11:0]         cnt_h                      ;
reg                    [   9:0]         cnt_v                      ;

wire                                    ov5640_wr_en               ;
wire                   [  15:0]         ov5640_data_out            ;
wire                                    ov5640_href                ;
wire                                    ov5640_vsync               ;
wire cfg_down;
wire sccb_scl;
wire sccb_sda;
wire ov5640_rst_n;
initial                       //初始化相关参数
    begin
        sys_clk = 1'b1;
        ov5640_pclk = 1'b1;
        sys_rst_n <= 1'b0;
        #30
        sys_rst_n <= 1'b1;
    end
always #20 ov5640_pclk = ~ov5640_pclk;
always #20 sys_clk = ~sys_clk; //25M
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
    	cnt_h <= 1'b0;
    else if(cnt_h == H_TOTAL - 1'b1)
        cnt_h <= 1'b0;
    else 
        cnt_h <= cnt_h + 1'b1;
end
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
    	cnt_v <= 1'b0;
    else if(cnt_v == V_TOTAL - 1'b1)
        cnt_v <= 1'b0;
    else if(cnt_h == H_TOTAL - 1'b1)
        cnt_v = cnt_v + 1'b1;
end
assign ov5640_href = (cnt_h >= 1'b0 && (cnt_h < H_VALID ) && 
                    (cnt_v > V_SYNC + V_BACK)&& (cnt_v < V_BACK + V_SYNC + V_VALID)) ? 1'B1 : 1'B0;
assign ov5640_vsync = (cnt_v < V_SYNC) ? 1'b1 : 1'b0;

always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
    	ov5640_data <= 1'b0;
    else if(ov5640_href == 1'b1) 
        ov5640_data <= ov5640_data + 1'b1;
    else
        ov5640_data <= ov5640_data;
    
end
//完成模块例化
ov5640_top u_ov5640_top(
    .sys_rst_n       (sys_rst_n       ),
    .sys_clk         (sys_clk         ),
    .ov5640_pclk     (ov5640_pclk     ),
    .ov5640_href     (ov5640_href     ),
    .ov5640_data     (ov5640_data     ),
    .sys_init_down   (ov5640_rst_n   ),
    .ov5640_vsync    (ov5640_vsync    ),
    .ov5640_wr_en    (ov5640_wr_en    ),
    .ov5640_data_out (ov5640_data_out ),
    .cfg_down        (cfg_down        ),
    .sccb_scl        (sccb_scl        ),
    .sccb_sda        (sccb_sda        )
);


endmodule