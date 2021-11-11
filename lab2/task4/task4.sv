module task4(input logic CLOCK_50, input logic [3:0] KEY,
             input logic [9:0] SW, output logic [9:0] LEDR,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [7:0] VGA_R, output logic [7:0] VGA_G, output logic [7:0] VGA_B,
             output logic VGA_HS, output logic VGA_VS, output logic VGA_CLK,
             output logic [7:0] VGA_X, output logic [6:0] VGA_Y,
             output logic [2:0] VGA_COLOUR, output logic VGA_PLOT);

    `define BLACK    3'b000
    `define GREEN    3'b010

    reg done_fill, start_fill, done_draw, start_draw;
    wire rst_n, fs_plot_out, r_plot_out;
    wire [7:0] fs_x_out, r_x_out;
    wire [6:0] fs_y_out, r_y_out;
    wire [2:0] fs_colour_out, r_colour_out;

    logic [9:0] VGA_R_10;
    logic [9:0] VGA_G_10;
    logic [9:0] VGA_B_10;
    logic VGA_BLANK, VGA_SYNC;

    assign rst_n = KEY[3];
    assign VGA_R = VGA_R_10[9:2];
    assign VGA_G = VGA_G_10[9:2];
    assign VGA_B = VGA_B_10[9:2];

    assign start_fill = 1'b1;
    assign start_draw = done_fill;

    assign LEDR[0] = done_draw;

    assign VGA_X = done_fill ? r_x_out : fs_x_out;
    assign VGA_Y = done_fill ? r_y_out : fs_y_out;
    assign VGA_PLOT = done_fill ? r_plot_out : fs_plot_out;
    assign VGA_COLOUR = done_fill ? r_colour_out : fs_colour_out;

    fillscreen fs(.clk(CLOCK_50), 
                  .rst_n(rst_n),
                  .colour(`BLACK),
                  .start(start_fill),
                  .done(done_fill),
                  .vga_x(fs_x_out),
                  .vga_y(fs_y_out),
                  .vga_colour(fs_colour_out),
                  .vga_plot(fs_plot_out));

    reuleaux draw(.clk(CLOCK_50),
                  .rst_n(rst_n),
                  .colour(`GREEN),
                  .centre_x(8'd80),
                  .centre_y(7'd60),
                  .diameter(8'd80),
                  .start(start_draw),
                  .done(done_draw),
                  .vga_x(r_x_out),
                  .vga_y(r_y_out),
                  .vga_colour(r_colour_out),
                  .vga_plot(r_plot_out));

    vga_adapter#(.RESOLUTION("160x120")) vga_u0(.resetn(rst_n),
                                                .clock(CLOCK_50),
                                                .colour(VGA_COLOUR),
                                                .x(VGA_X),
                                                .y(VGA_Y),
                                                .plot(VGA_PLOT),
                                                .VGA_R(VGA_R_10),
                                                .VGA_G(VGA_G_10),
                                                .VGA_B(VGA_B_10),
                                                .*);

endmodule: task4
