`define NONE   7'b1111111
`define DASH   7'b0111111
`define ZERO   7'b1000000
`define ONE    7'b1111001
`define TWO    7'b0100100     
`define THREE  7'b0110000
`define FOUR   7'b0011001
`define FIVE   7'b0010010
`define SIX    7'b0000010
`define SEVEN  7'b1111000
`define EIGHT  7'b0000000
`define NINE   7'b0010000
`define A      7'b0001000
`define B      7'b0000011
`define C      7'b1000110
`define D      7'b0100001
`define E      7'b0000110
`define F      7'b0001110

module seg7(input [3:0] hex, input done, input found, output [6:0] HEX0);
    reg [6:0] led;

    assign HEX0 = led;

    always @(*) begin
        if (done == 1'b1) begin
            if (found == 1'b1)
                case (hex)
                    4'b0000: led = `ZERO;
                    4'b0001: led = `ONE;
                    4'b0010: led = `TWO;
                    4'b0011: led = `THREE;
                    4'b0100: led = `FOUR;
                    4'b0101: led = `FIVE;
                    4'b0110: led = `SIX;
                    4'b0111: led = `SEVEN;
                    4'b1000: led = `EIGHT;
                    4'b1001: led = `NINE;
                    4'b1010: led = `A;
                    4'b1011: led = `B;
                    4'b1100: led = `C;
                    4'b1101: led = `D;
                    4'b1110: led = `E;
                    4'b1111: led = `F;
                    default: led = `NONE;
                endcase
            else
                led = `DASH;    // Display dash when key is not found after done
        end else
            led = `NONE;        // Display blank when the circuit is computing
    end
    
endmodule: seg7