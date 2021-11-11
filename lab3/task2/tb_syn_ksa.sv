`timescale 1ps / 1ps

module tb_syn_ksa();

    logic clk, rst_n, en, rdy, wren, err;
    logic [23:0] key;
    logic [7:0] addr, rddata, wrdata, I;
    integer j;
    logic [7:0] key_arr[0:2];
    logic [7:0] mem[255:0];
    logic [7:0] res[255:0];

    ksa dut(.*);

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
            if (tb_syn_ksa.dut.rdy !== exp_rdy) begin
                $display("ERROR B: Expected rdy is %d, actual rdy is %d", exp_rdy, tb_syn_ksa.dut.rdy);
                err = 1'b1;
            end
            if (tb_syn_ksa.dut.addr !== exp_addr) begin
                $display("ERROR C: Expected addr is %d, actual addr is %d", exp_addr, tb_syn_ksa.dut.addr);
                err = 1'b1;
            end
            if (tb_syn_ksa.dut.wrdata !== exp_wrdata) begin
                $display("ERROR D: Expected wrdata is %d, actual wrdata is %d", exp_wrdata, tb_syn_ksa.dut.wrdata);
                err = 1'b1;
            end
            if (tb_syn_ksa.dut.wren !== exp_wren) begin
                $display("ERROR E: Expected wren is %d, actual wren is %d", exp_wren, tb_syn_ksa.dut.wren);
                err = 1'b1;
            end
        end
    endtask

    initial begin
        err = 1'b0;
        $readmemh("init_mem.txt", mem);

        // Case 1: Undefined inputs
        rst_n = 1'bx; en = 1'bx;
        #10;
        validator(1, 1'b0, 8'b0, 8'b0, 1'b0);

        // Case 2: Assert reset, and initialize key value
        key = 24'h00033C;
        $readmemh("key.txt", key_arr);
        rst_n = 1'b0; en = 1'b0;
        #10;
        validator(2, 1'b0, 8'b0, 8'b0, 1'b0);
        
        // Case 3: Deassert reset
        rst_n = 1'b1;
        #10;
        validator(3, 1'bx, 8'b0, 8'b0, 1'b0);

        // Case 4: Assert en when rdy = 1
        en = 1'b1;
        #10;
        validator(4, 1'b1, 8'b0, 8'b0, 1'b0);

        en = 1'b0; rddata = 8'b0; j = 0;

        for (int i = 0; i < 256; i++) begin
            @(posedge clk); // READY state
            @(posedge clk); // READ_I state
            rddata = mem[tb_syn_ksa.dut.addr];
            I = rddata;
            @(posedge clk); // STALL_R state
            @(posedge clk); // CALC_J state
            @(posedge clk); // READ_J state
            rddata = mem[tb_syn_ksa.dut.addr];
            j = tb_syn_ksa.dut.addr;
            @(posedge clk); // STALL_W state
            
            @(posedge clk && tb_syn_ksa.dut.wren == 1'b1);
            mem[tb_syn_ksa.dut.addr] = rddata;

            @(posedge clk && tb_syn_ksa.dut.wren == 1'b1);
            mem[j[7:0]] = I;
        end

        $readmemh("result.txt", res);

        for (int i = 0; i < 256; i++) begin
            if (res[i] !== mem[i]) begin 
                $display("MEM ERROR %d: Expected mem is %d, actual mem is %d", i[7:0], res[i], mem[i]);
                err = 1'b1;
            end
        end

        if (~err)
            $display("SUCCESS: All tests passed.");
        $stop;
    end

endmodule: tb_syn_ksa
