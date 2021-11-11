`timescale 1ps / 1ps

module tb_syn_init();

    logic clk, rst_n, en, rdy, wren, err;
    logic [7:0] addr, wrdata;
    integer i;

    init dut(.*);

    initial begin
        clk = 1;
        forever #5 clk = ~clk;
    end

    task validator;
        input [31:0] index;
        input exp_rdy;
        input [7:0] exp_addr, exp_wrdata;
        input exp_wren;
        begin
            $display("CASE %d", index);
            if (tb_syn_init.dut.rdy !== exp_rdy) begin
                $display("ERROR B: Expected rdy is %d, actual rdy is %d", exp_rdy, tb_syn_init.dut.rdy);
                err = 1'b1;
            end
            if (tb_syn_init.dut.addr !== exp_addr) begin
                $display("ERROR C: Expected addr is %d, actual addr is %d", exp_addr, tb_syn_init.dut.addr);
                err = 1'b1;
            end
            if (tb_syn_init.dut.wrdata !== exp_wrdata) begin
                $display("ERROR D: Expected wrdata is %d, actual wrdata is %d", exp_wrdata, tb_syn_init.dut.wrdata);
                err = 1'b1;
            end
            if (tb_syn_init.dut.wren !== exp_wren) begin
                $display("ERROR E: Expected wren is %d, actual wren is %d", exp_wren, tb_syn_init.dut.wren);
                err = 1'b1;
            end
        end
    endtask

    initial begin
        err = 1'b0;

        // Case 1: Assert reset
        rst_n = 1'b0; en = 1'b0;
        @(negedge clk)
        validator(1, 1'b0, 8'b0, 8'b0, 1'b0);
        
        // Case 2: Deassert reset, and rdy is high
        rst_n = 1'b1;
        @(posedge clk)
        validator(2, 1'b0, 8'b0, 8'b0, 1'b0);

        // Case 3: Assert en signal
        en = 1'b1;
        @(posedge clk)
        validator(3, 1'b1, 8'b0, 8'b0, 1'b0);

        // Case 4: Start writing to memory
        en = 1'b0;
        for (int i = 0; i < 256; i++) begin
            @(posedge clk)
            validator(i, 1'b0, i, i, 1'b1);
        end

        // Case 5: Stay at IDLE state after done writing all 0...256 to memory
        @(posedge clk)
        @(posedge clk)
        @(posedge clk)
        validator(5, 1'b1, 8'b0, 8'b0, 1'b0);

        // Case 6: Undefined inputs
        rst_n = 1'bx; en = 1'bx;
        @(posedge clk)
        validator(6, 1'b1, 8'b0, 8'b0, 1'b0);

        if (~err) begin
            $display("SUCCESS: All tests passed.");
        end
        $stop;
    end

endmodule: tb_syn_init
