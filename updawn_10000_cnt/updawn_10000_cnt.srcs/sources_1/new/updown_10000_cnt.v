`timescale 1ns / 1ps


module updown_10000_cnt #(
    parameter integer CLK_FREQ_HZ = 100_000_000,
    parameter integer TICK_HZ = 10,
    parameter integer FND_SCAN_HZ = 1000
) (
    input clk,
    input rst,
    input btnD,
    input btnL,
    input btnR,
    output [3:0] fnd_com,
    output [7:0] fnd_data
);
    wire [13:0] w_tick_counter;
    wire w_clear, w_run_stop, w_mode;
    wire w_btnR, w_btnL, w_btnD;


    debouncer U_BD_RUNSTOP (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnR),
        .o_btn(w_btnR)
    );
    debouncer U_BD_CLEAR (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnL),
        .o_btn(w_btnL)
    );
    debouncer U_BD_MODE (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnD),
        .o_btn(w_btnD)
    );

    control_unit_timer U_control (
        .clk(clk),
        .rst(rst),
        .BTN_D(w_btnD),
        .BTN_L(w_btnL),
        .BTN_R(w_btnR),
        .o_run_stop(w_run_stop),
        .o_clear(w_clear),
        .o_mode(w_mode)
    );

    fnd_controller U_FND_CNTL (
        .clk(clk),
        .rst(rst),
        .fnd_in(w_tick_counter),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );


    data_path U_DATAPATH (
        .clk(clk),
        .rst(rst),
        .i_run_stop(w_run_stop),
        .i_clear(w_clear),
        .i_mode(w_mode),
        .tick_counter(w_tick_counter)
    );




endmodule
