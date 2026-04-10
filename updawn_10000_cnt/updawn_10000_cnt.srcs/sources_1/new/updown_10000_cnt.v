`timescale 1ns / 1ps


module updown_10000_cnt #(
    parameter integer CLK_FREQ_HZ = 100_000_000,
    parameter integer TICK_HZ = 10,
    parameter integer FND_SCAN_HZ = 1000
) (
    input clk,
    input rst,
    input [2:0] sw,
    output [3:0] fnd_com,
    output [7:0] fnd_data
);
    wire [13:0] w_tick_counter;
    wire run_bnt, cnt_rst, mode;

    control_unit U_control (
        .sw(sw),
        .run_bnt(run_bnt),
        .rst(cnt_rst),
        .mode(mode)

    );

    fnd_controller #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .SCAN_HZ(FND_SCAN_HZ)
    ) U_FND_CNTL (
        .clk(clk),
        .rst(rst),
        .fnd_in(w_tick_counter),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );


    data_path #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .TICK_HZ(TICK_HZ)
    ) U_DATAPATH (
        .clk(clk),
        .rst(rst),
        .run_bnt(run_bnt),
        .cnt_rst(cnt_rst),
        .mode(mode),
        .tick_counter(w_tick_counter)
    );




endmodule
