`timescale 1ps / 1ps

module tb_rtl_arc4();

    logic clk, rst_n, en, rdy, pt_wren, err;
    logic [23:0] key;
    logic [7:0] ct_addr, ct_rddata, pt_addr, pt_rddata, pt_wrdata;

    // Internal wires
    logic [7:0] exp_ksa [255:0];
    logic [7:0] exp_pad [255:0];
    logic [7:0] exp_pt [255:0];
    logic [7:0] ciphertext [255:0];
    logic [7:0] pt [255:0];

    arc4 dut(.*);

    initial begin
        clk = 1;
        forever #5 clk = ~clk;
    end

    initial begin
        err = 1'b0;

        // Init memories array
        $readmemh("ksa_res.txt", exp_ksa);
        $readmemh("pad_res.txt", exp_pad);
        $readmemh("prga_res.txt", exp_pt);
        $readmemh("test1.memh", ciphertext);

        `define IDLE  2'b00
        `define START 2'b01

        // Case 1: Undefined inputs
        rst_n = 1'bx; en = 1'bx;
        #10;
        if (tb_rtl_arc4.dut.rdy !== 1'b0) begin
            $display("ERROR 1A: Expected rdy is %d, actual rdy is %d", 1'b0, tb_rtl_arc4.dut.rdy);
            err = 1'b1;
        end
        if (tb_rtl_arc4.dut.state !== `IDLE) begin
            $display("ERROR 1B: Expected state is %d, actual state is %d", `IDLE, tb_rtl_arc4.dut.state);
            err = 1'b1;
        end

        // Case 2: Assert reset
        rst_n = 1'b0; en = 1'b0; key = 24'h1E4600;
        @(negedge clk);
        if (tb_rtl_arc4.dut.rdy !== 1'b0) begin
            $display("ERROR 2A: Expected rdy is %d, actual rdy is %d", 1'b0, tb_rtl_arc4.dut.rdy);
            err = 1'b1;
        end
        if (tb_rtl_arc4.dut.state !== `IDLE) begin
            $display("ERROR 2B: Expected state is %d, actual state is %d", `IDLE, tb_rtl_arc4.dut.state);
            err = 1'b1;
        end

        // Case 3: Deassert reset
        rst_n = 1'b1;
        @(posedge clk);
        if (tb_rtl_arc4.dut.rdy !== 1'b0) begin
            $display("ERROR 3A: Expected rdy is %d, actual rdy is %d", 1'b0, tb_rtl_arc4.dut.rdy);
            err = 1'b1;
        end
        if (tb_rtl_arc4.dut.state !== `IDLE) begin
            $display("ERROR 3B: Expected state is %d, actual state is %d", `IDLE, tb_rtl_arc4.dut.state);
            err = 1'b1;
        end

        // Case 4: Assert en when rdy = 1
        en = 1'b1; ct_rddata = ciphertext[0];
        @(posedge clk);
        if (tb_rtl_arc4.dut.rdy !== 1'b1) begin
            $display("ERROR 4A: Expected rdy is %d, actual rdy is %d", 1'b1, tb_rtl_arc4.dut.rdy);
            err = 1'b1;
        end
        if (tb_rtl_arc4.dut.state !== `IDLE) begin
            $display("ERROR 4B: Expected state is %d, actual state is %d", `IDLE, tb_rtl_arc4.dut.state);
            err = 1'b1;
        end

        // Case 5: Start running init module
        en = 1'b0;
        @(posedge clk);
        if (tb_rtl_arc4.dut.rdy !== 1'b0) begin
            $display("ERROR 5A: Expected rdy is %d, actual rdy is %d", 1'b0, tb_rtl_arc4.dut.rdy);
            err = 1'b1;
        end
        if (tb_rtl_arc4.dut.state !== `START) begin
            $display("ERROR 5B: Expected state is %d, actual state is %d", `START, tb_rtl_arc4.dut.state);
            err = 1'b1;
        end

        // Case 6: Check memory result after done_init
        wait (tb_rtl_arc4.dut.done_init == 1'b1);
        for (int i = 0; i < 256; i++) begin
            if (tb_rtl_arc4.dut.s.altsyncram_component.m_default.altsyncram_inst.mem_data[i] !== i) begin
                $display("INIT MEM ERR: Expected value is %d, actual value is %d", i, tb_rtl_arc4.dut.s.altsyncram_component.m_default.altsyncram_inst.mem_data[i]);
                err = 1'b1;
            end
        end

        // Case 7: Check memory result after done_ksa
        wait (tb_rtl_arc4.dut.done_ksa == 1'b1);
        for (int i = 0; i < 256; i++) begin
            if (tb_rtl_arc4.dut.s.altsyncram_component.m_default.altsyncram_inst.mem_data[i] !== exp_ksa[i]) begin
                $display("KSA MEM ERR: Expected value is %d, actual value is %d", exp_ksa[i], tb_rtl_arc4.dut.s.altsyncram_component.m_default.altsyncram_inst.mem_data[i]);
                err = 1'b1;
            end
        end

        // Case 8: Start running prga module
        ct_rddata = ciphertext[0];
        @(posedge clk);

        for (int i = 0; i < 8'h49; i++) begin
            @(posedge clk);  // READ_I
            @(posedge clk);  // STALL_I
            ct_rddata = ciphertext[tb_rtl_arc4.dut.ct_addr];
            @(posedge clk);  // CALC_J
            @(posedge clk);  // STALL_J
            @(posedge clk);  // WRITE_I
            @(posedge clk);  // WRITE_J
            @(posedge clk);  // READ_P
            @(posedge clk);  // STALL_P
            @(posedge clk);  // WRITE_P
        end

        // Case 9: Check ct_mem result in prga module
        @(posedge clk);
        for (int i = 0; i <= 8'h49; i++) begin
            if (tb_rtl_arc4.dut.p.ct_mem[i] !== ciphertext[i]) begin 
                $display("CT[%d] ERROR: Expected ct is %h, actual ct is %h", i[7:0], ciphertext[i], tb_rtl_arc4.dut.p.ct_mem[i]);
                err = 1'b1;
            end
        end

        // Case 10: Check pad result against exp_pad
        for (int i = 0; i < 8'h49; i++) begin
            if (tb_rtl_arc4.dut.p.pad[i] !== exp_pad[i]) begin 
                $display("PAD[%d] ERROR: Expected pad is %h, actual pad is %h", i[7:0], exp_pad[i], tb_rtl_arc4.dut.p.pad[i]);
                err = 1'b1;
            end
        end

        // Start XOR operation
        pt[0] = tb_rtl_arc4.dut.p.message_length;
        for (int k = 0; k < 8'h49; k++) begin
            @(posedge clk);  // WRITE_PT
            pt[tb_rtl_arc4.dut.pt_addr] = tb_rtl_arc4.dut.p.pad[tb_rtl_arc4.dut.p.k] ^ ciphertext[tb_rtl_arc4.dut.p.k + 8'b1];
        end

        // Case 11: Check pt(plaintext) result against axp_pt
        for (int i = 0; i < 8'h49; i++) begin
           if (exp_pt[i] !== pt[i]) begin 
                $display("PT[%d] ERROR: Expected pt is %h, actual pt is %h", i[7:0], exp_pt[i], pt[i]);
                err = 1'b1;
            end
        end

        // Case 12: Make sure done_prga = 1
        #50;
        if (tb_rtl_arc4.dut.done_prga !== 1'b1) begin
            $display("ERROR 12A: Expected done_prga is %d, actual done_prga is %d", 1'b1, tb_rtl_arc4.dut.done_prga);
            err = 1'b1;
        end
        if (tb_rtl_arc4.dut.rdy !== 1'b1) begin
            $display("ERROR 12B: Expected rdy is %d, actual rdy is %d", 1'b1, tb_rtl_arc4.dut.rdy);
            err = 1'b1;
        end

        // ====================================================================================================================

        // Init memories array
        $readmemh("ksa_res2.txt", exp_ksa);
        $readmemh("pad_res2.txt", exp_pad);
        $readmemh("prga_res2.txt", exp_pt);
        $readmemh("test2.memh", ciphertext);

        // Case 13: 
        #10;
        if (tb_rtl_arc4.dut.rdy !== 1'b1) begin
            $display("ERROR 13A: Expected rdy is %d, actual rdy is %d", 1'b1, tb_rtl_arc4.dut.rdy);
            err = 1'b1;
        end
        if (tb_rtl_arc4.dut.state !== `IDLE) begin
            $display("ERROR 13B: Expected state is %d, actual state is %d", `IDLE, tb_rtl_arc4.dut.state);
            err = 1'b1;
        end

        // Case 14: Assert reset
        rst_n = 1'b0; en = 1'b0; key = 24'h000018;
        @(negedge clk);
        if (tb_rtl_arc4.dut.rdy !== 1'b0) begin
            $display("ERROR 14A: Expected rdy is %d, actual rdy is %d", 1'b0, tb_rtl_arc4.dut.rdy);
            err = 1'b1;
        end
        if (tb_rtl_arc4.dut.state !== `IDLE) begin
            $display("ERROR 14B: Expected state is %d, actual state is %d", `IDLE, tb_rtl_arc4.dut.state);
            err = 1'b1;
        end

        // Case 15: Deassert reset
        rst_n = 1'b1;
        @(posedge clk);
        if (tb_rtl_arc4.dut.rdy !== 1'b0) begin
            $display("ERROR 15A: Expected rdy is %d, actual rdy is %d", 1'b0, tb_rtl_arc4.dut.rdy);
            err = 1'b1;
        end
        if (tb_rtl_arc4.dut.state !== `IDLE) begin
            $display("ERROR 15B: Expected state is %d, actual state is %d", `IDLE, tb_rtl_arc4.dut.state);
            err = 1'b1;
        end

        // Case 16: Assert en when rdy = 1
        en = 1'b1; ct_rddata = ciphertext[0];
        @(posedge clk);
        if (tb_rtl_arc4.dut.rdy !== 1'b1) begin
            $display("ERROR 16A: Expected rdy is %d, actual rdy is %d", 1'b1, tb_rtl_arc4.dut.rdy);
            err = 1'b1;
        end
        if (tb_rtl_arc4.dut.state !== `IDLE) begin
            $display("ERROR 16B: Expected state is %d, actual state is %d", `IDLE, tb_rtl_arc4.dut.state);
            err = 1'b1;
        end

        // Case 17: Start running init module
        en = 1'b0;
        @(posedge clk);
        if (tb_rtl_arc4.dut.rdy !== 1'b0) begin
            $display("ERROR 17A: Expected rdy is %d, actual rdy is %d", 1'b0, tb_rtl_arc4.dut.rdy);
            err = 1'b1;
        end
        if (tb_rtl_arc4.dut.state !== `START) begin
            $display("ERROR 17B: Expected state is %d, actual state is %d", `START, tb_rtl_arc4.dut.state);
            err = 1'b1;
        end

        // Case 18: Check memory result after done_init
        wait (tb_rtl_arc4.dut.done_init == 1'b1);
        for (int i = 0; i < 256; i++) begin
            if (tb_rtl_arc4.dut.s.altsyncram_component.m_default.altsyncram_inst.mem_data[i] !== i) begin
                $display("INIT 2 MEM ERR: Expected value is %d, actual value is %d", i, tb_rtl_arc4.dut.s.altsyncram_component.m_default.altsyncram_inst.mem_data[i]);
                err = 1'b1;
            end
        end

        // Case 19: Check memory result after done_ksa
        wait (tb_rtl_arc4.dut.done_ksa == 1'b1);
        for (int i = 0; i < 256; i++) begin
            if (tb_rtl_arc4.dut.s.altsyncram_component.m_default.altsyncram_inst.mem_data[i] !== exp_ksa[i]) begin
                $display("KSA 2 MEM ERR: Expected value is %d, actual value is %d", exp_ksa[i], tb_rtl_arc4.dut.s.altsyncram_component.m_default.altsyncram_inst.mem_data[i]);
                err = 1'b1;
            end
        end

        // Case 20: Start running prga module
        ct_rddata = ciphertext[0];
        @(posedge clk);

        for (int i = 0; i < 8'd53; i++) begin
            @(posedge clk);  // READ_I
            @(posedge clk);  // STALL_I
            ct_rddata = ciphertext[tb_rtl_arc4.dut.ct_addr];
            @(posedge clk);  // CALC_J
            @(posedge clk);  // STALL_J
            @(posedge clk);  // WRITE_I
            @(posedge clk);  // WRITE_J
            @(posedge clk);  // READ_P
            @(posedge clk);  // STALL_P
            @(posedge clk);  // WRITE_P
        end

        // Case 21: Check ct_mem result in prga module
        @(posedge clk);
        for (int i = 0; i <= 8'd53; i++) begin
            if (tb_rtl_arc4.dut.p.ct_mem[i] !== ciphertext[i]) begin 
                $display("CT 2[%d] ERROR: Expected ct is %h, actual ct is %h", i[7:0], ciphertext[i], tb_rtl_arc4.dut.p.ct_mem[i]);
                err = 1'b1;
            end
        end

        // Case 22: Check pad result against exp_pad
        for (int i = 0; i < 8'd53; i++) begin
            if (tb_rtl_arc4.dut.p.pad[i] !== exp_pad[i]) begin 
                $display("PAD 2[%d] ERROR: Expected pad is %h, actual pad is %h", i[7:0], exp_pad[i], tb_rtl_arc4.dut.p.pad[i]);
                err = 1'b1;
            end
        end

        // Start XOR operation
        pt[0] = tb_rtl_arc4.dut.p.message_length;
        for (int k = 0; k < 8'd53; k++) begin
            @(posedge clk);  // WRITE_PT
            pt[tb_rtl_arc4.dut.pt_addr] = tb_rtl_arc4.dut.p.pad[tb_rtl_arc4.dut.p.k] ^ ciphertext[tb_rtl_arc4.dut.p.k + 8'b1];
        end

        // Case 23: Check pt(plaintext) result against axp_pt
        for (int i = 0; i < 8'd53; i++) begin
           if (exp_pt[i] !== pt[i]) begin 
                $display("PT 2[%d] ERROR: Expected pt is %h, actual pt is %h", i[7:0], exp_pt[i], pt[i]);
                err = 1'b1;
            end
        end

        // Case 24: Make sure done_prga = 1
        #50;
        if (tb_rtl_arc4.dut.done_prga !== 1'b1) begin
            $display("ERROR 24A: Expected done_prga is %d, actual done_prga is %d", 1'b1, tb_rtl_arc4.dut.done_prga);
            err = 1'b1;
        end
        if (tb_rtl_arc4.dut.rdy !== 1'b1) begin
            $display("ERROR 24B: Expected rdy is %d, actual rdy is %d", 1'b1, tb_rtl_arc4.dut.rdy);
            err = 1'b1;
        end

        if (~err)
            $display("SUCCESS: All tests passed.");
        $stop;
    end

endmodule: tb_rtl_arc4
