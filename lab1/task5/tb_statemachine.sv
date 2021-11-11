module tb_statemachine();

    logic slow_clock, resetb, load_pcard1, load_pcard2, load_pcard3, load_dcard1, load_dcard2, load_dcard3, player_win_light, dealer_win_light, err;
    logic [3:0] dscore, pscore, pcard3;

    statemachine dut(.*);

    initial begin
        slow_clock = 0;
        forever #5 slow_clock = ~slow_clock;
    end

    task validator;
        input [31:0] index;
        input [3:0] exp_state;
        input [7:0] exp_out;
        begin
            $display("TEST %d", index);
            if (tb_statemachine.dut.next_state !== exp_state) begin
                $display("ERROR A: Expected next_state is %b, actual next_state is %b", exp_state, tb_statemachine.dut.next_state);
                err = 1'b1;
            end
            if (tb_statemachine.dut.load_pcard1 !== exp_out[7]) begin
                $display("ERROR B: Expected load_pcard1 is %b, actual load_pcard1 is %b", exp_out[7], tb_statemachine.dut.load_pcard1);
                err = 1'b1;
            end
            if (tb_statemachine.dut.load_pcard2 !== exp_out[6]) begin
                $display("ERROR C: Expected load_pcard2 is %b, actual load_pcard2 is %b", exp_out[6], tb_statemachine.dut.load_pcard2);
                err = 1'b1;
            end
            if (tb_statemachine.dut.load_pcard3 !== exp_out[5]) begin
                $display("ERROR D: Expected load_pcard3 is %b, actual load_pcard3 is %b", exp_out[5], tb_statemachine.dut.load_pcard3);
                err = 1'b1;
            end
            if (tb_statemachine.dut.load_dcard1 !== exp_out[4]) begin
                $display("ERROR E: Expected load_dcard1 is %b, actual load_dcard1 is %b", exp_out[4], tb_statemachine.dut.load_dcard1);
                err = 1'b1;
            end
            if (tb_statemachine.dut.load_dcard2 !== exp_out[3]) begin
                $display("ERROR F: Expected load_dcard2 is %b, actual load_dcard2 is %b", exp_out[3], tb_statemachine.dut.load_dcard2);
                err = 1'b1;
            end
            if (tb_statemachine.dut.load_dcard3 !== exp_out[2]) begin
                $display("ERROR G: Expected load_dcard3 is %b, actual load_dcard3 is %b", exp_out[2], tb_statemachine.dut.load_dcard3);
                err = 1'b1;
            end
            if (tb_statemachine.dut.player_win_light !== exp_out[1]) begin
                $display("ERROR H: Expected player_win_light is %b, actual player_win_light is %b", exp_out[1], tb_statemachine.dut.player_win_light);
                err = 1'b1;
            end
            if (tb_statemachine.dut.dealer_win_light !== exp_out[0]) begin
                $display("ERROR I: Expected dealer_win_light is %b, actual dealer_win_light is %b", exp_out[0], tb_statemachine.dut.dealer_win_light);
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

    initial begin
        err = 1'b0;

        // Case 1: undefined
        validator(1, 4'bx, 8'bx);

        // Case 2: resetb is asserted, next state should be LOAD_P1 (after resetb signal goes high)
        resetb = 1'b0;
        #10;
        validator(2, `LOAD_P1, 8'b10000000);

        // Case 3: resetb signal is removed, next state should be LOAD_D1
        resetb = 1'b1;
        #10;
        validator(3, `LOAD_D1, 8'b00010000);

        // Case 4: Next state should be LOAD_P2
        #10;
        validator(4, `LOAD_P2, 8'b01000000);

        // Case 5: Next state should be LOAD_D2
        #10;
        validator(5, `LOAD_D2, 8'b00001000);

        // Case 6: Dealer's score is greater than player's score, next state should be D_WIN
        dscore = 4'd8; pscore = 4'd3; pcard3 = 4'd0;
        #10;
        validator(6, `D_WIN, 8'b00000001);

        // Case 7: Next state should be WAIT
        #10;
        validator(7, `WAIT, 8'b0);

        // ===================================================================================================================

        // Case 8: Player's score is 4'd9, dealer's score is 4'd8, next state should be P_WIN
        resetb = 1'b0; dscore = 4'b0; pscore = 4'b0; pcard3 = 4'b0;
        #10;
        resetb = 1'b1;
        #30;
        pscore = 4'd9; dscore = 4'd8; pcard3 = 4'b0;
        #10;
        validator(8, `P_WIN, 8'b00000010);

        // Case 9: Next state should be WAIT
        #10;
        validator(9, `WAIT, 8'b0);

        // ===================================================================================================================

        // Case 10: Player's score is 4'd8, dealer's score is 4'd8, next state should be TIE
        resetb = 1'b0; dscore = 4'b0; pscore = 4'b0; pcard3 = 4'b0;
        #10;
        resetb = 1'b1;
        #30;
        pscore = 4'd8; dscore = 4'd8; pcard3 = 4'b0;
        #10;
        validator(10, `TIE, 8'b00000011);

        // Case 11: Next state should be WAIT
        #10;
        validator(11, `WAIT, 8'b0);

        // ===================================================================================================================

        // Case 12: Player's score is 4'd3, dealer's score is 4'd7, next state should be LOAD_P3
        resetb = 1'b0; dscore = 4'b0; pscore = 4'b0; pcard3 = 4'b0;
        #10;
        resetb = 1'b1;
        #30;
        pscore = 4'd3; dscore = 4'd7; pcard3 = 4'b0;
        #10;
        validator(12, `LOAD_P3, 8'b00100000);

        // Case 13: Next state should be P_WIN
        pscore = 4'd8;
        #5;
        validator(13, `P_WIN, 8'b00000010);

        #5;
        validator(13, `WAIT, 8'b0);

        // ===================================================================================================================

        // Case 14: Player's score is 4'd4, dealer's score is 4'd7, next state should be LOAD_P3
        resetb = 1'b0; dscore = 4'b0; pscore = 4'b0; pcard3 = 4'b0;
        #10;
        resetb = 1'b1;
        #30;
        pscore = 4'd4; dscore = 4'd7; pcard3 = 4'b0;
        #10;
        validator(14, `LOAD_P3, 8'b00100000);

        // Case 15: Next state should be TIE
        pscore = 4'd7;
        #5;
        validator(15, `TIE, 8'b00000011);

        #5;
        validator(16, `WAIT, 8'b0);

        // ===================================================================================================================

        // Case 17: Player's score is 4'd4, dealer's score is 4'd7, next state should be LOAD_P3
        resetb = 1'b0; dscore = 4'b0; pscore = 4'b0; pcard3 = 4'b0;
        #10;
        resetb = 1'b1;
        #30;
        pscore = 4'd4; dscore = 4'd7; pcard3 = 4'b0;
        #10;
        validator(17, `LOAD_P3, 8'b00100000);

        // Case 18: Next state should be D_WIN
        #20;
        validator(18, `D_WIN, 8'b00000001);

        // ===================================================================================================================

        // Case 19: Player's score is 4'd2, dealer's score is 4'd6, next state should be LOAD_P3
        resetb = 1'b0; dscore = 4'b0; pscore = 4'b0; pcard3 = 4'b0;
        #10;
        resetb = 1'b1;
        #30;
        pscore = 4'd2; dscore = 4'd6; pcard3 = 4'd6;
        #10;
        validator(19, `LOAD_P3, 8'b00100000);

        // Case 20: Next state should be LOAD_D3
        #10;
        validator(20, `LOAD_D3, 8'b00000100);

        // Case 21: Next state should be D_WIN
        #10;
        validator(21, `D_WIN, 8'b00000001);

        // ===================================================================================================================

        // Case 22: Player's score is 4'd1, dealer's score is 4'd6, next state should be LOAD_P3
        resetb = 1'b0; dscore = 4'b0; pscore = 4'b0; pcard3 = 4'b0;
        #10;
        resetb = 1'b1;
        #30;
        pscore = 4'd1; dscore = 4'd6; pcard3 = 4'd4;
        #10;
        validator(22, `LOAD_P3, 8'b00100000);

        // Case 23: Next state should be P_WIN
        pscore = 4'd7;
        #5;
        validator(23, `P_WIN, 8'b00000010);

        #5;
        validator(24, `WAIT, 8'b0);

        // ===================================================================================================================

        // Case 25: Player's score is 4'd0, dealer's score is 4'd6, next state should be LOAD_P3
        resetb = 1'b0; dscore = 4'b0; pscore = 4'b0; pcard3 = 4'b0;
        #10;
        resetb = 1'b1;
        #30;
        pscore = 4'd0; dscore = 4'd6; pcard3 = 4'd8;
        #10;
        validator(25, `LOAD_P3, 8'b00100000);

        // Case 26: Next state should be TIE
        pscore = 4'd6;
        #5;
        validator(26, `TIE, 8'b00000011);

        #5;
        validator(27, `WAIT, 8'b0);

        // ===================================================================================================================

        // Case 28: Player's score is 4'd0, dealer's score is 4'd6, next state should be LOAD_P3
        resetb = 1'b0; dscore = 4'b0; pscore = 4'b0; pcard3 = 4'b0;
        #10;
        resetb = 1'b1;
        #30;
        pscore = 4'd0; dscore = 4'd6; pcard3 = 4'd8;
        #10;
        validator(28, `LOAD_P3, 8'b00100000);

        // Case 29: Next state should be D_WIN
        #20;
        validator(29, `D_WIN, 8'b00000001);

        // ===================================================================================================================

        // Case 30: Player's score is 4'd1, dealer's score is 4'd5, next state should be LOAD_P3
        resetb = 1'b0; dscore = 4'b0; pscore = 4'b0; pcard3 = 4'b0;
        #10;
        resetb = 1'b1;
        #30;
        pscore = 4'd1; dscore = 4'd5; pcard3 = 4'd5;
        #10;
        validator(30, `LOAD_P3, 8'b00100000);

        // Case 31: Next state should be LOAD_D3
        #10;
        validator(31, `LOAD_D3, 8'b00000100);

        // Case 32: Next state should be D_WIN
        #10;
        validator(32, `D_WIN, 8'b00000001);

        // ===================================================================================================================

        // Case 33: Player's score is 4'd1, dealer's score is 4'd5, next state should be LOAD_P3
        resetb = 1'b0; dscore = 4'b0; pscore = 4'b0; pcard3 = 4'b0;
        #10;
        resetb = 1'b1;
        #30;
        pscore = 4'd1; dscore = 4'd5; pcard3 = 4'd3;
        #10;
        validator(33, `LOAD_P3, 8'b00100000);

        // Case 34: Next state should be P_WIN
        pscore = 4'd6;
        #10;
        validator(34, `P_WIN, 8'b00000010);

        // ===================================================================================================================

        // Case 35: Player's score is 4'd2, dealer's score is 4'd5, next state should be LOAD_P3
        resetb = 1'b0; dscore = 4'b0; pscore = 4'b0; pcard3 = 4'b0;
        #10;
        resetb = 1'b1;
        #30;
        pscore = 4'd2; dscore = 4'd5; pcard3 = 4'd2;
        #10;
        validator(35, `LOAD_P3, 8'b00100000);

        // Case 36: Next state should be TIE
        pscore = 4'd5;
        #20;
        validator(36, `TIE, 8'b00000011);

        // ===================================================================================================================

        // Case 37: Player's score is 4'd3, dealer's score is 4'd5, next state should be LOAD_P3
        resetb = 1'b0; dscore = 4'b0; pscore = 4'b0; pcard3 = 4'b0;
        #10;
        resetb = 1'b1;
        #30;
        pscore = 4'd3; dscore = 4'd5; pcard3 = 4'd9;
        #10;
        validator(37, `LOAD_P3, 8'b00100000);

        // Case 38: Next state should be D_WIN
        #20;
        validator(38, `D_WIN, 8'b00000001);

        // ===================================================================================================================

        // Case 39: Player's score is 4'd4, dealer's score is 4'd4, next state should be LOAD_P3
        resetb = 1'b0; dscore = 4'b0; pscore = 4'b0; pcard3 = 4'b0;
        #10;
        resetb = 1'b1;
        #30;
        pscore = 4'd4; dscore = 4'd4; pcard3 = 4'd5;
        #10;
        validator(39, `LOAD_P3, 8'b00100000);

        // Case 40: Next state should be LOAD_D3
        #10;
        validator(40, `LOAD_D3, 8'b00000100);

        // Case 41: Next state should be TIE
        #10;
        validator(41, `TIE, 8'b00000011);

        // ===================================================================================================================

        // Case 42: Player's score is 4'd3, dealer's score is 4'd4, next state should be LOAD_P3
        resetb = 1'b0; dscore = 4'b0; pscore = 4'b0; pcard3 = 4'b0;
        #10;
        resetb = 1'b1;
        #30;
        pscore = 4'd3; dscore = 4'd4; pcard3 = 4'd8;
        #10;
        validator(42, `LOAD_P3, 8'b00100000);

        // Case 43: Next state should be P_WIN
        pscore = 4'd8;
        #5;
        validator(43, `P_WIN, 8'b00000010);

        #5;
        validator(44, `WAIT, 8'b0);

        // ===================================================================================================================

        // Case 45: Player's score is 4'd2, dealer's score is 4'd4, next state should be LOAD_P3
        resetb = 1'b0; dscore = 4'b0; pscore = 4'b0; pcard3 = 4'b0;
        #10;
        resetb = 1'b1;
        #30;
        pscore = 4'd2; dscore = 4'd4; pcard3 = 4'd9;
        #10;
        validator(45, `LOAD_P3, 8'b00100000);

        // Case 46: Next state should be TIE
        pscore = 4'd4;
        #20;
        validator(46, `TIE, 8'b00000011);

        // ===================================================================================================================

        // Case 47: Player's score is 4'd2, dealer's score is 4'd4, next state should be LOAD_P3
        resetb = 1'b0; dscore = 4'b0; pscore = 4'b0; pcard3 = 4'b0;
        #10;
        resetb = 1'b1;
        #30;
        pscore = 4'd2; dscore = 4'd4; pcard3 = 4'd1;
        #10;
        validator(47, `LOAD_P3, 8'b00100000);

        // Case 48: Next state should be D_WIN
        #20;
        validator(48, `D_WIN, 8'b00000001);
        
        // ===================================================================================================================

        // Case 49: Player's score is 4'd0, dealer's score is 4'd3, next state should be LOAD_P3
        resetb = 1'b0; dscore = 4'b0; pscore = 4'b0; pcard3 = 4'b0;
        #10;
        resetb = 1'b1;
        #30;
        pscore = 4'd0; dscore = 4'd3; pcard3 = 4'd1;
        #10;
        validator(49, `LOAD_P3, 8'b00100000);

        // Case 50: Next state should be LOAD_D3
        #10;
        validator(50, `LOAD_D3, 8'b00000100);

        // Case 51: Next state should be D_WIN
        #10;
        validator(51, `D_WIN, 8'b00000001);

        // ===================================================================================================================

        // Case 52: Player's score is 4'd5, dealer's score is 4'd3, next state should be LOAD_P3
        resetb = 1'b0; dscore = 4'b0; pscore = 4'b0; pcard3 = 4'b0;
        #10;
        resetb = 1'b1;
        #30;
        pscore = 4'd5; dscore = 4'd3; pcard3 = 4'd8;
        #10;
        validator(52, `LOAD_P3, 8'b00100000);

        // Case 53: Next state should be P_WIN
        #20;
        validator(53, `P_WIN, 8'b00000010);

        // ===================================================================================================================

        // Case 54: Player's score is 4'd3, dealer's score is 4'd3, next state should be LOAD_P3
        resetb = 1'b0; dscore = 4'b0; pscore = 4'b0; pcard3 = 4'b0;
        #10;
        resetb = 1'b1;
        #30;
        pscore = 4'd3; dscore = 4'd3; pcard3 = 4'd8;
        #10;
        validator(54, `LOAD_P3, 8'b00100000);

        // Case 55: Next state should be TIE
        #20;
        validator(55, `TIE, 8'b00000011);

        // ===================================================================================================================

        // Case 56: Player's score is 4'd1, dealer's score is 4'd3, next state should be LOAD_P3
        resetb = 1'b0; dscore = 4'b0; pscore = 4'b0; pcard3 = 4'b0;
        #10;
        resetb = 1'b1;
        #30;
        pscore = 4'd1; dscore = 4'd3; pcard3 = 4'd8;
        #10;
        validator(56, `LOAD_P3, 8'b00100000);

        // Case 57: Next state should be D_WIN
        #20;
        validator(57, `D_WIN, 8'b00000001);

        // ===================================================================================================================

        // Case 58: Player's score is 4'd4, dealer's score is 4'd2, next state should be LOAD_P3
        resetb = 1'b0; dscore = 4'b0; pscore = 4'b0; pcard3 = 4'b0;
        #10;
        resetb = 1'b1;
        #30;
        pscore = 4'd4; dscore = 4'd2; pcard3 = 4'd8;
        #10;
        validator(58, `LOAD_P3, 8'b00100000);

        // Case 59: Next state should be LOAD_D3
        #10;
        validator(59, `LOAD_D3, 8'b00000100);

        // Case 60: Next state should be P_WIN
        #10;
        validator(60, `P_WIN, 8'b00000010);

        // ===================================================================================================================

        // Case 61: Player's score is 4'd6, dealer's score is 4'd2, next state should be LOAD_D3
        resetb = 1'b0; dscore = 4'b0; pscore = 4'b0; pcard3 = 4'b0;
        #10;
        resetb = 1'b1;
        #30;
        pscore = 4'd6; dscore = 4'd2; pcard3 = 4'd8;
        #10;
        validator(61, `LOAD_D3, 8'b00000100);

        // Case 62: Next state should be P_WIN
        #10;
        validator(62, `P_WIN, 8'b00000010);

        // ===================================================================================================================

        // Case 63: Player's score is 4'd7, dealer's score is 4'd6, next state should be P_WIN
        resetb = 1'b0; dscore = 4'b0; pscore = 4'b0; pcard3 = 4'b0;
        #10;
        resetb = 1'b1;
        #30;
        pscore = 4'd7; dscore = 4'd6; pcard3 = 4'd0;
        #10;
        validator(63, `P_WIN, 8'b00000010);

        // ===================================================================================================================

        // Case 64: Player's score is 4'd6, dealer's score is 4'd6, next state should be TIE
        resetb = 1'b0; dscore = 4'b0; pscore = 4'b0; pcard3 = 4'b0;
        #10;
        resetb = 1'b1;
        #30;
        pscore = 4'd6; dscore = 4'd6; pcard3 = 4'd0;
        #10;
        validator(64, `TIE, 8'b00000011);

        // ===================================================================================================================

        // Case 65: Player's score is 4'd6, dealer's score is 4'd7, next state should be D_WIN
        resetb = 1'b0; dscore = 4'b0; pscore = 4'b0; pcard3 = 4'b0;
        #10;
        resetb = 1'b1;
        #30;
        pscore = 4'd6; dscore = 4'd7; pcard3 = 4'd0;
        #10;
        validator(65, `D_WIN, 8'b00000001);

        // ===================================================================================================================

        // Case 66: Undefined
        resetb = 1'bx; dscore = 4'bx; pscore = 4'bx; pcard3 = 4'bx;
        #10;
        validator(66, 4'bx, 8'bx);


        if (~err) begin
            $display("SUCCESS: All tests passed.");
        end
        $stop;
    end
						
endmodule

