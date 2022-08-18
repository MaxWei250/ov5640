module sdram_ctrl (
    //*sys
    input  wire                         sys_clk                    ,
    input  wire                         sys_rst_n                  ,
    //*write
    input  wire        [  23:0]         sdram_wr_addr              ,
    input  wire        [  15:0]         sdram_wr_data              ,
    input  wire        [   9:0]         wr_burst_len               ,
    output wire                         sdram_wr_ack               ,
    input  wire                         sdram_wr_req               ,
    //*read
    input  wire        [  23:0]         sdram_rd_addr              ,
    input  wire        [   9:0]         rd_burst_len               ,
    output wire                         sdram_rd_ack               ,
    output wire        [  15:0]         rd_data_out                ,
    input wire                         sdram_rd_req               ,
    output wire                         init_end                   ,
    //*sdram
    output wire                         sdram_cke                  ,
    output wire                         sdram_cs_n                 ,
    output wire                         sdram_cas_n                ,
    output wire                         sdram_ras_n                ,
    output wire                         sdram_we_n                 ,
    output wire        [   1:0]         sdram_ba                   ,
    output wire        [  12:0]         sdram_addr                 ,
    inout  wire        [  15:0]         sdram_dq                    
);

//*init
wire                   [   3:0]         init_cmd                   ;
wire                   [   1:0]         init_ba                    ;
wire                   [  12:0]         init_addr                  ;
//*write
wire                                    wr_en                      ;
wire                                    wr_end                     ;
wire                   [  15:0]         wr_sdram_data              ;
wire                   [   3:0]         wr_cmd                     ;
wire                   [   1:0]         wr_ba                      ;
wire                   [  12:0]         wr_sdram_addr              ;
wire                                    wr_sdram_en                ;
//*read
wire                                    rd_en                      ;
wire                                    rd_end                     ;
wire                   [  15:0]         rd_sdram_data              ;
wire                   [   3:0]         read_cmd                   ;
wire                   [   1:0]         read_ba                    ;
wire                   [  12:0]         read_addr                  ;
//*aref
wire                                    aref_en                    ;
wire                                    aref_req                   ;
wire                   [   3:0]         aref_cmd                   ;
wire                   [   1:0]         aref_ba                    ;
wire                   [  12:0]         aref_addr                  ;
wire                                    aref_end                   ;
sdram_arbit u_sdram_arbit(
    .sys_clk                           (sys_clk                   ),
    .sys_rst_n                         (sys_rst_n                 ),

    .init_end                          (init_end                  ),
    .init_ba                           (init_ba                   ),
    .init_addr                         (init_addr                 ),
    .init_cmd                          (init_cmd                  ),

    .wr_req                            (sdram_wr_req              ),
    .wr_sdram_en                       (wr_sdram_en               ),
    .wr_data                           (wr_sdram_data             ),
    .wr_end                            (wr_end                    ),
    .wr_cmd                            (wr_cmd                    ),
    .wr_ba                             (wr_ba                     ),
    .wr_addr                           (wr_sdram_addr             ),

    //.rd_sdram_en (rd_sdram_en ),
    .rd_addr                           (read_addr             ),
    .rd_cmd                            (read_cmd                  ),
    .rd_ba                             (read_ba                   ),
    .rd_req                            (sdram_rd_req              ),
    .rd_end                            (rd_end                    ),

    .aref_cmd                          (aref_cmd                  ),
    .aref_ba                           (aref_ba                   ),
    .aref_addr                         (aref_addr                 ),
    .aref_req                          (aref_req                  ),
    .aref_end                          (aref_end                  ),

    .sdram_cs_n                        (sdram_cs_n                ),
    .sdram_cas_n                       (sdram_cas_n               ),
    .sdram_ras_n                       (sdram_ras_n               ),
    .sdram_we_n                        (sdram_we_n                ),
    .sdram_ba                          (sdram_ba                  ),
    .sdram_addr                        (sdram_addr                ),
    .rd_en                             (rd_en                     ),
    .wr_en                             (wr_en                     ),
    .aref_en                           (aref_en                   ),
    .sdram_cke                         (sdram_cke                 ),
    .sdram_dq                          (sdram_dq                  ) 
);

sdram_init u_sdram_init(
    .sys_clk                           (sys_clk                   ),
    .sys_rst_n                         (sys_rst_n                 ),
    .init_cmd                          (init_cmd                  ),
    .init_ba                           (init_ba                   ),
    .init_addr                         (init_addr                 ),
    .init_end                          (init_end                  ) 
);

sdram_wr u_sdram_wr(
    .sys_clk                           (sys_clk                   ),
    .sys_rst_n                         (sys_rst_n                 ),
    .init_end                          (init_end                  ),
    .wr_en                             (wr_en                     ),
    .wr_addr                           (sdram_wr_addr             ),
    .wr_data                           (sdram_wr_data             ),
    .wr_burst_len                      (wr_burst_len              ),
    .wr_ack                            (sdram_wr_ack              ),

    .wr_end                            (wr_end                    ),
    .wr_sdram_data                     (wr_sdram_data             ),
    .wr_cmd                            (wr_cmd                    ),
    .wr_ba                             (wr_ba                     ),
    .wr_sdram_addr                     (wr_sdram_addr             ),
    .wr_sdram_en                       (wr_sdram_en               ) 
);
sdram_rd u_sdram_rd(
    .sys_clk                           (sys_clk                   ),
    .sys_rst_n                         (sys_rst_n                 ),
    .init_end                          (init_end                  ),
    .rd_en                             (rd_en                     ),
    .rd_addr                           (sdram_rd_addr             ),
    .rd_data                           (sdram_dq                  ),
    .rd_burst_len                      (rd_burst_len              ),

    .rd_ack                            (sdram_rd_ack                    ),
    .rd_end                            (rd_end                    ),
    .rd_sdram_data                     (rd_data_out             ),
    .read_cmd                          (read_cmd                  ),
    .read_ba                           (read_ba                   ),
    .read_addr                         (read_addr                 ) 
);
sdram_aref u_sdram_aref(
    .sys_clk                           (sys_clk                   ),
    .sys_rst_n                         (sys_rst_n                 ),
    .init_end                          (init_end                  ),

    .aref_en                           (aref_en                   ),
    .aref_req                          (aref_req                  ),
    .aref_cmd                          (aref_cmd                  ),
    .aref_ba                           (aref_ba                   ),
    .aref_addr                         (aref_addr                 ),
    .aref_end                          (aref_end                  ) 
);

endmodule                                                           //sdram_ctrl