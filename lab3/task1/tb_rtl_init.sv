module tb_rtl_init();

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
        input [1:0] exp_state;
        input exp_rdy;
        input [7:0] exp_addr, exp_wrdata;
        input exp_wren;
        begin
            $display("CASE %d", index);
            if (tb_rtl_init.dut.state !== exp_state) begin
                $display("ERROR A: Expected state is %d, actual state is %d", exp_state, tb_rtl_init.dut.state);
                err = 1'b1;
            end
            if (tb_rtl_init.dut.rdy !== exp_rdy) begin
                $display("ERROR B: Expected rdy is %d, actual rdy is %d", exp_rdy, tb_rtl_init.dut.rdy);
                err = 1'b1;
            end
            if (tb_rtl_init.dut.addr !== exp_addr) begin
                $display("ERROR C: Expected addr is %d, actual addr is %d", exp_addr, tb_rtl_init.dut.addr);
                err = 1'b1;
            end
            if (tb_rtl_init.dut.wrdata !== exp_wrdata) begin
                $display("ERROR D: Expected wrdata is %d, actual wrdata is %d", exp_wrdata, tb_rtl_init.dut.wrdata);
                err = 1'b1;
            end
            if (tb_rtl_init.dut.wren !== exp_wren) begin
                $display("ERROR E: Expected wren is %d, actual wren is %d", exp_wren, tb_rtl_init.dut.wren);
                err = 1'b1;
            end
        end
    endtask

    // States
    `define IDLE 1'b0
    `define WRITE 1'b1

    initial begin
        err = 1'b0;

        // Case 1: Undefined inputs
        rst_n = 1'bx; en = 1'bx;
        #10;
        validator(1, `IDLE, 1'b0, 8'b0, 8'b0, 1'b0);

        // Case 2: Assert reset
        rst_n = 1'b0;
        #10;
        validator(2, `IDLE, 1'b0, 8'b0, 8'b0, 1'b0);
        
        // Case 3: Deassert reset, state should be IDLE and rdy is high
        rst_n = 1'b1; #1; en = 1'b1;
        #10;
        validator(3, `WRITE, 1'b0, 8'b0, 8'b0, 1'b1);

        // Case 4: Start writing to memory
        en = 1'b0;
        for (int i = 1; i < 256; i++) begin
            #10;
            validator(i, `WRITE, 1'b0, i, i, 1'b1);
        end

        // Case 5: Stay at IDLE state after done writing all 0...256 to memory
        #20;
        validator(5, `IDLE, 1'b1, 8'b0, 8'b0, 1'b0);

        if (~err) begin
            $display("SUCCESS: All tests passed.");
        end
        $stop;
    end

endmodule: tb_rtl_init
