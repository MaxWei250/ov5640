module ov5640_top (
    input  wire                         sys_rst_n                  ,
    input  wire                         sys_clk                    ,
    input  wire                         ov5640_pclk                ,
    input  wire                         ov5640_href                ,
    input  wire        [   7:0]         ov5640_data                ,
    input  wire                         sys_init_done              ,//sdram & ov5640 init end
    input  wire                         ov5640_vsync               ,

    output wire                         ov5640_wr_en               ,
    output wire        [  15:0]         ov5640_data_out            ,
    output wire                         cfg_done                  ,
    output wire                         sccb_scl                   ,
    inout  wire                         sccb_sda                    
);
    parameter                           OV5640_ADDR = 7'H3C        ;
    parameter                           CLK_FREQ   = 26'd50_000_000;// i2c_dri模块的驱动时钟频率(CLK_FREQ)
    parameter                           I2C_FREQ   = 18'd250_000   ;// I2C的SCL时钟频率
wire                                    cfg_end                    ;
wire                                    cfg_start                  ;
wire                   [  23:0]         cfg_data                   ;
wire                                    cfg_clk                    ;
i2c_ctrl
#(
    .CLK_FREQ                          (CLK_FREQ                  ),
    .I2C_CLK                           (I2C_FREQ                  ),
    .DEVICE_ADDR                       (OV5640_ADDR               )
)
u_i2c_ctrl(
    .sys_clk                           (sys_clk                   ),
    .sys_rst_n                         (sys_rst_n                 ),
    .wr_en                             (1'b1                      ),
    .byte_addr                         (cfg_data[23:8]            ),
    .wr_data                           (cfg_data[7:0]             ),
    .addr_num                          (1'b1                      ),
    .rd_en                             (                          ),
    .i2c_start                         (cfg_start                 ),
   
    .i2c_clk                           (cfg_clk                   ),
    .i2c_scl                           (sccb_scl                  ),
    .i2c_end                           (cfg_end                   ),
    .rd_data                           (                          ),
    .i2c_sda                           (sccb_sda                  ) 
);
ov5640_cfg u_ov5640_cfg(
    .sys_clk                           (cfg_clk                   ),
    .cfg_end                           (cfg_end                   ),
    .sys_rst_n                         (sys_rst_n                 ),
    .cfg_done                          (cfg_done                  ),
    .cfg_start                         (cfg_start                 ),
    .cfg_data                          (cfg_data                  ) 
);

ov5640_data u_ov5640_data(
    .ov5640_pclk                       (ov5640_pclk               ),
    .sys_rst_n                         (sys_rst_n & sys_init_done ),
    .ov5640_href                       (ov5640_href               ),
    .ov5640_vsync                      (ov5640_vsync              ),
    .ov5640_data                       (ov5640_data               ),
    .ov5640_wr_en                      (ov5640_wr_en              ),
    .ov5640_data_out                   (ov5640_data_out           ) 
);

endmodule                                                           //ov5640_top