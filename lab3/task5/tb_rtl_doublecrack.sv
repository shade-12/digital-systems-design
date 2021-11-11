`timescale 1ps / 1ps

module tb_rtl_doublecrack();

    logic clk, rst_n, en, rdy, key_valid, err;
    logic [23:0] key;
    logic [7:0] ct_addr, ct_rddata;

    // Internal wires
    logic [7:0] ciphertext [255:0];
    logic [7:0] exp_pt [255:0];

    doublecrack dut(.*);

    initial begin
        clk = 1;
        forever #5 clk = ~clk;
    end

    task state_checker;
        input [31:0] index;
        input [2:0] exp_state;
        begin
            if (tb_rtl_doublecrack.dut.state !== exp_state) begin
                $display("ERROR %dA: Expected state is %d, actual state is %d", index, exp_state, tb_rtl_doublecrack.dut.state);
                err = 1'b1;
            end
        end
    endtask

    // States
    `define IDLE        3'b000
    `define READ_CT     3'b001
    `define WRITE_CT    3'b010
    `define EN_CRACK    3'b011
    `define DEN_CRACK   3'b100
    `define CRACKING    3'b101
    `define DONE        3'b110

    // Constants
    `define KEY_MAX     24'hFFFFFF

    initial begin
        err = 1'b0;

        // Test 1 expected result:
        // Key: 24'h18
        // Decrypted message: Mrs. Dalloway said she would buy the flowers herself.

        // Init memories array
        $readmemh("crack_res1.txt", exp_pt);
        $readmemh("test1.memh", ciphertext);

        // Case 1: Undefined inputs
        rst_n = 1'bx; en = 1'bx;
        #10;
        state_checker(1, `IDLE);
        if (tb_rtl_doublecrack.dut.rdy !== 1'bx) begin
            $display("ERROR 1: Expected rdy is %d, actual rdy is %d", 1'bx, tb_rtl_doublecrack.dut.rdy);
            err = 1'b1;
        end

        // Case 2: Assert reset
        rst_n = 1'b0; en = 1'b0;
        @(negedge clk);
        state_checker(2, `IDLE);
        if (tb_rtl_doublecrack.dut.rdy !== 1'b0) begin
            $display("ERROR 2: Expected rdy is %d, actual rdy is %d", 1'b0, tb_rtl_doublecrack.dut.rdy);
            err = 1'b1;
        end

        // Case 3: Deassert reset
        rst_n = 1'b1;
        @(posedge clk);
        state_checker(3, `IDLE);
        if (tb_rtl_doublecrack.dut.rdy !== 1'b0) begin
            $display("ERROR 3: Expected rdy is %d, actual rdy is %d", 1'b0, tb_rtl_doublecrack.dut.rdy);
            err = 1'b1;
        end

        // Case 4: Assert en when rdy = 1
        en = 1'b1; ct_rddata = ciphertext[tb_rtl_doublecrack.dut.ct_addr];
        @(posedge clk);
        state_checker(4, `IDLE);
        if (tb_rtl_doublecrack.dut.rdy !== 1'b1) begin
            $display("ERROR 4A: Expected rdy is %d, actual rdy is %d", 1'b1, tb_rtl_doublecrack.dut.rdy);
            err = 1'b1;
        end

        // Case 5: Deassert en signal
        en = 1'b0;
        @(posedge clk);
        state_checker(5, `READ_CT);
        if (tb_rtl_doublecrack.dut.rdy !== 1'b0) begin
            $display("ERROR 5A: Expected rdy is %d, actual rdy is %d", 1'b0, tb_rtl_doublecrack.dut.rdy);
            err = 1'b1;
        end

        // Case 6: Start copy ct into module
        ct_rddata = ciphertext[tb_rtl_doublecrack.dut.ct_addr];
        while (tb_rtl_doublecrack.dut.state !== `EN_CRACK) begin
            @(posedge clk);
            @(posedge clk);
            ct_rddata = ciphertext[tb_rtl_doublecrack.dut.ct_addr];
        end
        for (int i = 0; i <= tb_rtl_doublecrack.dut.message_length; i++) begin
           if (ciphertext[i] !== tb_rtl_doublecrack.dut.ct_copy[i]) begin 
                $display("CT MEM [%d] ERROR: Expected ct_copy is %h, actual ct_copy is %h", i[7:0], ciphertext[i], tb_rtl_doublecrack.dut.ct_copy[i]);
                err = 1'b1;
            end
        end

        // Case 7: Raise en signals for both crack modules
        @(posedge clk);
        state_checker(7, `DEN_CRACK);
        if (tb_rtl_doublecrack.dut.en_c1 !== 1'b1) begin
            $display("ERROR 7A: Expected en_c1 is %d, actual en_c1 is %d", 1'b1, tb_rtl_doublecrack.dut.en_c1);
            err = 1'b1;
        end
        if (tb_rtl_doublecrack.dut.en_c2 !== 1'b1) begin
            $display("ERROR 7B: Expected en_c2 is %d, actual en_c2 is %d", 1'b1, tb_rtl_doublecrack.dut.en_c2);
            err = 1'b1;
        end

        // Case 8: Deassert en signals
        @(posedge clk);
        state_checker(8, `CRACKING);
        if (tb_rtl_doublecrack.dut.en_c1 !== 1'b0) begin
            $display("ERROR 8A: Expected en_c1 is %d, actual en_c1 is %d", 1'b0, tb_rtl_doublecrack.dut.en_c1);
            err = 1'b1;
        end
        if (tb_rtl_doublecrack.dut.en_c2 !== 1'b0) begin
            $display("ERROR 8B: Expected en_c2 is %d, actual en_c2 is %d", 1'b0, tb_rtl_doublecrack.dut.en_c2);
            err = 1'b1;
        end

        // Case 9: Wait for done
        wait (tb_rtl_doublecrack.dut.state == `DONE);
        if (tb_rtl_doublecrack.dut.key_valid_c1 !== 1'b1) begin
            $display("ERROR 9A: Expected key_valid_c1 is %d, actual key_valid_c1 is %d", 1'b1, tb_rtl_doublecrack.dut.key_valid_c1);
            err = 1'b1;
        end

        @(posedge clk);
        if (tb_rtl_doublecrack.dut.key_valid !== 1'b1) begin
            $display("ERROR 9B: Expected key_valid is %d, actual key_valid is %d", 1'b1, tb_rtl_doublecrack.dut.key_valid);
            err = 1'b1;
        end

        // Check pt_mem values
        for (int i = 0; i <= 8'h35; i++) begin
           if (exp_pt[i] !== tb_rtl_doublecrack.dut.pt.altsyncram_component.m_default.altsyncram_inst.mem_data[i]) begin 
                $display("PT MEM [%d] ERROR: Expected pt is %h, actual pt is %h", i[7:0], exp_pt[i], tb_rtl_doublecrack.dut.pt.altsyncram_component.m_default.altsyncram_inst.mem_data[i]);
                err = 1'b1;
            end
        end

        if (~err)
            $display("SUCCESS: All tests passed.");
        $stop;
    end

endmodule: tb_rtl_doublecrack
