module isp_top (
    input  wire                         sys_clk                    ,
    input  wire                         sys_rst_n                  ,
    input  wire                         wr_en                      ,
    input  wire        [  15:0]         ov5640_data_out            ,

    output wire                         isp_wr_en                  ,
    output wire        [  15:0]         isp_rgb565                  
);
wire                                    ycbcr_wr_en                ;
wire                                    sobel_wr_en                ;
wire                                    erosion_wr_en0             ;
//wire                                    erosion_wr_en1             ;
wire                                    dilation_wr_en             ;
wire                                    sobel_1bit                 ;
wire                                    erosion_1bit_out0          ;
//wire                                    erosion_1bit_out1          ;
wire                   [   7:0]         img_Y                      ;
rgb_ycbcr u_rgb_ycbcr(
    .sys_clk                           (sys_clk                   ),
    .sys_rst_n                         (sys_rst_n                 ),
    .pre_wr_en                         (wr_en                     ),
    .ov5640_data                       (ov5640_data_out           ),
    .wr_en_dly                         (ycbcr_wr_en               ),
    .rgb565_data                       (                          ),
    .img_y                             (img_Y                     ),
    .img_cb                            (                          ),
    .img_cr                            (                          ) 
);
sobel_isp u_sobel_isp(
    .sys_clk                           (sys_clk                   ),
    .sys_rst_n                         (sys_rst_n                 ),
    .wr_en                             (ycbcr_wr_en               ),
    .img_Y                             (img_Y                     ),
    .sobel_data                        (                          ),
    .sobel_wr_en                       (sobel_wr_en               ),
    .sobel_1bit                        (sobel_1bit                ) 
);
 isp_1bit_erosion u_isp_1bit_erosion0(
    .sys_clk                           (sys_clk                   ),
    .sys_rst_n                         (sys_rst_n                 ),
    .wr_en                             (sobel_wr_en               ),
    .img_1bit_in                       (sobel_1bit                ),
    .erosion_wr_en                     (erosion_wr_en0             ),
    .img_1bit_out                      (erosion_1bit_out0          ),
    .erosion_rgb565                    (                          ) 
);
/*  isp_1bit_erosion u_isp_1bit_erosion1(
    .sys_clk                           (sys_clk                   ),
    .sys_rst_n                         (sys_rst_n                 ),
    .wr_en                             (erosion_wr_en0            ),
    .img_1bit_in                       (erosion_1bit_out0         ),
    .erosion_wr_en                     (erosion_wr_en1            ),
    .img_1bit_out                      (erosion_1bit_out1         ),
    .erosion_rgb565                    (                          ) 
);
 isp_1bit_erosion u_isp_1bit_erosion2(
    .sys_clk                           (sys_clk                   ),
    .sys_rst_n                         (sys_rst_n                 ),
    .wr_en                             (erosion_wr_en1            ),
    .img_1bit_in                       (erosion_1bit_out1         ),
    .erosion_wr_en                     (isp_wr_en                 ),
    .img_1bit_out                      (                          ),
    .erosion_rgb565                    (isp_rgb565                ) 
); */
isp_1bit_dilation u_isp_1bit_dilation(
    .sys_clk                           (sys_clk                   ),
    .sys_rst_n                         (sys_rst_n                 ),
    .wr_en                             (erosion_wr_en0             ),
    .img_1bit_in                       (erosion_1bit_out0          ),
    .dilation_wr_en                    (isp_wr_en                 ),
    .img_1bit_out                      (                          ),
    .dilation_data                     (isp_rgb565                ) 
);
endmodule                                                           //isp_top