`timescale 1ps / 1ps

module tb_syn_crack();

    logic clk, rst_n, en, rdy, key_valid, fpt_wren, err;
    logic [23:0] key, start_key;
    logic [7:0] ct_addr, ct_rddata, fpt_addr, fpt_wrdata;

    // Internal wires
    logic [7:0] ciphertext [255:0];
    logic [7:0] exp_pt [255:0];
    logic [7:0] parent_pt [255:0];

    crack dut(
        .altera_reserved_tms(32'b0),
        .altera_reserved_tck(32'b0),
        .altera_reserved_tdi(32'b0),
        .altera_reserved_tdo(tdo),
        .*
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

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
        if (tb_syn_crack.dut.rdy !== 1'bx) begin
            $display("ERROR 1: Expected rdy is %d, actual rdy is %d", 1'bx, tb_syn_crack.dut.rdy);
            err = 1'b1;
        end

        // Case 2: Assert reset
        rst_n = 1'b0; en = 1'b0;
        @(posedge clk);
        @(posedge clk);
        if (tb_syn_crack.dut.rdy !== 1'b0) begin
            $display("ERROR 2: Expected rdy is %d, actual rdy is %d", 1'b0, tb_syn_crack.dut.rdy);
            err = 1'b1;
        end

        // Case 3: Deassert reset
        rst_n = 1'b1; start_key = 24'h0;
        @(posedge clk);
        if (tb_syn_crack.dut.rdy !== 1'b0) begin
            $display("ERROR 3: Expected rdy is %d, actual rdy is %d", 1'b0, tb_syn_crack.dut.rdy);
            err = 1'b1;
        end

        // Case 4: Assert en when rdy = 1
        en = 1'b1; ct_rddata = ciphertext[tb_syn_crack.dut.ct_addr];
        @(posedge clk);
        if (tb_syn_crack.dut.rdy !== 1'b1) begin
            $display("ERROR 4A: Expected rdy is %d, actual rdy is %d", 1'b1, tb_syn_crack.dut.rdy);
            err = 1'b1;
        end

        // Case 5: Deassert en signal
        en = 1'b0;
        @(posedge clk);
        if (tb_syn_crack.dut.rdy !== 1'b0) begin
            $display("ERROR 5A: Expected rdy is %d, actual rdy is %d", 1'b0, tb_syn_crack.dut.rdy);
            err = 1'b1;
        end

        // Case 6: Pass in the right ct value for each read op
        while (tb_syn_crack.dut.fpt_wren !== 1'b1) begin
            @(posedge clk);
            ct_rddata = ciphertext[tb_syn_crack.dut.ct_addr];
        end

        // Case 7: Wait until the ciphertext is cracked
        if (tb_syn_crack.dut.key !== 24'h18) begin
            $display("ERROR 7B: Expected key is %h, actual key is %h", 24'h18, tb_syn_crack.dut.key);
            err = 1'b1;
        end

        // Case 8: Check pt_mem and pt_copy
        for (int i = 0; i <= 8'h35; i++) begin
           if (exp_pt[i] !== tb_syn_crack.dut.\pt|altsyncram_component|auto_generated|altsyncram1|ram_block3a0 .ram_core0.ram_core0.mem[i]) begin 
                $display("PT MEM [%d] ERROR: Expected pt is %h, actual pt is %h", i[7:0], exp_pt[i], tb_syn_crack.dut.\pt|altsyncram_component|auto_generated|altsyncram1|ram_block3a0 .ram_core0.ram_core0.mem[i]);
                err = 1'b1;
            end
        end

        // Case 9: Update doublecracker's pt_mem
        while (tb_syn_crack.dut.fpt_wren == 1'b1) begin
            parent_pt[tb_syn_crack.dut.fpt_addr] = tb_syn_crack.dut.fpt_wrdata;
            @(posedge clk);
        end

        if (tb_syn_crack.dut.key_valid !== 1'b1) begin
            $display("ERROR 9: Expected key_valid is %d, actual key_valid is %d", 1'b1, tb_syn_crack.dut.key_valid);
            err = 1'b1;
        end

        for (int i = 0; i <= 8'h35; i++) begin
           if (exp_pt[i] !== parent_pt[i]) begin 
                $display("PT MEM [%d] ERROR: Expected pt is %h, actual pt is %h", i[7:0], exp_pt[i], parent_pt[i]);
                err = 1'b1;
            end
        end

        if (~err)
            $display("SUCCESS: All tests passed.");
        $stop;
    end

endmodule: tb_syn_crack
