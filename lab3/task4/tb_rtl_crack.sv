`timescale 1ps / 1ps

module tb_rtl_crack();

    logic clk, rst_n, en, rdy, key_valid, err;
    logic [23:0] key;
    logic [7:0] ct_addr, ct_rddata;

    // Internal wires
    logic [7:0] ciphertext [255:0];
    logic [7:0] exp_pt [255:0];

    crack dut(.*);

    initial begin
        clk = 1;
        forever #5 clk = ~clk;
    end

    task state_checker;
        input [31:0] index;
        input [2:0] exp_state;
        begin
            if (tb_rtl_crack.dut.state !== exp_state) begin
                $display("ERROR %dA: Expected state is %d, actual state is %d", index, exp_state, tb_rtl_crack.dut.state);
                err = 1'b1;
            end
        end
    endtask

    // States
    `define IDLE     3'b000
    `define EN_A4    3'b001
    `define DEN_A4   3'b010
    `define CRACK    3'b011
    `define VERIFY   3'b100
    `define READ_PT  3'b101
    `define CHECK    3'b110
    `define CRACKED  3'b111

    // Constants
    `define KEY_MAX     24'hFFFFFF

    initial begin
        err = 1'b0;

        // Test 1 expected result:
        // Key: 24'h1
        // Decrypted message: In a hole in the ground there lived a hobbit.

        // Init memories array
        $readmemh("crack_res1.txt", exp_pt);
        $readmemh("test1.memh", ciphertext);

        // Case 1: Undefined inputs
        rst_n = 1'bx; en = 1'bx;
        #10;
        state_checker(1, `IDLE);
        if (tb_rtl_crack.dut.rdy !== 1'bx) begin
            $display("ERROR 1: Expected rdy is %d, actual rdy is %d", 1'bx, tb_rtl_crack.dut.rdy);
            err = 1'b1;
        end

        // Case 2: Assert reset
        rst_n = 1'b0; en = 1'b0;
        @(negedge clk);
        state_checker(2, `IDLE);
        if (tb_rtl_crack.dut.rdy !== 1'b0) begin
            $display("ERROR 2: Expected rdy is %d, actual rdy is %d", 1'b0, tb_rtl_crack.dut.rdy);
            err = 1'b1;
        end

        // Case 3: Deassert reset
        rst_n = 1'b1;
        @(posedge clk);
        state_checker(3, `IDLE);
        if (tb_rtl_crack.dut.rdy !== 1'b0) begin
            $display("ERROR 3: Expected rdy is %d, actual rdy is %d", 1'b0, tb_rtl_crack.dut.rdy);
            err = 1'b1;
        end

        // Case 4: Assert en when rdy = 1
        en = 1'b1; ct_rddata = ciphertext[tb_rtl_crack.dut.ct_addr];
        @(posedge clk);
        state_checker(4, `IDLE);
        if (tb_rtl_crack.dut.rdy !== 1'b1) begin
            $display("ERROR 4A: Expected rdy is %d, actual rdy is %d", 1'b1, tb_rtl_crack.dut.rdy);
            err = 1'b1;
        end

        // Case 5: Deassert en signal
        en = 1'b0;
        @(posedge clk);
        state_checker(5, `EN_A4);
        if (tb_rtl_crack.dut.rdy !== 1'b0) begin
            $display("ERROR 5A: Expected rdy is %d, actual rdy is %d", 1'b0, tb_rtl_crack.dut.rdy);
            err = 1'b1;
        end

        // Case 6: Pass in the right ct value for each read op
        while (tb_rtl_crack.dut.state !== `CRACKED) begin
            @(posedge clk);
            ct_rddata = ciphertext[tb_rtl_crack.dut.ct_addr];
        end

        // Case 7: Wait until the ciphertext is cracked
        wait (tb_rtl_crack.dut.rdy == 1'b1);
        if (tb_rtl_crack.dut.key_valid !== 1'b1) begin
            $display("ERROR 7A: Expected key_valid is %d, actual key_valid is %d", 1'b1, tb_rtl_crack.dut.key_valid);
            err = 1'b1;
        end
        if (tb_rtl_crack.dut.key !== 24'h1) begin
            $display("ERROR 7B: Expected key is %h, actual key is %h", 24'h1, tb_rtl_crack.dut.key);
            err = 1'b1;
        end

        // Case 8: Check pt_mem
        for (int i = 0; i <= 8'h2D; i++) begin
           if (exp_pt[i] !== tb_rtl_crack.dut.pt.altsyncram_component.m_default.altsyncram_inst.mem_data[i]) begin 
                $display("PT MEM [%d] ERROR: Expected pt is %h, actual pt is %h", i[7:0], exp_pt[i], tb_rtl_crack.dut.pt.altsyncram_component.m_default.altsyncram_inst.mem_data[i]);
                err = 1'b1;
            end
        end

        // ======================================================================================================================================================================================

        // Test 2 expected result:
        // Key: 24'h7
        // Decrypted message: The sky above the port was the color of television, tuned to a dead channel.

        // Init memories array
        $readmemh("crack_res2.txt", exp_pt);
        $readmemh("test2.memh", ciphertext);

        // Case 9: Assert reset
        rst_n = 1'b0; en = 1'b0;
        @(posedge clk);
        @(posedge clk);
        state_checker(9, `IDLE);
        if (tb_rtl_crack.dut.rdy !== 1'b0) begin
            $display("ERROR 9: Expected rdy is %d, actual rdy is %d", 1'b0, tb_rtl_crack.dut.rdy);
            err = 1'b1;
        end

        // Case 10: Deassert reset
        rst_n = 1'b1;
        @(posedge clk);
        state_checker(10, `IDLE);
        if (tb_rtl_crack.dut.rdy !== 1'b0) begin
            $display("ERROR 10: Expected rdy is %d, actual rdy is %d", 1'b0, tb_rtl_crack.dut.rdy);
            err = 1'b1;
        end

        // Case 11: Assert en when rdy = 1
        en = 1'b1; ct_rddata = ciphertext[tb_rtl_crack.dut.ct_addr];
        @(posedge clk);
        state_checker(11, `IDLE);
        if (tb_rtl_crack.dut.rdy !== 1'b1) begin
            $display("ERROR 11: Expected rdy is %d, actual rdy is %d", 1'b1, tb_rtl_crack.dut.rdy);
            err = 1'b1;
        end

        // Case 12: Deassert en signal
        en = 1'b0;
        @(posedge clk);
        state_checker(12, `EN_A4);
        if (tb_rtl_crack.dut.rdy !== 1'b0) begin
            $display("ERROR 12: Expected rdy is %d, actual rdy is %d", 1'b0, tb_rtl_crack.dut.rdy);
            err = 1'b1;
        end

        // Case 13: Pass in the right ct value for each read op
        while (tb_rtl_crack.dut.state !== `CRACKED) begin
            @(posedge clk);
            ct_rddata = ciphertext[tb_rtl_crack.dut.ct_addr];
        end

        // Case 14: Wait until the ciphertext is cracked
        wait (tb_rtl_crack.dut.rdy == 1'b1);
        if (tb_rtl_crack.dut.key_valid !== 1'b1) begin
            $display("ERROR 14A: Expected key_valid is %d, actual key_valid is %d", 1'b1, tb_rtl_crack.dut.key_valid);
            err = 1'b1;
        end
        if (tb_rtl_crack.dut.key !== 24'h7) begin
            $display("ERROR 14B: Expected key is %h, actual key is %h", 24'h7, tb_rtl_crack.dut.key);
            err = 1'b1;
        end

        // Case 15: Check pt_mem
        for (int i = 0; i <= 8'h2D; i++) begin
           if (exp_pt[i] !== tb_rtl_crack.dut.pt.altsyncram_component.m_default.altsyncram_inst.mem_data[i]) begin 
                $display("PT MEM 2[%d] ERROR: Expected pt is %h, actual pt is %h", i[7:0], exp_pt[i], tb_rtl_crack.dut.pt.altsyncram_component.m_default.altsyncram_inst.mem_data[i]);
                err = 1'b1;
            end
        end

        // ==================================================================================================================================================================

        // Run branch where there is no valid key
        // Case 16: Assert reset
        rst_n = 1'b0; en = 1'b0;
        @(posedge clk);
        @(posedge clk);
        state_checker(16, `IDLE);
        if (tb_rtl_crack.dut.rdy !== 1'b0) begin
            $display("ERROR 16: Expected rdy is %d, actual rdy is %d", 1'b0, tb_rtl_crack.dut.rdy);
            err = 1'b1;
        end

        // Case 17: Deassert reset
        rst_n = 1'b1;
        @(posedge clk);
        state_checker(17, `IDLE);
        if (tb_rtl_crack.dut.rdy !== 1'b0) begin
            $display("ERROR 17: Expected rdy is %d, actual rdy is %d", 1'b0, tb_rtl_crack.dut.rdy);
            err = 1'b1;
        end

        // Case 18: Assert en when rdy = 1
        en = 1'b1; ct_rddata = ciphertext[tb_rtl_crack.dut.ct_addr];
        @(posedge clk);
        state_checker(18, `IDLE);
        if (tb_rtl_crack.dut.rdy !== 1'b1) begin
            $display("ERROR 18: Expected rdy is %d, actual rdy is %d", 1'b1, tb_rtl_crack.dut.rdy);
            err = 1'b1;
        end

        // Case 19: Deassert en signal
        en = 1'b0;
        @(posedge clk);
        state_checker(19, `EN_A4);
        if (tb_rtl_crack.dut.rdy !== 1'b0) begin
            $display("ERROR 19: Expected rdy is %d, actual rdy is %d", 1'b0, tb_rtl_crack.dut.rdy);
            err = 1'b1;
        end

        force tb_rtl_crack.dut.curr_key = `KEY_MAX;

        // Case 20: Pass in the right ct value for each read op
        while (tb_rtl_crack.dut.state !== `IDLE) begin
            @(posedge clk);
            ct_rddata = ciphertext[tb_rtl_crack.dut.ct_addr];
        end

        // Case 21: Wait till done
        wait (tb_rtl_crack.dut.rdy == 1'b1);
        release tb_rtl_crack.dut.curr_key;

        if (tb_rtl_crack.dut.key_valid !== 1'b0) begin
            $display("ERROR 21A: Expected key_valid is %d, actual key_valid is %d", 1'b0, tb_rtl_crack.dut.key_valid);
            err = 1'b1;
        end
        if (tb_rtl_crack.dut.key !== `KEY_MAX) begin
            $display("ERROR 21B: Expected key is %h, actual key is %h", `KEY_MAX, tb_rtl_crack.dut.key);
            err = 1'b1;
        end

        if (~err)
            $display("SUCCESS: All tests passed.");
        $stop;
    end

endmodule: tb_rtl_crack
