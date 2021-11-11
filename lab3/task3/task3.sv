module task3(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    logic rst_n, rdy, en, enabled, ct_wren, pt_wren;
	logic [7:0] ct_addr, ct_rddata, ct_wrdata, pt_addr, pt_rddata, pt_wrdata;

    assign rst_n = KEY[3];
	assign en = rdy & ~enabled;

    // Assign signals for testing purpose
    assign LEDR[0] = rdy;

    always @(posedge CLOCK_50) begin
		if (rst_n == 1'b0)
			enabled <= 1'b0;
		if (en == 1'b1)
			enabled <= 1'b1;
    end

    ct_mem ct(.address(ct_addr),
			  .clock(CLOCK_50),
              .data(ct_wrdata),
	          .wren(ct_wren),
			  .q(ct_rddata));

    pt_mem pt(.address(pt_addr),
	          .clock(CLOCK_50),
	          .data(pt_wrdata),
	          .wren(pt_wren),
	          .q(pt_rddata));

    arc4 a4(.clk(CLOCK_50), 
            .rst_n(rst_n),
            .en(en), 
            .rdy(rdy),
            .key({14'b0, SW[9:0]}),
            .ct_addr(ct_addr), 
            .ct_rddata(ct_rddata),
            .pt_addr(pt_addr), 
            .pt_rddata(pt_rddata), 
            .pt_wrdata(pt_wrdata),
            .pt_wren(pt_wren));

endmodule: task3
