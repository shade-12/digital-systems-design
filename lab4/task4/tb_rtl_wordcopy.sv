module tb_rtl_wordcopy();
    logic clk, rst_n, slave_waitrequest, slave_read, slave_write, err;
    logic [3:0] slave_address;
    logic [31:0] slave_readdata, slave_writedata;
    logic master_waitrequest, master_read, master_readdatavalid, master_write;
    logic [31:0] master_address, master_readdata, master_writedata;

    wordcopy dut(.*);

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    `define IDLE       3'b000
    `define START_READ 3'b001
    `define WAIT_R_SIG 3'b010
    `define START_COPY 3'b011
    `define WAIT_W_SIG 3'b100
    `define DONE       3'b101

    initial begin
        err = 1'b0;

        #2 rst_n = 0;
        @(posedge clk); // do sync reset
        @(negedge clk);
        if (tb_rtl_wordcopy.dut.slave_waitrequest !== 1'b1) begin
            $display("ERROR 1: Expected slave_waitrequest is %d, actual slave_waitrequest is %d", 1'b1, tb_rtl_wordcopy.dut.slave_waitrequest);
            err = 1'b1;
        end
        if (tb_rtl_wordcopy.dut.slave_readdata !== 32'b0) begin
            $display("ERROR 2: Expected slave_readdata is %d, actual slave_readdata is %d", 32'b0, tb_rtl_wordcopy.dut.slave_readdata);
            err = 1'b1;
        end
        if (tb_rtl_wordcopy.dut.state !== `IDLE) begin
            $display("ERROR 3: Expected state is %d, actual state is %d", `IDLE, tb_rtl_wordcopy.dut.state);
            err = 1'b1;
        end

        #2 rst_n = 1;
        master_waitrequest = 1'bx;

        // wait a bit
        @(negedge clk);
        @(negedge clk);

        slave_write = 1;

        // Write no of words to accelerator's address
        slave_address = 4'd3;
        slave_writedata = 32'h03;
        @(negedge clk);
        if (tb_rtl_wordcopy.dut.no_of_words !== 32'h03) begin
            $display("ERROR 4: Expected no_of_words is %d, actual no_of_words is %d", 32'h03, tb_rtl_wordcopy.dut.no_of_words);
            err = 1'b1;
        end

        slave_write = 0;
        slave_writedata = 32'bx;
        @(negedge clk);
        @(negedge clk);

        slave_write = 1;

        // Write destination address
        slave_address = 4'd1;
        slave_writedata = 32'h12;
        @(negedge clk);
        if (tb_rtl_wordcopy.dut.dest !== 32'h12) begin
            $display("ERROR 5: Expected dest is %d, actual dest is %d", 32'h12, tb_rtl_wordcopy.dut.dest);
            err = 1'b1;
        end

        // Write source address
        slave_address = 4'd2;
        slave_writedata = 32'h13;
        @(negedge clk);
        if (tb_rtl_wordcopy.dut.src !== 32'h13) begin
            $display("ERROR 6: Expected src is %d, actual src is %d", 32'h13, tb_rtl_wordcopy.dut.src);
            err = 1'b1;
        end
        
        // Write to word offset 0 to start copy
        slave_address = 4'd0;
        slave_writedata = 32'haa;
        @(negedge clk);
        if (tb_rtl_wordcopy.dut.start_copy !== 1'b1) begin
            $display("ERROR 7: Expected start_copy is %d, actual start_copy is %d", 1'b1, tb_rtl_wordcopy.dut.start_copy);
            err = 1'b1;
        end

        slave_write = 0;
        slave_writedata = 32'bx;
        // Read from wordcopy accelerator offset 0, should stall until slave_waitrequest = 0
        slave_read = 1;
        slave_address = 4'd0;
        if (tb_rtl_wordcopy.dut.slave_waitrequest !== 1'b1) begin
            $display("ERROR 8: Expected slave_waitrequest is %d, actual slave_waitrequest is %d", 1'b1, tb_rtl_wordcopy.dut.slave_waitrequest);
            err = 1'b1;
        end

        // Start reading from src address
        master_waitrequest = 1'b0;
        @(posedge clk);
        if (tb_rtl_wordcopy.dut.state !== `START_READ) begin
            $display("ERROR 9: Expected state is %d, actual state is %d", `START_READ, tb_rtl_wordcopy.dut.state);
            err = 1'b1;
        end

        
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        master_readdata = 32'h25;
        master_readdatavalid = 1;
        @(negedge clk);
        @(negedge clk);
        master_readdata = 32'h26;
        master_readdatavalid = 1;
        @(negedge clk);
        @(negedge clk);
        master_readdata = 32'h27;
        master_readdatavalid = 1;
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        slave_write = 0;
        slave_writedata = 32'bx; @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        
        // Done copy, output slave_readdata value and deaasert waitrequest
        if (tb_rtl_wordcopy.dut.slave_readdata !== 32'haa) begin
            $display("ERROR 9: Expected slave_readdata is %d, actual slave_readdata is %d", 32'haa, tb_rtl_wordcopy.dut.slave_readdata);
            err = 1'b1;
        end
        if (tb_rtl_wordcopy.dut.slave_waitrequest !== 1'b0) begin
            $display("ERROR 10: Expected slave_waitrequest is %d, actual slave_waitrequest is %d", 1'b0, tb_rtl_wordcopy.dut.slave_waitrequest);
            err = 1'b1;
        end

        if (~err)
            $display("SUCCESS: All tests passed.");
        $stop;
    end


endmodule: tb_rtl_wordcopy