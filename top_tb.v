module top_tb;

    initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);

        # 5000 $finish;
    end

    reg clk = 0;
    wire led2;
    wire led3;
    wire led4;
    wire led5;
    wire leddata;
    wire ledlatch;
    wire ledclk;
    wire debug1;
    wire debug2;
    wire debug3;

    always #1 clk = !clk;

    top #(
        .clk_divider(0)
    ) c1 (
        clk,
        led2, led3, led4, led5,
        leddata, ledlatch, ledclk,
        debug1, debug2, debug3
    );

endmodule
