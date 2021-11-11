`timescale 1ps / 1ps

module tb_rtl_task3();

    logic CLOCK_50, err;
    logic [3:0] KEY;
    logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    logic [9:0] SW, LEDR;

    // Internal wires
    logic [7:0] exp_ksa [255:0];
    logic [7:0] exp_pad [255:0];
    logic [7:0] exp_pt [255:0];

    task3 dut(.*);

    initial begin
        CLOCK_50 = 1;
        forever #5 CLOCK_50 = ~CLOCK_50;
    end

    initial begin
        err = 1'b0;

        // Init memories array
        $readmemh("ksa_res2.txt", exp_ksa);
        $readmemh("pad_res2.txt", exp_pad);
        $readmemh("prga_res2.txt", exp_pt);
        $readmemh("test2.memh", tb_rtl_task3.dut.ct.altsyncram_component.m_default.altsyncram_inst.mem_data);

        // Case 1: Undefined inputs
        KEY[3] = 1'bx;
        #10;
        if (tb_rtl_task3.dut.rdy !== 1'b0) begin
            $display("ERROR 1: Expected rdy is %d, actual rdy is %d", 1'b0, tb_rtl_task3.dut.rdy);
            err = 1'b1;
        end

        // Case 2: Assert reset
        KEY[3] = 1'b0; SW = 10'h18;
        @(negedge CLOCK_50);
        if (tb_rtl_task3.dut.rdy !== 1'b0) begin
            $display("ERROR 2: Expected rdy is %d, actual rdy is %d", 1'b0, tb_rtl_task3.dut.rdy);
            err = 1'b1;
        end

        // Case 3: Deassert reset
        KEY[3] = 1'b1;
        @(posedge CLOCK_50);
        if (tb_rtl_task3.dut.rdy !== 1'b0) begin
            $display("ERROR 3: Expected rdy is %d, actual rdy is %d", 1'b0, tb_rtl_task3.dut.rdy);
            err = 1'b1;
        end

        // Case 4: Assert en when rdy = 1
        @(posedge CLOCK_50);
        if (tb_rtl_task3.dut.rdy !== 1'b1) begin
            $display("ERROR 4: Expected rdy is %d, actual rdy is %d", 1'b1, tb_rtl_task3.dut.rdy);
            err = 1'b1;
        end

        // Case 5: Start running init module
        @(posedge CLOCK_50);
        if (tb_rtl_task3.dut.rdy !== 1'b0) begin
            $display("ERROR 5: Expected rdy is %d, actual rdy is %d", 1'b0, tb_rtl_task3.dut.rdy);
            err = 1'b1;
        end

        // Case 6: Check memory result after a4.done_init
        wait (tb_rtl_task3.dut.a4.done_init == 1'b1);
        for (int i = 0; i < 256; i++) begin
            if (tb_rtl_task3.dut.a4.s.altsyncram_component.m_default.altsyncram_inst.mem_data[i] !== i) begin
                $display("INIT MEM ERR: Expected value is %d, actual value is %d", i, tb_rtl_task3.dut.a4.s.altsyncram_component.m_default.altsyncram_inst.mem_data[i]);
                err = 1'b1;
            end
        end

        // Case 7: Check memory result after done_ksa
        wait (tb_rtl_task3.dut.a4.done_ksa == 1'b1);
        for (int i = 0; i < 256; i++) begin
            if (tb_rtl_task3.dut.a4.s.altsyncram_component.m_default.altsyncram_inst.mem_data[i] !== exp_ksa[i]) begin
                $display("KSA MEM ERR: Expected value is %d, actual value is %d", exp_ksa[i], tb_rtl_task3.dut.a4.s.altsyncram_component.m_default.altsyncram_inst.mem_data[i]);
                err = 1'b1;
            end
        end

        // Case 8: Start running prga module
        @(posedge CLOCK_50);

        for (int i = 0; i < 8'd53; i++) begin
            @(posedge CLOCK_50);  // READ_I
            @(posedge CLOCK_50);  // STALL_I
            @(posedge CLOCK_50);  // CALC_J
            @(posedge CLOCK_50);  // STALL_J
            @(posedge CLOCK_50);  // WRITE_I
            @(posedge CLOCK_50);  // WRITE_J
            @(posedge CLOCK_50);  // READ_P
            @(posedge CLOCK_50);  // STALL_P
            @(posedge CLOCK_50);  // WRITE_P
        end

        // Case 9: Check ct_mem result in prga module
        @(posedge CLOCK_50);
        for (int i = 0; i <= 8'd53; i++) begin
            if (tb_rtl_task3.dut.a4.p.ct_mem[i] !== tb_rtl_task3.dut.ct.altsyncram_component.m_default.altsyncram_inst.mem_data[i]) begin 
                $display("CT[%d] ERROR: Expected ct is %h, actual ct is %h", i[7:0], tb_rtl_task3.dut.ct.altsyncram_component.m_default.altsyncram_inst.mem_data[i], tb_rtl_task3.dut.a4.p.ct_mem[i]);
                err = 1'b1;
            end
        end

        // Case 10: Check pad result against exp_pad
        for (int i = 0; i < 8'd53; i++) begin
            if (tb_rtl_task3.dut.a4.p.pad[i] !== exp_pad[i]) begin 
                $display("PAD[%d] ERROR: Expected pad is %h, actual pad is %h", i[7:0], exp_pad[i], tb_rtl_task3.dut.a4.p.pad[i]);
                err = 1'b1;
            end
        end

        @(posedge CLOCK_50);  
        @(posedge CLOCK_50);  

        // Start XOR operation
        for (int k = 0; k < 8'd53; k++) begin
            @(posedge CLOCK_50);  // WRITE_PT
        end

        // Case 11: Check pt(plaintext) result against axp_pt
        if (tb_rtl_task3.dut.pt.altsyncram_component.m_default.altsyncram_inst.mem_data[0] !== 8'd53) begin 
            $display("PT LENGTH MISMATCH: Expected pt length is %h, actual pt length is %h", 8'd53, tb_rtl_task3.dut.pt.altsyncram_component.m_default.altsyncram_inst.mem_data[0]);
            err = 1'b1;
        end
        for (int i = 0; i < 8'd53; i++) begin
           if (exp_pt[i] !== tb_rtl_task3.dut.pt.altsyncram_component.m_default.altsyncram_inst.mem_data[i + 1]) begin 
                $display("PT[%d] ERROR: Expected pt is %h, actual pt is %h", i[7:0], exp_pt[i], tb_rtl_task3.dut.pt.altsyncram_component.m_default.altsyncram_inst.mem_data[i + 1]);
                err = 1'b1;
            end
        end

        // Case 12: Make sure done_prga = 1
        #50;
        if (tb_rtl_task3.dut.a4.done_prga !== 1'b1) begin
            $display("ERROR 12A: Expected done_prga is %d, actual done_prga is %d", 1'b1, tb_rtl_task3.dut.a4.done_prga);
            err = 1'b1;
        end
        if (tb_rtl_task3.dut.rdy !== 1'b1) begin
            $display("ERROR 12B: Expected rdy is %d, actual rdy is %d", 1'b1, tb_rtl_task3.dut.rdy);
            err = 1'b1;
        end

        if (~err)
            $display("SUCCESS: All tests passed.");
        $stop;
    end

endmodule: tb_rtl_task3
