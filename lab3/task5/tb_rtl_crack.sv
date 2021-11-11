`timescale 1ps / 1ps

module tb_rtl_crack();

    logic clk, rst_n, en, rdy, key_valid, fpt_wren, err;
    logic [23:0] key, start_key;
    logic [7:0] ct_addr, ct_rddata, fpt_addr, fpt_wrdata;

    // Internal wires
    logic [7:0] ciphertext [255:0];
    logic [7:0] exp_pt [255:0];
    logic [7:0] parent_pt [255:0];

    crack dut(.*);

    initial begin
        clk = 1;
        forever #5 clk = ~clk;
    end

    task state_checker;
        input [31:0] index;
        input [3:0] exp_state;
        begin
            if (tb_rtl_crack.dut.state !== exp_state) begin
                $display("ERROR %dA: Expected state is %d, actual state is %d", index, exp_state, tb_rtl_crack.dut.state);
                err = 1'b1;
            end
        end
    endtask

    // States
    `define IDLE     4'b0000
    `define EN_A4    4'b0001
    `define DEN_A4   4'b0010
    `define CRACK    4'b0011
    `define VERIFY   4'b0100
    `define READ_PT  4'b0101
    `define CHECK    4'b0110
    `define COPY_PT  4'b0111
    `define CRACKED  4'b1000

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
        rst_n = 1'b1; start_key = 24'h0;
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
        while (tb_rtl_crack.dut.state !== `COPY_PT) begin
            @(posedge clk);
            ct_rddata = ciphertext[tb_rtl_crack.dut.ct_addr];
        end

        // Case 7: Wait until the ciphertext is cracked
        if (tb_rtl_crack.dut.key !== 24'h18) begin
            $display("ERROR 7B: Expected key is %h, actual key is %h", 24'h18, tb_rtl_crack.dut.key);
            err = 1'b1;
        end

        // Case 8: Check pt_mem and pt_copy
        for (int i = 0; i <= 8'h35; i++) begin
           if (exp_pt[i] !== tb_rtl_crack.dut.pt.altsyncram_component.m_default.altsyncram_inst.mem_data[i]) begin 
                $display("PT MEM [%d] ERROR: Expected pt is %h, actual pt is %h", i[7:0], exp_pt[i], tb_rtl_crack.dut.pt.altsyncram_component.m_default.altsyncram_inst.mem_data[i]);
                err = 1'b1;
            end
        end

        for (int i = 0; i <= 8'h35; i++) begin
           if (exp_pt[i] !== tb_rtl_crack.dut.pt_copy[i]) begin 
                $display("PT MEM [%d] ERROR: Expected pt is %h, actual pt is %h", i[7:0], exp_pt[i], tb_rtl_crack.dut.pt_copy[i]);
                err = 1'b1;
            end
        end

        // Case 9: Update doublecracker's pt_mem
        while (tb_rtl_crack.dut.state == `COPY_PT) begin
            parent_pt[tb_rtl_crack.dut.fpt_addr] = tb_rtl_crack.dut.fpt_wrdata;
            @(posedge clk);
        end
        state_checker(9, `CRACKED);

        if (tb_rtl_crack.dut.key_valid !== 1'b1) begin
            $display("ERROR 9: Expected key_valid is %d, actual key_valid is %d", 1'b1, tb_rtl_crack.dut.key_valid);
            err = 1'b1;
        end

        for (int i = 0; i <= 8'h35; i++) begin
           if (exp_pt[i] !== parent_pt[i]) begin 
                $display("PT MEM [%d] ERROR: Expected pt is %h, actual pt is %h", i[7:0], exp_pt[i], parent_pt[i]);
                err = 1'b1;
            end
        end

        // ==================================================================================================================================================================

        // Run branch where there is no valid key
        // Case 10: Assert reset
        rst_n = 1'b0; en = 1'b0;
        @(posedge clk);
        @(posedge clk);
        state_checker(10, `IDLE);
        if (tb_rtl_crack.dut.rdy !== 1'b0) begin
            $display("ERROR 10: Expected rdy is %d, actual rdy is %d", 1'b0, tb_rtl_crack.dut.rdy);
            err = 1'b1;
        end

        // Case 11: Deassert reset
        rst_n = 1'b1;
        @(posedge clk);
        state_checker(11, `IDLE);
        if (tb_rtl_crack.dut.rdy !== 1'b0) begin
            $display("ERROR 11: Expected rdy is %d, actual rdy is %d", 1'b0, tb_rtl_crack.dut.rdy);
            err = 1'b1;
        end

        // Case 12: Assert en when rdy = 1
        en = 1'b1; ct_rddata = ciphertext[tb_rtl_crack.dut.ct_addr];
        @(posedge clk);
        state_checker(12, `IDLE);
        if (tb_rtl_crack.dut.rdy !== 1'b1) begin
            $display("ERROR 12: Expected rdy is %d, actual rdy is %d", 1'b1, tb_rtl_crack.dut.rdy);
            err = 1'b1;
        end

        // Case 13: Deassert en signal
        en = 1'b0;
        @(posedge clk);
        state_checker(13, `EN_A4);
        if (tb_rtl_crack.dut.rdy !== 1'b0) begin
            $display("ERROR 13: Expected rdy is %d, actual rdy is %d", 1'b0, tb_rtl_crack.dut.rdy);
            err = 1'b1;
        end

        force tb_rtl_crack.dut.curr_key = `KEY_MAX;

        // Case 14: Pass in the right ct value for each read op
        while (tb_rtl_crack.dut.state !== `IDLE) begin
            @(posedge clk);
            ct_rddata = ciphertext[tb_rtl_crack.dut.ct_addr];
        end

        // Case 15: Wait till done
        wait (tb_rtl_crack.dut.rdy == 1'b1);
        release tb_rtl_crack.dut.curr_key;

        if (tb_rtl_crack.dut.key_valid !== 1'b0) begin
            $display("ERROR 15A: Expected key_valid is %d, actual key_valid is %d", 1'b0, tb_rtl_crack.dut.key_valid);
            err = 1'b1;
        end
        if (tb_rtl_crack.dut.key !== `KEY_MAX) begin
            $display("ERROR 15B: Expected key is %h, actual key is %h", `KEY_MAX, tb_rtl_crack.dut.key);
            err = 1'b1;
        end

        if (~err)
            $display("SUCCESS: All tests passed.");
        $stop;
    end

endmodule: tb_rtl_crack
