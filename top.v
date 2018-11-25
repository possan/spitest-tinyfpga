// look in pins.pcf for all the pin names on the TinyFPGA BX board

module top #(
    parameter clk_divider = 100
) (
    input CLK,
    output wire LED2,
    output wire LED3,
    output wire LED4,
    output wire LED5,
    output wire LEDDATA,
    output wire LEDLATCH,
    output wire LEDCLK,
    output wire DEB1,
    output wire DEB2,
    output wire DEB3
);
    localparam
        IDLE=0,
        RESET=1,
        RESETTED=4,
        STOPPED=5;


    localparam INIT1 = 16'b0000110000000001; // set shutdown mode (12) to 1 (not shut down)
    localparam INIT2 = 16'b0000111100000001; // send displaytest to 1
    localparam INIT3 = 16'b0000111100000000; // set displaytest to 0
    localparam INIT4 = 16'b0000100100000000; // set decodemode (9) to 0
    localparam INIT5 = 16'b0000101100000111; // reset #2: set scanlimit (11) to 7

    //                            1...4...
    localparam GFX1 = 16'b0000000100111100;
    localparam GFX2 = 16'b0000001001111110;
    localparam GFX3 = 16'b0000001110011001;
    localparam GFX4 = 16'b0000010011111111;
    localparam GFX5 = 16'b0000010111111111;
    localparam GFX6 = 16'b0000011011000011;
    localparam GFX7 = 16'b0000011101100110;
    localparam GFX8 = 16'b0000100000111100;

    reg [5:0] r_state;
    reg [5:0] r_nextstate;
    reg [30:0] r_counter;

    reg r_clk;
    reg r_reset;
    reg [4:0] r_setup;
    // reg [63:0] r_pixels;
    reg [15:0] r_shiftdata;
    // reg r_init = 0;

    wire w_done;
    wire w_debug;
    reg [15:0] r_dummy_reset;
    reg w_debug2 = 0;
    wire w_clk_out;
    wire w_data_out;
    wire w_latch_out;
    reg w_last_done;

    assign LED2 = r_clk;
    assign LED3 = w_clk_out;
    assign LED4 = w_data_out;
    assign LED5 = w_latch_out;

    assign LEDDATA = w_data_out;
    assign LEDLATCH = w_latch_out;
    assign LEDCLK = w_clk_out;

    assign DEB1 = w_data_out;
    assign DEB2 = w_done;
    assign DEB3 = r_reset;

    // ledmatrix ledmatriximport(r_clk, r_reset, r_pixels, w_clk_out, w_data_out, w_latch_out, w_done, w_debug);
    shiftout s(
        .reset_in(r_reset),
        .clk_in(r_clk),
        .bitstowrite_in(r_shiftdata),
        .clk_out(w_clk_out),
        .data_out(w_data_out),
        .latch_out(w_latch_out),
        .done_out(w_done),
        .debug_out(w_debug));

    initial begin
        r_clk <= 0;
        r_reset <= 0;
        r_setup <= 0;
        r_state <= IDLE;
        r_nextstate <= IDLE;
        r_counter <= 0;
        r_dummy_reset <= 0;
    end

    always @(posedge CLK) begin
        r_counter <= r_counter + 1;
        if (r_counter >= clk_divider) begin
            r_counter <= 0;

            r_dummy_reset <= r_dummy_reset + 1;
            if (r_dummy_reset >= 6000) begin
                r_dummy_reset <= 0;
                r_clk <= 0;
                r_setup <= 0;
                r_nextstate <= IDLE;
            end else begin
                if (w_done == 1 && !w_last_done) begin
                    $display("in w_done = 1");
                    // r_reset <= 1;
                    r_nextstate <= IDLE;
                    r_setup <= r_setup + 1;
                    // r_debug2 <= 0;
                end
                case (r_state)
                    IDLE: begin
                        // reset #1: send displaytest = 0
                        $display("TOP: resetting.");
                        // r_pixels <= 64'b1111001100110101111100110011010111110011001101011111001100110101;

                        if (r_setup == 0) begin
                            r_shiftdata <= INIT1;
                            r_nextstate <= RESET;
                        end else if (r_setup == 1) begin
                            r_shiftdata <= INIT2;
                            r_nextstate <= RESET;
                        end else if (r_setup == 2) begin
                            r_shiftdata <= INIT3;
                            r_nextstate <= RESET;
                        end else if (r_setup == 3) begin
                            r_shiftdata <= INIT4;
                            r_nextstate <= RESET;
                        end else if (r_setup == 4) begin
                            r_shiftdata <= INIT5;
                            r_nextstate <= RESET;
                        end else if (r_setup == 5) begin
                            r_shiftdata <= GFX1;
                            r_nextstate <= RESET;
                        end else if (r_setup == 6) begin
                            r_shiftdata <= GFX2;
                            r_nextstate <= RESET;
                        end else if (r_setup == 7) begin
                            r_shiftdata <= GFX3;
                            r_nextstate <= RESET;
                        end else if (r_setup == 8) begin
                            r_shiftdata <= GFX4;
                            r_nextstate <= RESET;
                        end else if (r_setup == 9) begin
                            r_shiftdata <= GFX5;
                            r_nextstate <= RESET;
                        end else if (r_setup == 10) begin
                            r_shiftdata <= GFX6;
                            r_nextstate <= RESET;
                        end else if (r_setup == 11) begin
                            r_shiftdata <= GFX7;
                            r_nextstate <= RESET;
                        end else if (r_setup == 12) begin
                            r_shiftdata <= GFX8;
                            r_nextstate <= RESET;
                        end else begin
                            r_nextstate <= RESETTED;
                        end
                    end
                    RESET: begin
                        r_reset <= 1;
                        r_nextstate <= RESETTED;
                    end
                    RESETTED: begin
                        r_reset <= 0;
                    end
                endcase
            end
            w_last_done <= w_done;
            r_clk <= !r_clk;
            r_state <= r_nextstate;
        end
    end

endmodule
