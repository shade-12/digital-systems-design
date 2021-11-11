module reg4(input clock, input load, input resetb, input[3:0] in, output reg[3:0] out);
    always @(posedge clock) begin
        if (!resetb) out <= 4'b0;
        else if (load) out <= in;
    end
endmodule