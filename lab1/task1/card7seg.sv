`define NONE   7'b1111111
`define ACE    7'b0001000
`define TWO    7'b0100100     
`define THREE  7'b0110000
`define FOUR   7'b0011001
`define FIVE   7'b0010010
`define SIX    7'b0000010
`define SEVEN  7'b1111000
`define EIGHT  7'b0000000
`define NINE   7'b0010000
`define TEN    7'b1000000
`define JACK   7'b1100001
`define QUEEN  7'b0011000
`define KING   7'b0001001

module card7seg(input [3:0] SW, output [6:0] HEX0);
   reg [6:0] led;

   assign HEX0 = led;

   always @(*) begin
      case (SW)
         4'b0000: led <= `NONE;
         4'b0001: led <= `ACE;
         4'b0010: led <= `TWO;
         4'b0011: led <= `THREE;
         4'b0100: led <= `FOUR;
         4'b0101: led <= `FIVE;
         4'b0110: led <= `SIX;
         4'b0111: led <= `SEVEN;
         4'b1000: led <= `EIGHT;
         4'b1001: led <= `NINE;
         4'b1010: led <= `TEN;
         4'b1011: led <= `JACK;
         4'b1100: led <= `QUEEN;
         4'b1101: led <= `KING;
         default: led <= `NONE;
      endcase
   end
	
endmodule

