module lab0(CLOCK_50, resetn, valueA, valueB, loadA, loadB, sum);
    input CLOCK_50, resetn, loadA, loadB;
    input [3:0] valueA, valueB;
    output reg [4:0] sum;

    reg [3:0] storedA, storedB;

    assign sum = storedA + storedB;

    always @(posedge CLOCK_50) begin
        if (~resetn) begin
            storedA = 4'b0;
            storedB = 4'b0;
        end else begin
            case ({loadA, loadB})
                2'b00,
                2'b01: storedB = valueB;
                2'b10: storedA = valueA;
                2'b11: begin
                    storedA = valueA;
                    storedB = valueB;
                end
            endcase
        end
    end

endmodule