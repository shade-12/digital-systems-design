module task1(input logic CLOCK_50, input logic [3:0] KEY, input logic [9:0] SW,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [9:0] LEDR);

    logic rst_n, en, rdy, wren, enabled;
    logic [7:0] addr, wrdata, q;

    assign rst_n = KEY[3];
    assign en = rdy & ~enabled;

    always @(posedge CLOCK_50) begin
       if (rst_n == 1'b0)
              enabled <= 1'b0;
       if (en == 1'b1)
              enabled <= 1'b1;
    end

    init i(.clk(CLOCK_50),
           .rst_n(rst_n),
           .en(en),
           .rdy(rdy),
           .addr(addr),
           .wrdata(wrdata),
           .wren(wren));

    s_mem s(.address(addr),
            .clock(CLOCK_50),
            .data(wrdata),
            .wren(wren),
            .q(q));

endmodule: task1
