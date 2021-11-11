module task1(input logic CLOCK_50, input logic [3:0] KEY, // KEY[3] is active-low reset
             input logic [9:0] SW, output logic [9:0] LEDR,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [7:0] VGA_R, output logic [7:0] VGA_G, output logic [7:0] VGA_B,
             output logic VGA_HS, output logic VGA_VS, output logic VGA_CLK,
             output logic [7:0] VGA_X, output logic [6:0] VGA_Y,
             output logic [2:0] VGA_COLOUR, output logic VGA_PLOT);

    `define RED 3'b100

    logic VGA_BLANK, VGA_SYNC;
    logic [9:0] VGA_R_10, VGA_G_10, VGA_B_10;
    assign VGA_R = VGA_R_10[9:2];
    assign VGA_G = VGA_G_10[9:2];
    assign VGA_B = VGA_B_10[9:2];

    logic clock, resetn, done, start;
    assign clock = CLOCK_50;
    assign resetn = KEY[3];
    assign LEDR[0] = start;
    assign LEDR[1] = done;

    // After reset, it should automatically trigger the drawline module to draw a line from (80,90) to (60,65).
    always @(posedge clock)
        if (resetn == 1'b0)
            start <= 1'b1;
        else
            start <= 1'b0;

    drawline  MyDrawLine(.clk(clock), 
                         .rst_n(resetn),
                         .colour(`RED),
                         .x0(8'd80), 
                         .y0(7'd90),
                         .x1(8'd60),
                         .y1(7'd65),
                         .start(start), 
                         .done(done),
                         .vga_x(VGA_X),
                         .vga_y(VGA_Y),
                         .vga_colour(VGA_COLOUR),
                         .vga_plot(VGA_PLOT));

    // Asynchoronours reset only for vga_adapter
    vga_adapter#(.RESOLUTION("160x120")) MyVGA(.resetn(resetn),
                                               .clock(clock),
                                               .colour(VGA_COLOUR),
                                               .x(VGA_X),
                                               .y(VGA_Y),
                                               .plot(VGA_PLOT),
                                               .VGA_R(VGA_R_10),
                                               .VGA_G(VGA_G_10),
                                               .VGA_B(VGA_B_10),
                                               .*);


endmodule: task1
