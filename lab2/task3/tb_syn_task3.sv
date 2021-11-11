`timescale 1 ps / 1 ps

module tb_syn_task3();

// Your testbench goes here. Our toplevel will give up after 1,000,000 ticks.
    logic CLOCK_50, VGA_HS, VGA_VS, VGA_CLK, VGA_PLOT, err;
    logic [3:0] KEY;
    logic [9:0] SW, LEDR;
    logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, VGA_Y;
    logic [7:0] VGA_R, VGA_G, VGA_B, VGA_X;
    logic [2:0] VGA_COLOUR;
    integer i, j, cycle_count;

    task3 dut(.*);

    initial begin
        CLOCK_50 = 0;
        forever #5 CLOCK_50 = ~CLOCK_50;
    end

    task validator;
        input [7:0] exp_x;
        input [6:0] exp_y;
        input [2:0] exp_colour;
        input exp_plot;
        begin
            if (tb_syn_task3.dut.VGA_X !== exp_x) begin
                $display("ERROR A: Expected VGA_X is %d, actual VGA_X is %d at x =%d, y =%d", exp_x, tb_syn_task3.dut.VGA_X, i, j);
                err = 1'b1;
            end
            if (tb_syn_task3.dut.VGA_Y !== exp_y) begin
                $display("ERROR B: Expected VGA_Y is %d, actual VGA_Y is %d at x =%d, y =%d", exp_y, tb_syn_task3.dut.VGA_Y, i, j);
                err = 1'b1;
            end
            if (tb_syn_task3.dut.VGA_COLOUR !== exp_colour) begin
                $display("ERROR C: Expected VGA_COLOUR is %d, actual VGA_COLOUR is %d at x =%d, y =%d", exp_colour, tb_syn_task3.dut.VGA_COLOUR, i, j);
                err = 1'b1;
            end
            if (tb_syn_task3.dut.VGA_PLOT !== exp_plot) begin
                $display("ERROR D: Expected VGA_PLOT is %b, actual VGA_PLOT is %b at x =%d, y =%d", exp_plot, tb_syn_task3.dut.VGA_PLOT, i, j);
                err = 1'b1;
            end
        end
    endtask

    `define BLACK    3'b000
    `define GREEN    3'b010

    initial begin
        err = 1'b0;
        cycle_count = 0;

        // Case 1: Undefined rst_n (run default branch)
        KEY[3] = 1'bx;
        #10;
        validator(8'b0, 7'b0, 3'b0, 1'b0);

        // Case 2: KEY[3](rst_n) is asserted
        KEY[3] = 1'b0;
        #10;
        validator(8'b0, 7'b0, 3'b0, 1'b0);

        // Case 3: KEY[3](rst_n) signal is removed
        KEY[3] = 1'b1;
        #10; cycle_count = cycle_count + 1;
        validator(8'b0, 7'b0, 3'b0, 1'b1);

        for (i = 0; i < 160; i = i + 1) begin
            for (j = 0; j < 120; j = j + 1) begin
                validator(i, j, `BLACK, 1'b1);
                #10; cycle_count = cycle_count + 1;
            end
        end

        // Case 4: As soon as done is asserted, output colour will change to green 
        //         and start_draw is asserted
        #10; cycle_count = cycle_count + 1;
        validator(8'd0, 7'd0, `GREEN, 1'b0);

        // Case 5: Start drawing circle in octant 1
        #10;
        $display("CASE 5");
        validator(8'd120, 7'd60, `GREEN, 1'b1);

        // Case 6: Start drawing circle in octant 2
        #10;
        $display("CASE 6");
        validator(8'd80, 7'd100, `GREEN, 1'b1);

        // Case 7: Start drawing circle in octant 4
        #10;
        $display("CASE 7");
        validator(8'd40, 7'd60, `GREEN, 1'b1);

        // Case 8: Start drawing circle in octant 3
        #10;
        $display("CASE 8");
        validator(8'd80, 7'd100, `GREEN, 1'b1);

        // Case 9: Start drawing circle in octant 5
        #10;
        $display("CASE 9");
        validator(8'd40, 7'd60, `GREEN, 1'b1);

        // Case 10: Start drawing circle in octant 6
        #10;
        $display("CASE 10");
        validator(8'd80, 7'd20, `GREEN, 1'b1);

        // case 11: Start drawing circle in octant 8
        #10;
        $display("CASE 11");
        validator(8'd120, 7'd60, `GREEN, 1'b1);

        // Case 12: Start drawing circle in octant 7
        #10;
        $display("CASE 12");
        validator(8'd80, 7'd20, `GREEN, 1'b1);

        // Case 13: Last pixel to plot is (108, 31)
        wait (tb_syn_task3.dut.VGA_X == 8'd108 && tb_syn_task3.dut.VGA_Y == 7'd31);
        $display("CASE 13");
        validator(8'd108, 7'd31, `GREEN, 1'b1); // Plot the last pixel

        // Case 14: Output remains
        #20; // plot (1 cycle) + assert done (1 cycle)
        $display("CASE 14");
        validator(8'd108, 7'd31, `GREEN, 1'b0);

        $display("TOTAL NO OF CYCLES: %d", cycle_count);

        if (~err) begin
            $display("SUCCESS: All tests passed.");
        end
        $stop;
    end

endmodule: tb_syn_task3
