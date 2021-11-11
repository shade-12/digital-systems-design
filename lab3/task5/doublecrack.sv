module doublecrack(input logic clk, input logic rst_n,
             input logic en, output logic rdy,
             output logic [23:0] key, output logic key_valid,
             output logic [7:0] ct_addr, input logic [7:0] ct_rddata);

    logic en_c1, en_c2, rdy_c1, rdy_c2, 
          key_valid_c1, key_valid_c2, pt_wren, pt_wren_c1, pt_wren_c2, 
          rdy_out;
    logic [7:0] ct_addr_c1, ct_addr_c2, ct_rddata_c1, ct_rddata_c2,
                pt_addr, pt_wrdata, pt_rddata,
                pt_addr_c1, pt_wrdata_c1, pt_addr_c2, pt_wrdata_c2,
                message_length, ct_addr_out, i;
    logic [23:0] key_c1, key_c2, key_out;
    logic [2:0] state;
    logic [7:0] ct_copy [255:0];

    // States
    `define IDLE        3'b000
    `define READ_CT     3'b001
    `define WRITE_CT    3'b010
    `define EN_CRACK    3'b011
    `define DEN_CRACK   3'b100
    `define CRACKING    3'b101
    `define DONE        3'b110

    assign rdy = rdy_out;
    assign key_valid = (key_valid_c1 == 1'b1 || key_valid_c2 == 1'b1) ? 1'b1 : 1'b0;   // Need to copy c1/c2.pt to pt before raising this signal
    assign ct_addr = ct_addr_out;
    assign key = key_out;

    // Each crack modules reads from ct_copy array
    assign ct_rddata_c1 = ct_copy[ct_addr_c1];
    assign ct_rddata_c2 = ct_copy[ct_addr_c2];

    always @(*) begin
        if (key_valid_c1 == 1'b1)
            key_out = key_c1;
        else if (key_valid_c2 == 1'b1)
            key_out = key_c2;
        else
            key_out = 24'b0;
    end

    always @(posedge clk) begin
        rdy_out <= (rst_n == 1'b1) & (state == `IDLE || state == `DONE) & (en == 1'b0);
    end

    always @(posedge clk) begin
        if (rst_n == 1'b0) begin
            ct_addr_out <= 8'b0;
            state <= `IDLE;
        end else
            case (state)
                `IDLE: begin
                    ct_addr_out <= 8'b0;
                    en_c1 <= 1'b0; en_c2 <= 1'b0;
                    if (en == 1'b1) begin
                        state <= `READ_CT;
                        i <= 8'b1;
                        ct_addr_out <= 8'b1;
                        message_length <= ct_rddata;
                        ct_copy[0] <= ct_rddata;
                    end
                end
                `READ_CT: begin
                    ct_addr_out <= i;
                    state <= `WRITE_CT;
                end
                `WRITE_CT: begin
                    ct_copy[i] <= ct_rddata;
                    i <= i + 8'b1;
                    ct_addr_out <= i + 8'b1;
                    state <= `READ_CT;
                    if (i == message_length) begin
                        i <= 8'b0;
                        ct_addr_out <= 8'b0;
                        state <= `EN_CRACK;
                    end
                end
                `EN_CRACK: begin
                    ct_addr_out <= 8'b0;
                    en_c1 <= 1'b1;
                    en_c2 <= 1'b1;
                    state <= `DEN_CRACK;
                end
                `DEN_CRACK: begin
                    ct_addr_out <= 8'b0;
                    en_c1 <= 1'b0;
                    en_c2 <= 1'b0;
                    state <= `CRACKING;
                end
                `CRACKING: begin
                    ct_addr_out <= 8'b0;
                    if (rdy_c1 == 1'b1 || rdy_c2 == 1'b1) begin
                        state <= `DONE;
                    end
                end
                `DONE: begin
                    if (en == 1'b1) begin
                        state <= `READ_CT;
                        i <= 8'b1;
                        message_length <= ct_rddata;
                        ct_copy[0] <= ct_rddata;
                    end
                end
                default: begin
                    ct_addr_out <= 8'b0;
                    state <= `IDLE;
                end
            endcase
    end

    always @(*) begin
        if (pt_wren_c1 == 1'b1) begin
            {pt_addr, pt_wrdata, pt_wren} = {pt_addr_c1, pt_wrdata_c1, pt_wren_c1};
        end else if (pt_wren_c2 == 1'b1) begin
            {pt_addr, pt_wrdata, pt_wren} = {pt_addr_c2, pt_wrdata_c2, pt_wren_c2};
        end else
            {pt_addr, pt_wrdata, pt_wren} = 17'b0;
    end

    pt_mem pt(.address(pt_addr),
	          .clock(clk),
	          .data(pt_wrdata),
	          .wren(pt_wren),
	          .q(pt_rddata));

    crack c1(.clk(clk), 
             .rst_n(rst_n),
             .en(en_c1),
             .rdy(rdy_c1),
             .key(key_c1),
             .key_valid(key_valid_c1),
             .ct_addr(ct_addr_c1),
             .ct_rddata(ct_rddata_c1),
             .start_key(24'b0),
             .fpt_addr(pt_addr_c1),
             .fpt_wrdata(pt_wrdata_c1),
             .fpt_wren(pt_wren_c1));

    crack c2(.clk(clk), 
             .rst_n(rst_n),
             .en(en_c2),
             .rdy(rdy_c2),
             .key(key_c2),
             .key_valid(key_valid_c2),
             .ct_addr(ct_addr_c2),
             .ct_rddata(ct_rddata_c2),
             .start_key(24'b1),
             .fpt_addr(pt_addr_c2),
             .fpt_wrdata(pt_wrdata_c2),
             .fpt_wren(pt_wren_c2));

endmodule: doublecrack
