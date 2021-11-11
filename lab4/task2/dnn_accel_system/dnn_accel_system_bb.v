
module dnn_accel_system (
	clk_clk,
	hex_export,
	reset_reset_n,
	sdram_clk_clk,
	pll_locked_export,
	sdram_addr,
	sdram_ba,
	sdram_cas_n,
	sdram_cke,
	sdram_cs_n,
	sdram_dq,
	sdram_dqm,
	sdram_ras_n,
	sdram_we_n);	

	input		clk_clk;
	output	[6:0]	hex_export;
	input		reset_reset_n;
	output		sdram_clk_clk;
	output		pll_locked_export;
	output	[12:0]	sdram_addr;
	output	[1:0]	sdram_ba;
	output		sdram_cas_n;
	output		sdram_cke;
	output		sdram_cs_n;
	inout	[15:0]	sdram_dq;
	output	[1:0]	sdram_dqm;
	output		sdram_ras_n;
	output		sdram_we_n;
endmodule
