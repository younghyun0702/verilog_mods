`timescale 1ns / 1ps

module data_path #(
    parameter integer CLK_FREQ_HZ = 100_000_000,
    parameter integer TICK_HZ = 10
) (
    input clk,
    input rst,
    input run_bnt,
    input cnt_rst,
    input mode,  // <-------------add
    output [13:0] tick_counter
);

    wire w_tick_10hz;
    wire counter_clk, counter_rst;

    updown_tick_counter U_TICK_COUNTER (
        .clk(counter_clk),
        .rst(counter_rst),
        .i_tick(w_tick_10hz),
        .mode(mode),
        .o_tick_counter(tick_counter)
    );

    clk_tick_gen #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .TICK_HZ(TICK_HZ)
    ) U_CLK_TICK_GEN (
        .clk(counter_clk),
        .rst(counter_rst),
        .o_tick(w_tick_10hz)
    );

    and U0 (counter_clk, clk, run_bnt);
    or U1 (counter_rst, rst, cnt_rst);


endmodule

module updown_tick_counter (
    input clk,
    input rst,
    input i_tick,
    input mode,  //<------------add
    output [13:0] o_tick_counter
);

    reg [13:0] tick_counter_reg;

    assign o_tick_counter = tick_counter_reg;

    //add updown conter mode
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            tick_counter_reg <= 14'd0;
        end else if (i_tick == 1'b1) begin
            if (!mode) begin
                if (tick_counter_reg == 14'd9999) begin
                    tick_counter_reg <= 14'd0;
                end else begin
                    tick_counter_reg <= tick_counter_reg + 1'b1;
                end
            end else begin
                if (tick_counter_reg == 14'd0) begin
                    tick_counter_reg <= 14'd9999;
                end else begin
                    tick_counter_reg <= tick_counter_reg - 1'b1;
                end

            end

        end else tick_counter_reg <= tick_counter_reg;

    end

endmodule

module clk_tick_gen #(
    parameter integer CLK_FREQ_HZ = 100_000_000,
    parameter integer TICK_HZ = 10
) (
    input clk,
    input rst,
    output reg o_tick
);

    localparam integer TICK_COUNT = CLK_FREQ_HZ / TICK_HZ;
    localparam integer COUNTER_WIDTH = (TICK_COUNT <= 1) ? 1 : $clog2(
        TICK_COUNT
    );

    reg [COUNTER_WIDTH-1:0] counter_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg <= {COUNTER_WIDTH{1'b0}};
            o_tick      <= 1'b0;
        end else begin
            o_tick <= 1'b0;
            if (counter_reg == TICK_COUNT - 1) begin
                counter_reg <= {COUNTER_WIDTH{1'b0}};
                o_tick      <= 1'b1;
            end else begin
                counter_reg <= counter_reg + 1'b1;
            end
        end
    end

endmodule
