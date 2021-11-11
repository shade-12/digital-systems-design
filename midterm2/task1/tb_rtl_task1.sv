`timescale 1ns / 1ns

module tb_rtl_task1();

    logic CLOCK_50=1; 
    logic [3:0] KEY=0;
    logic [9:0] SW, LEDR;
    logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    logic [7:0] VGA_R, VGA_G, VGA_B;
    logic VGA_HS, VGA_VS, VGA_CLK;
    logic [7:0] VGA_X; 
    logic [6:0] VGA_Y;
    logic [2:0] VGA_COLOUR;
    logic VGA_PLOT;

    always #10 CLOCK_50 = ~CLOCK_50;

    task1 dut(.*);

    initial
    begin
        $monitor( "monitor: reset %0d, plot=%0d, vga_x=%0d, vga_y=%0d, vga_colour=%0d, time=%0d", KEY[3], VGA_PLOT, VGA_X, VGA_Y, VGA_COLOUR, $time );

        KEY[3] = 0;
        #10 
        KEY[3] = 1;

        wait(LEDR[1]); // wait for done
        #20 // one more clock cycle
        $finish;
    end

endmodule
