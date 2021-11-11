`timescale 1 ps / 1 ps

module tb_syn_circle();

// Your testbench goes here. Our toplevel will give up after 1,000,000 ticks.
    logic clk, rst_n, start, done, vga_plot, err;
    logic [2:0] colour, vga_colour;
    logic [7:0] centre_x, radius, vga_x;
    logic [6:0] centre_y, vga_y;

    circle dut(.*);

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task validator;
        input [31:0] index;
        input [7:0] exp_x;
        input [6:0] exp_y;
        input [2:0] exp_colour;
        input exp_done, exp_plot;
        begin
            $display("CASE %d", index);
            if (tb_syn_circle.dut.vga_x !== exp_x) begin
                $display("ERROR B: Expected vga_x is %d, actual vga_x is %d", exp_x, tb_syn_circle.dut.vga_x);
                err = 1'b1;
            end
            if (tb_syn_circle.dut.vga_y !== exp_y) begin
                $display("ERROR C: Expected vga_y is %d, actual vga_y is %d", exp_y, tb_syn_circle.dut.vga_y);
                err = 1'b1;
            end
            if (tb_syn_circle.dut.vga_colour !== exp_colour) begin
                $display("ERROR D: Expected vga_colour is %d, actual vga_colour is %d", exp_colour, tb_syn_circle.dut.vga_colour);
                err = 1'b1;
            end
            if (tb_syn_circle.dut.done !== exp_done) begin
                $display("ERROR E: Expected done is %b, actual done is %b", exp_done, tb_syn_circle.dut.done);
                err = 1'b1;
            end
            if (tb_syn_circle.dut.vga_plot !== exp_plot) begin
                $display("ERROR F: Expected vga_plot is %b, actual vga_plot is %b", exp_plot, tb_syn_circle.dut.vga_plot);
                err = 1'b1;
            end
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

    initial begin
        err = 1'b0;

        // Case 1: Undefined output, run the default branch
        rst_n = 1'bx; start = 1'bx;
        #10;
        validator(1, 8'b0, 7'b0, 3'bx, 1'b0, 1'b0);

        // Case 2: rst_n is asserted, start signal is set to 0
        rst_n = 1'b0; start = 1'b0;
        colour = `BLUE; centre_x = 8'd80; centre_y = 7'd60; radius = 8'd10;
        #10;
        validator(2, 8'd0, 7'd0, `BLUE, 1'b0, 1'b0);

        // Case 3: rst_n signal is removed, run !start === true branch
        rst_n = 1'b1;
        #20;
        validator(3, 8'd0, 7'd0, `BLUE, 1'b0, 1'b0);

        // Case 4: start signal is asserted, start drawing pixel in octant 1
        start = 1'b1;
        #10;
        validator(4, 8'd90, 7'd60, `BLUE, 1'b0, 1'b1);

        // Case 5: Start drawing pixel in octant 2
        #10;
        validator(5, 8'd80, 7'd70, `BLUE, 1'b0, 1'b1);

        // Case 6: Start drawing pixel in octant 4
        #10;
        validator(6, 8'd70, 7'd60, `BLUE, 1'b0, 1'b1);

        // Case 7: Start drawing pixel in octant 3
        #10;
        validator(7, 8'd80, 7'd70, `BLUE, 1'b0, 1'b1);

        // Case 8: Start drawing pixel in octant 5
        #10;
        validator(8, 8'd70, 7'd60, `BLUE, 1'b0, 1'b1);

        // Case 9: Start drawing pixel in octant 6
        #10;
        validator(9, 8'd80, 7'd50, `BLUE, 1'b0, 1'b1);
        
        // Case 10: Start drawing pixel in octant 8
        #10;
        validator(10, 8'd90, 7'd60, `BLUE, 1'b0, 1'b1);

        // Case 11: Start drawing pixel in octant 7
        #10;
        validator(11, 8'd80, 7'd50, `BLUE, 1'b0, 1'b1);

        // Case 12: Set crit for case where crit <= 0 and draw pixel in octant 1
        #10;
        validator(12, 8'd90, 7'd61, `BLUE, 1'b0, 1'b1);

        // Case 13: Wait for done signal
        wait (tb_syn_circle.dut.done === 1'b1)
        validator(13, 8'd87, 7'd53, `BLUE, 1'b1, 1'b0);

        // ==========================================================================================================================
        
        colour = `MAGENTA; centre_x = 8'd159; centre_y = 7'd119; radius = 8'd5;
        start = 1'b0;
        #20;
        start = 1'b1;

        // Case 14: Start drawing pixel in octant 1
        #10;
        validator(14, 8'd0, 7'd64, `MAGENTA, 1'b0, 1'b0);

        // Case 15: Start drawing pixel in octant 2
        #10;
        validator(15, 8'd159, 7'd124, `MAGENTA, 1'b0, 1'b0);

        // Case 16: Start drawing pixel in octant 4
        #10;
        validator(16, 8'd154, 7'd119, `MAGENTA, 1'b0, 1'b1);

        // Case 17: Start drawing pixel in octant 3
        #10;
        validator(17, 8'd159, 7'd124, `MAGENTA, 1'b0, 1'b0);

        // Case 18: Start drawing pixel in octant 5
        #10;
        validator(18, 8'd154, 7'd119, `MAGENTA, 1'b0, 1'b1);

        // Case 19: Start drawing pixel in octant 6
        #10;
        validator(19, 8'd159, 7'd114, `MAGENTA, 1'b0, 1'b1);

        // Case 20: Start drawing pixel in octant 8
        #10;
        validator(20, 8'd164, 7'd119, `MAGENTA, 1'b0, 1'b0);

        // Case 21: Start drawing pixel in octant 7
        #10;
        validator(21, 8'd159, 7'd114, `MAGENTA, 1'b0, 1'b1);

        // Case 22: Wait for done signal
        wait (tb_syn_circle.dut.done === 1'b1)
        validator(22, 8'd162, 7'd115, `MAGENTA, 1'b1, 1'b0);

        // ======================================================================================================================

        // Case 23: Check initial state
        colour = `CYAN; centre_x = 8'd0; centre_y = 7'd0; radius = 8'd20;
        start = 0;
        #20;
        start = 1;
        validator(23, 8'd0, 7'd0, `CYAN, 1'b0, 1'b0);

        // Case 24: Start drawing pixel in octant 1
        #10;
        validator(24, 8'd0, 7'd0, `CYAN, 1'b0, 1'b1);

        // Case 25: Start drawing pixel in octant 2
        #10;
        validator(25, 8'd0, 7'd20, `CYAN, 1'b0, 1'b1);

        // Case 26: Start drawing pixel in octant 4
        #10;
        validator(26, -20, 7'd0, `CYAN, 1'b0, 1'b0);

        // Case 27: Start drawing pixel in octant 3
        #10;
        validator(27, 8'd0, 7'd20, `CYAN, 1'b0, 1'b1);

        // Case 28: Start drawing pixel in octant 5
        #10;
        validator(28, -20, 7'd0, `CYAN, 1'b0, 1'b0);

        // Case 29: Start drawing pixel in octant 6
        #10;
        validator(29, 8'd0, -20, `CYAN, 1'b0, 1'b0);

        // Case 30: Start drawing pixel in octant 8
        #10;
        validator(30, 8'd20, 7'd0, `CYAN, 1'b0, 1'b1);

        // Case 31: Start drawing pixel in octant 7
        #10;
        validator(31, 8'd0, -20, `CYAN, 1'b0, 1'b0);

        // Case 32: Wait for done signal
        wait (tb_syn_circle.dut.done === 1'b1)
        validator(32, 8'd14, 7'd114, `CYAN, 1'b1, 1'b0);

        // Case 33: Stay in `DONE and keep start signal high
        #20;
        validator(33, 8'd0, 7'd0, `CYAN, 1'b1, 1'b0);

        if (~err) begin
            $display("SUCCESS: All tests passed.");
        end
        $stop;
    end

endmodule: tb_syn_circle
