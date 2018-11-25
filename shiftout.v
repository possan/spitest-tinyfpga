module shiftout (
    input reset_in,
    input clk_in,
    input [15:0] bitstowrite_in,
    output wire clk_out,
    output wire data_out,
    output wire latch_out,
    output wire done_out
);
    localparam WAITING_FOR_RESET=0, RESETTING=1, WRITING=2, STOPPED=3;

    reg [3:0] r_state = WAITING_FOR_RESET;
    reg [3:0] r_nextstate = WAITING_FOR_RESET;
    reg [6:0] r_counter = 0;
    reg [0:15] r_queue = 0;
    reg r_latch_out = 1;
    reg r_done_out;
    reg r_clk_out;
    reg r_data_out;

    assign data_out = r_data_out;
    assign latch_out = r_latch_out;
    assign clk_out = r_clk_out;
    assign done_out = r_done_out;

    initial begin
        r_data_out <= 0;
        r_done_out <= 0;
        r_clk_out <= 0;
    end

    always @(posedge clk_in) begin
        if (reset_in == 1) begin
            r_queue <= bitstowrite_in;
            r_nextstate <= RESETTING;
            r_latch_out <= 0;
            r_done_out <= 0;
            r_clk_out <= 0;
            r_counter <= 0;
        end else begin
            if (r_clk_out == 0) begin
                case (r_state)
                    WAITING_FOR_RESET: begin
                        r_data_out <= 0;
                        r_done_out <= 0;
                        r_counter <= 0;
                    end

                    RESETTING: begin
                        r_nextstate <= WRITING;
                        r_data_out <= r_queue[r_counter];
                    end

                    WRITING: begin
                        if (r_counter < 16) begin
                            r_clk_out <= 1;
                        end else begin
                            r_data_out <= 0;
                            r_latch_out <= 1;
                            r_nextstate <= STOPPED;
                        end
                    end

                    STOPPED: begin
                        r_done_out <= 1;
                        r_nextstate <= WAITING_FOR_RESET;
                    end
                endcase
            end else begin
                r_clk_out <= 0;
                if (r_state == WRITING) begin
                    r_counter <= r_counter + 1;
                    if (r_counter < 15) begin
                        r_data_out <= r_queue[r_counter + 1];
                    end else begin
                        r_latch_out <= 1;
                        r_data_out <= 0;
                        r_nextstate <= STOPPED;
                    end
                end else begin
                    r_counter <= 0;
                end
            end
            r_state <= r_nextstate;
        end
    end

endmodule
