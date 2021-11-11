module tb_rtl_reuleaux();

// Your testbench goes here. Our toplevel will give up after 1,000,000 ticks.
    logic clk, rst_n, start, done, vga_plot, err;
    logic [2:0] colour, vga_colour;
    logic [7:0] centre_x, diameter, vga_x;
    logic [6:0] centre_y, vga_y;

    reuleaux dut(.*);

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task validator;
        input [31:0] index;
        input [3:0] exp_state;
        input [7:0] exp_x;
        input [6:0] exp_y;
        input [2:0] exp_colour;
        input exp_done, exp_plot;
        begin
            $display("CASE %d", index);
            if (tb_rtl_reuleaux.dut.state !== exp_state) begin
                $display("ERROR A: Expected state is %d, actual state is %d", exp_state, tb_rtl_reuleaux.dut.state);
                err = 1'b1;
            end
            if (tb_rtl_reuleaux.dut.vga_x !== exp_x) begin
                $display("ERROR B: Expected vga_x is %d, actual vga_x is %d", exp_x, tb_rtl_reuleaux.dut.vga_x);
                err = 1'b1;
            end
            if (tb_rtl_reuleaux.dut.vga_y !== exp_y) begin
                $display("ERROR C: Expected vga_y is %d, actual vga_y is %d", exp_y, tb_rtl_reuleaux.dut.vga_y);
                err = 1'b1;
            end
            if (tb_rtl_reuleaux.dut.vga_colour !== exp_colour) begin
                $display("ERROR D: Expected vga_colour is %d, actual vga_colour is %d", exp_colour, tb_rtl_reuleaux.dut.vga_colour);
                err = 1'b1;
            end
            if (tb_rtl_reuleaux.dut.done !== exp_done) begin
                $display("ERROR E: Expected done is %b, actual done is %b", exp_done, tb_rtl_reuleaux.dut.done);
                err = 1'b1;
            end
            if (tb_rtl_reuleaux.dut.vga_plot !== exp_plot) begin
                $display("ERROR F: Expected vga_plot is %b, actual vga_plot is %b", exp_plot, tb_rtl_reuleaux.dut.vga_plot);
                err = 1'b1;
            end
        end
    endtask

    task circle_in_validator;
        input [31:0] index;
        input [7:0] exp_curr_cx, exp_min_x, exp_max_x;
        input [6:0] exp_curr_cy, exp_min_y, exp_max_y;
        $display("CASE %d", index);
        if (tb_rtl_reuleaux.dut.curr_cx !== exp_curr_cx) begin
            $display("C ERROR A: Expected curr_cx is %d, actual curr_cx is %d", exp_curr_cx, tb_rtl_reuleaux.dut.curr_cx);
            err = 1'b1;
        end
        if (tb_rtl_reuleaux.dut.min_x !== exp_min_x) begin
            $display("C ERROR C: Expected min_x is %d, actual min_x is %d", exp_min_x, tb_rtl_reuleaux.dut.min_x);
            err = 1'b1;
        end
        if (tb_rtl_reuleaux.dut.max_x !== exp_max_x) begin
            $display("C ERROR D: Expected max_x is %d, actual max_x is %d", exp_max_x, tb_rtl_reuleaux.dut.max_x);
            err = 1'b1;
        end
        if (tb_rtl_reuleaux.dut.curr_cy !== exp_curr_cy) begin
            $display("C ERROR B: Expected curr_cy is %d, actual curr_cy is %d", exp_curr_cy, tb_rtl_reuleaux.dut.curr_cy);
            err = 1'b1;
        end
        if (tb_rtl_reuleaux.dut.min_y !== exp_min_y) begin
            $display("C ERROR E: Expected min_y is %d, actual min_y is %d", exp_min_y, tb_rtl_reuleaux.dut.min_y);
            err = 1'b1;
        end
        if (tb_rtl_reuleaux.dut.max_y !== exp_max_y) begin
            $display("C ERROR F: Expected max_y is %d, actual max_y is %d", exp_max_y, tb_rtl_reuleaux.dut.max_y);
            err = 1'b1;
        end
    endtask

    // Colours
    `define BLACK    3'b000
    `define BLUE     3'b001
    `define GREEN    3'b010
    `define CYAN     3'b011
    `define RED      3'b100
    `define MAGENTA  3'b101
    `define YELLOW   3'b110
    `define WHITE    3'b111

    `define IDLE   3'b000 // Store centre_x and centre_y in register
    `define CALC   3'b001 // Calculate reuleaux triangle vertices
    `define DRAW_1 3'b010 // Draw first circle
    `define DRAW_2 3'b011
    `define DRAW_3 3'b100
    `define DONE   3'b101

    `define DIAMETER 8'd80
    `define CENTRE_X 8'd80
    `define CENTRE_Y 7'd60

    initial begin
        err = 1'b0;

        // Case 1: Undefined output, run the default branch
        rst_n = 1'bx; start = 1'bx;
        #10;
        validator(1, `IDLE, 8'b0, 7'b0, 3'bx, 1'b0, 1'b0);

        // Case 2: rst_n is asserted, start signal is set to 0
        rst_n = 1'b0; start = 1'b0;
        colour = `BLUE; centre_x = `CENTRE_X; centre_y = `CENTRE_Y; diameter = `DIAMETER;
        #10;
        validator(2, `IDLE, 8'd0, 7'd0, `BLUE, 1'b0, 1'b0);

        // Case 3: rst_n signal is removed, run !start === true branch
        rst_n = 1'b1;
        #10;
        validator(3, `IDLE, 8'd0, 7'd0, `BLUE, 1'b0, 1'b0);

        // Case 4: start signal is asserted
        start = 1'b1;
        #10; // First cycle
        validator(4, `CALC, 8'd0, 7'd0, `BLUE, 1'b0, 1'b0);
        if (tb_rtl_reuleaux.dut.c_x !== centre_x) begin
            $display("CASE 4 ERROR: Expected c_x is %b, actual c_x is %b", centre_x, tb_rtl_reuleaux.dut.c_x);
            err = 1'b1;
        end
        if (tb_rtl_reuleaux.dut.c_y !== centre_y) begin
            $display("CASE 4 ERROR: Expected c_y is %b, actual c_y is %b", centre_y, tb_rtl_reuleaux.dut.c_y);
            err = 1'b1;
        end

        // Case 5: Calculate vertices coordinates
        #10;
        validator(5, `DRAW_1, 8'd0, 7'd0, `BLUE, 1'b0, 1'b0);
        if (tb_rtl_reuleaux.dut.c_x1 !== 8'd120) begin
            $display("CASE 5 ERROR: Expected c_x1 is %d, actual c_x1 is %d", 8'd120, tb_rtl_reuleaux.dut.c_x1);
            err = 1'b1;
        end
        if (tb_rtl_reuleaux.dut.c_y1 !== 7'd83) begin
            $display("CASE 5 ERROR: Expected c_y1 is %d, actual c_y1 is %d", 7'd83, tb_rtl_reuleaux.dut.c_y1);
            err = 1'b1;
        end
        if (tb_rtl_reuleaux.dut.c_x2 !== 8'd40) begin
            $display("CASE 5 ERROR: Expected c_x2 is %d, actual c_x2 is %d", 8'd40, tb_rtl_reuleaux.dut.c_x2);
            err = 1'b1;
        end
        if (tb_rtl_reuleaux.dut.c_y2 !== 7'd83) begin
            $display("CASE 5 ERROR: Expected c_y2 is %d, actual c_y2 is %d", 7'd83, tb_rtl_reuleaux.dut.c_y2);
            err = 1'b1;
        end
        if (tb_rtl_reuleaux.dut.c_x3 !== 8'd80) begin
            $display("CASE 5 ERROR: Expected c_x3 is %d, actual c_x3 is %d", 8'd80, tb_rtl_reuleaux.dut.c_x3);
            err = 1'b1;
        end
        if (tb_rtl_reuleaux.dut.c_y3 !== 7'd14) begin
            $display("CASE 5 ERROR: Expected c_y3 is %d, actual c_y3 is %d", 7'd14, tb_rtl_reuleaux.dut.c_y3);
            err = 1'b1;
        end

        // Print out expected result
        // $display("SQRT 3 is %f, expected %f", tb_rtl_reuleaux.dut.sqrt3div3 * diameter /2, $sqrt(3)/3 * diameter /2);
        // $display("DEC SQRT is %d", tb_rtl_reuleaux.dut.sqrt3div3);
        // $display("BIN SQRT is %b", tb_rtl_reuleaux.dut.sqrt3div3);
        // $display("EXP SQRT is %b", $sqrt(3)/3);
        // $display("BIN TMP_D is %b", tb_rtl_reuleaux.dut.tmp_d);
        // $display("BIN ACT is %b", $sqrt(3)/3 * diameter /2);
        // $display("tmp is %d", tb_rtl_reuleaux.dut.tmp);
        // $display("CENTRE_X is %d", `CENTRE_X);
        // $display("CENTRE_Y is %d", `CENTRE_Y);
        // $display("CENTRE_X1 is %d", `CENTRE_X + `DIAMETER/2); // 120
        // $display("CENTRE_Y1 is %d", `CENTRE_Y + `DIAMETER * $sqrt(3)/6); // 83.09
        // $display("CENTRE_X2 is %d", `CENTRE_X - `DIAMETER/2); // 40
        // $display("CENTRE_Y2 is %d", `CENTRE_Y + `DIAMETER * $sqrt(3)/6); // 83.09
        // $display("CENTRE_X3 is %d", `CENTRE_X); // 80
        // $display("CENTRE_Y3 is %d", `CENTRE_Y - `DIAMETER * $sqrt(3)/3); // 13.81

        // Case 6: Start drawing first circle
        #10;
        validator(6, `DRAW_1, 8'bx, 7'bx, `BLUE, 1'b0, 1'b0);
        if (tb_rtl_reuleaux.dut.start_draw !== 1'b1) begin
            $display("CASE 6 ERROR: Expected start_draw is %d, actual start_draw is %d", 1'b1, tb_rtl_reuleaux.dut.start_draw);
            err = 1'b1;
        end

        // Case 7: Validate first circle module input values
        #10;
        circle_in_validator(7, 8'd120, 8'd40, 8'd80, 7'd83, 7'd14, 7'd83);

        // Case 8: Wait for done signal
        wait (tb_rtl_reuleaux.dut.done_draw === 1'b1);
        validator(8, `DRAW_1, 8'd176, 7'd26, `BLUE, 1'b0, 1'b0);
        if (tb_rtl_reuleaux.dut.draw.offset_y <= tb_rtl_reuleaux.dut.draw.offset_x) begin
            $display("CASE 8 ERROR: Expected offset_y to be less than or equal to offset_x.");
            err = 1'b1;
        end

        // Case 9: Draw second circle
        #20;
        validator(9, `DRAW_2, 8'd0, 7'd0, `BLUE, 1'b0, 1'b0);

        // Case 10: Validate second circle input values
        #10;
        circle_in_validator(10, 8'd40, 8'd80, 8'd120, 7'd83, 7'd14, 7'd83);
        if (tb_rtl_reuleaux.dut.start_draw !== 1'b1) begin
            $display("CASE 10 ERROR: Expected start_draw is %d, actual start_draw is %d", 1'b1, tb_rtl_reuleaux.dut.start_draw);
            err = 1'b1;
        end

        // Case 11: Wait for done signal
        wait (tb_rtl_reuleaux.dut.done_draw === 1'b1);
        validator(11, `DRAW_2, 8'd96, 7'd26, `BLUE, 1'b0, 1'b0);
        if (tb_rtl_reuleaux.dut.draw.offset_y <= tb_rtl_reuleaux.dut.draw.offset_x) begin
            $display("CASE 11 ERROR: Expected offset_y to be less than or equal to offset_x.");
            err = 1'b1;
        end

        // Case 12: Draw third circle
        #20;
        validator(12, `DRAW_3, 8'd0, 7'd0, `BLUE, 1'b0, 1'b0);

        // Case 13: Validate third circle input values
        #10;
        circle_in_validator(13, 8'd80, 8'd40, 8'd120, 7'd14, 7'd83, 7'd119);
        if (tb_rtl_reuleaux.dut.start_draw !== 1'b1) begin
            $display("CASE 13 ERROR: Expected start_draw is %d, actual start_draw is %d", 1'b1, tb_rtl_reuleaux.dut.start_draw);
            err = 1'b1;
        end

        // Case 14: Wait for done signal
        wait (tb_rtl_reuleaux.dut.done_draw === 1'b1);
        validator(14, `DRAW_3, 8'd136, 7'd85, `BLUE, 1'b0, 1'b0);
        if (tb_rtl_reuleaux.dut.draw.offset_y <= tb_rtl_reuleaux.dut.draw.offset_x) begin
            $display("CASE 14 ERROR: Expected offset_y to be less than or equal to offset_x.");
            err = 1'b1;
        end

        // Case 15: Verify done signal
        #20;
        validator(15, `DONE, 8'd0, 7'd0, `BLUE, 1'b1, 1'b0);

        // Case 16: Verify state remains in `DONE
        #20;
        validator(16, `DONE, 8'd0, 7'd0, `BLUE, 1'b1, 1'b0);

        // Case 17: Deassert start
        start = 0;
        #10;
        validator(17, `IDLE, 8'd0, 7'd0, `BLUE, 1'b0, 1'b0);

        // =====================================================================================================================

        // Case 18: rst_n is asserted, start signal is set to 0
        rst_n = 1'b0; start = 1'b0;
        colour = `MAGENTA; centre_x = 8'd159; centre_y = 7'd119; diameter = 8'd5;
        #10;
        validator(18, `IDLE, 8'd0, 7'd0, `MAGENTA, 1'b0, 1'b0);

        // Case 19: rst_n signal is removed, run !start === true branch
        rst_n = 1'b1;
        #10;
        validator(19, `IDLE, 8'd0, 7'd0, `MAGENTA, 1'b0, 1'b0);

        // Case 20: start signal is asserted
        start = 1'b1;
        #10; // First cycle
        validator(20, `CALC, 8'd0, 7'd0, `MAGENTA, 1'b0, 1'b0);
        if (tb_rtl_reuleaux.dut.c_x !== centre_x) begin
            $display("CASE 20 ERROR: Expected c_x is %b, actual c_x is %b", centre_x, tb_rtl_reuleaux.dut.c_x);
            err = 1'b1;
        end
        if (tb_rtl_reuleaux.dut.c_y !== centre_y) begin
            $display("CASE 20 ERROR: Expected c_y is %b, actual c_y is %b", centre_y, tb_rtl_reuleaux.dut.c_y);
            err = 1'b1;
        end

        // Case 21: Calculate vertices coordinates
        #10;
        validator(21, `DRAW_1, 8'd0, 7'd0, `MAGENTA, 1'b0, 1'b0);
        if (tb_rtl_reuleaux.dut.c_x1 !== 8'd161) begin
            $display("CASE 21 ERROR: Expected c_x1 is %d, actual c_x1 is %d", 8'd161, tb_rtl_reuleaux.dut.c_x1);
            err = 1'b1;
        end
        if (tb_rtl_reuleaux.dut.c_y1 !== 7'd120) begin
            $display("CASE 21 ERROR: Expected c_y1 is %d, actual c_y1 is %d", 7'd120, tb_rtl_reuleaux.dut.c_y1);
            err = 1'b1;
        end
        if (tb_rtl_reuleaux.dut.c_x2 !== 8'd157) begin
            $display("CASE 21 ERROR: Expected c_x2 is %d, actual c_x2 is %d", 8'd157, tb_rtl_reuleaux.dut.c_x2);
            err = 1'b1;
        end
        if (tb_rtl_reuleaux.dut.c_y2 !== 7'd120) begin
            $display("CASE 21 ERROR: Expected c_y2 is %d, actual c_y2 is %d", 7'd120, tb_rtl_reuleaux.dut.c_y2);
            err = 1'b1;
        end
        if (tb_rtl_reuleaux.dut.c_x3 !== 8'd159) begin
            $display("CASE 21 ERROR: Expected c_x3 is %d, actual c_x3 is %d", 8'd159, tb_rtl_reuleaux.dut.c_x3);
            err = 1'b1;
        end
        if (tb_rtl_reuleaux.dut.c_y3 !== 7'd116) begin
            $display("CASE 21 ERROR: Expected c_y3 is %d, actual c_y3 is %d", 7'd116, tb_rtl_reuleaux.dut.c_y3);
            err = 1'b1;
        end

        // Print out expected result
        // $display("BIN TMP_D is %b", tb_rtl_reuleaux.dut.tmp_d);
        // $display("CENTRE_X is %d", 8'd159);
        // $display("CENTRE_Y is %d", 7'd119);
        // $display("CENTRE_X1 is %d", 8'd159 + 8'd5/2); // 161
        // $display("CENTRE_Y1 is %d", 7'd119 + 8'd5 * $sqrt(3)/6); // 120
        // $display("CENTRE_X2 is %d", 8'd159 - 8'd5/2); // 157
        // $display("CENTRE_Y2 is %d", 7'd119 + 8'd5 * $sqrt(3)/6); // 120
        // $display("CENTRE_X3 is %d", 8'd159); // 159
        // $display("CENTRE_Y3 is %d", 7'd119 - 8'd5 * $sqrt(3)/3); // 116

        // Case 22: Start drawing first circle
        #10;
        validator(22, `DRAW_1, 8'd85, 7'd14, `MAGENTA, 1'b0, 1'b0);
        if (tb_rtl_reuleaux.dut.start_draw !== 1'b1) begin
            $display("CASE 22 ERROR: Expected start_draw is %d, actual start_draw is %d", 1'b1, tb_rtl_reuleaux.dut.start_draw);
            err = 1'b1;
        end

        // Case 23: Validate first circle module input values
        #10;
        circle_in_validator(23, 8'd161, 8'd157, 8'd159, 7'd120, 7'd116, 7'd120);

        // Case 24: Wait for done signal
        wait (tb_rtl_reuleaux.dut.done_draw === 1'b1);
        validator(24, `DRAW_1, 8'd164, 7'd116, `MAGENTA, 1'b0, 1'b0);
        if (tb_rtl_reuleaux.dut.draw.offset_y <= tb_rtl_reuleaux.dut.draw.offset_x) begin
            $display("CASE 24 ERROR: Expected offset_y to be less than or equal to offset_x.");
            err = 1'b1;
        end

        // Case 25: Draw second circle
        #20;
        validator(25, `DRAW_2, 8'd0, 7'd0, `MAGENTA, 1'b0, 1'b0);

        // Case 26: Validate second circle input values
        #10;
        circle_in_validator(26, 8'd157, 8'd159, 8'd161, 7'd120, 7'd116, 7'd120);
        if (tb_rtl_reuleaux.dut.start_draw !== 1'b1) begin
            $display("CASE 26 ERROR: Expected start_draw is %d, actual start_draw is %d", 1'b1, tb_rtl_reuleaux.dut.start_draw);
            err = 1'b1;
        end

        // Case 27: Wait for done signal
        wait (tb_rtl_reuleaux.dut.done_draw === 1'b1);
        validator(27, `DRAW_2, 8'd160, 7'd116, `MAGENTA, 1'b0, 1'b0);
        if (tb_rtl_reuleaux.dut.draw.offset_y <= tb_rtl_reuleaux.dut.draw.offset_x) begin
            $display("CASE 27 ERROR: Expected offset_y to be less than or equal to offset_x.");
            err = 1'b1;
        end

        // Case 28: Draw third circle
        #20;
        validator(28, `DRAW_3, 8'd0, 7'd0, `MAGENTA, 1'b0, 1'b0);

        // Case 29: Validate third circle input values
        #10;
        circle_in_validator(29, 8'd159, 8'd157, 8'd161, 7'd116, 7'd120, 7'd119);
        if (tb_rtl_reuleaux.dut.start_draw !== 1'b1) begin
            $display("CASE 29 ERROR: Expected start_draw is %d, actual start_draw is %d", 1'b1, tb_rtl_reuleaux.dut.start_draw);
            err = 1'b1;
        end

        // Case 30: Wait for done signal
        wait (tb_rtl_reuleaux.dut.done_draw === 1'b1);
        validator(30, `DRAW_3, 8'd162, 7'd112, `MAGENTA, 1'b0, 1'b0);
        if (tb_rtl_reuleaux.dut.draw.offset_y <= tb_rtl_reuleaux.dut.draw.offset_x) begin
            $display("CASE 30 ERROR: Expected offset_y to be less than or equal to offset_x.");
            err = 1'b1;
        end

        // Case 31: Verify done signal
        #20;
        validator(31, `DONE, 8'd0, 7'd0, `MAGENTA, 1'b1, 1'b0);

        // Case 32: Verify state remains in `DONE
        #20;
        validator(32, `DONE, 8'd0, 7'd0, `MAGENTA, 1'b1, 1'b0);

        // Case 33: Deassert start
        start = 0;
        #10;
        validator(33, `IDLE, 8'd0, 7'd0, `MAGENTA, 1'b0, 1'b0);

        if (~err) begin
            $display("SUCCESS: All tests passed.");
        end
        $stop;
    end

endmodule: tb_rtl_reuleaux
