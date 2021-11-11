module crack(input logic clk, input logic rst_n,
             input logic en, output logic rdy,
             output logic [23:0] key, output logic key_valid,
             output logic [7:0] ct_addr, input logic [7:0] ct_rddata,
             input logic [23:0] start_key,
             output logic [7:0] fpt_addr, output logic [7:0] fpt_wrdata, output logic fpt_wren);

    logic pt_wren, pt_wren_a, pt_wren_c, en_a4, rdy_a4, rdy_out, key_valid_out;
    logic [23:0] curr_key;
    logic [7:0] pt_addr, pt_rddata, pt_wrdata, 
                pt_addr_a, pt_wrdata_a, 
                pt_addr_c, pt_wrdata_c,
                message_length, i;
    logic [3:0] state;
    logic [7:0] pt_copy [255:0];
    logic [16:0] fpt_out;

    // Constants
    `define ASCII_MIN   8'h20
    `define ASCII_MAX   8'h7E
    `define KEY_MAX     24'hFFFFFF

    // States
    `define IDLE     4'b0000  // Ready to accept a request, waiting for en signal to go high, read message length (ciphertext[0]) from ct_mem
    `define EN_A4    4'b0001  // Wait for rdy_a4 signal to go high, then assert en_a4
    `define DEN_A4   4'b0010  // Deassert en_a4 signal
    `define CRACK    4'b0011  // Running arc4, wait for rdy_a4 signal to come high again
    `define VERIFY   4'b0100  // Verify plaintext result
    `define READ_PT  4'b0101  // Read palintext[i] from pt_mem
    `define CHECK    4'b0110  // Verify if pt[i] value is between ASCII_MIN and ASCII_MAX inclusive
    `define COPY_PT  4'b0111  // Copy pt into doublecrack's pt_mem
    `define CRACKED  4'b1000  // Done cracking, ready to accept another request

    assign rdy = rdy_out;
    assign key_valid = key_valid_out;
    assign key = curr_key;
    assign { pt_addr, pt_wrdata, pt_wren } = (state == `EN_A4 || state == `DEN_A4 || state == `CRACK) ? { pt_addr_a, pt_wrdata_a, pt_wren_a } : { pt_addr_c, 8'bx, 1'b0 };
    assign { fpt_addr, fpt_wrdata, fpt_wren } = fpt_out;

    always @(posedge clk) begin
        rdy_out <= (rst_n == 1'b1) & (state == `IDLE || state == `CRACKED) & (en == 1'b0);
    end

    always @(posedge clk) begin
        if (rst_n == 1'b0) begin
            fpt_out <= 17'b0;
            key_valid_out <= 1'b0;
            state <= `IDLE;
        end else
            case (state)
                `IDLE: begin
                    fpt_out <= 17'b0;
                    key_valid_out <= 1'b0;
                    en_a4 <= 1'b0;
                    if (en == 1'b1) begin
                        state <= `EN_A4;
                        curr_key <= start_key;
                        message_length <= ct_rddata;
                    end
                end
                `EN_A4: begin
                    fpt_out <= 17'b0;
                    key_valid_out <= 1'b0;
                    en_a4 <= 1'b0;
                    if (rdy_a4 == 1'b1) begin
                        state <= `DEN_A4;
                        en_a4 <= 1'b1;
                    end
                end
                `DEN_A4: begin
                    fpt_out <= 17'b0;
                    key_valid_out <= 1'b0;
                    en_a4 <= 1'b0;
                    state <= `CRACK;
                end
                `CRACK: begin
                    fpt_out <= 17'b0;
                    key_valid_out <= 1'b0;
                    en_a4 <= 1'b0;
                    if (rdy_a4 == 1'b1) begin
                        i <= 8'b1;
                        state <= `VERIFY;
                    end
                end
                `VERIFY: begin
                    fpt_out <= 17'b0;
                    key_valid_out <= 1'b0;
                    if (i <= message_length) begin
                        pt_addr_c <= i;
                        state <= `READ_PT;
                    end else begin
                        i <= 8'b0;
                        state <= `COPY_PT;
                    end
                end
                `READ_PT: begin
                    fpt_out <= 17'b0;
                    key_valid_out <= 1'b0;
                    pt_addr_c <= i;
                    state <= `CHECK;
                end
                `CHECK: begin
                    fpt_out <= 17'b0;
                    key_valid_out <= 1'b0;
                    if (pt_rddata > `ASCII_MAX || pt_rddata < `ASCII_MIN) begin
                        if (curr_key == `KEY_MAX || curr_key == (`KEY_MAX - 24'h1))
                            state <= `IDLE;
                        else begin
                            curr_key <= curr_key + 24'd2;
                            state <= `EN_A4;
                        end
                    end else begin
                        i <= i + 8'b1;
                        state <= `VERIFY;
                    end 
                end
                `COPY_PT: begin
                    key_valid_out <= 1'b0;
                    if (i <= message_length) begin
                        fpt_out <= {i, pt_copy[i], 1'b1 };
                        i <= i + 8'b1;
                    end else begin
                        fpt_out <= 17'b0;
                        key_valid_out <= 1'b1;
                        state <= `CRACKED;
                    end
                end
                `CRACKED: begin
                    fpt_out <= 17'b0;
                    key_valid_out <= 1'b1;
                    if (en == 1'b1) begin
                        key_valid_out <= 1'b0;
                        state <= `EN_A4;
                        curr_key <= start_key;
                        message_length <= ct_rddata;
                    end
                end
                default: begin
                    fpt_out <= 17'b0;
                    key_valid_out <= 1'b0;
                    state <= `IDLE;
                end
            endcase
    end

    always @(posedge clk)
        if (pt_wren == 1'b1)
            pt_copy[pt_addr] <= pt_wrdata;

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
