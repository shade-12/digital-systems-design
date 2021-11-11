module task2(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    logic rst_n, en_i, en_k, rdy_i, rdy_k, wren, wren_i, wren_k, enabled_i, enabled_k;
    logic [7:0] addr, addr_i, addr_k, wrdata, wrdata_i, wrdata_k, q;

    assign rst_n = KEY[3];
    assign en_i = rdy_i & ~enabled_i;
    assign en_k = rdy_k & ~enabled_k && rdy_i && enabled_i;

    assign { addr, wrdata, wren } = (en_k | enabled_k) ? { addr_k, wrdata_k, wren_k } : { addr_i, wrdata_i, wren_i };

    always @(posedge CLOCK_50) begin
       if (rst_n == 1'b0) begin
            enabled_i <= 1'b0;
            enabled_k <= 1'b0;
       end
       if (en_i == 1'b1)
            enabled_i <= 1'b1;
        // Assert enabled_k when rdy_i rise for the second time
        if (en_k == 1'b1)
            enabled_k <= 1'b1;
    end

    init i(.clk(CLOCK_50),
           .rst_n(rst_n),
           .en(en_i),
           .rdy(rdy_i),
           .addr(addr_i),
           .wrdata(wrdata_i),
           .wren(wren_i));

    ksa k(.clk(CLOCK_50),
          .rst_n(rst_n),
          .en(en_k),
          .rdy(rdy_k),
          .key({14'b0, SW[9:0]}),
          .addr(addr_k),
          .rddata(q),
          .wrdata(wrdata_k),
          .wren(wren_k));

    s_mem s(.address(addr),
            .clock(CLOCK_50),
            .data(wrdata),
            .wren(wren),
            .q(q));

endmodule: task2
