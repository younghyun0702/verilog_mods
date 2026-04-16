`timescale 1ns / 1ps

module stopwatch_datapath #(
    parameter MAIN_CLK_100MHZ = 100_000_000,
    parameter BASIC_TIME      = 100,
    parameter MSEC_WIDTH      = 7,
    parameter SEC_WIDTH       = 6,
    parameter MIN_WIDTH       = 6,
    parameter HOUR_WIDTH      = 5
) (
    input                     clk,
    input                     rst,
    input                     i_runstop,
    input                     i_clear,
    input                     i_mode,
    output [MSEC_WIDTH  -1:0] msec,
    output [SEC_WIDTH   -1:0] sec,
    output [MIN_WIDTH   -1:0] min,
    output [HOUR_WIDTH  -1:0] hour
);

    wire w_tick_100hz;
    wire w_sec_tick, w_min_tick, w_hour_tick;

    tick_counter #(
        .TIMES    (24),
        .BIT_WIDTH(HOUR_WIDTH)
    ) U_HOUR_COUNTER (
        .clk       (clk),
        .rst       (rst),
        .i_tick    (w_hour_tick),
        .i_clear   (i_clear),
        .i_mode    (i_mode),
        .time_count(hour)
        // 날짜 없음
    );

    tick_counter #(
        .TIMES    (60),
        .BIT_WIDTH(MIN_WIDTH)
    ) U_MIN_COUNTER (
        .clk       (clk),
        .rst       (rst),
        .i_tick    (w_min_tick),
        .i_clear   (i_clear),
        .i_mode    (i_mode),
        .time_count(min),
        .o_tick    (w_hour_tick)
    );

    tick_counter #(
        .TIMES    (60),
        .BIT_WIDTH(SEC_WIDTH)
    ) U_SEC_COUNTER (
        .clk       (clk),
        .rst       (rst),
        .i_tick    (w_sec_tick),
        .i_clear   (i_clear),
        .i_mode    (i_mode),
        .time_count(sec),
        .o_tick    (w_min_tick)
    );

    tick_counter #(
        .TIMES    (100),
        .BIT_WIDTH(MSEC_WIDTH)
    ) U_MSEC_COUNTER (
        .clk       (clk),
        .rst       (rst),
        .i_tick    (w_tick_100hz),
        .i_clear   (i_clear),
        .i_mode    (i_mode),
        .time_count(msec),
        .o_tick    (w_sec_tick)
    );


    tick_gen_100hz #(
        .MAIN_CLK_100MHZ(MAIN_CLK_100MHZ),
        .CLK_DIV_HZ     (BASIC_TIME)
    ) U_TICK_GEN_100HZ (
        .clk         (clk),
        .rst         (rst),
        .i_runstop   (i_runstop),
        .i_clear     (i_clear),
        .o_tick_100hz(w_tick_100hz)
    );


endmodule


//TICK GEN
module tick_gen_100hz #(
    parameter MAIN_CLK_100MHZ = 100_000_000,
    parameter CLK_DIV_HZ = 100
) (
    input clk,
    input rst,
    input i_runstop,
    input i_clear,
    output reg o_tick_100hz
);
    //100_000_000/100= 1000000

    parameter COUNT = MAIN_CLK_100MHZ / CLK_DIV_HZ;
    reg [$clog2(COUNT)-1:0] counter_reg;




    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg  <= 0;
            o_tick_100hz <= 1'b0;
        end else begin
            if (i_runstop) begin

                counter_reg  <= counter_reg + 1'b1;
                o_tick_100hz <= 1'b0;

                if (counter_reg == (COUNT - 1)) begin
                    counter_reg  <= 0;
                    o_tick_100hz <= 1'b1;
                end else begin
                    o_tick_100hz <= 1'b0;
                end
            end else if (i_clear) begin
                counter_reg  <= 0;
                o_tick_100hz <= 0;
            end
        end
    end
endmodule



module tick_counter #(
    parameter TIMES = 100,
    parameter BIT_WIDTH = 7
) (
    input                        clk,
    input                        rst,
    input                        i_tick,
    input                        i_clear,
    input                        i_mode,
    output     [BIT_WIDTH-1 : 0] time_count,
    output reg                   o_tick
);

    reg [BIT_WIDTH-1:0] counter_reg, counter_next;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg <= 0;
        end else begin
            counter_reg <= counter_next;
        end
    end

    //next_counter
    always @(*) begin
        counter_next = counter_reg;
        o_tick = 1'b0;


        if (i_tick) begin
            if (i_mode) begin
                if (counter_reg == 0) begin
                    counter_next = TIMES - 1;
                    o_tick = 1'b1;
                end else begin
                    counter_next = counter_next - 1;
                end

            end else begin
                if (counter_reg == (TIMES - 1)) begin
                    counter_next = 0;
                    o_tick = 1'b1;
                end else begin
                    counter_next = counter_next + 1;
                end
            end
        end else if (i_clear) begin
            counter_next = 0;
            o_tick = 0;
        end
    end

    assign time_count = counter_reg;

endmodule
