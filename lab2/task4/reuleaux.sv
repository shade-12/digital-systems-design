module reuleaux(input logic clk, input logic rst_n, input logic [2:0] colour,
                input logic [7:0] centre_x, input logic [6:0] centre_y, input logic [7:0] diameter,
                input logic start, output logic done,
                output logic [7:0] vga_x, output logic [6:0] vga_y,
                output logic [2:0] vga_colour, output logic vga_plot);

     /**
      * To draw reuleaux triangle:
      * 1. When start is asserted, initialize c_x and c_y to centre_x and centre_y.
      * 2. Find x and y coordinates for all three vertices (also the centre of all three circles to be drawn), 
      *    A, B and C of the reuleaux triangle.
      * 3. Start drawing the three circles with radius = diameter / 2.
      * 4. For circle with centre at (Ax, Ay), only assert plot when pixel to be plotted has value
      *    between (Bx, By) and (Cx, Cy).
      * 5. Plot the other two circles in the same way as circle A.
      * 6. Assert done signal when the last pixel has been plotted.
      *
     */

     // All states
     `define IDLE   3'b000 // Store centre_x and centre_y in register
     `define CALC   3'b001 // Calculate reuleaux triangle vertices
     `define DRAW_1 3'b010 // Draw first circle
     `define DRAW_2 3'b011
     `define DRAW_3 3'b100
     `define DONE   3'b101

     // Internal signals
     reg [31:0] tmp, tmp_d;
     reg [2:0] state;
     reg [18:0] sqrt3div3; // [18:11] integer bits, [10:0] fraction bits
     reg [7:0] c_x, c_x1, c_x2, c_x3, curr_cx, d, r, min_x, max_x, rounded_tmp;
     reg [6:0] c_y, c_y1, c_y2, c_y3, curr_cy, min_y, max_y, rounded_tmp_d;
     reg done_draw, done_out, start_draw;

     assign done = done_out;
     assign r = d >> 1;

     always @(*) begin
          case (state)
               `IDLE: start_draw <= 0;
               `CALC: start_draw <= 0;
               `DRAW_1: start_draw <= !done_draw;
               `DRAW_2: start_draw <= !done_draw;
               `DRAW_3: start_draw <= 1'b1;
               `DONE: start_draw <= 1'b1;
               default: start_draw <= 0;
          endcase
     end

     assign sqrt3div3 = {{8{1'b0}}, 11'b10010011110};
     assign tmp = ({r, {11{1'b0}}} * sqrt3div3); // tmp[31:22] is the integer part
     assign tmp_d = ({d, {11{1'b0}}} * sqrt3div3);
     assign rounded_tmp = (tmp[21] == 1'b1) ? tmp[29:22] + 1'b1 : tmp[29:22]; // Round up if MSB is 1
     assign rounded_tmp_d = (tmp_d[21] == 1'b1) ? tmp_d[29:22] + 1'b1 : tmp_d[29:22];

     // Each draw get 3 extra cycles than total cycles required to draw all the pixels for a circle
     circle draw(.clk(clk),
                 .rst_n(rst_n),
                 .colour(colour),
                 .centre_x(curr_cx),
                 .centre_y(curr_cy),
                 .radius(d),
                 .min_x(min_x),
                 .max_x(max_x),
                 .min_y(min_y),
                 .max_y(max_y),
                 .start(start_draw),
                 .done(done_draw),
                 .vga_x(vga_x),
                 .vga_y(vga_y),
                 .vga_colour(vga_colour),
                 .vga_plot(vga_plot));

     always @(posedge clk or negedge rst_n)
          if (!rst_n) begin
               state <= `IDLE;
               done_out <= 0;
          end
          else
               case ({ state, start })
                    {`IDLE, 1'b1}: begin
                         // 1st extra cycle
                         state <= `CALC;
                         c_x <= centre_x;
                         c_y <= centre_y;
                         d <= diameter;
                         done_out <= 0;
                    end
                    {`CALC, 1'b1}: begin
                         // 2nd extra cycle
                         state <= `DRAW_1;
                         c_x1 <= c_x + r;
                         c_y1 <= c_y + rounded_tmp;
                         c_x2 <= c_x - r;
                         c_y2 <= c_y + rounded_tmp;
                         c_x3 <= c_x;
                         c_y3 <= c_y - rounded_tmp_d;
                         done_out <= 0;
                    end
                    {`DRAW_1, 1'b1}: begin
                         // 3rd extra cycle
                         if (done_draw == 1'b1) begin
                              state <= `DRAW_2;
                         end else begin
                              curr_cx <= c_x1;
                              curr_cy <= c_y1;
                              min_x <= c_x2;
                              max_x <= c_x3;
                              min_y <= c_y3;
                              max_y <= c_y2;
                         end
                         done_out <= 0;
                    end
                    {`DRAW_2, 1'b1}: begin
                         // 4th extra cycle
                         if (done_draw == 1'b1) begin
                              state <= `DRAW_3;
                         end else begin
                              curr_cx <= c_x2;
                              curr_cy <= c_y2;
                              min_x <= c_x3;
                              max_x <= c_x1;
                              min_y <= c_y3;
                              max_y <= c_y1;
                         end
                         done_out <= 0;
                    end
                    {`DRAW_3, 1'b1}: begin
                         // 5th extra cycle
                         if (done_draw == 1'b1) begin
                              state <= `DONE;
                              done_out <= 1'b1;
                         end else begin
                              curr_cx <= c_x3;
                              curr_cy <= c_y3;
                              min_x <= c_x2;
                              max_x <= c_x1;
                              min_y <= c_y1;
                              max_y <= 7'd119;
                              done_out <= 0;
                         end
                    end
                    {`DONE, 1'b1}: begin
                         done_out <= 1'b1;
                    end
                    default: begin
                         state <= `IDLE;
                         done_out <= 0;
                    end
               endcase

endmodule

