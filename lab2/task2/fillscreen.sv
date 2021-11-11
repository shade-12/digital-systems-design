module fillscreen(input logic clk, input logic rst_n, input logic [2:0] colour,
                  input logic start, output logic done,
                  output logic [7:0] vga_x, output logic [6:0] vga_y,
                  output logic [2:0] vga_colour, output logic vga_plot);

     // All states
     `define WAIT 2'b00  // Initial state: waiting for start signal to rise
     `define FILL 2'b01  // Start filling the screen, when start signal is high
     `define DONE 2'b10  // On the same clk cycle to draw the last pixel

     /* To write to framebuffer:
      * 1. Drive the vga_x output.
      * 2. Drive the vga_y output.
      * 3. Set vga_colour.
      * 4. Raise the vga_plot signal.
      * 5. At the next rising clk edge, new vga_colour will be written to framebuffer.
      */
     
     // Internal signals
     reg [7:0] current_x;
     reg [6:0] current_y;
     reg [1:0] state, out;

     // Assign wire outputs to reg
     assign { done, vga_plot } = out;
     assign vga_x = current_x;
     assign vga_y = current_y;
     assign vga_colour = current_x[2:0];

     always @(posedge clk or negedge rst_n) begin
          if (!rst_n) begin
               state <= `WAIT;
               current_x <= 8'b0;
               current_y <= 7'b0;
               out <= 2'b0;
          end 
          else begin
               case ({ state, start })
                    {`WAIT, 1'b1}: state <= `FILL;
                    {`FILL, 1'b1}:
                         if (current_y !== 7'd119)
                              current_y++;
                         else begin
                              if (current_x == 8'd159 && current_y == 7'd119)
                                   state <= `DONE;
                              else begin
                                   current_x++;
                                   current_y <= 7'b0;
                              end  
                         end
                    {`DONE, 1'b1}: begin
                         current_x <= 8'b0;
                         current_y <= 7'b0;
                    end
                    default: begin
                         state <= `WAIT;
                         current_x <= 8'b0;
                         current_y <= 7'b0;
                    end
               endcase

               case ({ state, start })
                    {`WAIT, 1'b1}: out <= 2'b01;
                    {`FILL, 1'b1}: out <= 2'b01;
                    {`DONE, 1'b1}: out <= 2'b10;
                    default: out <= 2'b0;
               endcase
          end
     end

endmodule

