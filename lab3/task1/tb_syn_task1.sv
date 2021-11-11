`timescale 1ps / 1ps

module tb_syn_task1();

    logic CLOCK_50, err;
    logic [3:0] KEY;
    logic [9:0] SW, LEDR;
    logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    logic [31:0] tdo;

    task1 dut(
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

        // Case 2: Assert reset
        KEY[3] = 1'b0;
        @(negedge CLOCK_50)

        // Case 3: Deassert reset, state should be IDLE and rdy is high
        KEY[3] = 1'b1;
        @(posedge CLOCK_50)

        // Case 4: Start writing to memory
        for (int i = 0; i < 256; i++)
            @(posedge CLOCK_50)

        // Case 5: Stay at IDLE state after done writing all 0...256 to memory
        #50;

        // Case 6: Check memory
        for (int i = 0; i < 256; i++) begin
            if (tb_syn_task1.dut.\s|altsyncram_component|auto_generated|altsyncram1|ram_block3a0 .ram_core0.ram_core0.mem[i] !== i) begin
                $display("MEM ERR: Expected value is %d, actual value is %d", i, tb_syn_task1.dut.\s|altsyncram_component|auto_generated|altsyncram1|ram_block3a0 .ram_core0.ram_core0.mem[i]);
                err = 1'b1;
            end
        end

        // Case 1: Undefined inputs
        KEY[3] = 1'bx;
        #10;

        if (~err) begin
            $display("SUCCESS: All tests passed.");
        end
        $stop;
    end

endmodule: tb_syn_task1
