module arc4(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            input logic [23:0] key,
            output logic [7:0] ct_addr, input logic [7:0] ct_rddata,
            output logic [7:0] pt_addr, input logic [7:0] pt_rddata, output logic [7:0] pt_wrdata, output logic pt_wren);

    logic s_wren, rdy_out,
          en_i, en_k, en_p, 
          rdy_i, rdy_k, rdy_p, 
          wren_i, wren_k, wren_p, 
          enabled_i, enabled_k, enabled_p,
          done_init, done_ksa, done_prga;
    logic [1:0] state;
    logic [7:0] s_addr, s_wrdata, s_rddata, addr_i, wrdata_i, addr_k, wrdata_k, addr_p, wrdata_p;

    `define IDLE  2'b00
    `define START 2'b01

    assign rdy = rdy_out;

    // Done signals for each module
    assign done_init = rdy_i & enabled_i;
    assign done_ksa = rdy_k & enabled_k;
    assign done_prga = rdy_p & enabled_p;

	// en signals to trigger each module
	assign en_i = rdy_i & ~enabled_i;
    assign en_k = rdy_k & ~enabled_k & done_init;
	assign en_p = rdy_p & ~enabled_p & done_init & done_ksa;

    always @(posedge clk) begin
        if (rst_n == 1'b0) begin
            rdy_out <= 1'b0;
            state <= `IDLE;
        end else
            case (state)
                `IDLE: begin
                    rdy_out <= 1'b1;
                    if (en == 1'b1) begin
                        rdy_out <= 1'b0;
                        state <= `START;
                        enabled_i <= 1'b0;
                        enabled_k <= 1'b0;
                        enabled_p <= 1'b0;
                    end
                end
                `START: begin
                    rdy_out <= 1'b0;
                    if (en_i == 1'b1)
                        enabled_i <= 1'b1;
                    if (en_k == 1'b1)
                        enabled_k <= 1'b1;
                    if (en_p == 1'b1)
                        enabled_p <= 1'b1;
                    if (done_init & done_ksa & done_prga)
                        state <= `IDLE;
                end
                default: begin
                    rdy_out <= 1'b0;
                    state <= `IDLE;
                end
            endcase
    end

	// Combinational logic to connect the correct wires to s_mem module
    always @(*) begin
		case({ done_init, done_ksa, done_prga })
			// Done initialize the s array, running key-scheduling algorithm
			3'b100: begin
				s_addr = addr_k;
				s_wrdata = wrdata_k;
				s_wren = wren_k;
			end
			// Done key-scheduling algorithm, running pseudo-random generation algorithm
			3'b110: begin
				s_addr = addr_p;
				s_wrdata = wrdata_p;
				s_wren = wren_p;
			end
			// Start initializing the s array or done everything
			default: begin
				s_addr = addr_i;
				s_wrdata = wrdata_i;
				s_wren = wren_i;
			end
		endcase
    end

    s_mem s(.address(s_addr),
            .clock(clk),
            .data(s_wrdata),
            .wren(s_wren),
            .q(s_rddata));

    init i(.clk(clk),
           .rst_n(rst_n),
           .en(en_i),
           .rdy(rdy_i),
           .addr(addr_i),
           .wrdata(wrdata_i),
           .wren(wren_i));

    ksa k(.clk(clk),
          .rst_n(rst_n),
          .en(en_k),
          .rdy(rdy_k),
          .key(key),
          .addr(addr_k),
          .rddata(s_rddata),
          .wrdata(wrdata_k),
          .wren(wren_k));

    prga p(.clk(clk),
           .rst_n(rst_n),
           .en(en_p), 
           .rdy(rdy_p),
           .key(key),
           .s_addr(addr_p),
           .s_rddata(s_rddata),
           .s_wrdata(wrdata_p),
           .s_wren(wren_p),
           .ct_addr(ct_addr),
           .ct_rddata(ct_rddata),
           .pt_addr(pt_addr),
           .pt_rddata(pt_rddata),
           .pt_wrdata(pt_wrdata),
           .pt_wren(pt_wren));

endmodule: arc4