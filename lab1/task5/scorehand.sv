module scorehand(input [3:0] card1, input [3:0] card2, input [3:0] card3, output [3:0] total);
    wire [3:0] cval1, cval2, cval3;
    wire [4:0] temp;

    assign cval1 = (card1 <= 4'd9) ? card1 : 4'd0;
    assign cval2 = (card2 <= 4'd9) ? card2 : 4'd0;
    assign cval3 = (card3 <= 4'd9) ? card3 : 4'd0;
    assign temp = cval1 + cval2 + cval3;
    mod10 calc(temp, total);

endmodule
