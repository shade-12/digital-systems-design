`timescale 1ps / 1ps

module tb_syn_doublecrack();

    logic clk, rst_n, en, rdy, key_valid, err;
    logic [23:0] key;
    logic [7:0] ct_addr, ct_rddata;

    // Internal wires
    logic [7:0] ciphertext [255:0];
    logic [7:0] exp_pt [255:0];
    logic [7:0] ct_copy [255:0];

    doublecrack dut(
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
        if (tb_syn_doublecrack.dut.rdy !== 1'bx) begin
            $display("ERROR 1: Expected rdy is %d, actual rdy is %d", 1'bx, tb_syn_doublecrack.dut.rdy);
            err = 1'b1;
        end

        // Case 2: Assert reset
        rst_n = 1'b0; en = 1'b0;
        @(posedge clk);
        @(posedge clk);
        if (tb_syn_doublecrack.dut.rdy !== 1'b0) begin
            $display("ERROR 2: Expected rdy is %d, actual rdy is %d", 1'b0, tb_syn_doublecrack.dut.rdy);
            err = 1'b1;
        end

        // Case 3: Deassert reset
        rst_n = 1'b1;
        @(posedge clk);
        if (tb_syn_doublecrack.dut.rdy !== 1'b0) begin
            $display("ERROR 3: Expected rdy is %d, actual rdy is %d", 1'b0, tb_syn_doublecrack.dut.rdy);
            err = 1'b1;
        end

        // Case 4: Assert en when rdy = 1
        en = 1'b1; ct_rddata = ciphertext[tb_syn_doublecrack.dut.ct_addr];
        ct_copy[tb_syn_doublecrack.dut.ct_addr] = ct_rddata;
        @(posedge clk);
        if (tb_syn_doublecrack.dut.rdy !== 1'b1) begin
            $display("ERROR 4: Expected rdy is %d, actual rdy is %d", 1'b1, tb_syn_doublecrack.dut.rdy);
            err = 1'b1;
        end

        // Case 5: Deassert en signal
        en = 1'b0;
        @(posedge clk);
        if (tb_syn_doublecrack.dut.rdy !== 1'b0) begin
            $display("ERROR 5: Expected rdy is %d, actual rdy is %d", 1'b0, tb_syn_doublecrack.dut.rdy);
            err = 1'b1;
        end

        // Case 6: Start copy ct into module
        ct_rddata = ciphertext[tb_syn_doublecrack.dut.ct_addr];
        ct_copy[tb_syn_doublecrack.dut.ct_addr] = ct_rddata;
        for (int i = 0; i <= 24'h35; i++) begin
            @(posedge clk);
            @(posedge clk);
            ct_rddata = ciphertext[tb_syn_doublecrack.dut.ct_addr];
            ct_copy[tb_syn_doublecrack.dut.ct_addr] = ct_rddata;
        end
        for (int i = 0; i <= 24'h35; i++) begin
           if (ciphertext[i] !== ct_copy[i]) begin 
                $display("CT MEM [%d] ERROR: Expected ct_copy is %h, actual ct_copy is %h", i[7:0], ciphertext[i], ct_copy[i]);
                err = 1'b1;
            end
        end

        // Case 7: Wait for done
        wait (tb_syn_doublecrack.dut.key_valid == 1'b1);

        // Check pt_mem values
        for (int i = 0; i <= 8'h35; i++) begin
           if (exp_pt[i] !== tb_syn_doublecrack.dut.\pt|altsyncram_component|auto_generated|altsyncram1|ram_block3a0 .ram_core0.ram_core0.mem[i]) begin 
                $display("PT MEM [%d] ERROR: Expected pt is %h, actual pt is %h", i[7:0], exp_pt[i], tb_syn_doublecrack.dut.\pt|altsyncram_component|auto_generated|altsyncram1|ram_block3a0 .ram_core0.ram_core0.mem[i]);
                err = 1'b1;
            end
        end

        if (~err)
            $display("SUCCESS: All tests passed.");
        $stop;
    end

endmodule: tb_syn_doublecrack
