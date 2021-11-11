module tb_task5();

    logic CLOCK_50, err;
    logic [3:0] KEY;
    logic [9:0] LEDR;
    logic [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;

    task5 dut(.*);

    initial begin
        CLOCK_50 = 0;
        forever #5 CLOCK_50 = ~CLOCK_50;
    end

    task validator;
        input [31:0] index;
        input [3:0] exp_state;
        input e_pwin, e_dwin;
        input [3:0] e_pscore, e_dscore;
        input [6:0] e_HEX5, e_HEX4, e_HEX3, e_HEX2, e_HEX1, e_HEX0;
        begin
            $display("TEST %d", index);
            if (tb_task5.dut.sm.present_state !== exp_state) begin
                $display("ERROR A: Expected present_state is %b, actual present_state is %b", exp_state, tb_task5.dut.sm.present_state);
                err = 1'b1;
            end
            if (tb_task5.dut.LEDR[8] !== e_pwin) begin
                $display("ERROR B: Expected LEDR[8] is %b, actual LEDR[8] is %b", e_pwin, tb_task5.dut.LEDR[8]);
                err = 1'b1;
            end
            if (tb_task5.dut.LEDR[9] !== e_dwin) begin
                $display("ERROR C: Expected LEDR[9] is %b, actual LEDR[9] is %b", e_dwin, tb_task5.dut.LEDR[9]);
                err = 1'b1;
            end
            if (tb_task5.dut.LEDR[3:0] !== e_pscore) begin
                $display("ERROR D: Expected LEDR[3:0] is %b, actual LEDR[3:0] is %b", e_pscore, tb_task5.dut.LEDR[3:0]);
                err = 1'b1;
            end
            if (tb_task5.dut.LEDR[7:4] !== e_dscore) begin
                $display("ERROR E: Expected LEDR[7:4] is %b, actual LEDR[7:4] is %b", e_dscore, tb_task5.dut.LEDR[7:4]);
                err = 1'b1;
            end
            if (tb_task5.dut.HEX5 !== e_HEX5) begin
                $display("ERROR F: Expected HEX5 is %b, actual HEX5 is %b", e_HEX5, tb_task5.dut.HEX5);
                err = 1'b1;
            end
            if (tb_task5.dut.HEX4 !== e_HEX4) begin
                $display("ERROR G: Expected HEX4 is %b, actual HEX4 is %b", e_HEX4, tb_task5.dut.HEX4);
                err = 1'b1;
            end
            if (tb_task5.dut.HEX3 !== e_HEX3) begin
                $display("ERROR H: Expected HEX3 is %b, actual HEX3 is %b", e_HEX3, tb_task5.dut.HEX3);
                err = 1'b1;
            end
            if (tb_task5.dut.HEX2 !== e_HEX2) begin
                $display("ERROR I: Expected HEX2 is %b, actual HEX2 is %b", e_HEX2, tb_task5.dut.HEX2);
                err = 1'b1;
            end
            if (tb_task5.dut.HEX1 !== e_HEX1) begin
                $display("ERROR J: Expected HEX1 is %b, actual HEX1 is %b", e_HEX1, tb_task5.dut.HEX1);
                err = 1'b1;
            end
            if (tb_task5.dut.HEX0 !== e_HEX0) begin
                $display("ERROR K: Expected HEX0 is %b, actual HEX0 is %b", e_HEX0, tb_task5.dut.HEX0);
                err = 1'b1;
            end
        end
    endtask

    `define WAIT      4'b0000
    `define LOAD_P1   4'b0001
    `define LOAD_P2   4'b0010
    `define LOAD_P3   4'b0011
    `define LOAD_D1   4'b0100
    `define LOAD_D2   4'b0101
    `define LOAD_D3   4'b0110
    `define CALC_RES  4'b0111
    `define P_WIN     4'b1000
    `define D_WIN     4'b1001
    `define TIE       4'b1010

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
        // validator inputs: index, state, pwin, dwin, pscore, dscore, HEX5...HEX0

        // Case 1: undefined
        validator(1, 4'bx, 1'bx, 1'bx, 4'bx, 4'bx, 7'bx, 7'bx, 7'bx, 7'bx, 7'bx, 7'bx);

        // Case 2: KEY[3](resetb) is asserted
        KEY[3] = 1'b0;
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        KEY[3] = 1'b1;
        validator(2, `WAIT, 1'b0, 1'b0, 4'b0, 4'b0, `NONE, `NONE, `NONE, `NONE, `NONE, `NONE);

        // Case 3: Present state should be LOAD_P1
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(3, `LOAD_P1, 1'b0, 1'b0, 4'd1, 4'b0, `NONE, `NONE, `NONE, `NONE, `NONE, `ACE);

        // Case 4: Present state should be LOAD_D1
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(4, `LOAD_D1, 1'b0, 1'b0, 4'd1, 4'd2, `NONE, `NONE, `TWO, `NONE, `NONE, `ACE);

        // Case 5: Present state should be LOAD_P2
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(5, `LOAD_P2, 1'b0, 1'b0, 4'd4, 4'd2, `NONE, `NONE, `TWO, `NONE, `THREE, `ACE);

        // Case 6: Present state should be LOAD_D2
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(6, `LOAD_D2, 1'b0, 1'b0, 4'd4, 4'd6, `NONE, `FOUR, `TWO, `NONE, `THREE, `ACE);

        // Case 7: Present state should be LOAD_P3
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(7, `LOAD_P3, 1'b0, 1'b0, 4'd9, 4'd6, `NONE, `FOUR, `TWO, `FIVE, `THREE, `ACE);

        // Case 8: Present state should be CALC_RES and triggers P_WIN
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(8, `CALC_RES, 1'b1, 1'b0, 4'd9, 4'd6, `NONE, `FOUR, `TWO, `FIVE, `THREE, `ACE);

        // Case 9: Present state should be P_WIN
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(9, `P_WIN, 1'b0, 1'b0, 4'd9, 4'd6, `NONE, `FOUR, `TWO, `FIVE, `THREE, `ACE);

        // Case 10: Present state should be WAIT
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(10, `WAIT, 1'b0, 1'b0, 4'd9, 4'd6, `NONE, `FOUR, `TWO, `FIVE, `THREE, `ACE);

        // ===================================================================================================================

        // Case 11: KEY[3](resetb) is asserted
        KEY[3] = 1'b0;
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        KEY[3] = 1'b1;
        validator(11, `WAIT, 1'b0, 1'b0, 4'b0, 4'b0, `NONE, `NONE, `NONE, `NONE, `NONE, `NONE);

        // Case 12: Present state should be LOAD_P1
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd6)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(12, `LOAD_P1, 1'b0, 1'b0, 4'd6, 4'b0, `NONE, `NONE, `NONE, `NONE, `NONE, `SIX);

        // Case 13: Present state should be LOAD_D1
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd7)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(13, `LOAD_D1, 1'b0, 1'b0, 4'd6, 4'd7, `NONE, `NONE, `SEVEN, `NONE, `NONE, `SIX);

        // Case 14: Present state should be LOAD_P2
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd8)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(14, `LOAD_P2, 1'b0, 1'b0, 4'd4, 4'd7, `NONE, `NONE, `SEVEN, `NONE, `EIGHT, `SIX);

        // Case 15: Present state should be LOAD_D2
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd9)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(15, `LOAD_D2, 1'b0, 1'b0, 4'd4, 4'd6, `NONE, `NINE, `SEVEN, `NONE, `EIGHT, `SIX);

        // Case 16: Present state should be LOAD_P3
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd7)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(16, `LOAD_P3, 1'b0, 1'b0, 4'd1, 4'd6, `NONE, `NINE, `SEVEN, `SEVEN, `EIGHT, `SIX);

        // Case 17: Present state should be LOAD_D3 and triggers D_WIN
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd10)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(17, `LOAD_D3, 1'b0, 1'b1, 4'd1, 4'd6, `TEN, `NINE, `SEVEN, `SEVEN, `EIGHT, `SIX);

        // Case 18: Present state should be D_WIN
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(18, `D_WIN, 1'b0, 1'b0, 4'd1, 4'd6, `TEN, `NINE, `SEVEN, `SEVEN, `EIGHT, `SIX);

        // ===================================================================================================================

        // Case 19: KEY[3](resetb) is asserted
        KEY[3] = 1'b0;
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        KEY[3] = 1'b1;
        validator(19, `WAIT, 1'b0, 1'b0, 4'b0, 4'b0, `NONE, `NONE, `NONE, `NONE, `NONE, `NONE);

        // Case 20: Present state should be LOAD_P1
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd8)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(20, `LOAD_P1, 1'b0, 1'b0, 4'd8, 4'b0, `NONE, `NONE, `NONE, `NONE, `NONE, `EIGHT);

        // Case 21: Present state should be LOAD_D1
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd11)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(21, `LOAD_D1, 1'b0, 1'b0, 4'd8, 4'd0, `NONE, `NONE, `JACK, `NONE, `NONE, `EIGHT);

        // Case 22: Present state should be LOAD_P2
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd12)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(22, `LOAD_P2, 1'b0, 1'b0, 4'd8, 4'd0, `NONE, `NONE, `JACK, `NONE, `QUEEN, `EIGHT);

        // Case 23: Present state should be LOAD_D2
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd13)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(23, `LOAD_D2, 1'b1, 1'b0, 4'd8, 4'd0, `NONE, `KING, `JACK, `NONE, `QUEEN, `EIGHT);

        // Case 24: Present state should be P_WIN
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(24, `P_WIN, 1'b0, 1'b0, 4'd8, 4'd0, `NONE, `KING, `JACK, `NONE, `QUEEN, `EIGHT);

        // ===================================================================================================================

        // Case 25: KEY[3](resetb) is asserted
        KEY[3] = 1'b0;
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        KEY[3] = 1'b1;
        validator(25, `WAIT, 1'b0, 1'b0, 4'b0, 4'b0, `NONE, `NONE, `NONE, `NONE, `NONE, `NONE);

        // Case 26: Present state should be LOAD_P1
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd8)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(26, `LOAD_P1, 1'b0, 1'b0, 4'd8, 4'b0, `NONE, `NONE, `NONE, `NONE, `NONE, `EIGHT);

        // Case 27: Present state should be LOAD_D1
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd8)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(27, `LOAD_D1, 1'b0, 1'b0, 4'd8, 4'd8, `NONE, `NONE, `EIGHT, `NONE, `NONE, `EIGHT);

        // Case 28: Present state should be LOAD_P2
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd12)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(28, `LOAD_P2, 1'b0, 1'b0, 4'd8, 4'd8, `NONE, `NONE, `EIGHT, `NONE, `QUEEN, `EIGHT);

        // Case 29: Present state should be LOAD_D2 and triggers TIE
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd13)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(29, `LOAD_D2, 1'b1, 1'b1, 4'd8, 4'd8, `NONE, `KING, `EIGHT, `NONE, `QUEEN, `EIGHT);

        // Case 30: Present state should be TIE
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(30, `TIE, 1'b0, 1'b0, 4'd8, 4'd8, `NONE, `KING, `EIGHT, `NONE, `QUEEN, `EIGHT);

        // ===================================================================================================================

        // Case 31: KEY[3](resetb) is asserted
        KEY[3] = 1'b0;
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        KEY[3] = 1'b1;
        validator(31, `WAIT, 1'b0, 1'b0, 4'b0, 4'b0, `NONE, `NONE, `NONE, `NONE, `NONE, `NONE);

        // Case 32: Present state should be LOAD_P1
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd8)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(32, `LOAD_P1, 1'b0, 1'b0, 4'd8, 4'b0, `NONE, `NONE, `NONE, `NONE, `NONE, `EIGHT);

        // Case 33: Present state should be LOAD_D1
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd9)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(33, `LOAD_D1, 1'b0, 1'b0, 4'd8, 4'd9, `NONE, `NONE, `NINE, `NONE, `NONE, `EIGHT);

        // Case 34: Present state should be LOAD_P2
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd10)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(34, `LOAD_P2, 1'b0, 1'b0, 4'd8, 4'd9, `NONE, `NONE, `NINE, `NONE, `TEN, `EIGHT);

        // Case 35: Present state should be LOAD_D2 and triggers D_WIN
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd11)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(35, `LOAD_D2, 1'b0, 1'b1, 4'd8, 4'd9, `NONE, `JACK, `NINE, `NONE, `TEN, `EIGHT);

        // Case 36: Present state should be D_WIN
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(36, `D_WIN, 1'b0, 1'b0, 4'd8, 4'd9, `NONE, `JACK, `NINE, `NONE, `TEN, `EIGHT);

        // ===================================================================================================================

        // Case 37: KEY[3](resetb) is asserted
        KEY[3] = 1'b0;
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        KEY[3] = 1'b1;
        validator(37, `WAIT, 1'b0, 1'b0, 4'b0, 4'b0, `NONE, `NONE, `NONE, `NONE, `NONE, `NONE);

        // Case 38: Present state should be LOAD_P1
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd10)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(38, `LOAD_P1, 1'b0, 1'b0, 4'd0, 4'b0, `NONE, `NONE, `NONE, `NONE, `NONE, `TEN);

        // Case 39: Present state should be LOAD_D1
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd5)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(39, `LOAD_D1, 1'b0, 1'b0, 4'd0, 4'd5, `NONE, `NONE, `FIVE, `NONE, `NONE, `TEN);

        // Case 40: Present state should be LOAD_P2
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd11)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(40, `LOAD_P2, 1'b0, 1'b0, 4'd0, 4'd5, `NONE, `NONE, `FIVE, `NONE, `JACK, `TEN);

        // Case 41: Present state should be LOAD_D2
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd2)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(41, `LOAD_D2, 1'b0, 1'b0, 4'd0, 4'd7, `NONE, `TWO, `FIVE, `NONE, `JACK, `TEN);

        // Case 42: Present state should be LOAD_P3
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(42, `LOAD_P3, 1'b0, 1'b0, 4'd2, 4'd7, `NONE, `TWO, `FIVE, `TWO, `JACK, `TEN);

        // Case 43: Present state should be CALC_RES and triggers D_WIN
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(43, `CALC_RES, 1'b0, 1'b1, 4'd2, 4'd7, `NONE, `TWO, `FIVE, `TWO, `JACK, `TEN);

        // ===================================================================================================================

        // Case 44: KEY[3](resetb) is asserted
        KEY[3] = 1'b0;
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        KEY[3] = 1'b1;
        validator(44, `WAIT, 1'b0, 1'b0, 4'b0, 4'b0, `NONE, `NONE, `NONE, `NONE, `NONE, `NONE);

        // Case 45: Present state should be LOAD_P1
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd1)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(45, `LOAD_P1, 1'b0, 1'b0, 4'd1, 4'b0, `NONE, `NONE, `NONE, `NONE, `NONE, `ACE);

        // Case 46: Present state should be LOAD_D1
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd5)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(46, `LOAD_D1, 1'b0, 1'b0, 4'd1, 4'd5, `NONE, `NONE, `FIVE, `NONE, `NONE, `ACE);

        // Case 47: Present state should be LOAD_P2
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd11)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(47, `LOAD_P2, 1'b0, 1'b0, 4'd1, 4'd5, `NONE, `NONE, `FIVE, `NONE, `JACK, `ACE);

        // Case 48: Present state should be LOAD_D2
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd13)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(48, `LOAD_D2, 1'b0, 1'b0, 4'd1, 4'd5, `NONE, `KING, `FIVE, `NONE, `JACK, `ACE);

        // Case 49: Present state should be LOAD_P3
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd5)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(49, `LOAD_P3, 1'b0, 1'b0, 4'd6, 4'd5, `NONE, `KING, `FIVE, `FIVE, `JACK, `ACE);

        // Case 50: Present state should be LOAD_D3 and triggers TIE
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd1)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(50, `LOAD_D3, 1'b1, 1'b1, 4'd6, 4'd6, `ACE, `KING, `FIVE, `FIVE, `JACK, `ACE);

        // Case 51: Present state should be TIE
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(51, `TIE, 1'b0, 1'b0, 4'd6, 4'd6, `ACE, `KING, `FIVE, `FIVE, `JACK, `ACE);

        // ===================================================================================================================

        // Case 52: KEY[3](resetb) is asserted
        KEY[3] = 1'b0;
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        KEY[3] = 1'b1;
        validator(52, `WAIT, 1'b0, 1'b0, 4'b0, 4'b0, `NONE, `NONE, `NONE, `NONE, `NONE, `NONE);

        // Case 53: Present state should be LOAD_P1
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd4)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(53, `LOAD_P1, 1'b0, 1'b0, 4'd4, 4'b0, `NONE, `NONE, `NONE, `NONE, `NONE, `FOUR);

        // Case 54: Present state should be LOAD_D1
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd5)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(54, `LOAD_D1, 1'b0, 1'b0, 4'd4, 4'd5, `NONE, `NONE, `FIVE, `NONE, `NONE, `FOUR);

        // Case 55: Present state should be LOAD_P2
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd11)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(55, `LOAD_P2, 1'b0, 1'b0, 4'd4, 4'd5, `NONE, `NONE, `FIVE, `NONE, `JACK, `FOUR);

        // Case 56: Present state should be LOAD_D2
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd13)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(56, `LOAD_D2, 1'b0, 1'b0, 4'd4, 4'd5, `NONE, `KING, `FIVE, `NONE, `JACK, `FOUR);

        // Case 57: Present state should be LOAD_P3
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd1)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(57, `LOAD_P3, 1'b0, 1'b0, 4'd5, 4'd5, `NONE, `KING, `FIVE, `ACE, `JACK, `FOUR);

        // Case 58: Present state should be CALC_RES and triggers TIE
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd1)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(58, `CALC_RES, 1'b1, 1'b1, 4'd5, 4'd5, `NONE, `KING, `FIVE, `ACE, `JACK, `FOUR);

        // Case 59: Present state should be TIE
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(59, `TIE, 1'b0, 1'b0, 4'd5, 4'd5, `NONE, `KING, `FIVE, `ACE, `JACK, `FOUR);

        // ===================================================================================================================

        // Case 60: KEY[3](resetb) is asserted
        KEY[3] = 1'b0;
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        KEY[3] = 1'b1;
        validator(60, `WAIT, 1'b0, 1'b0, 4'b0, 4'b0, `NONE, `NONE, `NONE, `NONE, `NONE, `NONE);

        // Case 61: Present state should be LOAD_P1
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd4)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(61, `LOAD_P1, 1'b0, 1'b0, 4'd4, 4'b0, `NONE, `NONE, `NONE, `NONE, `NONE, `FOUR);

        // Case 62: Present state should be LOAD_D1
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd4)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(62, `LOAD_D1, 1'b0, 1'b0, 4'd4, 4'd4, `NONE, `NONE, `FOUR, `NONE, `NONE, `FOUR);

        // Case 63: Present state should be LOAD_P2
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd11)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(63, `LOAD_P2, 1'b0, 1'b0, 4'd4, 4'd4, `NONE, `NONE, `FOUR, `NONE, `JACK, `FOUR);

        // Case 64: Present state should be LOAD_D2
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd13)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(64, `LOAD_D2, 1'b0, 1'b0, 4'd4, 4'd4, `NONE, `KING, `FOUR, `NONE, `JACK, `FOUR);

        // Case 65: Present state should be LOAD_P3
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd2)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(65, `LOAD_P3, 1'b0, 1'b0, 4'd6, 4'd4, `NONE, `KING, `FOUR, `TWO, `JACK, `FOUR);

        // Case 66: Present state should be LOAD_D3 and triggers P_WIN
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd10)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(66, `LOAD_D3, 1'b1, 1'b0, 4'd6, 4'd4, `TEN, `KING, `FOUR, `TWO, `JACK, `FOUR);

        // Case 67: Present state should be P_WIN
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(67, `P_WIN, 1'b0, 1'b0, 4'd6, 4'd4, `TEN, `KING, `FOUR, `TWO, `JACK, `FOUR);

        // ===================================================================================================================

        // Case 68: KEY[3](resetb) is asserted
        KEY[3] = 1'b0;
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        KEY[3] = 1'b1;
        validator(68, `WAIT, 1'b0, 1'b0, 4'b0, 4'b0, `NONE, `NONE, `NONE, `NONE, `NONE, `NONE);

        // Case 69: Present state should be LOAD_P1
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd4)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(69, `LOAD_P1, 1'b0, 1'b0, 4'd4, 4'b0, `NONE, `NONE, `NONE, `NONE, `NONE, `FOUR);

        // Case 70: Present state should be LOAD_D1
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd4)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(70, `LOAD_D1, 1'b0, 1'b0, 4'd4, 4'd4, `NONE, `NONE, `FOUR, `NONE, `NONE, `FOUR);

        // Case 71: Present state should be LOAD_P2
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd11)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(71, `LOAD_P2, 1'b0, 1'b0, 4'd4, 4'd4, `NONE, `NONE, `FOUR, `NONE, `JACK, `FOUR);

        // Case 72: Present state should be LOAD_D2
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd13)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(72, `LOAD_D2, 1'b0, 1'b0, 4'd4, 4'd4, `NONE, `KING, `FOUR, `NONE, `JACK, `FOUR);

        // Case 73: Present state should be LOAD_P3
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd8)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(73, `LOAD_P3, 1'b0, 1'b0, 4'd2, 4'd4, `NONE, `KING, `FOUR, `EIGHT, `JACK, `FOUR);

        // Case 74: Present state should be CALC_RES and triggers D_WIN
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd10)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(74, `CALC_RES, 1'b0, 1'b1, 4'd2, 4'd4, `NONE, `KING, `FOUR, `EIGHT, `JACK, `FOUR);

        // Case 75: Present state should be D_WIN
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(75, `D_WIN, 1'b0, 1'b0, 4'd2, 4'd4, `NONE, `KING, `FOUR, `EIGHT, `JACK, `FOUR);

        // ===================================================================================================================

        // Case 76: KEY[3](resetb) is asserted
        KEY[3] = 1'b0;
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        KEY[3] = 1'b1;
        validator(76, `WAIT, 1'b0, 1'b0, 4'b0, 4'b0, `NONE, `NONE, `NONE, `NONE, `NONE, `NONE);

        // Case 77: Present state should be LOAD_P1
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd3)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(77, `LOAD_P1, 1'b0, 1'b0, 4'd3, 4'b0, `NONE, `NONE, `NONE, `NONE, `NONE, `THREE);

        // Case 78: Present state should be LOAD_D1
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd1)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(78, `LOAD_D1, 1'b0, 1'b0, 4'd3, 4'd1, `NONE, `NONE, `ACE, `NONE, `NONE, `THREE);

        // Case 79: Present state should be LOAD_P2
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd1)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(79, `LOAD_P2, 1'b0, 1'b0, 4'd4, 4'd1, `NONE, `NONE, `ACE, `NONE, `ACE, `THREE);

        // Case 80: Present state should be LOAD_D2
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd2)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(80, `LOAD_D2, 1'b0, 1'b0, 4'd4, 4'd3, `NONE, `TWO, `ACE, `NONE, `ACE, `THREE);

        // Case 81: Present state should be LOAD_P3
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd7)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(81, `LOAD_P3, 1'b0, 1'b0, 4'd1, 4'd3, `NONE, `TWO, `ACE, `SEVEN, `ACE, `THREE);

        // Case 82: Present state should be LOAD_D3 and triggers D_WIN
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd10)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(82, `LOAD_D3, 1'b0, 1'b1, 4'd1, 4'd3, `TEN, `TWO, `ACE, `SEVEN, `ACE, `THREE);

        // Case 83: Present state should be D_WIN
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(83, `D_WIN, 1'b0, 1'b0, 4'd1, 4'd3, `TEN, `TWO, `ACE, `SEVEN, `ACE, `THREE);

        // ===================================================================================================================

        // Case 84: KEY[3](resetb) is asserted
        KEY[3] = 1'b0;
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        KEY[3] = 1'b1;
        validator(84, `WAIT, 1'b0, 1'b0, 4'b0, 4'b0, `NONE, `NONE, `NONE, `NONE, `NONE, `NONE);

        // Case 85: Present state should be LOAD_P1
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd3)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(85, `LOAD_P1, 1'b0, 1'b0, 4'd3, 4'b0, `NONE, `NONE, `NONE, `NONE, `NONE, `THREE);

        // Case 86: Present state should be LOAD_D1
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd1)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(86, `LOAD_D1, 1'b0, 1'b0, 4'd3, 4'd1, `NONE, `NONE, `ACE, `NONE, `NONE, `THREE);

        // Case 87: Present state should be LOAD_P2
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd1)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(87, `LOAD_P2, 1'b0, 1'b0, 4'd4, 4'd1, `NONE, `NONE, `ACE, `NONE, `ACE, `THREE);

        // Case 88: Present state should be LOAD_D2
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd2)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(88, `LOAD_D2, 1'b0, 1'b0, 4'd4, 4'd3, `NONE, `TWO, `ACE, `NONE, `ACE, `THREE);

        // Case 89: Present state should be LOAD_P3
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd8)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(89, `LOAD_P3, 1'b0, 1'b0, 4'd2, 4'd3, `NONE, `TWO, `ACE, `EIGHT, `ACE, `THREE);

        // Case 90: Present state should be CALC_RES and triggers D_WIN
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd10)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(90, `CALC_RES, 1'b0, 1'b1, 4'd2, 4'd3, `NONE, `TWO, `ACE, `EIGHT, `ACE, `THREE);

        // Case 91: Present state should be D_WIN
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(91, `D_WIN, 1'b0, 1'b0, 4'd2, 4'd3, `NONE, `TWO, `ACE, `EIGHT, `ACE, `THREE);

        // ===================================================================================================================

        // Case 92: KEY[3](resetb) is asserted
        KEY[3] = 1'b0;
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        KEY[3] = 1'b1;
        validator(92, `WAIT, 1'b0, 1'b0, 4'b0, 4'b0, `NONE, `NONE, `NONE, `NONE, `NONE, `NONE);

        // Case 93: Present state should be LOAD_P1
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd3)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(93, `LOAD_P1, 1'b0, 1'b0, 4'd3, 4'b0, `NONE, `NONE, `NONE, `NONE, `NONE, `THREE);

        // Case 94: Present state should be LOAD_D1
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd1)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(94, `LOAD_D1, 1'b0, 1'b0, 4'd3, 4'd1, `NONE, `NONE, `ACE, `NONE, `NONE, `THREE);

        // Case 95: Present state should be LOAD_P2
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd1)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(95, `LOAD_P2, 1'b0, 1'b0, 4'd4, 4'd1, `NONE, `NONE, `ACE, `NONE, `ACE, `THREE);

        // Case 96: Present state should be LOAD_D2
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd11)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(96, `LOAD_D2, 1'b0, 1'b0, 4'd4, 4'd1, `NONE, `JACK, `ACE, `NONE, `ACE, `THREE);

        // Case 97: Present state should be LOAD_P3
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd8)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(97, `LOAD_P3, 1'b0, 1'b0, 4'd2, 4'd1, `NONE, `JACK, `ACE, `EIGHT, `ACE, `THREE);

        // Case 98: Present state should be LOAD_D3 and triggers TIE
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd1)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(98, `LOAD_D3, 1'b1, 1'b1, 4'd2, 4'd2, `ACE, `JACK, `ACE, `EIGHT, `ACE, `THREE);

        // Case 99: Present state should be TIE
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(99, `TIE, 1'b0, 1'b0, 4'd2, 4'd2, `ACE, `JACK, `ACE, `EIGHT, `ACE, `THREE);

        // ===================================================================================================================

        // Case 100: KEY[3](resetb) is asserted
        KEY[3] = 1'b0;
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        KEY[3] = 1'b1;
        validator(100, `WAIT, 1'b0, 1'b0, 4'b0, 4'b0, `NONE, `NONE, `NONE, `NONE, `NONE, `NONE);

        // Case 101: Present state should be LOAD_P1
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd3)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(101, `LOAD_P1, 1'b0, 1'b0, 4'd3, 4'b0, `NONE, `NONE, `NONE, `NONE, `NONE, `THREE);

        // Case 102: Present state should be LOAD_D1
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd1)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(102, `LOAD_D1, 1'b0, 1'b0, 4'd3, 4'd1, `NONE, `NONE, `ACE, `NONE, `NONE, `THREE);

        // Case 103: Present state should be LOAD_P2
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd4)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(103, `LOAD_P2, 1'b0, 1'b0, 4'd7, 4'd1, `NONE, `NONE, `ACE, `NONE, `FOUR, `THREE);

        // Case 104: Present state should be LOAD_D2
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd11)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(104, `LOAD_D2, 1'b0, 1'b0, 4'd7, 4'd1, `NONE, `JACK, `ACE, `NONE, `FOUR, `THREE);

        // Case 105: Present state should be LOAD_D3 and triggers TIE
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd6)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(105, `LOAD_D3, 1'b1, 1'b1, 4'd7, 4'd7, `SIX, `JACK, `ACE, `NONE, `FOUR, `THREE);

        // ===================================================================================================================

        // Case 106: KEY[3](resetb) is asserted
        KEY[3] = 1'b0;
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        KEY[3] = 1'b1;
        validator(106, `WAIT, 1'b0, 1'b0, 4'b0, 4'b0, `NONE, `NONE, `NONE, `NONE, `NONE, `NONE);

        // Case 107: Present state should be LOAD_P1
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd3)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(107, `LOAD_P1, 1'b0, 1'b0, 4'd3, 4'b0, `NONE, `NONE, `NONE, `NONE, `NONE, `THREE);

        // Case 108: Present state should be LOAD_D1
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd1)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(108, `LOAD_D1, 1'b0, 1'b0, 4'd3, 4'd1, `NONE, `NONE, `ACE, `NONE, `NONE, `THREE);

        // Case 109: Present state should be LOAD_P2
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd4)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(109, `LOAD_P2, 1'b0, 1'b0, 4'd7, 4'd1, `NONE, `NONE, `ACE, `NONE, `FOUR, `THREE);

        // Case 110: Present state should be LOAD_D2 and triggers P_WIN
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd5)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(110, `LOAD_D2, 1'b1, 1'b0, 4'd7, 4'd6, `NONE, `FIVE, `ACE, `NONE, `FOUR, `THREE);

        // ===================================================================================================================

        // Case 111: KEY[3](resetb) is asserted
        KEY[3] = 1'b0;
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        KEY[3] = 1'b1;
        validator(111, `WAIT, 1'b0, 1'b0, 4'b0, 4'b0, `NONE, `NONE, `NONE, `NONE, `NONE, `NONE);

        // Case 112: Present state should be LOAD_P1
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd3)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(112, `LOAD_P1, 1'b0, 1'b0, 4'd3, 4'b0, `NONE, `NONE, `NONE, `NONE, `NONE, `THREE);

        // Case 113: Present state should be LOAD_D1
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd1)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(113, `LOAD_D1, 1'b0, 1'b0, 4'd3, 4'd1, `NONE, `NONE, `ACE, `NONE, `NONE, `THREE);

        // Case 114: Present state should be LOAD_P2
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd4)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(114, `LOAD_P2, 1'b0, 1'b0, 4'd7, 4'd1, `NONE, `NONE, `ACE, `NONE, `FOUR, `THREE);

        // Case 115: Present state should be LOAD_D2 and triggers TIE
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd6)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(115, `LOAD_D2, 1'b1, 1'b1, 4'd7, 4'd7, `NONE, `SIX, `ACE, `NONE, `FOUR, `THREE);

        // ===================================================================================================================

        // Case 116: KEY[3](resetb) is asserted
        KEY[3] = 1'b0;
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        KEY[3] = 1'b1;
        validator(116, `WAIT, 1'b0, 1'b0, 4'b0, 4'b0, `NONE, `NONE, `NONE, `NONE, `NONE, `NONE);

        // Case 117: Present state should be LOAD_P1
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd3)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(117, `LOAD_P1, 1'b0, 1'b0, 4'd3, 4'b0, `NONE, `NONE, `NONE, `NONE, `NONE, `THREE);

        // Case 118: Present state should be LOAD_D1
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd1)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(118, `LOAD_D1, 1'b0, 1'b0, 4'd3, 4'd1, `NONE, `NONE, `ACE, `NONE, `NONE, `THREE);

        // Case 119: Present state should be LOAD_P2
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd3)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(119, `LOAD_P2, 1'b0, 1'b0, 4'd6, 4'd1, `NONE, `NONE, `ACE, `NONE, `THREE, `THREE);

        // Case 120: Present state should be LOAD_D2 and triggers D_WIN
        wait (tb_task5.dut.dp.dc.dealer_card == 4'd6)
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(120, `LOAD_D2, 1'b0, 1'b1, 4'd6, 4'd7, `NONE, `SIX, `ACE, `NONE, `THREE, `THREE);

        // Case 121: Present state should be D_WIN
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(121, `D_WIN, 1'b0, 1'b0, 4'd6, 4'd7, `NONE, `SIX, `ACE, `NONE, `THREE, `THREE);

        // ===================================================================================================================

        // Case 122: KEY[3](resetb) is asserted
        KEY[3] = 1'b0;
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        KEY[3] = 1'b1;
        validator(122, `WAIT, 1'b0, 1'b0, 4'b0, 4'b0, `NONE, `NONE, `NONE, `NONE, `NONE, `NONE);

        // Case 123: Undefined
        KEY[3] = 1'bx;
        KEY[0] = 1'b1; #5; KEY[0] = 1'b0; #5;
        validator(123, 4'b000x, 1'bx, 1'bx, 4'b1, 4'b0, `NONE, `NONE, `NONE, `NONE, `NONE, `ACE);

        if (~err) begin
            $display("SUCCESS: All tests passed.");
        end
        $stop;
    end
						
endmodule