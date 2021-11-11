`timescale 1 ps / 1 ps

module tb_rtl_task2();

// Your testbench goes here. Our toplevel will give up after 1,000,000 ticks.
    logic CLOCK_50, VGA_HS, VGA_VS, VGA_CLK, VGA_PLOT, err;
    logic [3:0] KEY;
    logic [9:0] SW, LEDR;
    logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, VGA_Y;
    logic [7:0] VGA_R, VGA_G, VGA_B, VGA_X;
    logic [2:0] VGA_COLOUR;
    integer i, j, cycle_count;

    task2 dut(.*);

    initial begin
        CLOCK_50 = 0;
        forever #5 CLOCK_50 = ~CLOCK_50;
    end

    task validator;
        input [7:0] exp_x;
        input [6:0] exp_y;
        input [2:0] exp_colour;
        input exp_done, exp_plot;
        begin
            if (tb_rtl_task2.dut.VGA_X !== exp_x) begin
                $display("ERROR A: Expected VGA_X is %d, actual VGA_X is %d", exp_x, tb_rtl_task2.dut.VGA_X);
                err = 1'b1;
            end
            if (tb_rtl_task2.dut.VGA_Y !== exp_y) begin
                $display("ERROR B: Expected VGA_Y is %d, actual VGA_Y is %d", exp_y, tb_rtl_task2.dut.VGA_Y);
                err = 1'b1;
            end
            if (tb_rtl_task2.dut.VGA_COLOUR !== exp_colour) begin
                $display("ERROR C: Expected VGA_COLOUR is %d, actual VGA_COLOUR is %d", exp_colour, tb_rtl_task2.dut.VGA_COLOUR);
                err = 1'b1;
            end
            if (tb_rtl_task2.dut.done !== exp_done) begin
                $display("ERROR D: Expected done is %b, actual done is %b", exp_done, tb_rtl_task2.dut.done);
                err = 1'b1;
            end
            if (tb_rtl_task2.dut.VGA_PLOT !== exp_plot) begin
                $display("ERROR E: Expected VGA_PLOT is %b, actual VGA_PLOT is %b", exp_plot, tb_rtl_task2.dut.VGA_PLOT);
                err = 1'b1;
            end
        end
    endtask

    initial begin
        err = 1'b0;
        cycle_count = 0;

        // Case 1: Undefined rst_n (run default branch)
        KEY[3] = 1'bx;
        #10;
        validator(8'b0, 7'b0, 3'b0, 1'b0, 1'b0);
        if (tb_rtl_task2.dut.start !== 1'b1) begin
            $display("ERROR 1: Expected start is %b, actual start is %b", 1'b1, tb_rtl_task2.dut.start);
            err = 1'b1;
        end

        // Case 2: KEY[3](rst_n) is asserted
        KEY[3] = 1'b0;
        #10;
        validator(8'b0, 7'b0, 3'b0, 1'b0, 1'b0);
        if (tb_rtl_task2.dut.start !== 1'b1) begin
            $display("ERROR 2: Expected start is %b, actual start is %b", 1'b1, tb_rtl_task2.dut.start);
            err = 1'b1;
        end

        // Case 3: KEY[3](rst_n) signal is removed
        KEY[3] = 1'b1;
        #10; cycle_count = cycle_count + 1;
        validator(8'b0, 7'b0, 3'b0, 1'b0, 1'b1);
        if (tb_rtl_task2.dut.start !== 1'b1) begin
            $display("ERROR 3: Expected start is %b, actual start is %b", 1'b1, tb_rtl_task2.dut.start);
            err = 1'b1;
        end

        for (i = 0; i < 160; i = i + 1) begin
            for (j = 0; j < 120; j = j + 1) begin
                validator(i, j, i % 8, 1'b0, 1'b1);
                #10; cycle_count = cycle_count + 1;
            end
        end

        #10; cycle_count = cycle_count + 1;
        validator(8'd0, 7'd0, 3'd0, 1'b1, 1'b0);
        if (tb_rtl_task2.dut.start !== 1'b0) begin
            $display("ERROR 4: Expected start is %b, actual start is %b", 1'b0, tb_rtl_task2.dut.start);
            err = 1'b1;
        end

        #10;
        validator(8'd0, 7'd0, 3'd0, 1'b0, 1'b0);
        if (tb_rtl_task2.dut.start !== 1'b1) begin
            $display("ERROR 5: Expected start is %b, actual start is %b", 1'b1, tb_rtl_task2.dut.start);
            err = 1'b1;
        end

        $display("TOTAL NO OF CYCLES: %d", cycle_count);

        if (~err) begin
            $display("SUCCESS: All tests passed.");
        end
        $stop;
    end

endmodule: tb_rtl_task2
