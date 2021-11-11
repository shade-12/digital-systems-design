`timescale 1ps / 1ps

module tb_syn_task2();

    logic CLOCK_50, err;
    logic [3:0] KEY;
    logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    logic [9:0] SW, LEDR;
    logic [7:0] mem[255:0];
    logic [31:0] tdo;

    task2 dut(
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

        // Case 1: Undefined inputs
        KEY[3] = 1'bx;
        #10;

        // Case 2: Assert reset
        KEY[3] = 1'b0;
        #30;

        // Case 3: Deassert reset, state should be IDLE and rdy_i is high
        KEY[3] = 1'b1;
        #10;

        // Case 4: Start writing to memory
        for (int i = 0; i < 256; i++) begin
            #10;
        end

        // Case 5: Done init memory
        #10;

        // Case 6: Check memory value
        for (int i = 0; i < 256; i++) begin
            if (tb_syn_task2.dut.\s|altsyncram_component|auto_generated|altsyncram1|ram_block3a0 .ram_core0.ram_core0.mem[i] !== i) begin
                $display("MEM ERR: Expected value is %d, actual value is %d", i, tb_syn_task2.dut.\s|altsyncram_component|auto_generated|altsyncram1|ram_block3a0 .ram_core0.ram_core0.mem[i]);
                err = 1'b1;
            end
        end

        SW = 10'h033C;
        #10;

        for (int i = 0; i < 256; i++)
            for (int j = 0; j < 7; j++)
                @(posedge CLOCK_50)         // Each swap takes eight cycle
        #20;

        $readmemh("result.txt", mem);

        for (int i = 0; i < 256; i++) begin
            if (tb_syn_task2.dut.\s|altsyncram_component|auto_generated|altsyncram1|ram_block3a0 .ram_core0.ram_core0.mem[i] !== mem[i]) begin 
                $display("MEM ERROR %d: Expected mem is %d, actual mem is %d", i[7:0], mem[i], tb_syn_task2.dut.\s|altsyncram_component|auto_generated|altsyncram1|ram_block3a0 .ram_core0.ram_core0.mem[i]);
                err = 1'b1;
            end
        end

        if (~err)
            $display("SUCCESS: All tests passed.");
        $stop;
    end

endmodule: tb_syn_task2
