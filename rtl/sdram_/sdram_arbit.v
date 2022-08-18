module sdram_arbit (
    input  wire                         sys_clk                    ,
    input  wire                         sys_rst_n                  ,

    input  wire                         init_end                   ,
    input  wire        [   1:0]         init_ba                    ,
    input  wire        [  12:0]         init_addr                  ,
    input  wire        [   3:0]         init_cmd                   ,

    input  wire                         wr_req                     ,
    input  wire                         wr_sdram_en                ,
    input  wire        [  15:0]         wr_data                    ,
    input  wire                         wr_end                     ,
    input  wire        [   3:0]         wr_cmd                     ,
    input  wire        [   1:0]         wr_ba                      ,
    input  wire        [  12:0]         wr_addr                    ,

    //input  wire                         rd_sdram_en                ,
    input  wire        [  12:0]         rd_addr                    ,
    input  wire        [   3:0]         rd_cmd                     ,
    input  wire        [   1:0]         rd_ba                      ,
    input  wire                         rd_req                     ,
    input  wire                         rd_end                     ,

    input  wire        [   3:0]         aref_cmd                   ,
    input  wire        [   1:0]         aref_ba                    ,
    input  wire        [  12:0]         aref_addr                  ,
    input  wire                         aref_req                   ,
    input  wire                         aref_end                   ,

    output wire                         sdram_cs_n                 ,
    output wire                         sdram_cas_n                ,
    output wire                         sdram_ras_n                ,
    output wire                         sdram_we_n                 ,
    output reg         [   1:0]         sdram_ba                   ,
    output reg         [  12:0]         sdram_addr                 ,
    output reg                          rd_en                      ,
    output reg                          wr_en                      ,
    output reg                          aref_en                    ,
    output wire                         sdram_cke                  ,

    inout  wire        [  15:0]         sdram_dq                    
);
reg                    [   4:0]         state                      ;
reg                    [   3:0]         sdram_cmd                  ;
parameter   IDLE    =   5'b00001,
            ARBIT   =   5'B00010,
            AREF    =   5'B00100,
            WRITE   =   5'B01000,
            READ    =   5'B10000;
    parameter                           NOP     =   4'b0111        ;
assign {sdram_cs_n,sdram_ras_n,sdram_cas_n,sdram_we_n} = sdram_cmd;
assign sdram_cke = 1'b1;
assign sdram_dq = (wr_sdram_en == 1'b1) ? wr_data : 16'hzzzz;
//*wr_en rd_en aref_en
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
        aref_en <= 1'b0;
    else if(state == ARBIT && aref_req == 1'b1)
        aref_en <= 1'b1;
    else if(aref_end == 1'b1)
        aref_en <= 1'b0;
end
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
        wr_en <= 1'b0;
    else if(state == ARBIT && aref_req == 1'b0 && wr_req == 1'b1)
        wr_en <= 1'b1;
    else if(wr_end == 1'b1)
        wr_en <= 1'b0;
end
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
        rd_en <= 1'b0;
    else if(state == ARBIT && aref_req == 1'b0 && wr_req == 1'b0 && rd_req == 1'b1)
        rd_en <= 1'b1;
    else if(rd_end == 1'b1)
        rd_en <= 1'b0;
end
//*state
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(sys_rst_n == 1'b0)
        state <= IDLE;
    else
    case (state)
        IDLE:
            if(init_end == 1'b1)
                state <= ARBIT;
            else
                state <= IDLE;
        ARBIT:
            if(aref_req == 1'b1)
                state <= AREF;
            else if(wr_req == 1'b1)
                state <= WRITE;
            else if(rd_req === 1'b1)
                state <= READ;
            else
                state <= ARBIT;
        AREF :
            if(aref_end == 1'b1)
                state <= ARBIT;
            else
                state <= state;
        WRITE:
            if(wr_end == 1'b1)
                state <= ARBIT;
            else
                state <= state;
        READ :
            if(rd_end == 1'b1)
                state <= ARBIT;
            else
                state <= state;
        default
            state <= IDLE;
    endcase
end
//*sdram_cmd
always @(*) begin
    case (state)
        IDLE :begin
            sdram_cmd   = init_cmd;
            sdram_ba    = init_ba;
            sdram_addr  = init_addr;
        end
        ARBIT:begin
            sdram_cmd   = NOP;
            sdram_ba    = 2'd0;
            sdram_addr  = 13'h1fff;
        end
        AREF :begin
            sdram_cmd   = aref_cmd;
            sdram_ba    = aref_ba;
            sdram_addr  = aref_addr;
        end
        WRITE:begin
            sdram_cmd   = wr_cmd;
            sdram_ba    = wr_ba;
            sdram_addr  = wr_addr;
        end
        READ :begin
            sdram_cmd   = rd_cmd;
            sdram_ba    = rd_ba;
            sdram_addr  = rd_addr;
        end
        default begin
            sdram_cmd   = NOP;
            sdram_ba    = 2'd0;
            sdram_addr  = 13'h1fff;
        end
    endcase
end
endmodule                                                           //sdram_arbit