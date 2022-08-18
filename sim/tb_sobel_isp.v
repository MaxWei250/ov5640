module tb_sobel_isp ();
reg sys_clk;
reg sys_rst_n;
reg wr_en;
reg [7:0] img_Y;
wire [15:0] sobel_data;
wire sobel_wr_en;
initial begin
    sys_clk = 1'b1;
    sys_rst_n <= 1'b0;
    #200
    sys_rst_n <= 1'b1;
end
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
    	wr_en <= 1'b0;
    else 
        wr_en <= ~wr_en;
end
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
    	img_Y <= 1'b0;
    else if(wr_en == 1'b0)
        img_Y <= img_Y + 1'b1;
end
always #10 sys_clk = ~sys_clk;
defparam u_sobel_isp.u_matrix3_3_generate.CNT_PIC_MAX = 'd7;
sobel_isp u_sobel_isp(
    .sys_clk     (sys_clk     ),
    .sys_rst_n   (sys_rst_n   ),
    .wr_en       (wr_en       ),
    .img_Y       (img_Y       ),
    .sobel_data  (sobel_data  ),
    .sobel_wr_en (sobel_wr_en )
);

endmodule //tb_sobel_isp