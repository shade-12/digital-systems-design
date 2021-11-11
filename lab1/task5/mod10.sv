module mod10(input [4:0] in, output [3:0] lsd);
    integer i;
    reg [3:0] ones;

    assign lsd = (in <= 4'd9) ? in[3:0] : ones;

    // Find least significant decimal digit using the Double Dable Algorithm
    // Rules:
    // 1. If 1's is greater then or equal to 5, add 3 to 1's
    // 2. Shift all bits to left by 1 position
    always @(in) begin
        ones = 4'd0;
        for (i = 4; i >= 0; i = i - 1) begin
            if (ones >= 4'd5)
                ones = ones + 4'd3;
            ones = ones << 1;
            ones[0] = in[i];
        end
    end
endmodule