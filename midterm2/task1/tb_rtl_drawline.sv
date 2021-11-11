`timescale 1ps / 1ps

module tb_rtl_drawline();

    logic clk=0;
    logic rst_n=1;
    logic [2:0] colour,vga_colour;
    logic [7:0] x0, x1, vga_x;
    logic [6:0] y0, y1, vga_y;
    logic start, done, vga_plot;

    always #5 clk = ~clk;

    drawline dut(.*);

    initial
    begin
        start=0;
        colour = 2;
        rst_n = 0;
        #10
        rst_n = 1;

        x0 = 59; x1 = 50; y0=20; y1=25; start=1; wait(done); start=0; wait(!done);
        x0 = 59; x1 = 50; y0=25; y1=20; start=1; wait(done); start=0; wait(!done);
        x0 = 50; x1 = 59; y0=20; y1=25; start=1; wait(done); start=0; wait(!done);
        x0 = 50; x1 = 59; y0=25; y1=20; start=1; wait(done); start=0; wait(!done);

        #20;
        $display(done);
        $stop;
    end

endmodule: tb_rtl_drawline
