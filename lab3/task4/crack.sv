module crack(input logic clk, input logic rst_n,
             input logic en, output logic rdy,
             output logic [23:0] key, output logic key_valid,
             output logic [7:0] ct_addr, input logic [7:0] ct_rddata);

    logic pt_wren, pt_wren_a, pt_wren_c, en_a4, rdy_a4, rdy_out, key_valid_out;
    logic [23:0] curr_key;
    logic [7:0] pt_addr, pt_rddata, pt_wrdata, 
                pt_addr_a, pt_wrdata_a, 
                pt_addr_c, pt_wrdata_c, 
                message_length, i;
    logic [2:0] state;

    // Constants
    `define ASCII_MIN   8'h20
    `define ASCII_MAX   8'h7E
    `define KEY_MAX     24'hFFFFFF     

    // States
    `define IDLE     3'b000  // Ready to accept a request, waiting for en signal to go high, read message length (ciphertext[0]) from ct_mem
    `define EN_A4    3'b001  // Wait for rdy_a4 signal to go high, then assert en_a4
    `define DEN_A4   3'b010  // Deassert en_a4 signal
    `define CRACK    3'b011  // Running arc4, wait for rdy_a4 signal to come high again
    `define VERIFY   3'b100  // Verify plaintext result
    `define READ_PT  3'b101  // Read palintext[i] from pt_mem
    `define CHECK    3'b110  // Verify if pt[i] value is between ASCII_MIN and ASCII_MAX inclusive
    `define CRACKED  3'b111  // Done cracking, ready to accept another request

    assign rdy = rdy_out;
    assign key_valid = key_valid_out;
    assign key = curr_key;
    assign { pt_addr, pt_wrdata, pt_wren } = (state == `EN_A4 || state == `DEN_A4 || state == `CRACK) ? { pt_addr_a, pt_wrdata_a, pt_wren_a } : { pt_addr_c, 8'bx, 1'b0 };

    always @(posedge clk) begin
        rdy_out <= (rst_n == 1'b1) & (state == `IDLE || state == `CRACKED) & (en == 1'b0);
    end

    always @(posedge clk) begin
        if (rst_n == 1'b0) begin
            key_valid_out <= 1'b0;
            state <= `IDLE;
        end else
            case (state)
                `IDLE: begin
                    key_valid_out <= 1'b0;
                    en_a4 <= 1'b0;
                    if (en == 1'b1) begin
                        state <= `EN_A4;
                        curr_key <= 24'b0;
                        message_length <= ct_rddata;
                    end
                end
                `EN_A4: begin
                    key_valid_out <= 1'b0;
                    en_a4 <= 1'b0;
                    if (rdy_a4 == 1'b1) begin
                        state <= `DEN_A4;
                        en_a4 <= 1'b1;
                    end
                end
                `DEN_A4: begin
                    key_valid_out <= 1'b0;
                    en_a4 <= 1'b0;
                    state <= `CRACK;
                end
                `CRACK: begin
                    key_valid_out <= 1'b0;
                    en_a4 <= 1'b0;
                    if (rdy_a4 == 1'b1) begin
                        i <= 8'b1;
                        state <= `VERIFY;
                    end
                end
                `VERIFY: begin
                    key_valid_out <= 1'b0;
                    if (i <= message_length) begin
                        pt_addr_c <= i;
                        state <= `READ_PT;
                    end else begin
                        key_valid_out <= 1'b1;
                        state <= `CRACKED;
                    end
                end
                `READ_PT: begin
                    key_valid_out <= 1'b0;
                    pt_addr_c <= i;
                    state <= `CHECK;
                end
                `CHECK: begin
                    key_valid_out <= 1'b0;
                    if (pt_rddata > `ASCII_MAX || pt_rddata < `ASCII_MIN) begin
                        if (curr_key == `KEY_MAX)
                            state <= `IDLE;
                        else begin
                            curr_key <= curr_key + 24'b1;
                            state <= `EN_A4;
                        end
                    end else begin
                        i <= i + 8'b1;
                        state <= `VERIFY;
                    end 
                end
                `CRACKED: begin
                    key_valid_out <= 1'b1;
                    if (en == 1'b1) begin
                        key_valid_out <= 1'b0;
                        state <= `EN_A4;
                        curr_key <= 24'b0;
                        message_length <= ct_rddata;
                    end
                end
                default: begin
                    key_valid_out <= 1'b0;
                    state <= `IDLE;
                end
            endcase
    end

    pt_mem pt(.address(pt_addr),
	          .clock(clk),
	          .data(pt_wrdata),
	          .wren(pt_wren),
	          .q(pt_rddata));

    arc4 a4(.clk(clk), 
            .rst_n(rst_n),
            .en(en_a4), 
            .rdy(rdy_a4),
            .key(curr_key),
            .ct_addr(ct_addr), 
            .ct_rddata(ct_rddata),
            .pt_addr(pt_addr_a), 
            .pt_rddata(pt_rddata), 
            .pt_wrdata(pt_wrdata_a),
            .pt_wren(pt_wren_a));

endmodule: crack
