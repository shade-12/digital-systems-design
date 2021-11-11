`timescale 1 ps / 1 ps

module tb_syn_task4();

// Your testbench goes here. Our toplevel will give up after 1,000,000 ticks.
    logic CLOCK_50, VGA_HS, VGA_VS, VGA_CLK, VGA_PLOT, err;
    logic [3:0] KEY;
    logic [9:0] SW, LEDR;
    logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, VGA_Y;
    logic [7:0] VGA_R, VGA_G, VGA_B, VGA_X;
    logic [2:0] VGA_COLOUR;
    integer i, j;

    task4 dut(.*);

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
            if (tb_syn_task4.dut.VGA_X !== exp_x) begin
                $display("ERROR A: Expected VGA_X is %d, actual VGA_X is %d at x =%d, y =%d", exp_x, tb_syn_task4.dut.VGA_X, i, j);
                err = 1'b1;
            end
            if (tb_syn_task4.dut.VGA_Y !== exp_y) begin
                $display("ERROR B: Expected VGA_Y is %d, actual VGA_Y is %d at x =%d, y =%d", exp_y, tb_syn_task4.dut.VGA_Y, i, j);
                err = 1'b1;
            end
            if (tb_syn_task4.dut.VGA_COLOUR !== exp_colour) begin
                $display("ERROR C: Expected VGA_COLOUR is %d, actual VGA_COLOUR is %d at x =%d, y =%d", exp_colour, tb_syn_task4.dut.VGA_COLOUR, i, j);
                err = 1'b1;
            end
            if (tb_syn_task4.dut.VGA_PLOT !== exp_plot) begin
                $display("ERROR E: Expected VGA_PLOT is %b, actual VGA_PLOT is %b at x =%d, y =%d", exp_plot, tb_syn_task4.dut.VGA_PLOT, i, j);
                err = 1'b1;
            end
        end
    endtask

    `define BLACK    3'b000
    `define GREEN    3'b010

    initial begin
        err = 1'b0;

        // Case 1: Undefined rst_n (run default branch)
        KEY[3] = 1'bx;
        #10;
        $display("CASE 1");
        validator(8'b0, 7'b0, 3'b0, 1'b0);

        // Case 2: KEY[3](rst_n) is asserted
        KEY[3] = 1'b0;
        #10;
        $display("CASE 2");
        validator(8'b0, 7'b0, 3'b0, 1'b0);

        // Case 3: KEY[3](rst_n) signal is removed
        KEY[3] = 1'b1;
        #10;
        $display("CASE 3");
        validator(8'b0, 7'b0, 3'b0, 1'b1);

        for (i = 0; i < 160; i = i + 1) begin
            for (j = 0; j < 120; j = j + 1) begin
                validator(i, j, `BLACK, 1'b1);
                #10;
            end
        end

        // Case 4: As soon as done is asserted, output colour will change to green 
        //         and start_draw is asserted
        #10;
        $display("CASE 4");
        validator(8'd0, 7'd0, `GREEN, 1'b0);

        // Case 5: Start drawing reuleaux triangle
        #10;
        $display("CASE 5");
        validator(8'd0, 7'd0, `GREEN, 1'b0);

        // Case 6: Done draw
        wait (tb_syn_task4.dut.LEDR[0] == 1'b1);
        $display("CASE 6");
        validator(8'd136, 7'd85, `GREEN, 1'b0);

        // Case 7: Done stays high
        #20;
        $display("CASE 7");
        if (tb_syn_task4.dut.LEDR[0] !== 1'b1) begin
            $display("ERROR E: Expected done_draw is %b, actual done_draw is %b", 1'b1, tb_syn_task4.dut.LEDR[0]);
            err = 1'b1;
        end

        if (~err) begin
            $display("SUCCESS: All tests passed.");
        end
        $stop;
    end

endmodule: tb_syn_task4
