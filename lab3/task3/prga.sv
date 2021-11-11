module prga(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            input logic [23:0] key,
            output logic [7:0] s_addr, input logic [7:0] s_rddata, output logic [7:0] s_wrdata, output logic s_wren,
            output logic [7:0] ct_addr, input logic [7:0] ct_rddata,
            output logic [7:0] pt_addr, input logic [7:0] pt_rddata, output logic [7:0] pt_wrdata, output logic pt_wren);

    // BYTESTREAM FUNC STATES
    `define IDLE      4'b0000   // Ready to accept a request, waiting for en signal to go high, read message length (ciphertext[0]) from ct_mem
    `define READ_I    4'b0001   // Calculate value i and read s[i] from s_mem, read ct[k] value from mem
    `define STALL_I   4'b0010   // Wait for s[i] and ct[k] values to become available
    `define CALC_J    4'b0011   // Calculate value of j using value s[i], read value s[j] from s_mem, store value ct[k] in ct_mem
    `define STALL_J   4'b0100   // Wait for s[j] value to become available
    `define WRITE_I   4'b0101   // Write s[j] value to addr i in s_mem
    `define WRITE_J   4'b0110   // Write previous s[i] value to addr j in s_mem
    `define READ_P    4'b0111   // Read s[(s[i]+s[j]) mod 256] from s_mem
    `define STALL_P   4'b1000   // Wait for value to become available
    `define WRITE_P   4'b1001   // Write value to pad[k]

    // XOR FUNC STATES
    `define WRITE_PT  4'b1010   // Perform xor operation on pad[k] and ct[k]

    logic rdy_out;
    logic [3:0] state;
    logic [7:0] ct_addr_out, i, j, k, I, pad_i, message_length;
    logic [16:0] s_out, pt_out;
    logic [7:0] pad [255:0];
    logic [7:0] ct_mem [255:0];

    // Output wires
    assign rdy = rdy_out;
    assign ct_addr = ct_addr_out;
    assign { s_addr, s_wrdata, s_wren } = s_out;
    assign { pt_addr, pt_wrdata, pt_wren } = pt_out;

    always @(posedge clk) begin
        rdy_out <= (rst_n == 1'b1) & (state == `IDLE) & (en == 1'b0);
    end

    always @(posedge clk) begin
        if (rst_n == 1'b0) begin
            i <= 8'b0; j <= 8'b0; k <= 8'b0;
            state <= `IDLE;
            ct_addr_out <= 8'b0;
            s_out <= 17'b0;
            pt_out <= 17'b0;
        end else
            case (state)
                `IDLE: begin
                    i <= 8'b0; j <= 8'b0; k <= 8'b0;
                    ct_addr_out <= 8'b0;
                    s_out <= 17'b0;
                    pt_out <= 17'b0;
                    if (en == 1'b1) begin
                        state <= `READ_I;
                        message_length <= ct_rddata;
                        ct_mem[k] <= ct_rddata;
                    end
                end
                `READ_I: begin
                    if (k < message_length) begin
                        i <= i + 8'b1;
                        state <= `STALL_I;
                        ct_addr_out <= k + 8'b1;
                        s_out <= { i + 8'b1, 8'bx, 1'b0 };
                        pt_out <= 17'b0;
                    end else begin
                        // Write message length to pt_mem[0]
                        i <= 8'b0; j <= 8'b0; k <= 8'b0;
                        state <= `WRITE_PT;
                        ct_addr_out <= 8'b0;
                        s_out <= 17'b0;
                        pt_out <= { 8'b0, message_length, 1'b1 };
                    end
                end
                `STALL_I: begin
                    state <= `CALC_J;
                end
                `CALC_J: begin
                    ct_mem[k + 8'b1] <= ct_rddata;
                    I <= s_rddata;
                    j <= j + s_rddata;
                    state <= `STALL_J;
                    ct_addr_out <= 8'b0;
                    s_out <= { j + s_rddata, 8'bx, 1'b0 };
                    pt_out <= 17'b0;
                end
                `STALL_J: begin
                    state <= `WRITE_I;
                end
                `WRITE_I: begin
                    pad_i <= I + s_rddata;
                    state <= `WRITE_J;
                    ct_addr_out <= 8'b0;
                    s_out <= { i, s_rddata, 1'b1 };
                    pt_out <= 17'b0;
                end
                `WRITE_J: begin
                    state <= `READ_P;
                    ct_addr_out <= 8'b0;
                    s_out <= { j, I, 1'b1 };
                    pt_out <= 17'b0;
                end
                `READ_P: begin
                    state <= `STALL_P;
                    ct_addr_out <= 8'b0;
                    s_out <= { pad_i, 8'bx, 1'b0 };
                    pt_out <= 17'b0;
                end
                `STALL_P: begin
                    state <= `WRITE_P;
                end
                `WRITE_P: begin
                    k <= k + 8'b1;
                    pad[k] <= s_rddata;
                    state <= `READ_I;
                    ct_addr_out <= 8'b0;
                    s_out <= 17'b0;
                    pt_out <= 17'b0;
                end
                `WRITE_PT: begin
                    if (k < message_length) begin
                        k <= k + 8'b1;
                        ct_addr_out <= 8'b0;
                        s_out <= 17'b0;
                        pt_out <= { k + 8'b1, pad[k] ^ ct_mem[k + 8'b1], 1'b1 };
                    end else begin
                        i <= 8'b0; j <= 8'b0; k <= 8'b0;
                        state <= `IDLE;
                        ct_addr_out <= 8'b0;
                        s_out <= 17'b0;
                        pt_out <= 17'b0;
                    end
                end
                default: begin
                    i <= 8'b0; j <= 8'b0; k <= 8'b0;
                    state <= `IDLE;
                    ct_addr_out <= 8'b0;
                    s_out <= 17'b0;
                    pt_out <= 17'b0;
                end
            endcase
    end

endmodule: prga
