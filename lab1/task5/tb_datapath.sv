module tb_datapath();

    logic slow_clock, fast_clock, resetb, load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2, load_dcard3, err;
    logic [3:0] pcard3_out, pscore_out, dscore_out;
    logic [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;

    datapath dut(.*);

    initial begin
        fast_clock = 0;
        forever #5 fast_clock = ~fast_clock;
    end

    initial begin
        slow_clock = 0;
        forever #5 slow_clock = ~slow_clock;
    end

    task validator;
        input [31:0] index;
        input [3:0] e_pcard3_out, e_pscore_out, e_dscore_out;
        input [6:0] e_HEX5, e_HEX4, e_HEX3, e_HEX2, e_HEX1, e_HEX0;
        begin
            $display("TEST %d", index);
            if (tb_datapath.dut.pcard3_out !== e_pcard3_out) begin
                $display("ERROR A: Expected pcard3_out is %b, actual pcard3_out is %b", e_pcard3_out, tb_datapath.dut.pcard3_out);
                err = 1'b1;
            end
            if (tb_datapath.dut.pscore_out !== e_pscore_out) begin
                $display("ERROR B: Expected pscore_out is %b, actual pscore_out is %b", e_pscore_out, tb_datapath.dut.pscore_out);
                err = 1'b1;
            end
            if (tb_datapath.dut.dscore_out !== e_dscore_out) begin
                $display("ERROR C: Expected dscore_out is %b, actual dscore_out is %b", e_dscore_out, tb_datapath.dut.dscore_out);
                err = 1'b1;
            end
            if (tb_datapath.dut.HEX5 !== e_HEX5) begin
                $display("ERROR D: Expected HEX5 is %b, actual HEX5 is %b", e_HEX5, tb_datapath.dut.HEX5);
                err = 1'b1;
            end
            if (tb_datapath.dut.HEX4 !== e_HEX4) begin
                $display("ERROR E: Expected HEX4 is %b, actual HEX4 is %b", e_HEX4, tb_datapath.dut.HEX4);
                err = 1'b1;
            end
            if (tb_datapath.dut.HEX3 !== e_HEX3) begin
                $display("ERROR F: Expected HEX3 is %b, actual HEX3 is %b", e_HEX3, tb_datapath.dut.HEX3);
                err = 1'b1;
            end
            if (tb_datapath.dut.HEX2 !== e_HEX2) begin
                $display("ERROR G: Expected HEX2 is %b, actual HEX2 is %b", e_HEX2, tb_datapath.dut.HEX2);
                err = 1'b1;
            end
            if (tb_datapath.dut.HEX1 !== e_HEX1) begin
                $display("ERROR H: Expected HEX1 is %b, actual HEX1 is %b", e_HEX1, tb_datapath.dut.HEX1);
                err = 1'b1;
            end
            if (tb_datapath.dut.HEX0 !== e_HEX0) begin
                $display("ERROR I: Expected HEX0 is %b, actual HEX0 is %b", e_HEX0, tb_datapath.dut.HEX0);
                err = 1'b1;
            end
        end
    endtask

    `define NONE   7'b1111111
    `define ACE    7'b0001000
    `define TWO    7'b0100100     
    `define THREE  7'b0110000
    `define FOUR   7'b0011001
    `define FIVE   7'b0010010
    `define SIX    7'b0000010
    `define SEVEN  7'b1111000
    `define EIGHT  7'b0000000
    `define NINE   7'b0010000
    `define TEN    7'b1000000
    `define JACK   7'b1100001
    `define QUEEN  7'b0011000
    `define KING   7'b0001001

    initial begin
        err = 1'b0;

        validator(0, 4'dx, 4'dx, 4'dx, 7'bx, 7'bx, 7'bx, 7'bx, 7'bx, 7'bx);

        // Case 1: resetb is asserted
        resetb = 1'b0;
        #10;
        validator(1, 4'd0, 4'd0, 4'd0, `NONE, `NONE, `NONE, `NONE, `NONE, `NONE);

        // Case 2: Load player card 1
        resetb = 1'b1;
        load_pcard1 = 1'b1; 
        #20;
        validator(2, 4'd0, 4'd2, 4'd0, `NONE, `NONE, `NONE, `NONE, `NONE, `TWO);

        // Case 3: Load dealer card 1
        load_pcard1 = 1'b0;
        load_dcard1 = 1'b1; 
        #10;
        validator(3, 4'd0, 4'd2, 4'd3, `NONE, `NONE, `THREE, `NONE, `NONE, `TWO);

        // Case 4: Load player card 2
        load_dcard1 = 1'b0;
        load_pcard2 = 1'b1; 
        #10;
        validator(4, 4'd0, 4'd6, 4'd3, `NONE, `NONE, `THREE, `NONE, `FOUR, `TWO);

        // Case 5: Load dealer card 2
        load_pcard2 = 1'b0;
        load_dcard2 = 1'b1; 
        #10;
        validator(5, 4'd0, 4'd6, 4'd8, `NONE, `FIVE, `THREE, `NONE, `FOUR, `TWO);

        // Case 6: Load player card 3
        load_dcard2 = 1'b0;
        load_pcard3 = 1'b1; 
        #10;
        validator(6, 4'd6, 4'd2, 4'd8, `NONE, `FIVE, `THREE, `SIX, `FOUR, `TWO);

        // Case 7: Load banker card 3
        load_pcard3 = 1'b0;
        load_dcard3 = 1'b1; 
        #10;
        validator(7, 4'd6, 4'd2, 4'd5, `SEVEN, `FIVE, `THREE, `SIX, `FOUR, `TWO);

        // Case 8: resetb is asserted
        load_dcard3 = 1'b0;
        resetb = 1'b0;
        @(posedge slow_clock)
        resetb = 1'b1;
        @(posedge slow_clock)
        validator(8, 4'd0, 4'd0, 4'd0, `NONE, `NONE, `NONE, `NONE, `NONE, `NONE);

        // Case 9: Load player card 1 and load dealer card 1 (both cards should have the same value)
        wait (tb_datapath.dut.dc.dealer_card == 4'd1 && slow_clock == 1'b1)
        load_pcard1 = 1'b1; load_dcard1 = 1'b1;
        @(posedge slow_clock)
        load_pcard1 = 1'b0; load_dcard1 = 1'b0;
        @(posedge slow_clock)
        validator(9, 4'd0, 4'd1, 4'd1, `NONE, `NONE, `ACE, `NONE, `NONE, `ACE);

        // Case 10: Load player card 2 and load dealer card 2 (both cards should have the same value)
        wait (tb_datapath.dut.dc.dealer_card == 4'd8 && slow_clock == 1'b1)
        load_pcard2 = 1'b1; load_dcard2 = 1'b1;
        @(posedge slow_clock)
        load_pcard2 = 1'b0; load_dcard2 = 1'b0;
        @(posedge slow_clock)
        validator(10, 4'd0, 4'd9, 4'd9, `NONE, `EIGHT, `ACE, `NONE, `EIGHT, `ACE);

        // ===========================================================================================================================

        // Case 11: resetb is asserted
        resetb = 1'b0;
        @(posedge slow_clock)
        resetb = 1'b1;
        @(posedge slow_clock)
        validator(11, 4'd0, 4'd0, 4'd0, `NONE, `NONE, `NONE, `NONE, `NONE, `NONE);

        // Case 12: Load player card 1
        wait (tb_datapath.dut.dc.dealer_card == 4'd11 && slow_clock == 1'b1)
        load_pcard1 = 1'b1; 
        @(posedge slow_clock)
        load_pcard1 = 1'b0;
        @(posedge slow_clock)
        validator(12, 4'd0, 4'd0, 4'd0, `NONE, `NONE, `NONE, `NONE, `NONE, `JACK);

        // Case 13: Load dealer card 1
        wait (tb_datapath.dut.dc.dealer_card == 4'd5 && slow_clock == 1'b1)
        load_dcard1 = 1'b1; 
        @(posedge slow_clock)
        load_dcard1 = 1'b0;
        @(posedge slow_clock)
        validator(13, 4'd0, 4'd0, 4'd5, `NONE, `NONE, `FIVE, `NONE, `NONE, `JACK);

        // Case 14: Load player card 2
        wait (tb_datapath.dut.dc.dealer_card == 4'd13 && slow_clock == 1'b1)
        load_pcard2 = 1'b1; 
        @(posedge slow_clock)
        load_pcard2 = 1'b0;
        @(posedge slow_clock)
        validator(14, 4'd0, 4'd0, 4'd5, `NONE, `NONE, `FIVE, `NONE, `KING, `JACK);

        // Case 15: Load dealer card 2
        wait (tb_datapath.dut.dc.dealer_card == 4'd12 && slow_clock == 1'b1)
        load_dcard2 = 1'b1; 
        @(posedge slow_clock)
        load_dcard2 = 1'b0;
        @(posedge slow_clock)
        validator(15, 4'd0, 4'd0, 4'd5, `NONE, `QUEEN, `FIVE, `NONE, `KING, `JACK);

        // Case 16: Load player card 3
        wait (tb_datapath.dut.dc.dealer_card == 4'd9 && slow_clock == 1'b1)
        load_pcard3 = 1'b1; 
        @(posedge slow_clock)
        load_pcard3 = 1'b0;
        @(posedge slow_clock)
        validator(16, 4'd9, 4'd9, 4'd5, `NONE, `QUEEN, `FIVE, `NINE, `KING, `JACK);

        // Case 17: Load dealer card 3
        wait (tb_datapath.dut.dc.dealer_card == 4'd10 && slow_clock == 1'b1)
        load_dcard3 = 1'b1; 
        @(posedge slow_clock)
        load_dcard3 = 1'b0;
        @(posedge slow_clock)
        validator(17, 4'd9, 4'd9, 4'd5, `TEN, `QUEEN, `FIVE, `NINE, `KING, `JACK);

        // Case 18: resetb is asserted
        resetb = 1'b0;
        @(posedge slow_clock)
        resetb = 1'b1;
        @(posedge slow_clock)
        validator(18, 4'd0, 4'd0, 4'd0, `NONE, `NONE, `NONE, `NONE, `NONE, `NONE);

        if (~err) begin
            $display("SUCCESS: All tests passed.");
        end
        $stop;
    end
						
endmodule

