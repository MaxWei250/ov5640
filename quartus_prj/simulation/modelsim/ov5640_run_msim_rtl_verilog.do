transcript on
if ![file isdirectory verilog_libs] {
	file mkdir verilog_libs
}

vlib verilog_libs/altera_ver
vmap altera_ver ./verilog_libs/altera_ver
vlog -vlog01compat -work altera_ver {e:/altera/13.1/quartus/eda/sim_lib/altera_primitives.v}

vlib verilog_libs/lpm_ver
vmap lpm_ver ./verilog_libs/lpm_ver
vlog -vlog01compat -work lpm_ver {e:/altera/13.1/quartus/eda/sim_lib/220model.v}

vlib verilog_libs/sgate_ver
vmap sgate_ver ./verilog_libs/sgate_ver
vlog -vlog01compat -work sgate_ver {e:/altera/13.1/quartus/eda/sim_lib/sgate.v}

vlib verilog_libs/altera_mf_ver
vmap altera_mf_ver ./verilog_libs/altera_mf_ver
vlog -vlog01compat -work altera_mf_ver {e:/altera/13.1/quartus/eda/sim_lib/altera_mf.v}

vlib verilog_libs/altera_lnsim_ver
vmap altera_lnsim_ver ./verilog_libs/altera_lnsim_ver
vlog -sv -work altera_lnsim_ver {e:/altera/13.1/quartus/eda/sim_lib/altera_lnsim.sv}

vlib verilog_libs/cycloneive_ver
vmap cycloneive_ver ./verilog_libs/cycloneive_ver
vlog -vlog01compat -work cycloneive_ver {e:/altera/13.1/quartus/eda/sim_lib/cycloneive_atoms.v}

if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+E:/FPGA_isp/ov5640_sobel/rtl/isp {E:/FPGA_isp/ov5640_sobel/rtl/isp/line_shift_RAM_8bit.v}
vlog -vlog01compat -work work +incdir+E:/FPGA_isp/ov5640_sobel/rtl/isp {E:/FPGA_isp/ov5640_sobel/rtl/isp/isp_top.v}
vlog -vlog01compat -work work +incdir+E:/FPGA_isp/ov5640_sobel/rtl/isp {E:/FPGA_isp/ov5640_sobel/rtl/isp/isp_1bit_dilation.v}
vlog -vlog01compat -work work +incdir+E:/FPGA_isp/ov5640_sobel/rtl/isp {E:/FPGA_isp/ov5640_sobel/rtl/isp/matrix3_3_generate_8bit.v}
vlog -vlog01compat -work work +incdir+E:/FPGA_isp/ov5640_sobel/rtl/isp {E:/FPGA_isp/ov5640_sobel/rtl/isp/matrix3_3_generate_1bit.v}
vlog -vlog01compat -work work +incdir+E:/FPGA_isp/ov5640_sobel/rtl/isp {E:/FPGA_isp/ov5640_sobel/rtl/isp/isp_1bit_erosion.v}
vlog -vlog01compat -work work +incdir+E:/FPGA_isp/ov5640_sobel/rtl/isp {E:/FPGA_isp/ov5640_sobel/rtl/isp/sobel_isp.v}
vlog -vlog01compat -work work +incdir+E:/FPGA_isp/ov5640_sobel/rtl/isp {E:/FPGA_isp/ov5640_sobel/rtl/isp/rgb_ycbcr.v}
vlog -vlog01compat -work work +incdir+E:/FPGA_isp/ov5640_sobel/rtl/ov5640 {E:/FPGA_isp/ov5640_sobel/rtl/ov5640/ov5640_top.v}
vlog -vlog01compat -work work +incdir+E:/FPGA_isp/ov5640_sobel/rtl/ov5640 {E:/FPGA_isp/ov5640_sobel/rtl/ov5640/ov5640_data.v}
vlog -vlog01compat -work work +incdir+E:/FPGA_isp/ov5640_sobel/rtl/ov5640 {E:/FPGA_isp/ov5640_sobel/rtl/ov5640/ov5640_cfg.v}
vlog -vlog01compat -work work +incdir+E:/FPGA_isp/ov5640_sobel/rtl/ov5640 {E:/FPGA_isp/ov5640_sobel/rtl/ov5640/i2c_ctrl.v}
vlog -vlog01compat -work work +incdir+E:/FPGA_isp/ov5640_sobel/rtl/sdram {E:/FPGA_isp/ov5640_sobel/rtl/sdram/sdram_write.v}
vlog -vlog01compat -work work +incdir+E:/FPGA_isp/ov5640_sobel/rtl/sdram {E:/FPGA_isp/ov5640_sobel/rtl/sdram/sdram_top.v}
vlog -vlog01compat -work work +incdir+E:/FPGA_isp/ov5640_sobel/rtl/sdram {E:/FPGA_isp/ov5640_sobel/rtl/sdram/sdram_read.v}
vlog -vlog01compat -work work +incdir+E:/FPGA_isp/ov5640_sobel/rtl/sdram {E:/FPGA_isp/ov5640_sobel/rtl/sdram/sdram_init.v}
vlog -vlog01compat -work work +incdir+E:/FPGA_isp/ov5640_sobel/rtl/sdram {E:/FPGA_isp/ov5640_sobel/rtl/sdram/sdram_ctrl.v}
vlog -vlog01compat -work work +incdir+E:/FPGA_isp/ov5640_sobel/rtl/sdram {E:/FPGA_isp/ov5640_sobel/rtl/sdram/sdram_arbit.v}
vlog -vlog01compat -work work +incdir+E:/FPGA_isp/ov5640_sobel/rtl/sdram {E:/FPGA_isp/ov5640_sobel/rtl/sdram/sdram_a_ref.v}
vlog -vlog01compat -work work +incdir+E:/FPGA_isp/ov5640_sobel/rtl/sdram {E:/FPGA_isp/ov5640_sobel/rtl/sdram/fifo_ctrl.v}
vlog -vlog01compat -work work +incdir+E:/FPGA_isp/ov5640_sobel/quartus_prj/IP_core/fifo_data {E:/FPGA_isp/ov5640_sobel/quartus_prj/IP_core/fifo_data/fifo_data.v}
vlog -vlog01compat -work work +incdir+E:/FPGA_isp/ov5640_sobel/rtl {E:/FPGA_isp/ov5640_sobel/rtl/tft_ctrl.v}
vlog -vlog01compat -work work +incdir+E:/FPGA_isp/ov5640_sobel/rtl {E:/FPGA_isp/ov5640_sobel/rtl/ov5640.v}
vlog -vlog01compat -work work +incdir+E:/FPGA_isp/ov5640_sobel/quartus_prj/IP_core/clk_gen {E:/FPGA_isp/ov5640_sobel/quartus_prj/IP_core/clk_gen/clk_gen.v}
vlog -vlog01compat -work work +incdir+E:/FPGA_isp/ov5640_sobel/quartus_prj/IP_core/sqrt {E:/FPGA_isp/ov5640_sobel/quartus_prj/IP_core/sqrt/sqrt.v}
vlog -vlog01compat -work work +incdir+E:/FPGA_isp/ov5640_sobel/quartus_prj/IP_core/shift_register_1bit {E:/FPGA_isp/ov5640_sobel/quartus_prj/IP_core/shift_register_1bit/shift_register_1bit.v}
vlog -vlog01compat -work work +incdir+E:/FPGA_isp/ov5640_sobel/quartus_prj/IP_core/ram {E:/FPGA_isp/ov5640_sobel/quartus_prj/IP_core/ram/blk_mem_gen_0.v}
vlog -vlog01compat -work work +incdir+E:/FPGA_isp/ov5640_sobel/quartus_prj/db {E:/FPGA_isp/ov5640_sobel/quartus_prj/db/clk_gen_altpll.v}

vlog -vlog01compat -work work +incdir+E:/FPGA_isp/ov5640_sobel/quartus_prj/../sim {E:/FPGA_isp/ov5640_sobel/quartus_prj/../sim/tb_matrix3_3_generate.v}
vlog -vlog01compat -work work +incdir+E:/FPGA_isp/ov5640_sobel/quartus_prj/IP_core/ram {E:/FPGA_isp/ov5640_sobel/quartus_prj/IP_core/ram/blk_mem_gen_0.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  tb_matrix3_3_generate

add wave *
view structure
view signals
run 1 us
