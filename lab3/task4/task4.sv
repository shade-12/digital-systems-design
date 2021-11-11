module task4(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    logic ct_wren, rdy, en, enabled, key_valid, done, rst_n;
    logic [7:0] ct_addr, ct_rddata, ct_wrdata;
    logic [23:0] key;
    logic [41:0] HEX_OUT;
    genvar i;

    assign rst_n = KEY[3];
    assign { HEX5, HEX4, HEX3, HEX2, HEX1, HEX0 } = HEX_OUT;
    assign en = rdy & ~enabled;
    assign done = rdy & enabled;

    // Assign signal for testing purpose
    assign LEDR[0] = rdy;

    always @(posedge CLOCK_50) begin
		if (rst_n == 1'b0)
			enabled <= 1'b0;
		if (en == 1'b1)
			enabled <= 1'b1;
    end

    generate
        for (i = 0; i < 6; i = i + 1) begin: s7
            seg7 S7(key[i*4+3:i*4], done, key_valid, HEX_OUT[i*7+6:i*7]);
        end
    endgenerate

    ct_mem ct(.address(ct_addr),
			  .clock(CLOCK_50),
              .data(ct_wrdata),
	          .wren(ct_wren),
			  .q(ct_rddata));

    crack c(.clk(CLOCK_50), 
            .rst_n(rst_n),
            .en(en),
            .rdy(rdy),
            .key(key),
            .key_valid(key_valid),
            .ct_addr(ct_addr),
            .ct_rddata(ct_rddata));

endmodule: task4
