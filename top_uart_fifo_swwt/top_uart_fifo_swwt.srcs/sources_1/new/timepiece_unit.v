`timescale 1ns / 1ps

module timepiece_unit #(
    parameter CLK_FREQ_HZ = 100_000_000,
    parameter BASIC_TIME  = 100,

    parameter MSEC_WIDTH = 7,
    parameter SEC_WIDTH  = 6,
    parameter MIN_WIDTH  = 6,
    parameter HOUR_WIDTH = 5,
    parameter MSEC_TIMES = 100,
    parameter SEC_TIMES  = 60,
    parameter MIN_TIMES  = 60,
    parameter HOUR_TIMES = 24
) (
    input  clk,
    input  rst,
    input  i_display_mode,
    input  i_btnL,
    input  i_btnU,
    input  i_btnD,
    input  i_btnU_hold,
    input  i_btnD_hold,
    input  i_btnR_hold,
    input  [1:0] i_sw,
    input  i_sw15,
    output o_set_mode,
    output o_set_index,
    output o_set_time
);

    wire w_set_mode;
    wire [1:0] w_set_index;
    wire w_increment, w_increment_tens;
    wire w_decrement, w_decrement_tens;

    timepiece_fsm U_TIMEPIECE_FSM (
        .clk(clk),
        .rst(rst),
        .i_display_mode(i_display_mode),
        .i_btnL(i_btnL),
        .i_btnU(i_btnU),
        .i_btnD(i_btnD),
        .i_btnU_hold(i_btnU_hold),
        .i_btnD_hold(i_btnD_hold),
        .i_btnR_hold(i_btnR_hold),
        .i_sw(i_sw),
        .o_set_mode(w_set_mode),
        .o_set_index(w_set_index),
        .o_index_shift(w_index_shift),
        .o_increment(w_increment),
        .o_increment_tens(w_increment_tens),
        .o_decrement(w_decrement),
        .o_decrement_tens(w_decrement_tens)
    );

    timepiece_datapath #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .TICK_HZ(BASIC_TIME),
        .MSEC_TIMES(MSEC_TIMES),
        .SEC_TIMES(SEC_TIMES),
        .MIN_TIMES(MIN_TIMES),
        .HOUR_TIMES(HOUR_TIMES),
        .MSEC_WIDTH(MSEC_WIDTH),
        .SEC_WIDTH(SEC_WIDTH),
        .MIN_WIDTH(MIN_WIDTH),
        .HOUR_WIDTH(HOUR_WIDTH)
    ) U_TIMEPIECE_DATAPATH (
        .clk(clk),
        .rst(rst),
        .i_set_mode(w_set_mode),
        .i_set_index(w_set_index),
        .i_index_shift(w_index_shift),
        .i_increment(w_increment),
        .i_increment_tens(w_increment_tens),
        .i_decrement(w_decrement),
        .i_decrement_tens(w_decrement_tens),
        .i_time_24(),
        .o_set_time(),
        .o_timepiece_vault(),
        .o_sec_tick(),
        .o_min_tick(),
        .o_hour_tick(),
        .msec(),
        .sec(),
        .min(),
        .hour()
    );



endmodule
