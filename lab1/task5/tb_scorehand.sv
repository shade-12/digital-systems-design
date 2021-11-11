module tb_scorehand();

    logic [3:0] card1, card2, card3, total;
    logic err;

    scorehand dut(.*);

    initial begin
        err = 1'b0;

        // Case 1: card1, card2, card3 are 4'd0
        card1 = 4'd0; card2 = 4'd0; card3 = 4'd0;
        #1;
        if (tb_scorehand.dut.total !== 4'b0) begin
            $display("ERROR 1: Expected total is %b, actual total is %b", 4'b0, tb_scorehand.dut.total);
            err = 1'b1;
        end

        // Case 2: card1 is 4'd1 (ACE), card2, card3 are 4'd0
        card1 = 4'd1; card2 = 4'd0; card3 = 4'd0;
        #1;
        if (tb_scorehand.dut.total !== 4'd1) begin
            $display("ERROR 2: Expected total is %b, actual total is %b", 4'd1, tb_scorehand.dut.total);
            err = 1'b1;
        end

        // Case 3: card1 is 4'd10 (TEN), card2, card3 are 4'd0
        card1 = 4'd10; card2 = 4'd0; card3 = 4'd0;
        #1;
        if (tb_scorehand.dut.total !== 4'd0) begin
            $display("ERROR 3: Expected total is %b, actual total is %b", 4'd0, tb_scorehand.dut.total);
            err = 1'b1;
        end

        // Case 4: card1 is 4'd9 (NINE), card2, card3 are 4'd0
        card1 = 4'd9; card2 = 4'd0; card3 = 4'd0;
        #1;
        if (tb_scorehand.dut.total !== 4'd9) begin
            $display("ERROR 4: Expected total is %b, actual total is %b", 4'd9, tb_scorehand.dut.total);
            err = 1'b1;
        end

        // Case 5: card1 is 4'd11 (JACK), card2, card3 are 4'd0
        card1 = 4'd11; card2 = 4'd0; card3 = 4'd0;
        #1;
        if (tb_scorehand.dut.total !== 4'd0) begin
            $display("ERROR 5: Expected total is %b, actual total is %b", 4'd0, tb_scorehand.dut.total);
            err = 1'b1;
        end

        // Case 6: card1 is 4'd3 (THREE), card2, card3 are 4'd0
        card1 = 4'd3; card2 = 4'd0; card3 = 4'd0;
        #1;
        if (tb_scorehand.dut.total !== 4'd3) begin
            $display("ERROR 6: Expected total is %b, actual total is %b", 4'd3, tb_scorehand.dut.total);
            err = 1'b1;
        end

        // Case 7: card1 is 4'd12 (QUEEN), card2, card3 are 4'd0
        card1 = 4'd12; card2 = 4'd0; card3 = 4'd0;
        #1;
        if (tb_scorehand.dut.total !== 4'd0) begin
            $display("ERROR 7: Expected total is %b, actual total is %b", 4'd0, tb_scorehand.dut.total);
            err = 1'b1;
        end

        // Case 8: card2 is 4'd7 (SEVEN), card1, card3 are 4'd0
        card1 = 4'd0; card2 = 4'd7; card3 = 4'd0;
        #1;
        if (tb_scorehand.dut.total !== 4'd7) begin
            $display("ERROR 8: Expected total is %b, actual total is %b", 4'd7, tb_scorehand.dut.total);
            err = 1'b1;
        end

        // Case 9: card3 is 4'd13 (KING), card1, card2 are 4'd0
        card1 = 4'd0; card2 = 4'd0; card3 = 4'd13;
        #1;
        if (tb_scorehand.dut.total !== 4'd0) begin
            $display("ERROR 9: Expected total is %b, actual total is %b", 4'd0, tb_scorehand.dut.total);
            err = 1'b1;
        end

        // Case 10: 
        card1 = 4'd2; card2 = 4'd3; card3 = 4'd7;
        #1;
        if (tb_scorehand.dut.total !== 4'd2) begin
            $display("ERROR 10: Expected total is %b, actual total is %b", 4'd2, tb_scorehand.dut.total);
            err = 1'b1;
        end

        // Case 11: 
        card1 = 4'd9; card2 = 4'd9; card3 = 4'd0;
        #1;
        if (tb_scorehand.dut.total !== 4'd8) begin
            $display("ERROR 11: Expected total is %b, actual total is %b", 4'd8, tb_scorehand.dut.total);
            err = 1'b1;
        end

        // Case 12: 
        card1 = 4'd8; card2 = 4'd8; card3 = 4'd0;
        #1;
        if (tb_scorehand.dut.total !== 4'd6) begin
            $display("ERROR 12: Expected total is %b, actual total is %b", 4'd6, tb_scorehand.dut.total);
            err = 1'b1;
        end

        // Case 13: 
        card1 = 4'd13; card2 = 4'd13; card3 = 4'd13;
        #1;
        if (tb_scorehand.dut.total !== 4'd0) begin
            $display("ERROR 13: Expected total is %b, actual total is %b", 4'd0, tb_scorehand.dut.total);
            err = 1'b1;
        end

        // Case 14: 
        card1 = 4'd2; card2 = 4'd10; card3 = 4'd9;
        #1;
        if (tb_scorehand.dut.total !== 4'd1) begin
            $display("ERROR 14: Expected total is %b, actual total is %b", 4'd1, tb_scorehand.dut.total);
            err = 1'b1;
        end

        // Case 15: all undefined case
        card1 = 4'dx; card2 = 4'dx; card3 = 4'dx;
        #1;
        if (tb_scorehand.dut.total !== 4'dx) begin
            $display("ERROR 15: Expected total is %b, actual total is %b", 4'dx, tb_scorehand.dut.total);
            err = 1'b1;
        end

        // Case 16: two undefined case
        card1 = 4'dx; card2 = 4'd2; card3 = 4'dx;
        #1;
        if (tb_scorehand.dut.total !== 4'dx) begin
            $display("ERROR 16: Expected total is %b, actual total is %b", 4'dx, tb_scorehand.dut.total);
            err = 1'b1;
        end

        // Case 17: one undefined case
        card1 = 4'dx; card2 = 4'd2; card3 = 4'd5;
        #1;
        if (tb_scorehand.dut.total !== 4'dx) begin
            $display("ERROR 17: Expected total is %b, actual total is %b", 4'dx, tb_scorehand.dut.total);
            err = 1'b1;
        end

        // Case 18:
        card1 = 4'd5; card2 = 4'd5; card3 = 4'd0;
        #1;
        if (tb_scorehand.dut.total !== 4'd0) begin
            $display("ERROR 18: Expected total is %b, actual total is %b", 4'd0, tb_scorehand.dut.total);
            err = 1'b1;
        end

        if (~err) begin
            $display("SUCCESS: All tests passed.");
        end
        $stop;
    end
						
endmodule

