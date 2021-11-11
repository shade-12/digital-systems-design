`timescale 1ps / 1ps

module tb_rtl_task1();

    logic CLOCK_50, err;
    logic [3:0] KEY;
    logic [9:0] SW, LEDR;
    logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    task1 dut(.*);

    initial begin
        CLOCK_50 = 1;
        forever #5 CLOCK_50 = ~CLOCK_50;
    end

    task validator;
        input [31:0] index;
        input [1:0] exp_state;
        input exp_rdy;
        input [7:0] exp_addr, exp_wrdata;
        input exp_wren;
        begin
            $display("CASE %d", index);
            if (tb_rtl_task1.dut.i.state !== exp_state) begin
                $display("ERROR A: Expected state is %d, actual state is %d", exp_state, tb_rtl_task1.dut.i.state);
                err = 1'b1;
            end
            if (tb_rtl_task1.dut.rdy !== exp_rdy) begin
                $display("ERROR B: Expected rdy is %d, actual rdy is %d", exp_rdy, tb_rtl_task1.dut.rdy);
                err = 1'b1;
            end
            if (tb_rtl_task1.dut.addr !== exp_addr) begin
                $display("ERROR C: Expected addr is %d, actual addr is %d", exp_addr, tb_rtl_task1.dut.addr);
                err = 1'b1;
            end
            if (tb_rtl_task1.dut.wrdata !== exp_wrdata) begin
                $display("ERROR D: Expected wrdata is %d, actual wrdata is %d", exp_wrdata, tb_rtl_task1.dut.wrdata);
                err = 1'b1;
            end
            if (tb_rtl_task1.dut.wren !== exp_wren) begin
                $display("ERROR E: Expected wren is %d, actual wren is %d", exp_wren, tb_rtl_task1.dut.wren);
                err = 1'b1;
            end
        end
    endtask

    // init module states
    `define IDLE 1'b0
    `define WRITE 1'b1

    initial begin
        err = 1'b0;

        // Case 1: Undefined inputs
        KEY[3] = 1'bx;
        #10;
        validator(1, `IDLE, 1'b0, 8'b0, 8'b0, 1'b0);

        // Case 2: Assert reset
        KEY[3] = 1'b0;
        #30;
        validator(2, `IDLE, 1'b0, 8'b0, 8'b0, 1'b0);

        // Case 3: Deassert reset, state should be IDLE and rdy is high
        KEY[3] = 1'b1;
        #10;
        validator(3, `IDLE, 1'b1, 8'b0, 8'b0, 1'b0);

        // Case 4: Start writing to memory
        for (int i = 0; i < 256; i++) begin
            #10;
            validator(i, `WRITE, 1'b0, i, i, 1'b1);
        end

        // Case 5: Stay at IDLE state after done writing all 0...256 to memory
        #50;
        validator(5, `IDLE, 1'b1, 8'b0, 8'b0, 1'b0);

        // Case 6: Check memory
        for (int i = 0; i < 256; i++) begin
            if (tb_rtl_task1.dut.s.altsyncram_component.m_default.altsyncram_inst.mem_data[i] !== i) begin
                $display("MEM ERR: Expected value is %d, actual value is %d", i, tb_rtl_task1.dut.s.altsyncram_component.m_default.altsyncram_inst.mem_data[i]);
                err = 1'b1;
            end
        end

        if (~err) begin
            $display("SUCCESS: All tests passed.");
        end
        $stop;
    end

endmodule: tb_rtl_task1
