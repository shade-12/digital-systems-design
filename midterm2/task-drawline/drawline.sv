module drawline(
        input logic clk, input logic rst_n,
        input logic [2:0] colour,
        input logic [7:0] x0, input logic [6:0] y0,
        input logic [7:0] x1, input logic [6:0] y1,
        input logic start, output logic done,
        output logic [7:0] vga_x, output logic [6:0] vga_y,
        output logic [2:0] vga_colour, output logic vga_plot
    );

    // All states
    `define IDLE 2'b00 
    `define CALC 2'b01
    `define DRAW 2'b10 
    `define DONE 2'b11

    `define X_BOUND 159
    `define Y_BOUND 119

    integer dx, dy, sx, sy, err, tmp_dx, tmp_dy, e2;
    reg [1:0] state, out;
    reg [2:0] str_colour;
    reg [7:0] max_x, min_x, x;
    reg [6:0] max_y, min_y, y;

    assign { vga_x, vga_y, vga_colour } = { x, y, str_colour };
    assign { vga_plot, done } = out;

    // Use synchronous reset
    always @(posedge clk) begin
        if (rst_n == 1'b0) begin
            state = `IDLE;
            x = 8'b0;
            y = 7'b0;
            str_colour = 3'b0;
            out = 2'b0;
        end else begin
            case ({state, start})
                {`IDLE, 1'b1}: begin
                    state = `DRAW;
                    str_colour = colour;
                    tmp_dx = x1 - x0;
                    tmp_dy = -1 * (y1 - y0);
                    dx = (tmp_dx[31] == 1'b1) ? -1 * tmp_dx : tmp_dx;
                    dy = (tmp_dy[31] == 1'b1) ? tmp_dy : -1 * tmp_dy;
                    sx = (x0 < x1) ? 1 : -1;
                    sy = (y0 < y1) ? 1 : -1;
                    err = dx + dy;
                    x = x0;
                    y = y0;
                    out = 2'b10;
                end
                {`DRAW, 1'b1}: begin
                   if (x == x1 && y == y1) begin
                       state = `DONE;
                       out = 2'b01;
                   end else begin
                       e2 = 2 * err;
                        if ( e2 >= dy ) begin
                            err = err + dy;
                            x = x + sx;
                        end
                        if( e2 <= dx ) begin
                            err = err + dx;
                            y = y + sy;
                        end
                        out = (x < 0 || x > `X_BOUND || y < 0 || y > `Y_BOUND) ? 2'b0 : 2'b10;
                   end
                end
                {`DONE, 1'b1}: begin
                    out = 2'b01;
                end
                default: begin
                    state = `IDLE;
                    x = 8'b0;
                    y = 7'b0;
                    str_colour = 3'b0;
                    out = 2'b0;
                end
            endcase
        end
    end

endmodule
