module tb_rtl_fillscreen();

// Your testbench goes here. Our toplevel will give up after 1,000,000 ticks. 
    logic clk, rst_n, start, done, vga_plot, err;
    logic [2:0] colour, vga_colour;
    logic [7:0] vga_x;
    logic [6:0] vga_y;
    integer i, j, cycle_count;

    fillscreen dut(.*);

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task validator;
        input [7:0] exp_x;
        input [6:0] exp_y;
        input [2:0] exp_colour;
        input exp_done, exp_plot;
        begin
            if (tb_rtl_fillscreen.dut.vga_x !== exp_x) begin
                $display("ERROR A: Expected vga_x is %d, actual vga_x is %d", exp_x, tb_rtl_fillscreen.dut.vga_x);
                err = 1'b1;
            end
            if (tb_rtl_fillscreen.dut.vga_y !== exp_y) begin
                $display("ERROR B: Expected vga_y is %d, actual vga_y is %d", exp_y, tb_rtl_fillscreen.dut.vga_y);
                err = 1'b1;
            end
            if (tb_rtl_fillscreen.dut.vga_colour !== exp_colour) begin
                $display("ERROR C: Expected vga_colour is %d, actual vga_colour is %d", exp_colour, tb_rtl_fillscreen.dut.vga_colour);
                err = 1'b1;
            end
            if (tb_rtl_fillscreen.dut.done !== exp_done) begin
                $display("ERROR D: Expected done is %b, actual done is %b", exp_done, tb_rtl_fillscreen.dut.done);
                err = 1'b1;
            end
            if (tb_rtl_fillscreen.dut.vga_plot !== exp_plot) begin
                $display("ERROR E: Expected vga_plot is %b, actual vga_plot is %b", exp_plot, tb_rtl_fillscreen.dut.vga_plot);
                err = 1'b1;
            end
        end
    endtask

    initial begin
        err = 1'b0;
        cycle_count = 0;

        // Case 1: Undefined inputs (run default branch)
        rst_n = 1'bx; start = 1'bx;
        #10;
        validator(8'b0, 7'b0, 3'b0, 1'b0, 1'b0);

        // Case 2: rst_n and start is asserted
        rst_n = 1'b0; start = 1'b1;
        #10;
        validator(8'b0, 7'b0, 3'b0, 1'b0, 1'b0);

        // Case 3: rst_n signal is removed
        rst_n = 1'b1;
        #10; cycle_count = cycle_count + 1;
        validator(8'b0, 7'b0, 3'b0, 1'b0, 1'b1);

        for (i = 0; i < 160; i = i + 1) begin
            for (j = 0; j < 120; j = j + 1) begin
                validator(i, j, i % 8, 1'b0, 1'b1);
                #10; cycle_count = cycle_count + 1;
            end
        end

        #10; cycle_count = cycle_count + 1;
        validator(8'd0, 7'd0, 3'd0, 1'b1, 1'b0);

        start = 1'b0;
        #10;
        validator(8'd0, 7'd0, 3'd0, 1'b0, 1'b0);

        $display("TOTAL NO OF CYCLES: %d", cycle_count);

        if (~err) begin
            $display("SUCCESS: All tests passed.");
        end
        $stop;
    end

endmodule: tb_rtl_fillscreen
