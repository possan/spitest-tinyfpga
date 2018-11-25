module shiftout_tb;

    reg r_reset = 0;
    reg [15:0] r_bitstowrite = 16'b1111111111111111;
    wire [15:0] w_bitstowrite;
    assign w_bitstowrite = r_bitstowrite;

    initial begin
        $dumpfile("shiftout_tb.vcd");
        $dumpvars(0, shiftout_tb);

        # 1 r_bitstowrite <= 16'b1111001100110101;
        # 1 r_reset <= 1;
        # 1 r_reset <= 0;

        # 150 r_bitstowrite <= 16'b1010101000000000;
        # 1 r_reset <= 1;
        # 1 r_reset <= 0;

        # 150 $finish;
    end

    reg [0:0] clk = 0;
    wire [0:0] done;
    wire [0:0] clkout;
    wire [0:0] dataout;
    wire [0:0] latchout;
    wire [0:0] debug;

    always #1 clk = !clk;

    shiftout c1 (
        .reset_in(r_reset),
        .clk_in(clk),
        .bitstowrite_in(w_bitstowrite),
        .clk_out(clkout),
        .data_out(dataout),
        .latch_out(latchout),
        .done_out(done),
        .debug_out(debug));

endmodule
