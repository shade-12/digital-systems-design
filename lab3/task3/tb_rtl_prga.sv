module tb_rtl_prga();

    logic clk, rst_n, en, rdy, s_wren, pt_wren, err;
    logic [23:0] key;
    logic [7:0] s_addr, s_rddata, s_wrdata, ct_addr, ct_rddata, pt_addr, pt_rddata, pt_wrdata;

    // Internal wires
    logic [7:0] s [255:0];
    logic [7:0] ct [255:0];
    logic [7:0] exp_pt [255:0];
    logic [7:0] pt [255:0];
    logic [7:0] exp_pad [255:0];

    prga dut(.*);

    initial begin
        clk = 1;
        forever #5 clk = ~clk;
    end

    task validator;
        input [31:0] index;
        input [3:0] exp_state;
        input exp_rdy;
        input [7:0] exp_s_addr, exp_s_wrdata;
        input exp_s_wren;
        input [7:0] exp_ct_addr, exp_pt_addr, exp_pt_wrdata;
        input exp_pt_wren;
        begin
            $display("CASE %d", index);
            if (tb_rtl_prga.dut.state !== exp_state) begin
                $display("ERROR A: Expected state is %d, actual state is %d", exp_state, tb_rtl_prga.dut.state);
                err = 1'b1;
            end
            if (tb_rtl_prga.dut.rdy !== exp_rdy) begin
                $display("ERROR B: Expected rdy is %d, actual rdy is %d", exp_rdy, tb_rtl_prga.dut.rdy);
                err = 1'b1;
            end
            if (tb_rtl_prga.dut.s_addr !== exp_s_addr) begin
                $display("ERROR C: Expected s_addr is %d, actual s_addr is %d", exp_s_addr, tb_rtl_prga.dut.s_addr);
                err = 1'b1;
            end
            if (tb_rtl_prga.dut.s_wrdata !== exp_s_wrdata) begin
                $display("ERROR D: Expected s_wrdata is %d, actual s_wrdata is %d", exp_s_wrdata, tb_rtl_prga.dut.s_wrdata);
                err = 1'b1;
            end
            if (tb_rtl_prga.dut.s_wren !== exp_s_wren) begin
                $display("ERROR E: Expected s_wren is %d, actual s_wren is %d", exp_s_wren, tb_rtl_prga.dut.s_wren);
                err = 1'b1;
            end
            if (tb_rtl_prga.dut.ct_addr !== exp_ct_addr) begin
                $display("ERROR F: Expected ct_addr is %d, actual ct_addr is %d", exp_ct_addr, tb_rtl_prga.dut.ct_addr);
                err = 1'b1;
            end
            if (tb_rtl_prga.dut.pt_addr !== exp_pt_addr) begin
                $display("ERROR G: Expected pt_addr is %d, actual pt_addr is %d", exp_pt_addr, tb_rtl_prga.dut.pt_addr);
                err = 1'b1;
            end
            if (tb_rtl_prga.dut.pt_wrdata !== exp_pt_wrdata) begin
                $display("ERROR H: Expected pt_wrdata is %d, actual pt_wrdata is %d", exp_pt_wrdata, tb_rtl_prga.dut.pt_wrdata);
                err = 1'b1;
            end
            if (tb_rtl_prga.dut.pt_wren !== exp_pt_wren) begin
                $display("ERROR I: Expected pt_wren is %d, actual pt_wren is %d", exp_pt_wren, tb_rtl_prga.dut.pt_wren);
                err = 1'b1;
            end
        end
    endtask

    `define IDLE      4'b0000
    `define READ_I    4'b0001 
    `define STALL_I   4'b0010 
    `define CALC_J    4'b0011 
    `define STALL_J   4'b0100 
    `define WRITE_I   4'b0101 
    `define WRITE_J   4'b0110 
    `define READ_P    4'b0111 
    `define STALL_P   4'b1000 
    `define WRITE_P   4'b1001
    `define WRITE_PT  4'b1010

    initial begin
        err = 0;

        // DECRYPTED STRING FOR T1:
        // It was a bright cold day in April, and the clocks were striking thirteen.
        // DECRYPTED STRING FOR T2:
        // Mrs. Dalloway said she would buy the flowers herself.

        // Init memories array
        $readmemh("ksa_res.txt", s);
        $readmemh("test1.memh", ct);
        $readmemh("pad_res.txt", exp_pad);
        $readmemh("prga_res.txt", exp_pt);

        // Case 1: Undefined inputs
        rst_n = 1'bx; en = 1'bx;
        #10;
        validator(1, `IDLE, 1'bx, 8'b0, 8'b0, 1'b0, 8'b0, 8'b0, 8'b0, 1'b0);

        // Case 2: Assert reset
        rst_n = 1'b0; en = 1'b0; key = 24'h1E4600;
        @(negedge clk);
        validator(2, `IDLE, 1'b0, 8'b0, 8'b0, 1'b0, 8'b0, 8'b0, 8'b0, 1'b0);

        // Case 3: Deassert reset
        rst_n = 1'b1;
        @(posedge clk);
        validator(3, `IDLE, 1'b0, 8'b0, 8'b0, 1'b0, 8'b0, 8'b0, 8'b0, 1'b0);

        // Case 4: Assert en when rdy = 1
        en = 1'b1; ct_rddata = ct[0];
        @(posedge clk);
        validator(4, `IDLE, 1'b1, 8'b0, 8'b0, 1'b0, 8'b0, 8'b0, 8'b0, 1'b0);

        // Case 5: Start prga
        en = 1'b0; s_rddata = 8'b0; ct_rddata = 8'b0; pt_rddata = 8'b0;

        for (int i = 0; i < 8'h49; i++) begin
            @(posedge clk);  // READ_I
            @(posedge clk);  // STALL_I
            ct_rddata = ct[tb_rtl_prga.dut.k + 1];
            s_rddata = s[tb_rtl_prga.dut.i];
            @(posedge clk);  // CALC_J
            s_rddata = s[tb_rtl_prga.dut.j + s_rddata];
            @(posedge clk);  // STALL_J
            @(posedge clk);  // WRITE_I
            s[tb_rtl_prga.dut.i] = s_rddata;
            @(posedge clk);  // WRITE_J
            s[tb_rtl_prga.dut.j] = tb_rtl_prga.dut.I;
            @(posedge clk);  // READ_P
            s_rddata = s[tb_rtl_prga.dut.pad_i];
            @(posedge clk);  // STALL_P
            @(posedge clk);  // WRITE_P
        end

        // Case 6: ct should be the same as ct_mem
        @(posedge clk);
        @(posedge clk);
        validator(6, `WRITE_PT, 1'b0, 8'b0, 8'b0, 1'b0, 8'b0, 8'b0, 8'h49, 1'b1);
        for (int i = 0; i <= 8'h49; i++) begin
            if (tb_rtl_prga.dut.ct_mem[i] !== ct[i]) begin 
                $display("CT MEM[%d] ERROR: Expected ct is %h, actual ct is %h", i[7:0], ct[i], tb_rtl_prga.dut.ct_mem[i]);
                err = 1'b1;
            end
        end
        
        // Check pad result
        for (int i = 0; i < 8'h49; i++) begin
            if (exp_pad[i] !== tb_rtl_prga.dut.pad[i]) begin 
                $display("PAD MEM[%d] ERROR: Expected pad is %h, actual pad is %h", i[7:0], exp_pad[i], tb_rtl_prga.dut.pad[i]);
                err = 1'b1;
            end
        end

        // Start XOR operation
        pt[0] = tb_rtl_prga.dut.message_length;
        for (int k = 0; k < 8'h49; k++) begin
            @(posedge clk);  // WRITE_PT
            pt[tb_rtl_prga.dut.pt_addr] = tb_rtl_prga.dut.pt_wrdata;
        end

        // Case 7: pt should be the same as exp_pt
        for (int i = 0; i < 8'h49; i++) begin
           if (exp_pt[i] !== pt[i + 1]) begin 
                $display("PT MEM[%d] ERROR: Expected pt is %h, actual pt is %h", i[7:0], exp_pt[i], pt[i + 1]);
                err = 1'b1;
            end
        end

        // Case 8: Check if rdy signal rises after done
        #20;
        if (tb_rtl_prga.dut.rdy !== 1'b1) begin
            $display("ERROR 8: Expected rdy is %d, actual rdy is %d", 1'b1, tb_rtl_prga.dut.rdy);
            err = 1'b1;
        end

        // =====================================================================================================================

        // Init memories array
        $readmemh("ksa_res2.txt", s);
        $readmemh("test2.memh", ct);
        $readmemh("pad_res2.txt", exp_pad);
        $readmemh("prga_res2.txt", exp_pt);

        // Case 9: Assert en when rdy = 1
        en = 1'b1; ct_rddata = ct[0]; key = 24'h000018;
        @(posedge clk);
        validator(9, `IDLE, 1'b1, 8'b0, 8'b0, 1'b0, 8'b0, 8'b0, 8'b0, 1'b0);

        // Case 10: Start prga
        en = 1'b0; s_rddata = 8'b0; ct_rddata = 8'b0; pt_rddata = 8'b0;

        for (int i = 0; i < 8'd53; i++) begin
            @(posedge clk);  // READ_I
            @(posedge clk);  // STALL_I
            ct_rddata = ct[tb_rtl_prga.dut.k + 1];
            s_rddata = s[tb_rtl_prga.dut.i];
            @(posedge clk);  // CALC_J
            s_rddata = s[tb_rtl_prga.dut.j + s_rddata];
            @(posedge clk);  // STALL_J
            @(posedge clk);  // WRITE_I
            s[tb_rtl_prga.dut.i] = s_rddata;
            @(posedge clk);  // WRITE_J
            s[tb_rtl_prga.dut.j] = tb_rtl_prga.dut.I;
            @(posedge clk);  // READ_P
            s_rddata = s[tb_rtl_prga.dut.pad_i];
            @(posedge clk);  // STALL_P
            @(posedge clk);  // WRITE_P
        end

        // Case 11: ct should be the same as ct_mem
        @(posedge clk);
        @(posedge clk);
        validator(11, `WRITE_PT, 1'b0, 8'b0, 8'b0, 1'b0, 8'b0, 8'b0, 8'd53, 1'b1);
        for (int i = 0; i <= 8'd53; i++) begin
            if (tb_rtl_prga.dut.ct_mem[i] !== ct[i]) begin 
                $display("CT MEM 2[%d] ERROR: Expected ct is %h, actual ct is %h", i[7:0], ct[i], tb_rtl_prga.dut.ct_mem[i]);
                err = 1'b1;
            end
        end
        
        // Check pad result
        for (int i = 0; i < 8'd53; i++) begin
            if (exp_pad[i] !== tb_rtl_prga.dut.pad[i]) begin 
                $display("PAD MEM 2[%d] ERROR: Expected pad is %h, actual pad is %h", i[7:0], exp_pad[i], tb_rtl_prga.dut.pad[i]);
                err = 1'b1;
            end
        end

        // Start XOR operation
        pt[0] = tb_rtl_prga.dut.message_length;
        for (int k = 0; k < 8'd53; k++) begin
            @(posedge clk);  // WRITE_PT
            pt[tb_rtl_prga.dut.pt_addr] = tb_rtl_prga.dut.pt_wrdata;
        end

        // Case 12: pt should be the same as exp_pt
        for (int i = 0; i < 8'd53; i++) begin
           if (exp_pt[i] !== pt[i + 1]) begin 
                $display("PT MEM 2[%d] ERROR: Expected pt is %h, actual pt is %h", i[7:0], exp_pt[i], pt[i + 1]);
                err = 1'b1;
            end
        end

        // Case 13: Check if rdy signal rises after done
        #20;
        if (tb_rtl_prga.dut.rdy !== 1'b1) begin
            $display("ERROR 13: Expected rdy is %d, actual rdy is %d", 1'b1, tb_rtl_prga.dut.rdy);
            err = 1'b1;
        end

        if (~err)
            $display("SUCCESS: All tests passed.");
        $stop;
    end

endmodule: tb_rtl_prga
