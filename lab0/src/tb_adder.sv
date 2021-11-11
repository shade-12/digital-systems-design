`timescale 1 ps / 1 ps

module tb_adder();
    reg [7:0] TB_SW;
    wire [3:0] TB_LEDR;
    adder adder(.SW(TB_SW), .LEDR(TB_LEDR));
    initial begin
        TB_SW = 0'b00000000;
        #10;
        BOGUS = 0'b00010001;
        #10;
        TB_SW = 0'b00100010;
        #10;
        TB_SW = 0'b01100011;
        #10;
    end
endmodule

