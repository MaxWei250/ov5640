`timescale 1ns/1ns
module tb_rgb_ycbcr ();
reg sys_clk;
reg sys_rst_n;
reg  [15:0] ov5640_data [99:0];
//wire [15:0] data_reg;
reg pre_wr_en;
wire  wr_en_dly  ;
wire [15:0] rgb565_data;
wire [7:0] img_y      ;
wire [7:0] img_cb     ;
wire [7:0] img_cr     ;
initial begin
    sys_clk = 1'b1;
    sys_rst_n <= 1'b0;
    pre_wr_en <= 1'b0;
    #30 
    sys_rst_n <= 1'b1;
end
always #10 sys_clk = ~sys_clk;
integer i,j;
initial begin
    for (i = 0;i < 100 ;i = i+1 ) begin
          ov5640_data[i] <= $random%100;
    end  
    pre_wr_en <= 1'b1;
end
always #500 j <= {$random}%100;
rgb_ycbcr u_rgb_ycbcr(
    .sys_clk     (sys_clk     ),
    .sys_rst_n   (sys_rst_n   ),
    .pre_wr_en   (pre_wr_en   ),
    .ov5640_data (ov5640_data[j] ),
    .wr_en_dly   (wr_en_dly   ),
    .rgb565_data (rgb565_data ),
    .img_y       (img_y       ),
    .img_cb      (img_cb      ),
    .img_cr      (img_cr      )
);

endmodule //tb_rgb_ycbcr