`timescale 1ps / 1ps

module tb_syn_task5();

    logic CLOCK_50, err;
    logic [3:0] KEY;
    logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    logic [9:0] SW, LEDR;

    // Internal wires
    logic [7:0] exp_pt [255:0];

    task5 dut(
        .altera_reserved_tms(32'b0),
        .altera_reserved_tck(32'b0),
        .altera_reserved_tdi(32'b0),
        .altera_reserved_tdo(tdo),
        .*
    );

    initial begin
        CLOCK_50 = 0;
        forever #5 CLOCK_50 = ~CLOCK_50;
    end

    task hex_checker;
        input [31:0] index;
        input [6:0] exp_HEX5, exp_HEX4, exp_HEX3, exp_HEX2, exp_HEX1, exp_HEX0;
        begin
            if (tb_syn_task5.dut.HEX5 !== exp_HEX5) begin
                $display("ERROR %dA: Expected HEX5 is %b, actual HEX5 is %b", index, exp_HEX5, tb_syn_task5.dut.HEX5);
                err = 1'b1;
            end
            if (tb_syn_task5.dut.HEX4 !== exp_HEX4) begin
                $display("ERROR %dB: Expected HEX4 is %b, actual HEX4 is %b", index, exp_HEX4, tb_syn_task5.dut.HEX4);
                err = 1'b1;
            end
            if (tb_syn_task5.dut.HEX3 !== exp_HEX3) begin
                $display("ERROR %dC: Expected HEX3 is %b, actual HEX3 is %b", index, exp_HEX3, tb_syn_task5.dut.HEX3);
                err = 1'b1;
            end
            if (tb_syn_task5.dut.HEX2 !== exp_HEX2) begin
                $display("ERROR %dD: Expected HEX2 is %b, actual HEX2 is %b", index, exp_HEX2, tb_syn_task5.dut.HEX2);
                err = 1'b1;
            end
            if (tb_syn_task5.dut.HEX1 !== exp_HEX1) begin
                $display("ERROR %dE: Expected HEX1 is %b, actual HEX1 is %b", index, exp_HEX1, tb_syn_task5.dut.HEX1);
                err = 1'b1;
            end
            if (tb_syn_task5.dut.HEX0 !== exp_HEX0) begin
                $display("ERROR %dF: Expected HEX0 is %b, actual HEX0 is %b", index, exp_HEX0, tb_syn_task5.dut.HEX0);
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
    `define EIGHT  7'b0000000

    // Some constants
     `define KEY_MAX     24'hFFFFFF

    initial begin
        err = 1'b0;

        // Test 1 expected result:
        // Key: 24'h18
        // Decrypted message: Mrs. Dalloway said she would buy the flowers herself.

        // Init memories array
        $readmemh("crack_res1.txt", exp_pt);
        $readmemh("test1.memh", tb_syn_task5.dut.\ct|altsyncram_component|auto_generated|altsyncram1|ram_block3a0 .ram_core0.ram_core0.mem);

        // Case 1: Assert reset
        KEY[3] = 1'b0;
        @(posedge CLOCK_50);
        @(posedge CLOCK_50);
        if (tb_syn_task5.dut.LEDR[0] !== 1'b0) begin
            $display("ERROR 1: Expected LEDR[0] is %d, actual LEDR[0] is %d", 1'b0, tb_syn_task5.dut.LEDR[0]);
            err = 1'b1;
        end

        // Case 2: Deassert reset
        KEY[3] = 1'b1;
        @(posedge CLOCK_50);
        if (tb_syn_task5.dut.LEDR[0] !== 1'b0) begin
            $display("ERROR 2: Expected LEDR[0] is %d, actual LEDR[0] is %d", 1'b0, tb_syn_task5.dut.LEDR[0]);
            err = 1'b1;
        end

        // Case 3: Assert en when LEDR[0] = 1
        @(posedge CLOCK_50);
        if (tb_syn_task5.dut.LEDR[0] !== 1'b1) begin
            $display("ERROR 3: Expected LEDR[0] is %d, actual LEDR[0] is %d", 1'b1, tb_syn_task5.dut.LEDR[0]);
            err = 1'b1;
        end

        // Case 4: Deassert en signal
        @(posedge CLOCK_50);
        if (tb_syn_task5.dut.LEDR[0] !== 1'b0) begin
            $display("ERROR 4: Expected LEDR[0] is %d, actual LEDR[0] is %d", 1'b0, tb_syn_task5.dut.LEDR[0]);
            err = 1'b1;
        end

        // Case 5: Check HEX0 outputs to make sure they're blank when computing result
        @(posedge CLOCK_50);
        hex_checker(5, `NONE, `NONE, `NONE, `NONE, `NONE, `NONE);

        // Wait until the ciphertext is cracked
        wait (tb_syn_task5.dut.LEDR[0] == 1'b1);
        @(posedge CLOCK_50);

        // Case 6: Check key result and HEX0 outputs
        hex_checker(6, `ZERO, `ZERO, `ZERO, `ZERO, `ONE, `EIGHT);

        // Case 7: Check pt_mem
        for (int i = 0; i <= 8'h35; i++) begin
           if (exp_pt[i] !== tb_syn_task5.dut.\dc|pt|altsyncram_component|auto_generated|altsyncram1|ram_block3a0 .ram_core0.ram_core0.mem[i]) begin 
                $display("PT MEM [%d] ERROR: Expected pt is %h, actual pt is %h", i[7:0], exp_pt[i], tb_syn_task5.dut.\dc|pt|altsyncram_component|auto_generated|altsyncram1|ram_block3a0 .ram_core0.ram_core0.mem[i]);
                err = 1'b1;
            end
        end

        // Check c1.pt_mem
        for (int i = 0; i <= 8'h35; i++) begin
           if (exp_pt[i] !== tb_syn_task5.dut.\dc|c1|pt|altsyncram_component|auto_generated|altsyncram1|ram_block3a0 .ram_core0.ram_core0.mem[i]) begin 
                $display("C1.PT MEM [%d] ERROR: Expected c1.pt is %h, actual c1.pt is %h", i[7:0], exp_pt[i], tb_syn_task5.dut.\dc|c1|pt|altsyncram_component|auto_generated|altsyncram1|ram_block3a0 .ram_core0.ram_core0.mem[i]);
                err = 1'b1;
            end
        end

        if (~err)
            $display("SUCCESS: All tests passed.");
        $stop;
    end

endmodule: tb_syn_task5
