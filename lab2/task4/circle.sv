module circle(input logic clk, input logic rst_n, input logic [2:0] colour,
              input logic [7:0] centre_x, input logic [6:0] centre_y, input logic [7:0] radius,
              input logic [7:0] min_x, input logic [7:0] max_x, 
              input logic [6:0] min_y, input logic [6:0] max_y,
              input logic start, output logic done,
              output logic [7:0] vga_x, output logic [6:0] vga_y,
              output logic [2:0] vga_colour, output logic vga_plot);

     // All states
     `define IDLE   4'b0000  // Initial state: waiting for start signal to rise
     `define OCT_1  4'b0001  // Start drawing circle, when start signal is high
     `define OCT_2  4'b0010
     `define OCT_3  4'b0011
     `define OCT_4  4'b0100
     `define OCT_5  4'b0101
     `define OCT_6  4'b0110
     `define OCT_7  4'b0111
     `define OCT_8  4'b1000
     `define DONE   4'b1001

     `define X_BOUND 159
     `define Y_BOUND 119

     // Internal signals
     integer offset_x, offset_y, crit, val_x, val_y;
     reg [3:0] state;
     reg [1:0] out;

     // Assign wire outputs to reg
     assign { done, vga_plot } = out;
     assign vga_x = val_x[7:0];
     assign vga_y = val_y[6:0];
     assign vga_colour = colour;

     always @(posedge clk or negedge rst_n) begin
          if (!rst_n) begin
               state = `IDLE;
               offset_x = radius;
               offset_y = 0;
               crit = 1 - radius;
               val_x = 0;
               val_y = 0;
               out = 2'b0;
          end 
          else 
               case ({ state, start })
                    {`IDLE, 1'b1}: begin
                         if (offset_y > 0) begin
                              if (crit <= 0)
                                   crit = crit + 2 * offset_y + 1;
                              else begin
                                   offset_x = offset_x - 1;
                                   crit = crit + 2 * (offset_y - offset_x) + 1;
                              end 
                         end
                         if (offset_y <= offset_x) begin
                              // Draw pixel in octant 1
                              val_x = centre_x + offset_x;
                              val_y = centre_y + offset_y;
                              state = `OCT_1;
                              if (val_x < 0 || val_x > `X_BOUND || val_y < 0 || val_y > `Y_BOUND)
                                   out = 2'b0;
                              else if (val_x >= min_x && val_x <= max_x && val_y >= min_y && val_y <= max_y)
                                   out = 2'b01;
                              else
                                   out = 2'b0;
                         end else begin
                              state = `DONE;
                              out = 2'b10;
                         end
                    end
                    {`OCT_1, 1'b1}: begin
                         // Draw pixel in octant 2
                         val_x = centre_x + offset_y;
                         val_y = centre_y + offset_x;
                         state = `OCT_2;
                         if (val_x < 0 || val_x > `X_BOUND || val_y < 0 || val_y > `Y_BOUND)
                              out = 2'b0;
                         else if (val_x >= min_x && val_x <= max_x && val_y >= min_y && val_y <= max_y)
                              out = 2'b01;
                         else
                              out = 2'b0;
                    end
                    {`OCT_2, 1'b1}: begin
                         // Draw pixel in octant 4
                         val_x = centre_x - offset_x;
                         val_y = centre_y + offset_y;
                         state = `OCT_4;
                         if (val_x < 0 || val_x > `X_BOUND || val_y < 0 || val_y > `Y_BOUND)
                              out = 2'b0;
                         else if (val_x >= min_x && val_x <= max_x && val_y >= min_y && val_y <= max_y)
                              out = 2'b01;
                         else
                              out = 2'b0;
                    end
                    {`OCT_4, 1'b1}: begin
                         // Draw pixel in octant 3
                         val_x = centre_x - offset_y;
                         val_y = centre_y + offset_x;
                         state = `OCT_3;
                         if (val_x < 0 || val_x > `X_BOUND || val_y < 0 || val_y > `Y_BOUND)
                              out = 2'b0;
                         else if (val_x >= min_x && val_x <= max_x && val_y >= min_y && val_y <= max_y)
                              out = 2'b01;
                         else
                              out = 2'b0;
                    end
                    {`OCT_3, 1'b1}: begin
                         // Draw pixel in octant 5
                         val_x = centre_x - offset_x;
                         val_y = centre_y - offset_y;
                         state = `OCT_5;
                         if (val_x < 0 || val_x > `X_BOUND || val_y < 0 || val_y > `Y_BOUND)
                              out = 2'b0;
                         else if (val_x >= min_x && val_x <= max_x && val_y >= min_y && val_y <= max_y)
                              out = 2'b01;
                         else
                              out = 2'b0;
                    end
                    {`OCT_5, 1'b1}: begin
                         // Draw pixel in octant 6
                         val_x = centre_x - offset_y;
                         val_y = centre_y - offset_x;
                         state = `OCT_6;
                         if (val_x < 0 || val_x > `X_BOUND || val_y < 0 || val_y > `Y_BOUND)
                              out = 2'b0;
                         else if (val_x >= min_x && val_x <= max_x && val_y >= min_y && val_y <= max_y)
                              out = 2'b01;
                         else
                              out = 2'b0;
                    end
                    {`OCT_6, 1'b1}: begin
                         // Draw pixel in octant 8
                         val_x = centre_x + offset_x;
                         val_y = centre_y - offset_y;
                         state = `OCT_8;
                         if (val_x < 0 || val_x > `X_BOUND || val_y < 0 || val_y > `Y_BOUND)
                              out = 2'b0;
                         else if (val_x >= min_x && val_x <= max_x && val_y >= min_y && val_y <= max_y)
                              out = 2'b01;
                         else
                              out = 2'b0;
                    end
                    {`OCT_8, 1'b1}: begin
                         // Draw pixel in octant 7
                         val_x = centre_x + offset_y;
                         val_y = centre_y - offset_x;
                         state = `IDLE;
                         if (val_x < 0 || val_x > `X_BOUND || val_y < 0 || val_y > `Y_BOUND)
                              out = 2'b0;
                         else if (val_x >= min_x && val_x <= max_x && val_y >= min_y && val_y <= max_y)
                              out = 2'b01;
                         else
                              out = 2'b0;
                         offset_y = offset_y + 1;
                    end    
                    {`DONE, 1'b1}: begin
                         offset_x = radius;
                         offset_y = 0;
                         crit = 1 - radius;
                         val_x = 0;
                         val_y = 0;
                         out = 2'b10;
                    end
                    default: begin
                         state = `IDLE;
                         offset_x = radius;
                         offset_y = 0;
                         crit = 1 - radius;
                         val_x = 0;
                         val_y = 0;
                         out = 2'b0;
                    end
               endcase
     end

endmodule