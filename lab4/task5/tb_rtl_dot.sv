module tb_rtl_dot();

    logic clk, rst_n, slave_waitrequest, slave_read, slave_write, err;
    logic [3:0] slave_address;
    logic [31:0] slave_readdata, slave_writedata;
    logic master_waitrequest, master_read, master_readdatavalid, master_write;
    logic [31:0] master_address, master_readdata, master_writedata;

    logic [63:0] mul;

    dot dut(.*);

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    `define IDLE    3'b000
    `define READ_W  3'b001      // Read w[i] value from memory
    `define WAIT_W  3'b010
    `define READ_V  3'b011      // Read ifmap[i] value from memory
    `define WAIT_V  3'b100
    `define CALC    3'b101      // Add value of w[i] * ifmap[i] to sum
    `define DONE    3'b110

    initial begin
        err = 1'b0;

        #2 rst_n = 0;
        @(posedge clk); // do sync reset
        @(negedge clk);
        if (tb_rtl_dot.dut.slave_waitrequest !== 1'b1) begin
            $display("ERROR 1: Expected slave_waitrequest is %d, actual slave_waitrequest is %d", 1'b1, tb_rtl_dot.dut.slave_waitrequest);
            err = 1'b1;
        end
        if (tb_rtl_dot.dut.slave_readdata !== 32'b0) begin
            $display("ERROR 2: Expected slave_readdata is %d, actual slave_readdata is %d", 32'b0, tb_rtl_dot.dut.slave_readdata);
            err = 1'b1;
        end
        if (tb_rtl_dot.dut.state !== `IDLE) begin
            $display("ERROR 3: Expected state is %d, actual state is %d", `IDLE, tb_rtl_dot.dut.state);
            err = 1'b1;
        end

        #2 rst_n = 1;
        master_waitrequest = 1'bx;

        // wait a bit
        @(negedge clk);
        @(negedge clk);

        slave_write = 1;

        // Write weight address to accelerator's address
        slave_address = 4'd2;
        slave_writedata = 32'h03;
        @(negedge clk);
        if (tb_rtl_dot.dut.weight_addr !== 32'h03) begin
            $display("ERROR 4: Expected weight_addr is %d, actual weight_addr is %d", 32'h03, tb_rtl_dot.dut.weight_addr);
            err = 1'b1;
        end

        slave_write = 0;
        slave_writedata = 32'bx;
        @(negedge clk);
        @(negedge clk);

        slave_write = 1;

        // Write vector address
        slave_address = 4'd3;
        slave_writedata = 32'h12;
        @(negedge clk);
        if (tb_rtl_dot.dut.vector_addr !== 32'h12) begin
            $display("ERROR 5: Expected vector_addr is %d, actual vector_addr is %d", 32'h12, tb_rtl_dot.dut.vector_addr);
            err = 1'b1;
        end

        // Write vector length
        slave_address = 4'd5;
        slave_writedata = 32'h3;
        @(negedge clk);
        if (tb_rtl_dot.dut.vector_length !== 32'h3) begin
            $display("ERROR 6: Expected vector_length is %d, actual vector_length is %d", 32'h3, tb_rtl_dot.dut.vector_length);
            err = 1'b1;
        end
        
        // Write to word offset 0 to start calculation
        slave_address = 4'd0;
        slave_writedata = 32'haa;
        @(negedge clk);
        if (tb_rtl_dot.dut.start_dot !== 1'b1) begin
            $display("ERROR 7: Expected start_dot is %d, actual start_dot is %d", 1'b1, tb_rtl_dot.dut.start_dot);
            err = 1'b1;
        end

        slave_write = 0;
        slave_writedata = 32'bx;
        // Read from dot product accelerator offset 0, should stall until slave_waitrequest = 0
        slave_read = 1;
        slave_address = 4'd0;
        if (tb_rtl_dot.dut.slave_waitrequest !== 1'b1) begin
            $display("ERROR 8: Expected slave_waitrequest is %d, actual slave_waitrequest is %d", 1'b1, tb_rtl_dot.dut.slave_waitrequest);
            err = 1'b1;
        end

        // Start reading from weight address
        master_waitrequest = 1'b0;
        if (tb_rtl_dot.dut.state !== `READ_W) begin
            $display("ERROR 9: Expected state is %d, actual state is %d", `READ_W, tb_rtl_dot.dut.state);
            err = 1'b1;
        end

        // Verify Q16.16 multiplication
        // 102236 is Q16.16 format for float number 1.56
        // 81265 is Q16.16 format for float number 1.24
        // mul = 102236 * 81265;
        // $display("%b", 1.56 * 1.24); // Should get 1 here
        // $display("%b", mul[63:32]); // Should be 1
        // $display("%b", mul[31:0]);  // Should be 0.934402...

        // mul = 65536 * -163185;
        // $display("%b", mul[63:32]); // Should be -2
        // $display("%b", mul[31:0]);  // Should be 0.49

        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        master_readdata = 32'd102236;
        master_readdatavalid = 1;
        @(negedge clk);
        @(negedge clk);
        master_readdata = 32'd81265;
        master_readdatavalid = 1;
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        // Should produce int_prod = 2 and sum = 2
        master_readdata = 32'd65536;
        master_readdatavalid = 1;
        @(negedge clk);
        @(negedge clk);
        master_readdata = -163185;
        master_readdatavalid = 1;
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        master_readdata = -370934;
        master_readdatavalid = 1;
        @(negedge clk);
        @(negedge clk);
        master_readdata = 122552;
        master_readdatavalid = 1;
        @(negedge clk);
        @(negedge clk);
        // Should produce int_prod = -11 and sum = 11
        slave_write = 0;
        slave_writedata = 32'bx; @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        
        // Done calc, output slave_readdata value and deaasert waitrequest
        if (tb_rtl_dot.dut.slave_readdata !== -11) begin
            $display("ERROR 9: Expected slave_readdata is %d, actual slave_readdata is %d", -11, tb_rtl_dot.dut.slave_readdata);
            err = 1'b1;
        end
        if (tb_rtl_dot.dut.slave_waitrequest !== 1'b0) begin
            $display("ERROR 10: Expected slave_waitrequest is %d, actual slave_waitrequest is %d", 1'b0, tb_rtl_dot.dut.slave_waitrequest);
            err = 1'b1;
        end

        if (~err)
            $display("SUCCESS: All tests passed.");
        $stop;
    end

endmodule: tb_rtl_dot