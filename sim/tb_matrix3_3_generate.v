`timescale 1ns/1ns

module tb_matrix3_3_generate ();
reg sys_clk;
reg sys_rst_n;
reg wr_en;
reg href;
reg  [7:0] img_Y;
wire pic_flag;
wire martrix_wr_en;
wire [7:0] matrix_p11;
wire [7:0] matrix_p12;
wire [7:0] matrix_p13;
wire [7:0] matrix_p21;
wire [7:0] matrix_p22;
wire [7:0] matrix_p23;
wire [7:0] matrix_p31;
wire [7:0] matrix_p32;
wire [7:0] matrix_p33;
initial begin
    sys_clk = 1'b1;
    sys_rst_n <= 1'b0;
    wr_en <= 1'b0;
    #200
    sys_rst_n <= 1'b1;
end
always #10 sys_clk = ~sys_clk;
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
    	wr_en <= 1'b0;
    else 
        wr_en <= ~wr_en;
end
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0) begin
    	href <= 1'b0;
    end
    else 
        href <= 1'b1;
end
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
    	img_Y <= 1'b0;
    else if(wr_en == 1'b0)
        img_Y <= img_Y + 1'b1;
end


matrix3_3_generate_8bit 
#(
    .CNT_PIC_MAX ('d7 )
)
u_matrix3_3_generate(
    .sys_clk       (sys_clk       ),
    .sys_rst_n     (sys_rst_n     ),
    .pre_href      (href          ),
    .wr_en         (wr_en         ),
    .img_Y         (img_Y         ),
    .matrix_wr_en  (martrix_wr_en ),
    .matrix_p11    (matrix_p11    ),
    .matrix_p12    (matrix_p12    ),
    .matrix_p13    (matrix_p13    ),
    .matrix_p21    (matrix_p21    ),
    .matrix_p22    (matrix_p22    ),
    .matrix_p23    (matrix_p23    ),
    .matrix_p31    (matrix_p31    ),
    .matrix_p32    (matrix_p32    ),
    .matrix_p33    (matrix_p33    )
);

endmodule //tb_matrix3_3_generate