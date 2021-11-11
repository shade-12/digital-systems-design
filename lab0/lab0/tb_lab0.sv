module tb_lab0();
    logic CLOCK_50, resetn, loadA, loadB, err;
    logic [3:0] valueA, valueB;
    logic [4:0] sum;

    lab0 dut(.*);

    initial begin
        CLOCK_50 = 0;
        forever #5 CLOCK_50 = ~CLOCK_50;
    end

    initial begin
        err = 1'b0;
        // Reset for two clock cycles
        resetn <= 1'b0;
        #20;
        resetn <= 1'b1;

        valueA = 4'b0001;
        valueB = 4'b0010;
        loadA = 1'b0;
        loadB = 1'b0;

        // Test for both loadA and loadB are 1'b0
        if (tb_lab0.dut.sum !== 5'b0) begin
            $display("ERROR: Expected sum is %b, actual sum is %b", 5'b0, tb_lab0.dut.sum);
            err = 1'b1;
        end

        loadA = 1'b1;
        #20;

        // Test for loadA = 1'b1 and loadB = 1'b0
        if (tb_lab0.dut.sum !== 5'b1) begin
            $display("ERROR: Expected sum is %b, actual sum is %b", 5'b1, tb_lab0.dut.sum);
            err = 1'b1;
        end

        loadA = 1'b0;
        loadB = 1'b1;
        #20;

        // Test for loadA = 1'b0 and loadB = 1'b1
        if (tb_lab0.dut.sum !== 5'b00011) begin
            $display("ERROR: Expected sum is %b, actual sum is %b", 5'b00011, tb_lab0.dut.sum);
            err = 1'b1;
        end

        valueA = 4'b0011;
        valueB = 4'b1000;
        loadA = 1'b1;
        loadB = 1'b1;
        #20;

        // Test for both loadA and loadB = 1'b1
        if (tb_lab0.dut.sum !== 5'b01011) begin
            $display("ERROR: Expected sum is %b, actual sum is %b", 5'b01011, tb_lab0.dut.sum);
            err = 1'b1;
        end

        if (~err) begin
            $display("SUCCESS: All tests passed.");
        end
        $stop;

    end
endmodule