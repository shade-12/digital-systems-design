`timescale 1ps / 1ps

module tb_rtl_task2();

    logic CLOCK_50, err;
    logic [3:0] KEY;
    logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    logic [9:0] SW, LEDR;
    logic [7:0] mem[255:0];

    task2 dut(.*);

    initial begin
        CLOCK_50 = 1;
        forever #5 CLOCK_50 = ~CLOCK_50;
    end

    task init_validator;
        input [31:0] index;
        input [1:0] exp_state;
        input exp_rdy;
        input [7:0] exp_addr, exp_wrdata;
        input exp_wren;
        begin
            $display("CASE %d", index);
            if (tb_rtl_task2.dut.i.state !== exp_state) begin
                $display("ERROR A: Expected state is %d, actual state is %d", exp_state, tb_rtl_task2.dut.i.state);
                err = 1'b1;
            end
            if (tb_rtl_task2.dut.rdy_i !== exp_rdy) begin
                $display("ERROR B: Expected rdy_i is %d, actual rdy_i is %d", exp_rdy, tb_rtl_task2.dut.rdy_i);
                err = 1'b1;
            end
            if (tb_rtl_task2.dut.addr !== exp_addr) begin
                $display("ERROR C: Expected addr is %d, actual addr is %d", exp_addr, tb_rtl_task2.dut.addr);
                err = 1'b1;
            end
            if (tb_rtl_task2.dut.wrdata !== exp_wrdata) begin
                $display("ERROR D: Expected wrdata is %d, actual wrdata is %d", exp_wrdata, tb_rtl_task2.dut.wrdata);
                err = 1'b1;
            end
            if (tb_rtl_task2.dut.wren !== exp_wren) begin
                $display("ERROR E: Expected wren is %d, actual wren is %d", exp_wren, tb_rtl_task2.dut.wren);
                err = 1'b1;
            end
        end
    endtask

    task ksa_validator;
        input [31:0] index;
        input [1:0] exp_state;
        input exp_rdy;
        input [7:0] exp_addr, exp_wrdata;
        input exp_wren;
        begin
            $display("CASE %d", index);
            if (tb_rtl_task2.dut.k.state !== exp_state) begin
                $display("ERROR A: Expected state is %d, actual state is %d", exp_state, tb_rtl_task2.dut.k.state);
                err = 1'b1;
            end
            if (tb_rtl_task2.dut.rdy_k !== exp_rdy) begin
                $display("ERROR B: Expected rdy_k is %d, actual rdy_k is %d", exp_rdy, tb_rtl_task2.dut.rdy_k);
                err = 1'b1;
            end
            if (tb_rtl_task2.dut.addr !== exp_addr) begin
                $display("ERROR C: Expected addr is %d, actual addr is %d", exp_addr, tb_rtl_task2.dut.addr);
                err = 1'b1;
            end
            if (tb_rtl_task2.dut.wrdata !== exp_wrdata) begin
                $display("ERROR D: Expected wrdata is %d, actual wrdata is %d", exp_wrdata, tb_rtl_task2.dut.wrdata);
                err = 1'b1;
            end
            if (tb_rtl_task2.dut.wren !== exp_wren) begin
                $display("ERROR E: Expected wren is %d, actual wren is %d", exp_wren, tb_rtl_task2.dut.wren);
                err = 1'b1;
            end
        end
    endtask

    // init module states
    `define IDLE 1'b0
    `define WRITE 1'b1

    // ksa module states
    `define READY     3'b000
    `define READ_I    3'b001
    `define STALL_R   3'b010
    `define CALC_J    3'b011
    `define READ_J    3'b100
    `define STALL_W   3'b101
    `define WRITE_I   3'b110
    `define WRITE_J   3'b111

    initial begin
        err = 1'b0;

        // Case 1: Undefined inputs
        KEY[3] = 1'bx;
        #10;
        init_validator(1, `IDLE, 1'b0, 8'b0, 8'b0, 1'b0);

        // Case 2: Assert reset
        KEY[3] = 1'b0;
        #30;
        init_validator(2, `IDLE, 1'b0, 8'b0, 8'b0, 1'b0);

        // Case 3: Deassert reset, state should be IDLE and rdy_i is high
        KEY[3] = 1'b1;
        #10;
        init_validator(3, `IDLE, 1'b1, 8'b0, 8'b0, 1'b0);
        ksa_validator(3, `READY, 1'b1, 8'b0, 8'b0, 1'b0);

        // Case 4: Start writing to memory
        for (int i = 0; i < 256; i++) begin
            #10;
            init_validator(i, `WRITE, 1'b0, i, i, 1'b1);
        end

        // Case 5: Done init memory
        #10;
        init_validator(5, `IDLE, 1'b0, 8'b0, 8'b0, 1'b0);

        // Case 6: Check memory value
        for (int i = 0; i < 256; i++) begin
            if (tb_rtl_task2.dut.s.altsyncram_component.m_default.altsyncram_inst.mem_data[i] !== i) begin
                $display("MEM ERR: Expected value is %d, actual value is %d", i, tb_rtl_task2.dut.s.altsyncram_component.m_default.altsyncram_inst.mem_data[i]);
                err = 1'b1;
            end
        end

        SW = 10'h033C;
        #10;
        // Case 7: Start ksa
        @(posedge CLOCK_50)
        ksa_validator(7, `READY, 1'b1, 8'b0, 8'b0, 1'b0);

        // Case 8: Start calculating value j and read s[i] from memory
        @(posedge CLOCK_50)
        ksa_validator(8, `READ_I, 1'b0, 8'b0, 8'b0, 1'b0);

        // Case 9: Read s[j] from memory
        @(posedge CLOCK_50)
        ksa_validator(9, `STALL_R, 1'b0, 8'b0, 8'bx, 1'b0);

        wait (tb_rtl_task2.dut.k.count_i == 256);
        #20;

        $readmemh("result.txt", mem);

        for (int i = 0; i < 256; i++) begin
            if (tb_rtl_task2.dut.s.altsyncram_component.m_default.altsyncram_inst.mem_data[i] !== mem[i]) begin 
                $display("MEM ERROR %d: Expected mem is %d, actual mem is %d", i[7:0], mem[i], tb_rtl_task2.dut.s.altsyncram_component.m_default.altsyncram_inst.mem_data[i]);
                err = 1'b1;
            end
        end

        if (~err)
            $display("SUCCESS: All tests passed.");
        $stop;
    end

endmodule: tb_rtl_task2
