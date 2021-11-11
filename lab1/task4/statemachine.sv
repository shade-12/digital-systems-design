module statemachine(input slow_clock, input resetb,
                    input [3:0] dscore, input [3:0] pscore, input [3:0] pcard3,
                    output load_pcard1, output load_pcard2,output load_pcard3,
                    output load_dcard1, output load_dcard2, output load_dcard3,
                    output player_win_light, output dealer_win_light);

    // All states
    `define WAIT    3'b000
    `define LOAD_P1 3'b001
    `define LOAD_P2 3'b010
    `define LOAD_D1 3'b011
    `define LOAD_D2 3'b100
    
    // Internal signals
    reg [7:0] out;
    wire [2:0] present_state, next_state_rst;
    reg [2:0] next_state;

    // Instantiate a 3-bit D Flip Flop
    vDFF #(3) STATE(slow_clock, next_state_rst, present_state);

    // MUX for reset logic
    assign next_state_rst = !resetb ? `WAIT : next_state;

    // Assign wire outputs to reg
    assign {
        load_pcard1,
        load_pcard2,
        load_pcard3,
        load_dcard1,
        load_dcard2,
        load_dcard3,
        player_win_light,
        dealer_win_light
    } = out;

    // Combinational logic for next_state and outputs
    always @(*) begin
        case (present_state)
            `WAIT:    next_state = `LOAD_P1;
            `LOAD_P1: next_state = `LOAD_D1;
            `LOAD_D1: next_state = `LOAD_P2;
            `LOAD_P2: next_state = `LOAD_D2;
            `LOAD_D2: next_state = `WAIT;
            default:  next_state = 3'bx;
        endcase

        case (present_state)
            `WAIT:    out = 8'b0;
            `LOAD_P1: out = 8'b10000000;
            `LOAD_P2: out = 8'b01000000;
            `LOAD_D1: out = 8'b00010000;
            `LOAD_D2: out = 8'b00001000;
            default:  out = 8'bx;
        endcase
    end

endmodule

module vDFF(clk,D,Q);
  parameter n=1;
  input clk;
  input [n-1:0] D;
  output reg [n-1:0] Q;
  always @(posedge clk)
    Q <= D;
endmodule

