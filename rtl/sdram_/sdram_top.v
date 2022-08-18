module sdram_top (
    input  wire                         sys_clk                    ,
    input  wire                         sys_rst_n                  ,
    input  wire                         clk_out                    ,
    //write fifo
    input  wire                         wr_fifo_wr_clk             ,
    input  wire                         wr_fifo_wr_req             ,
    input  wire        [  15:0]         wr_fifo_wr_data            ,
    input  wire        [  23:0]         sdram_wr_b_addr            ,
    input  wire        [  23:0]         sdram_wr_e_addr            ,
    input  wire        [   9:0]         sdram_wr_burst_len         ,
    input  wire                         wr_rst                     ,
    //read fifo
    input  wire                         rd_fifo_rd_clk             ,
    input  wire                         rd_fifo_rd_req             ,
    input  wire        [  23:0]         sdram_rd_b_addr            ,
    input  wire        [  23:0]         sdram_rd_e_addr            ,
    input  wire        [   9:0]         sdram_rd_burst_len        ,
    input  wire                         rd_rst                     ,
    output wire                         init_end                   ,
    input  wire                         read_valid                 ,
    output wire        [   9:0]         rd_fifo_num                ,
    output wire        [  15:0]         rd_fifo_data               ,
    //sdram 硬件接口
    output wire                         sdram_clk                  ,
    output wire                         sdram_cke                  ,
    output wire                         sdram_cs_n                 ,
    output wire                         sdram_cas_n                ,
    output wire                         sdram_ras_n                ,
    output wire                         sdram_we_n                 ,
    output wire        [   1:0]         sdram_ba                   ,
    output wire        [  12:0]         sdram_addr                 ,
    output wire        [   1:0]         sdram_dqm                  ,
    inout  wire        [  15:0]         sdram_dq                    
);
wire                                    sdram_wr_ack                     ;
wire                                    sdram_rd_ack                     ;
wire                                    sdram_wr_req               ;
wire                                    sdram_rd_req               ;
wire                   [  15:0]         sdram_wr_data              ;
wire                   [  23:0]         sdram_wr_addr              ;
wire [15:0] sdram_rd_data;
wire [23:0] sdram_rd_addr;

assign sdram_clk = clk_out;
assign sdram_dqm = 2'b00;
sdram_ctrl  sdram_ctrl_inst(

    .sys_clk        (sys_clk       ),   //系统时钟
    .sys_rst_n      (sys_rst_n          ),   //复位信号，低电平有效
//SDRAM 控制器写端口
    .sdram_wr_req   (sdram_wr_req          ),   //写SDRAM请求信号
    .sdram_wr_addr  (sdram_wr_addr   ),   //SDRAM写操作的地址
    .wr_burst_len   (sdram_wr_burst_len        ),   //写sdram时数据突发长度
    .sdram_wr_data  (sdram_wr_data     ),   //写入SDRAM的数据
    .sdram_wr_ack   (sdram_wr_ack   ),   //写SDRAM响应信号
//SDRAM 控制器读端口
    .sdram_rd_req   (sdram_rd_req          ),  //读SDRAM请求信号
    .sdram_rd_addr  (sdram_rd_addr    ),  //SDRAM写操作的地址
    .rd_burst_len   (sdram_rd_burst_len        ),  //读sdram时数据突发长度
    .rd_data_out (sdram_rd_data ),  //从SDRAM读出的数据
    .init_end       (init_end       ),  //SDRAM 初始化完成标志
    .sdram_rd_ack   (sdram_rd_ack   ),  //读SDRAM响应信号
//FPGA与SDRAM硬件接口
    .sdram_cke      (sdram_cke      ),  // SDRAM 时钟有效信号
    .sdram_cs_n     (sdram_cs_n     ),  // SDRAM 片选信号
    .sdram_ras_n    (sdram_ras_n    ),  // SDRAM 行地址选通脉冲
    .sdram_cas_n    (sdram_cas_n    ),  // SDRAM 列地址选通脉冲
    .sdram_we_n     (sdram_we_n     ),  // SDRAM 写允许位
    .sdram_ba       (sdram_ba       ),  // SDRAM L-Bank地址线
    .sdram_addr     (sdram_addr     ),  // SDRAM 地址总线
    .sdram_dq       (sdram_dq       )   // SDRAM 数据总线

);

fifo_ctrl u_fifo_ctrl(
    .sys_clk            (sys_clk            ),
    .sys_rst_n          (sys_rst_n          ),
    .wr_fifo_wr_clk     (wr_fifo_wr_clk     ),
    .wr_fifo_wr_req     (wr_fifo_wr_req     ),
    .wr_fifo_wr_data    (wr_fifo_wr_data    ),
    .sdram_wr_b_addr    (sdram_wr_b_addr    ),
    .sdram_wr_e_addr    (sdram_wr_e_addr    ),
    .sdram_wr_burst_len (sdram_wr_burst_len ),
    .wr_rst             (wr_rst             ),
    .sdram_wr_ack       (sdram_wr_ack       ),//
    .sdram_wr_addr      (sdram_wr_addr      ),
    .sdram_wr_data      (sdram_wr_data      ),
    .sdram_wr_req       (sdram_wr_req       ),
    .rd_fifo_rd_clk     (rd_fifo_rd_clk     ),
    .rd_fifo_rd_req     (rd_fifo_rd_req     ),
    .sdram_rd_b_addr    (sdram_rd_b_addr    ),
    .sdram_rd_e_addr    (sdram_rd_e_addr    ),
    .sdram_rd_burst_len (sdram_rd_burst_len ),
    .read_valid         (read_valid         ),
    .init_end           (init_end           ),
    .rd_fifo_data       (rd_fifo_data       ),
    .rd_fifo_num        (rd_fifo_num        ),
    .pingpang_en        (1'b1               ),
    .rd_rst             (rd_rst             ),
    .sdram_rd_data      (sdram_rd_data      ),
    .sdram_rd_ack       (sdram_rd_ack       ),
    .sdram_rd_addr      (sdram_rd_addr      ),
    .sdram_rd_req       (sdram_rd_req       )
);

endmodule //sdram_top