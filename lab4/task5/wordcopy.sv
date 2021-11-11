module wordcopy(input logic clk, input logic rst_n,
                // slave (CPU-facing)
                output logic slave_waitrequest,
                input logic [3:0] slave_address,
                input logic slave_read, output logic [31:0] slave_readdata,
                input logic slave_write, input logic [31:0] slave_writedata,
                // master (SDRAM-facing)
                input logic master_waitrequest,
                output logic [31:0] master_address,
                output logic master_read, input logic [31:0] master_readdata, input logic master_readdatavalid,
                output logic master_write, output logic [31:0] master_writedata);

    // Slave functionalities:
    // 1. Write the byte address of the destination range to word offset 1
    // 2. Write the source byte address to word offset 2
    // 3. Write the number of 32-bit words to copy to word offset 3
    // 4. Write any value to word offset 0 to start the copy process(start running SDRAM-facing master)
    // 5. Finally, the CPU will read offset 0 to make sure the copy process has finished. 

    logic done_copy, slave_waitrequest_out;
    logic [31:0] slave_readdata_out;
    logic [31:0] dest, src, no_of_words, start_indicator;

    // Master

    `define IDLE       3'b000
    `define START_READ 3'b001
    `define WAIT_R_SIG 3'b010
    `define START_COPY 3'b011
    `define WAIT_W_SIG 3'b100
    `define DONE       3'b101

    logic start_copy;
    logic [2:0] state;
    logic [1:0] master_signal_out;
    logic [63:0] master_data_out;
    integer count;

    assign slave_readdata = slave_readdata_out;

    /* A slave asserts waitrequest when unable to respond to a read or write request. 
     * Forces the master to wait until the interconnect is ready to proceed with the transfer. */
    assign slave_waitrequest = slave_waitrequest_out;

    always @(*) begin
        if (rst_n == 1'b0)
            slave_waitrequest_out = 1'b1;
        else
            if (state == `START_READ || state == `WAIT_R_SIG || state == `START_COPY || state == `WAIT_W_SIG)
                slave_waitrequest_out = 1'b1;
            else
                slave_waitrequest_out = 1'b0;
    end

    always @(posedge clk)
        if (rst_n == 1'b0)
            slave_readdata_out <= 32'b0;
        else begin
            if (slave_read & (slave_address == 4'd0) & done_copy)
                slave_readdata_out <= start_indicator;
            if (slave_write) begin
                if (slave_address == 4'd0) start_indicator <= slave_writedata;
                if (slave_address == 4'd1) dest <= slave_writedata;
                if (slave_address == 4'd2) src <= slave_writedata;
                if (slave_address == 4'd3) no_of_words <= slave_writedata;
            end
        end


    // Master

    assign start_copy = slave_write && (slave_address == 4'd0);
    assign { master_read, master_write } = master_signal_out;
    assign { master_address, master_writedata } = master_data_out;

    always @(posedge clk)
        if (rst_n == 1'b0) begin
            state <= `IDLE;
            master_signal_out <= 2'b0;
            master_data_out <= 64'bx;
            done_copy <= 1'b0;
        end else
            case (state)
                `IDLE: begin
                    done_copy <= 1'b0;
                    master_signal_out <= 2'b0;
                    master_data_out <= 64'bx;
                    count <= 0;
                    if (start_copy) begin
                        state <= `START_READ;
                    end
                end
                `START_READ: begin
                    done_copy <= 1'b0;
                    if (count < no_of_words) begin
                        master_signal_out <= 2'b10;
                        master_data_out <= { src + (count * 4), 32'bx };
                        state <= `WAIT_R_SIG;
                    end else begin
                        state <= `DONE;
                        done_copy <= 1'b1;
                    end
                end
                `WAIT_R_SIG: begin
                    done_copy <= 1'b0;
                    if (master_waitrequest == 1'b0) begin
                        master_signal_out <= 2'b0;
                        state <= `START_COPY;
                    end
                end
                `START_COPY: begin
                    done_copy <= 1'b0;
                    if (master_readdatavalid == 1'b1) begin
                        master_signal_out <= 2'b01;
                        master_data_out <= { dest + (count * 4), master_readdata };
                        state <= `WAIT_W_SIG;
                    end
                end
                `WAIT_W_SIG: begin
                    done_copy <= 1'b0;
                    // waitrequest = 0 means write request is received
                    if (master_waitrequest == 1'b0) begin
                        master_signal_out <= 2'b0;
                        count <= count + 1;
                        state <= `START_READ;
                    end
                end
                `DONE: begin
                    done_copy <= 1'b1;
                    master_signal_out <= 2'b0;
                    master_data_out <= 64'bx;
                    count <= 0;
                    if (master_waitrequest == 1'b0 & start_copy) begin
                        state <= `START_READ;
                        done_copy <= 1'b0;
                    end
                end
                default: begin
                    master_signal_out <= 2'b0;
                    master_data_out <= 64'bx;
                    done_copy <= 1'b0;
                end
            endcase

endmodule: wordcopy