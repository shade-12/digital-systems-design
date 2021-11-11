module statemachine(input slow_clock, input resetb,
                    input [3:0] dscore, input [3:0] pscore, input [3:0] pcard3,
                    output load_pcard1, output load_pcard2,output load_pcard3,
                    output load_dcard1, output load_dcard2, output load_dcard3,
                    output player_win_light, output dealer_win_light);

    // All states
    `define WAIT      4'b0000
    `define LOAD_P1   4'b0001
    `define LOAD_P2   4'b0010
    `define LOAD_P3   4'b0011
    `define LOAD_D1   4'b0100
    `define LOAD_D2   4'b0101
    `define LOAD_D3   4'b0110
    `define CALC_RES  4'b0111
    `define P_WIN     4'b1000
    `define D_WIN     4'b1001
    `define TIE       4'b1010
    
    // Internal signals
    reg [7:0] out;
    wire [3:0] present_state, next_state_rst;
    reg [3:0] next_state;

    // Instantiate a 4-bit D Flip Flop
    vDFF #(4) STATE(slow_clock, next_state_rst, present_state);

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
            `WAIT: begin
                next_state <= `LOAD_P1;
                out <= 8'b10000000;
            end
            `LOAD_P1: begin
                next_state <= `LOAD_D1;
                out <= 8'b00010000;
            end
            `LOAD_D1: begin
                next_state <= `LOAD_P2;
                out <= 8'b01000000;
            end
            `LOAD_P2: begin
                next_state <= `LOAD_D2;
                out <= 8'b00001000;
            end
            `LOAD_D2:
                if (pscore == 4'd8 || pscore == 4'd9 || dscore == 4'd8 || dscore == 4'd9) begin
                    if (pscore > dscore) begin  next_state <= `P_WIN; out <= 8'b00000010; end
                    else if (pscore == dscore) begin next_state <= `TIE; out <= 8'b00000011; end
                    else begin next_state <= `D_WIN; out <= 8'b00000001; end
                end
                else begin
                    if (pscore <= 4'd5) begin next_state <= `LOAD_P3; out <= 8'b00100000; end
                    else if (dscore <= 4'd5) begin next_state <= `LOAD_D3; out <= 8'b00000100; end
                    else if (pscore > dscore) begin next_state <= `P_WIN; out <= 8'b00000010; end
                    else if (pscore == dscore) begin next_state <= `TIE; out <= 8'b00000011; end
                    else begin next_state <= `D_WIN; out <= 8'b00000001; end
                end
            `LOAD_P3: 
                case (dscore)
                    4'd7: begin next_state <= `CALC_RES; out <= 8'b0; end
                    4'd6:
                        if (pcard3 == 4'd6 || pcard3 == 4'd7) begin next_state <= `LOAD_D3; out <= 8'b00000100; end
                        else begin next_state <= `CALC_RES; out <= 8'b0; end
                    4'd5:
                        if (pcard3 >= 4'd4 && pcard3 <= 4'd7) begin next_state <= `LOAD_D3; out <= 8'b00000100; end
                        else begin next_state <= `CALC_RES; out <= 8'b0; end
                    4'd4:
                        if (pcard3 >= 4'd2 && pcard3 <= 4'd7) begin next_state <= `LOAD_D3; out <= 8'b00000100; end
                        else begin next_state <= `CALC_RES; out <= 8'b0; end
                    4'd3:
                        if (pcard3 != 4'd8) begin next_state <= `LOAD_D3; out <= 8'b00000100; end
                        else begin next_state <= `CALC_RES; out <= 8'b0; end
                    default: begin next_state <= `LOAD_D3; out <= 8'b00000100; end
                endcase
            `LOAD_D3: 
                if (pscore > dscore) begin  next_state <= `P_WIN; out <= 8'b00000010; end
                else if (pscore == dscore) begin next_state <= `TIE; out <= 8'b00000011; end
                else begin next_state <= `D_WIN; out <= 8'b00000001; end
            `CALC_RES: 
                if (pscore > dscore) begin  next_state <= `P_WIN; out <= 8'b00000010; end
                else if (pscore == dscore) begin next_state <= `TIE; out <= 8'b00000011; end
                else begin next_state <= `D_WIN; out <= 8'b00000001; end
            `P_WIN:   begin next_state <= `WAIT; out <= 8'b0; end
            `D_WIN:   begin next_state <= `WAIT; out <= 8'b0; end
            `TIE:     begin next_state <= `WAIT; out <= 8'b0; end
            default:  begin next_state <= 4'bx; out <= 8'bx; end
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
