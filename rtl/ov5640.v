module        ov5640                                                //请输入模块名称
(
    input  wire                         sys_clk                    ,
    input  wire                         sys_rst_n                  ,
    input  wire                         ov5640_pclk                ,
    input  wire                         ov5640_vsync               ,
    input  wire                         ov5640_href                ,
    input  wire        [   7:0]         ov5640_data                ,

    output wire        [  15:0]         rgb_tft                    ,
    output wire                         hsync                      ,
    output wire                         vsync                      ,
    output wire                         tft_clk                    ,
    output wire                         tft_de                     ,
    output wire                         tft_bl                     ,
    output wire                         sdram_clk                  ,
    output wire                         sdram_cs_n                 ,
    output wire                         sdram_cas_n                ,
    output wire                         sdram_ras_n                ,
    output wire                         sdram_we_n                 ,//SDRAM 写有效
    output wire        [   1:0]         sdram_ba                   ,//SDRAM Bank地址
    output wire        [   1:0]         sdram_dqm                  ,//SDRAM 数据掩码
    output wire        [  12:0]         sdram_addr                 ,//SDRAM 地址
    inout  wire        [  15:0]         sdram_dq                   ,//SDRAM 数据
    output wire                         sdram_cke                  ,//SDRAM 时钟使能
    output wire                         ov5640_rst_n               ,
    output wire                         ov5640_pwdn                ,

    //*DEBUG
    output wire led0,
    output wire led1,
    output wire led2,

    output wire                         sccb_scl                   ,
    inout  wire                         sccb_sda                    
);
//parameter define
    parameter                           H_PIXEL     =   24'd800    ;//水平方向像素个数,用于设置SDRAM缓存大小
    parameter                           V_PIXEL     =   24'd480    ;//垂直方向像素个数,用于设置SDRAM缓存大小
wire                   [  15:0]         ov5640_data_out            ;
wire                                    wr_en_dly                  ;
wire                   [  15:0]         po_data                    ;
wire                                    clk_33m                    ;
wire                                    clk_100m                   ;
wire                                    clk_100m_shift             ;
wire                                    locked                     ;
wire                                    rst_n = locked & sys_rst_n ;
wire                                    cfg_done                   ;//摄像头初始化完成
wire                                    wr_en                      ;//sdram写使能
wire                   [  15:0]         wr_data                    ;//sdram写数据
wire                                    rd_en                      ;//sdram读使能
wire                   [  15:0]         rd_data                    ;//sdram读数据
wire                                    sdram_init_done            ;//SDRAM初始化完成
wire                                    sys_init_done              ;//系统初始化完成(SDRAM初始化+摄像头初始化)        
wire                                    isp_wr_en                  ;
wire                   [  15:0]         isp_rgb565                 ;
//sys_init_done:系统初始化完成(SDRAM初始化+摄像头初始化)
assign  sys_init_done = sdram_init_done & cfg_done;

//ov5640_rst_n:摄像头复位,固定高电平
assign  ov5640_rst_n = 1'b1;

//ov5640_pwdn
assign  ov5640_pwdn = 1'b0;
assign led0 = sys_init_done;
assign led1 = cfg_done;
assign led2 = sdram_init_done;
clk_gen u_clk_gen(
    .areset                            (~sys_rst_n                ),
    .inclk0                            (sys_clk                   ),
    .c0                                (clk_33m                   ),
    .c1                                (clk_100m                  ),
    .c2                                (clk_100m_shift            ),
    .locked                            (locked                    ) 
);
ov5640_top u_ov5640_top(
    .sys_rst_n                         (rst_n                     ),
    .sys_clk                           (clk_33m                   ),
    .ov5640_pclk                       (ov5640_pclk               ),
    .ov5640_href                       (ov5640_href               ),
    .ov5640_data                       (ov5640_data               ),
    .sys_init_done                     (sys_init_done             ),
    .ov5640_vsync                      (ov5640_vsync              ),
    .ov5640_wr_en                      (wr_en                     ),
    .ov5640_data_out                   (ov5640_data_out           ),
    .cfg_done                          (cfg_done                  ),
    .sccb_scl                          (sccb_scl                  ),
    .sccb_sda                          (sccb_sda                  ) 
);
isp_top u_isp_top(
    .sys_clk                           (ov5640_pclk               ),
    .sys_rst_n                         (rst_n                     ),
    .wr_en                             (wr_en                     ),
    .ov5640_data_out                   (ov5640_data_out           ),
    .isp_wr_en                         (isp_wr_en                 ),
    .isp_rgb565                        (isp_rgb565                ) 
);


sdram_top   sdram_top_inst(

    .sys_clk                           (clk_100m                  ),//sdram 控制器参考时钟
    .clk_out                           (clk_100m_shift            ),//用于输出的相位偏移时钟
    .sys_rst_n                         (rst_n                     ),//系统复位
//用户写端口    
    .wr_fifo_wr_clk                    (ov5640_pclk               ),//写端口FIFO: 写时钟
    .wr_fifo_wr_req                    (isp_wr_en                 ),//写端口FIFO: 写使能
    .wr_fifo_wr_data                   (isp_rgb565                ),//写端口FIFO: 写数据
    .sdram_wr_b_addr                   (24'd0                     ),//写SDRAM的起始地址
    .sdram_wr_e_addr                   (H_PIXEL*V_PIXEL           ),//写SDRAM的结束地址
    .wr_burst_len                      (10'd512                   ),//写SDRAM时的数据突发长度
    .wr_rst                            (~rst_n                    ),//写端口复位: 复位写地址,清空写FIFO
//用户读端口
    .rd_fifo_rd_clk                    (clk_33m                   ),//读端口FIFO: 读时钟
    .rd_fifo_rd_req                    (rd_en                     ),//读端口FIFO: 读使能
    .rd_fifo_rd_data                   (rd_data                   ),//读端口FIFO: 读数据
    .sdram_rd_b_addr                   (24'd0                     ),//读SDRAM的起始地址
    .sdram_rd_e_addr                   (H_PIXEL*V_PIXEL           ),//读SDRAM的结束地址
    .rd_burst_len                      (10'd512                   ),//从SDRAM中读数据时的突发长度
    .rd_rst                            (~rst_n                    ),//读端口复位: 复位读地址,清空读FIFO
//用户控制端口
    .read_valid                        (1'b1                      ),//SDRAM 读使能
    .pingpang_en                       (1'b1                      ),//SDRAM 乒乓操作使能
    .init_end                          (sdram_init_done           ),//SDRAM 初始化完成标志
//SDRAM 芯片接口
    .sdram_clk                         (sdram_clk                 ),//SDRAM 芯片时钟
    .sdram_cke                         (sdram_cke                 ),//SDRAM 时钟有效
    .sdram_cs_n                        (sdram_cs_n                ),//SDRAM 片选
    .sdram_ras_n                       (sdram_ras_n               ),//SDRAM 行有效
    .sdram_cas_n                       (sdram_cas_n               ),//SDRAM 列有效
    .sdram_we_n                        (sdram_we_n                ),//SDRAM 写有效
    .sdram_ba                          (sdram_ba                  ),//SDRAM Bank地址
    .sdram_addr                        (sdram_addr                ),//SDRAM 行/列地址
    .sdram_dq                          (sdram_dq                  ),//SDRAM 数据
    .sdram_dqm                         (sdram_dqm                 ) //SDRAM 数据掩码

);
tft_ctrl u_tft_ctrl(
    .clk_33m                           (clk_33m                   ),
    .sys_rst_n                         (rst_n                     ),
    .data_in                           (rd_data                   ),
    .data_req                          (rd_en                     ),//处于有效时刻发出数据请求
    .rgb_tft                           (rgb_tft                   ),
    .hsync                             (hsync                     ),
    .vsync                             (vsync                     ),
    .tft_clk                           (tft_clk                   ),
    .tft_de                            (tft_de                    ),
    .tft_bl                            (tft_bl                    ) 
);

endmodule
