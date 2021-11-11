module tb_card7seg();
// Your testbench goes here. Make sure your tests exercise the entire design
// in the .sv file.  Note that in our tests the simulator will exit after
// 10,000 ticks (equivalent to "initial #10000 $finish();").

    logic [3:0] SW;
    logic [6:0] HEX0;
    logic err;

    card7seg dut(.*);

    initial begin
        err = 1'b0;

        // Case 1: SW is undefined
        if (tb_card7seg.dut.HEX0 !== 7'bx) begin
            $display("ERROR 1: Expected HEX0 is %b, actual HEX0 is %b", 7'bx, tb_card7seg.dut.HEX0);
            err = 1'b1;
        end

        // Case 2: SW is 4'd0 (NONE)
        SW = 4'd0;
        #1;
        if (tb_card7seg.dut.HEX0 !== 7'b1111111) begin
            $display("ERROR 2: Expected HEX0 is %b, actual HEX0 is %b", 7'b1111111, tb_card7seg.dut.HEX0);
            err = 1'b1;
        end

        // Case 3: SW is 4'd1 (ACE)
        SW = 4'd1;
        #1;
        if (tb_card7seg.dut.HEX0 !== 7'b0001000) begin
            $display("ERROR 3: Expected HEX0 is %b, actual HEX0 is %b", 7'b0001000, tb_card7seg.dut.HEX0);
            err = 1'b1;
        end

        // Case 4: SW is 4'd2 (TWO)
        SW = 4'd2;
        #1;
        if (tb_card7seg.dut.HEX0 !== 7'b0100100) begin
            $display("ERROR 4: Expected HEX0 is %b, actual HEX0 is %b", 7'b0100100, tb_card7seg.dut.HEX0);
            err = 1'b1;
        end

        // Case 5: SW is 4'd3 (THREE)
        SW = 4'd3;
        #1;
        if (tb_card7seg.dut.HEX0 !== 7'b0110000) begin
            $display("ERROR 5: Expected HEX0 is %b, actual HEX0 is %b", 7'b0110000, tb_card7seg.dut.HEX0);
            err = 1'b1;
        end

        // Case 6: SW is 4'd4 (FOUR)
        SW = 4'd4;
        #1;
        if (tb_card7seg.dut.HEX0 !== 7'b0011001) begin
            $display("ERROR 6: Expected HEX0 is %b, actual HEX0 is %b", 7'b0011001, tb_card7seg.dut.HEX0);
            err = 1'b1;
        end

        // Case 7: SW is 4'd5 (FIVE)
        SW = 4'd5;
        #1;
        if (tb_card7seg.dut.HEX0 !== 7'b0010010) begin
            $display("ERROR 7: Expected HEX0 is %b, actual HEX0 is %b", 7'b0010010, tb_card7seg.dut.HEX0);
            err = 1'b1;
        end

        // Case 8: SW is 4'd6 (SIX)
        SW = 4'd6;
        #1;
        if (tb_card7seg.dut.HEX0 !== 7'b0000010) begin
            $display("ERROR 8: Expected HEX0 is %b, actual HEX0 is %b", 7'b0000010, tb_card7seg.dut.HEX0);
            err = 1'b1;
        end

        // Case 9: SW is 4'd7 (SEVEN)
        SW = 4'd7;
        #1;
        if (tb_card7seg.dut.HEX0 !== 7'b1111000) begin
            $display("ERROR 9: Expected HEX0 is %b, actual HEX0 is %b", 7'b1111000, tb_card7seg.dut.HEX0);
            err = 1'b1;
        end

        // Case 10: SW is 4'd8 (EIGHT)
        SW = 4'd8;
        #1;
        if (tb_card7seg.dut.HEX0 !== 7'b0000000) begin
            $display("ERROR 10: Expected HEX0 is %b, actual HEX0 is %b", 7'b0000000, tb_card7seg.dut.HEX0);
            err = 1'b1;
        end
        
        // Case 11: SW is 4'd9 (NINE)
        SW = 4'd9;
        #1;
        if (tb_card7seg.dut.HEX0 !== 7'b0010000) begin
            $display("ERROR 11: Expected HEX0 is %b, actual HEX0 is %b", 7'b0010000, tb_card7seg.dut.HEX0);
            err = 1'b1;
        end

        // Case 12: SW is 4'd10 (TEN)
        SW = 4'd10;
        #1;
        if (tb_card7seg.dut.HEX0 !== 7'b1000000) begin
            $display("ERROR 12: Expected HEX0 is %b, actual HEX0 is %b", 7'b1000000, tb_card7seg.dut.HEX0);
            err = 1'b1;
        end

        // Case 13: SW is 4'd11 (JACK)
        SW = 4'd11;
        #1;
        if (tb_card7seg.dut.HEX0 !== 7'b1100001) begin
            $display("ERROR 13: Expected HEX0 is %b, actual HEX0 is %b", 7'b1100001, tb_card7seg.dut.HEX0);
            err = 1'b1;
        end

        // Case 14: SW is 4'd12 (QUEEN)
        SW = 4'd12;
        #1;
        if (tb_card7seg.dut.HEX0 !== 7'b0011000) begin
            $display("ERROR 14: Expected HEX0 is %b, actual HEX0 is %b", 7'b0011000, tb_card7seg.dut.HEX0);
            err = 1'b1;
        end

        // Case 15: SW is 4'd13 (KING)
        SW = 4'd13;
        #1;
        if (tb_card7seg.dut.HEX0 !== 7'b0001001) begin
            $display("ERROR 15: Expected HEX0 is %b, actual HEX0 is %b", 7'b0001001, tb_card7seg.dut.HEX0);
            err = 1'b1;
        end

        // Case 16: SW is 4'd14
        SW = 4'd14;
        #1;
        if (tb_card7seg.dut.HEX0 !== 7'b1111111) begin
            $display("ERROR 16: Expected HEX0 is %b, actual HEX0 is %b", 7'b1111111, tb_card7seg.dut.HEX0);
            err = 1'b1;
        end

        // Case 17: SW is 4'd15
        SW = 4'd15;
        #1;
        if (tb_card7seg.dut.HEX0 !== 7'b1111111) begin
            $display("ERROR 17: Expected HEX0 is %b, actual HEX0 is %b", 7'b1111111, tb_card7seg.dut.HEX0);
            err = 1'b1;
        end

        if (~err) begin
            $display("SUCCESS: All tests passed.");
        end
        $stop;
    end
						
endmodule

