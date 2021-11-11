`timescale 1ps / 1ps

module tb_reverse();

  logic clk=0;
  logic rst_n;

  logic [7:0] din, dout;
  logic din_valid;
  logic rdy, ena;

  always #5 clk = ~clk;

  reverse dut( .* );

  initial
  begin

    din_valid = 0;
    rdy = 0;

    #2 rst_n = 0;
    @(posedge clk); // do sync reset
    @(negedge clk);

    #2 rst_n = 1;
    rdy = 1;

    // wait a bit
        @(negedge clk);
        @(negedge clk);

    din_valid = 1;
    din = 17;  @(negedge clk);
    din_valid = 0;
    din = 255;
        @(negedge clk);
        @(negedge clk);
    din_valid = 1;
    din = 18;  @(negedge clk);
    din = 19;  @(negedge clk);
    din = 20;  @(negedge clk);
    din = 255; @(negedge clk);
        @(negedge clk);
    rdy = 0;
        @(negedge clk);
        @(negedge clk);
    rdy = 1;
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
    rdy = 0;
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
    din_valid = 0;

    #200;

    $finish;
  end

endmodule
