module ksa(input logic clk, input logic rst_n,
           input logic en, output logic rdy,
           input logic [23:0] key,
           output logic [7:0] addr, input logic [7:0] rddata, output logic [7:0] wrdata, output logic wren);

    `define READY     3'b000
    `define READ_I    3'b001
    `define STALL_R   3'b010
    `define CALC_J    3'b011
    `define READ_J    3'b100
    `define STALL_W   3'b101
    `define WRITE_I   3'b110
    `define WRITE_J   3'b111

    `define KEYLENGTH 8'd3         // 24-bit key = 3 bytes
    
    reg [2:0] state;
    reg [17:0] out;
    reg [7:0] i, j, I, key_index, key_val;
    integer count_i, count_j;

    assign { addr, wrdata, wren, rdy } = out;
    assign key_index = i % `KEYLENGTH;
    assign i = count_i[7:0];
    assign j = count_j[7:0];

    always @(*)
        case (key_index)
            8'd0: key_val = key[23:16];
            8'd1: key_val = key[15:8];
            8'd2: key_val = key[7:0];
            default: key_val = 8'bx;
        endcase
    
    always @(posedge clk) begin
        if (rst_n == 1'b0) begin
            count_i <= 0;
            count_j <= 0;
            state <= `READY;
            out <= 18'b0;
        end else
            case (state)
                `READY: begin
                    count_i <= 0;
                    count_j <= 0;
                    if (en == 1'b1) begin
                        state <= `READ_I;
                        out <= 18'b0;
                    end else
                        out <= { 17'b0, 1'b1 };
                end
                `READ_I: begin
                    if (count_i < 256) begin
                        state <= `STALL_R;
                        out <= { i, 8'bx, 1'b0, 1'b0 };
                    end else begin
                        count_i <= 0;
                        count_j <= 0;
                        state <= `READY;
                        out <= 18'b0;
                    end
                end
                `STALL_R: begin
                    state <= `CALC_J;
                    out <= { i, 8'bx, 1'b0, 1'b0 };
                end
                `CALC_J: begin
                    I <= rddata;
                    count_j <= count_j + rddata + key_val;
                    state <= `READ_J;
                    out <= { i, 8'bx, 1'b0, 1'b0 };
                end
                `READ_J: begin
                    state <= `STALL_W;
                    out <= { j, 8'bx, 1'b0, 1'b0 };
                end
                `STALL_W: begin
                    state <= `WRITE_I;
                    out <= { j, 8'bx, 1'b0, 1'b0 };
                end
                `WRITE_I: begin
                    state <= `WRITE_J;
                    out <= { i, rddata, 1'b1, 1'b0 };
                end
                `WRITE_J: begin
                    count_i <= count_i + 1;
                    state <= `READ_I;
                    out <= { j, I, 1'b1, 1'b0 };
                end
                default: begin
                    count_i <= 0;
                    count_j <= 0;
                    state <= `READY;
                    out <= 18'b0;
                end
            endcase
    end

endmodule: ksa
