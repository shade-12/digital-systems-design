`timescale 1 ps / 1 ps

module tb_syn_reuleaux();

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
        input [7:0] exp_x;
        input [6:0] exp_y;
        input [2:0] exp_colour;
        input exp_done, exp_plot;
        begin
            $display("CASE %d", index);
            if (tb_syn_reuleaux.dut.vga_x !== exp_x) begin
                $display("ERROR B: Expected vga_x is %d, actual vga_x is %d", exp_x, tb_syn_reuleaux.dut.vga_x);
                err = 1'b1;
            end
            if (tb_syn_reuleaux.dut.vga_y !== exp_y) begin
                $display("ERROR C: Expected vga_y is %d, actual vga_y is %d", exp_y, tb_syn_reuleaux.dut.vga_y);
                err = 1'b1;
            end
            if (tb_syn_reuleaux.dut.vga_colour !== exp_colour) begin
                $display("ERROR D: Expected vga_colour is %d, actual vga_colour is %d", exp_colour, tb_syn_reuleaux.dut.vga_colour);
                err = 1'b1;
            end
            if (tb_syn_reuleaux.dut.done !== exp_done) begin
                $display("ERROR E: Expected done is %b, actual done is %b", exp_done, tb_syn_reuleaux.dut.done);
                err = 1'b1;
            end
            if (tb_syn_reuleaux.dut.vga_plot !== exp_plot) begin
                $display("ERROR F: Expected vga_plot is %b, actual vga_plot is %b", exp_plot, tb_syn_reuleaux.dut.vga_plot);
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

    `define DIAMETER 8'd80
    `define CENTRE_X 8'd80
    `define CENTRE_Y 7'd60

    initial begin
        err = 1'b0;

        // Case 1: Undefined output, run the default branch
        rst_n = 1'bx; start = 1'bx;
        #10;
        validator(1, 8'b0, 7'b0, 3'bx, 1'b0, 1'b0);

        // Case 2: rst_n is asserted, start signal is set to 0
        rst_n = 1'b0; start = 1'b0;
        colour = `BLUE; centre_x = `CENTRE_X; centre_y = `CENTRE_Y; diameter = `DIAMETER;
        #10;
        validator(2, 8'd0, 7'd0, `BLUE, 1'b0, 1'b0);

        // Case 3: rst_n signal is removed, run !start === true branch
        rst_n = 1'b1;
        #10;
        validator(3, 8'd0, 7'd0, `BLUE, 1'b0, 1'b0);

        // Case 4: start signal is asserted
        start = 1'b1;
        #10; // First cycle
        validator(4, 8'd0, 7'd0, `BLUE, 1'b0, 1'b0);

        // Case 5: Calculate vertices coordinates
        #10;
        validator(5, 8'd0, 7'd0, `BLUE, 1'b0, 1'b0);

        // Case 6: Start drawing first circle
        #10;
        validator(6, 8'd80, 7'b0, `BLUE, 1'b0, 1'b0);

        // Case 7: Wait for done signal
        wait (tb_syn_reuleaux.dut.done === 1'b1);
        validator(7, 8'd0, 7'd0, `BLUE, 1'b1, 1'b0);

        // Case 8: Verify done signal
        #20;
        validator(8, 8'd0, 7'd0, `BLUE, 1'b1, 1'b0);

        // Case 9: Verify state remains in `DONE
        #20;
        validator(9, 8'd0, 7'd0, `BLUE, 1'b1, 1'b0);

        // Case 10: Deassert start
        start = 0;
        #20;
        validator(10, 8'd0, 7'd0, `BLUE, 1'b0, 1'b0);

        if (~err) begin
            $display("SUCCESS: All tests passed.");
        end
        $stop;
    end

endmodule: tb_syn_reuleaux
