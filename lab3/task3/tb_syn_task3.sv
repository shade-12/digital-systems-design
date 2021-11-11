`timescale 1ps / 1ps

module tb_syn_task3();

    logic CLOCK_50, err;
    logic [3:0] KEY;
    logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    logic [9:0] SW, LEDR;

    // Internal wires
    logic [7:0] exp_ksa [255:0];
    logic [7:0] exp_pad [255:0];
    logic [7:0] exp_pt [255:0];

    task3 dut(
        .altera_reserved_tms(32'b0),
        .altera_reserved_tck(32'b0),
        .altera_reserved_tdi(32'b0),
        .altera_reserved_tdo(tdo),
        .*
    );

    initial begin
        CLOCK_50 = 1;
        forever #5 CLOCK_50 = ~CLOCK_50;
    end

    initial begin
        err = 1'b0;

        // Init memories array
        $readmemh("prga_res2.txt", exp_pt);
        $readmemh("test2.memh", tb_syn_task3.dut.\ct|altsyncram_component|auto_generated|altsyncram1|ram_block3a0 .ram_core0.ram_core0.mem);

        // Case 1: Undefined inputs
        KEY[3] = 1'bx;
        #10;
        if (tb_syn_task3.dut.LEDR[0] !== 1'b0) begin
            $display("ERROR 1: Expected rdy is %d, actual rdy is %d", 1'b0, tb_syn_task3.dut.LEDR[0]);
            err = 1'b1;
        end

        // Case 2: Assert reset
        KEY[3] = 1'b0; SW = 10'h18;
        @(negedge CLOCK_50);
        if (tb_syn_task3.dut.LEDR[0] !== 1'b0) begin
            $display("ERROR 2: Expected rdy is %d, actual rdy is %d", 1'b0, tb_syn_task3.dut.LEDR[0]);
            err = 1'b1;
        end

        // Case 3: Deassert reset
        KEY[3] = 1'b1;
        @(posedge CLOCK_50);
        if (tb_syn_task3.dut.LEDR[0] !== 1'b0) begin
            $display("ERROR 3: Expected rdy is %d, actual rdy is %d", 1'b0, tb_syn_task3.dut.LEDR[0]);
            err = 1'b1;
        end

        // Case 4: Assert en when rdy = 1
        @(posedge CLOCK_50);
        if (tb_syn_task3.dut.LEDR[0] !== 1'b1) begin
            $display("ERROR 4: Expected rdy is %d, actual rdy is %d", 1'b1, tb_syn_task3.dut.LEDR[0]);
            err = 1'b1;
        end

        @(posedge CLOCK_50);

        // Case 5: Check pt(plaintext) result against axp_pt
        wait(tb_syn_task3.dut.LEDR[0] == 1'b1);
        if (tb_syn_task3.dut.\pt|altsyncram_component|auto_generated|altsyncram1|ram_block3a0 .ram_core0.ram_core0.mem[0] !== 8'd53) begin 
            $display("PT LENGTH MISMATCH: Expected pt length is %h, actual pt length is %h", 8'd53, tb_syn_task3.dut.\pt|altsyncram_component|auto_generated|altsyncram1|ram_block3a0 .ram_core0.ram_core0.mem[0]);
            err = 1'b1;
        end
        for (int i = 0; i < 8'd53; i++) begin
           if (exp_pt[i] !== tb_syn_task3.dut.\pt|altsyncram_component|auto_generated|altsyncram1|ram_block3a0 .ram_core0.ram_core0.mem[i + 1]) begin 
                $display("PT[%d] ERROR: Expected pt is %h, actual pt is %h", i[7:0], exp_pt[i], tb_syn_task3.dut.\pt|altsyncram_component|auto_generated|altsyncram1|ram_block3a0 .ram_core0.ram_core0.mem[i + 1]);
                err = 1'b1;
            end
        end

        if (~err)
            $display("SUCCESS: All tests passed.");
        $stop;
    end

endmodule: tb_syn_task3
