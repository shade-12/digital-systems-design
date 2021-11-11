module init(input logic clk, input logic rst_n,
            input logic en, output logic rdy,
            output logic [7:0] addr, output logic [7:0] wrdata, output logic wren);

    /**
     * Conditions:
     * 1. When rdy is asserted (1), the circuit is ready to accept a new request.
     * 2. When rdy is asserted (1), the caller can assert en anytime as early as the same cycle when rdy is high.
     * 3. If the circuit required multiple cycle to complete, rdy should be deasserted in the cycle following the en call.
     * 4. en should be deaaserted in the following cycle if caller wished to make only one call.
     */
    
    `define IDLE 1'b0
    `define WRITE 1'b1
    
    reg state, rdy_out, wren_out;
    reg [7:0] count;

    assign addr = count;
    assign wrdata = count;
    assign wren = wren_out;
    assign rdy = rdy_out;
    
    always @(posedge clk) begin
        if (rst_n == 1'b0) begin
            count <= 8'b0;
            state <= `IDLE;
            wren_out <= 1'b0;
            rdy_out <= 1'b0;
        end else
            case (state)
                `IDLE: begin
                    count <= 8'b0;
                    if (en == 1'b1) begin
                        state <= `WRITE;
                        wren_out <= 1'b1;
                        rdy_out <= 1'b0;
                    end else begin
                        wren_out <= 1'b0;
                        rdy_out <= 1'b1;
                    end
                end
                `WRITE: begin
                    rdy_out <= 1'b0;
                    if (count < 255) begin
                        count <= count + 8'b1;
                        wren_out <= 1'b1;
                    end else begin
                        count <= 8'b0;
                        state <= `IDLE;
                        wren_out <= 1'b0;
                    end
                end
                default: begin
                    count <= 8'b0;
                    state <= `IDLE;
                    wren_out <= 1'b0;
                    rdy_out <= 1'b0;
                end
            endcase
    end

endmodule: init