`timescale 1ps / 1ps

module tb_rtl_task4();

    logic CLOCK_50, err;
    logic [3:0] KEY;
    logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    logic [9:0] SW, LEDR;

    // Internal wires
    logic [7:0] exp_pt [255:0];

    task4 dut(.*);

    initial begin
        CLOCK_50 = 1;
        forever #5 CLOCK_50 = ~CLOCK_50;
    end

    task hex_checker;
        input [31:0] index;
        input [6:0] exp_HEX5, exp_HEX4, exp_HEX3, exp_HEX2, exp_HEX1, exp_HEX0;
        begin
            if (tb_rtl_task4.dut.HEX5 !== exp_HEX5) begin
                $display("ERROR %dA: Expected HEX5 is %b, actual HEX5 is %b", index, exp_HEX5, tb_rtl_task4.dut.HEX5);
                err = 1'b1;
            end
            if (tb_rtl_task4.dut.HEX4 !== exp_HEX4) begin
                $display("ERROR %dB: Expected HEX4 is %b, actual HEX4 is %b", index, exp_HEX4, tb_rtl_task4.dut.HEX4);
                err = 1'b1;
            end
            if (tb_rtl_task4.dut.HEX3 !== exp_HEX3) begin
                $display("ERROR %dC: Expected HEX3 is %b, actual HEX3 is %b", index, exp_HEX3, tb_rtl_task4.dut.HEX3);
                err = 1'b1;
            end
            if (tb_rtl_task4.dut.HEX2 !== exp_HEX2) begin
                $display("ERROR %dD: Expected HEX2 is %b, actual HEX2 is %b", index, exp_HEX2, tb_rtl_task4.dut.HEX2);
                err = 1'b1;
            end
            if (tb_rtl_task4.dut.HEX1 !== exp_HEX1) begin
                $display("ERROR %dE: Expected HEX1 is %b, actual HEX1 is %b", index, exp_HEX1, tb_rtl_task4.dut.HEX1);
                err = 1'b1;
            end
            if (tb_rtl_task4.dut.HEX0 !== exp_HEX0) begin
                $display("ERROR %dF: Expected HEX0 is %b, actual HEX0 is %b", index, exp_HEX0, tb_rtl_task4.dut.HEX0);
                err = 1'b1;
            end
        end
    endtask

    // Constants from seg7 module
    `define NONE   7'b1111111
    `define DASH   7'b0111111
    `define ZERO   7'b1000000
    `define ONE    7'b1111001
    `define SEVEN  7'b1111000

    // Some constants
     `define KEY_MAX     24'hFFFFFF

    initial begin
        err = 1'b0;

        // Test 1 expected result:
        // Key: 24'h1
        // Decrypted message: In a hole in the ground there lived a hobbit.

        // Init memories array
        $readmemh("crack_res1.txt", exp_pt);
        $readmemh("test1.memh", tb_rtl_task4.dut.ct.altsyncram_component.m_default.altsyncram_inst.mem_data);

        // Case 1: Undefined inputs
        KEY[3] = 1'bx;
        #10;
        if (tb_rtl_task4.dut.rdy !== 1'bx) begin
            $display("ERROR 1: Expected rdy is %d, actual rdy is %d", 1'bx, tb_rtl_task4.dut.rdy);
            err = 1'b1;
        end

        // Case 2: Assert reset
        KEY[3] = 1'b0;
        @(negedge CLOCK_50);
        if (tb_rtl_task4.dut.rdy !== 1'b0) begin
            $display("ERROR 2: Expected rdy is %d, actual rdy is %d", 1'b0, tb_rtl_task4.dut.rdy);
            err = 1'b1;
        end

        // Case 3: Deassert reset
        KEY[3] = 1'b1;
        @(posedge CLOCK_50);
        if (tb_rtl_task4.dut.rdy !== 1'b0) begin
            $display("ERROR 3: Expected rdy is %d, actual rdy is %d", 1'b0, tb_rtl_task4.dut.rdy);
            err = 1'b1;
        end

        // Case 4: Assert en when rdy = 1
        @(posedge CLOCK_50);
        if (tb_rtl_task4.dut.rdy !== 1'b1) begin
            $display("ERROR 4A: Expected rdy is %d, actual rdy is %d", 1'b1, tb_rtl_task4.dut.rdy);
            err = 1'b1;
        end
        if (tb_rtl_task4.dut.en !== 1'b1) begin
            $display("ERROR 4B: Expected en is %d, actual en is %d", 1'b1, tb_rtl_task4.dut.en);
            err = 1'b1;
        end

        // Case 5: Deassert en signal
        @(posedge CLOCK_50);
        if (tb_rtl_task4.dut.rdy !== 1'b0) begin
            $display("ERROR 5A: Expected rdy is %d, actual rdy is %d", 1'b0, tb_rtl_task4.dut.rdy);
            err = 1'b1;
        end
        if (tb_rtl_task4.dut.en !== 1'b0) begin
            $display("ERROR 5B: Expected en is %d, actual en is %d", 1'b0, tb_rtl_task4.dut.en);
            err = 1'b1;
        end

        // Case 6: Check HEX0 outputs to make sure they're blank when computing result
        @(posedge CLOCK_50);
        hex_checker(6, `NONE, `NONE, `NONE, `NONE, `NONE, `NONE);

        // Case 7: Check if key_valid = 0 while computing
        @(posedge CLOCK_50);
        if (tb_rtl_task4.dut.key_valid !== 1'b0) begin
            $display("ERROR 7: Expected key_valid is %d, actual key_valid is %d", 1'b0, tb_rtl_task4.dut.key_valid);
            err = 1'b1;
        end

        // Wait until the ciphertext is cracked
        wait (tb_rtl_task4.dut.rdy == 1'b1);
        @(posedge CLOCK_50);
        // Case 8: Check key result and HEX0 outputs
        if (tb_rtl_task4.dut.key_valid !== 1'b1) begin
            $display("ERROR 8A: Expected key_valid is %d, actual key_valid is %d", 1'b1, tb_rtl_task4.dut.key_valid);
            err = 1'b1;
        end
        if (tb_rtl_task4.dut.key !== 24'h1) begin
            $display("ERROR 8B: Expected key is %h, actual key is %h", 24'h1, tb_rtl_task4.dut.key);
            err = 1'b1;
        end
        hex_checker(8, `ZERO, `ZERO, `ZERO, `ZERO, `ZERO, `ONE);

        // Case 9: Check pt_mem
        for (int i = 0; i <= 8'h2D; i++) begin
           if (exp_pt[i] !== tb_rtl_task4.dut.c.pt.altsyncram_component.m_default.altsyncram_inst.mem_data[i]) begin 
                $display("PT MEM [%d] ERROR: Expected pt is %h, actual pt is %h", i[7:0], exp_pt[i], tb_rtl_task4.dut.c.pt.altsyncram_component.m_default.altsyncram_inst.mem_data[i]);
                err = 1'b1;
            end
        end

        // ====================================================================================================================================================================================

        // Test 2 expected result:
        // Key: 24'h7
        // Decrypted message: The sky above the port was the color of television, tuned to a dead channel.

        // Init memories array
        $readmemh("crack_res2.txt", exp_pt);
        $readmemh("test2.memh", tb_rtl_task4.dut.ct.altsyncram_component.m_default.altsyncram_inst.mem_data);

        // Case 10: Assert reset
        KEY[3] = 1'b0;
        @(posedge CLOCK_50);
        @(posedge CLOCK_50);
        if (tb_rtl_task4.dut.rdy !== 1'b0) begin
            $display("ERROR 10: Expected rdy is %d, actual rdy is %d", 1'b0, tb_rtl_task4.dut.rdy);
            err = 1'b1;
        end

        // Case 11: Deassert reset
        KEY[3] = 1'b1;
        @(posedge CLOCK_50);
        if (tb_rtl_task4.dut.rdy !== 1'b0) begin
            $display("ERROR 11: Expected rdy is %d, actual rdy is %d", 1'b0, tb_rtl_task4.dut.rdy);
            err = 1'b1;
        end

        // Case 12: Assert en when rdy = 1
        @(posedge CLOCK_50);
        if (tb_rtl_task4.dut.rdy !== 1'b1) begin
            $display("ERROR 12A: Expected rdy is %d, actual rdy is %d", 1'b1, tb_rtl_task4.dut.rdy);
            err = 1'b1;
        end
        if (tb_rtl_task4.dut.en !== 1'b1) begin
            $display("ERROR 12B: Expected en is %d, actual en is %d", 1'b1, tb_rtl_task4.dut.en);
            err = 1'b1;
        end

        // Case 13: Deassert en signal
        @(posedge CLOCK_50);
        if (tb_rtl_task4.dut.rdy !== 1'b0) begin
            $display("ERROR 13A: Expected rdy is %d, actual rdy is %d", 1'b0, tb_rtl_task4.dut.rdy);
            err = 1'b1;
        end
        if (tb_rtl_task4.dut.en !== 1'b0) begin
            $display("ERROR 13B: Expected en is %d, actual en is %d", 1'b0, tb_rtl_task4.dut.en);
            err = 1'b1;
        end

        // Case 14: Check HEX0 outputs to make sure they're blank when computing result
        @(posedge CLOCK_50);
        hex_checker(14, `NONE, `NONE, `NONE, `NONE, `NONE, `NONE);

        // Case 15: Check if key_valid = 0 while computing
        @(posedge CLOCK_50);
        if (tb_rtl_task4.dut.key_valid !== 1'b0) begin
            $display("ERROR 15: Expected key_valid is %d, actual key_valid is %d", 1'b0, tb_rtl_task4.dut.key_valid);
            err = 1'b1;
        end

        // Wait until the ciphertext is cracked
        wait (tb_rtl_task4.dut.rdy == 1'b1);
        @(posedge CLOCK_50);
        // Case 16: Check key result and HEX0 outputs
        if (tb_rtl_task4.dut.key_valid !== 1'b1) begin
            $display("ERROR 16A: Expected key_valid is %d, actual key_valid is %d", 1'b1, tb_rtl_task4.dut.key_valid);
            err = 1'b1;
        end
        if (tb_rtl_task4.dut.key !== 24'h7) begin
            $display("ERROR 16B: Expected key is %h, actual key is %h", 24'h7, tb_rtl_task4.dut.key);
            err = 1'b1;
        end
        hex_checker(16, `ZERO, `ZERO, `ZERO, `ZERO, `ZERO, `SEVEN);

        // Case 17: Check pt_mem
        for (int i = 0; i <= 8'h2D; i++) begin
           if (exp_pt[i] !== tb_rtl_task4.dut.c.pt.altsyncram_component.m_default.altsyncram_inst.mem_data[i]) begin 
                $display("PT MEM 2[%d] ERROR: Expected pt is %h, actual pt is %h", i[7:0], exp_pt[i], tb_rtl_task4.dut.c.pt.altsyncram_component.m_default.altsyncram_inst.mem_data[i]);
                err = 1'b1;
            end
        end

        // ============================================================================================================================================================================================

        // Run branch where there is no valid key
        // Case 18: Assert reset
        KEY[3] = 1'b0;
        @(posedge CLOCK_50);
        @(posedge CLOCK_50);
        if (tb_rtl_task4.dut.rdy !== 1'b0) begin
            $display("ERROR 18: Expected rdy is %d, actual rdy is %d", 1'b0, tb_rtl_task4.dut.rdy);
            err = 1'b1;
        end

        // Case 19: Deassert reset
        KEY[3] = 1'b1;
        @(posedge CLOCK_50);
        if (tb_rtl_task4.dut.rdy !== 1'b0) begin
            $display("ERROR 19: Expected rdy is %d, actual rdy is %d", 1'b0, tb_rtl_task4.dut.rdy);
            err = 1'b1;
        end

        // Case 20: Assert en when rdy = 1
        @(posedge CLOCK_50);
        if (tb_rtl_task4.dut.rdy !== 1'b1) begin
            $display("ERROR 20A: Expected rdy is %d, actual rdy is %d", 1'b1, tb_rtl_task4.dut.rdy);
            err = 1'b1;
        end
        if (tb_rtl_task4.dut.en !== 1'b1) begin
            $display("ERROR 20B: Expected en is %d, actual en is %d", 1'b1, tb_rtl_task4.dut.en);
            err = 1'b1;
        end

        // Case 21: Deassert en signal
        force tb_rtl_task4.dut.c.curr_key = `KEY_MAX;
        @(posedge CLOCK_50);
        if (tb_rtl_task4.dut.rdy !== 1'b0) begin
            $display("ERROR 21A: Expected rdy is %d, actual rdy is %d", 1'b0, tb_rtl_task4.dut.rdy);
            err = 1'b1;
        end
        if (tb_rtl_task4.dut.en !== 1'b0) begin
            $display("ERROR 21B: Expected en is %d, actual en is %d", 1'b0, tb_rtl_task4.dut.en);
            err = 1'b1;
        end

        // Wait until it's done
        wait (tb_rtl_task4.dut.rdy == 1'b1);
        @(posedge CLOCK_50);
        release tb_rtl_task4.dut.c.curr_key;

        // Case 16: Check key result and HEX0 outputs
        if (tb_rtl_task4.dut.key_valid !== 1'b0) begin
            $display("ERROR 16A: Expected key_valid is %d, actual key_valid is %d", 1'b0, tb_rtl_task4.dut.key_valid);
            err = 1'b1;
        end
        if (tb_rtl_task4.dut.key !== `KEY_MAX) begin
            $display("ERROR 16B: Expected key is %h, actual key is %h", `KEY_MAX, tb_rtl_task4.dut.key);
            err = 1'b1;
        end
        hex_checker(16, `DASH, `DASH, `DASH, `DASH, `DASH, `DASH);

        if (~err)
            $display("SUCCESS: All tests passed.");
        $stop;
    end

endmodule: tb_rtl_task4
