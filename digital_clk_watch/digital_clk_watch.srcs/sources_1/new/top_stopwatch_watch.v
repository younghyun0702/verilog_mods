`timescale 1ns / 1ps


module top_stopwatch_watch #(
    parameter MAIN_CLK_100MHZ = 100_000_000,
    parameter BASIC_TIME      = 100,
    parameter SCAN_HZ         = 1000,
    parameter MSEC_WIDTH      = 7,
    parameter SEC_WIDTH       = 6,
    parameter MIN_WIDTH       = 6,
    parameter HOUR_WIDTH      = 5

) (
    input        clk,
    input        rst,
    input        btnR,
    input        btnL,
    input        btnU,
    input        btnD,
    input  [2:0] sw,
    output [7:0] fnd_data,
    output [3:0] fnd_com,
    output [1:0] led
);
    wire [MSEC_WIDTH  -1:0] w_msec;
    wire [SEC_WIDTH   -1:0] w_sec;
    wire [MIN_WIDTH   -1:0] w_min;
    wire [HOUR_WIDTH  -1:0] w_hour;
    wire w_btnR, w_btnD, w_btnL, w_btnU;
    wire w_runstop, w_clear, w_mode;

    control_unit_timer U_CONTROL_UNIT (
        .clk(clk),
        .rst(rst),
        .BTN_D(w_btnD),
        .BTN_L(w_btnL),
        .BTN_R(w_btnR),
        .BTN_U(w_btnU),
        .o_run_stop(w_runstop),
        .o_clear(w_clear),
        .o_mode(w_mode),
        .o_led(led[0])
    );

    debouncer U_BTNL (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnL),
        .o_btn(w_btnL)
    );

    debouncer U_BTNR (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnR),
        .o_btn(w_btnR)
    );
    debouncer U_BTND (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnD),
        .o_btn(w_btnD)
    );



    stopwatch_datapath U_DATAPATH (
        .clk(clk),
        .rst(rst),
        .i_runstop(),
        .i_clear(),
        .i_mode(),
        .msec(w_msec),
        .sec(w_sec),
        .min(w_min),
        .hour(w_hour)
    );


    fnd_controller #(
        .MAIN_CLK_100MHZ(MAIN_CLK_100MHZ),
        .SCAN_HZ        (SCAN_HZ),
        .MSEC_WIDTH     (MSEC_WIDTH),
        .SEC_WIDTH      (SEC_WIDTH),
        .MIN_WIDTH      (MIN_WIDTH),
        .HOUR_WIDTH     (HOUR_WIDTH)
    ) U_CONTROL_FND (
        .clk(clk),
        .rst(rst),
        .sw(sw[0]),  // sw[0] , 0 : msec_sec, 1 : mon_hour
        .msec(w_msec),
        .sec(w_sec),
        .min(w_min),
        .hour(w_hour),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );



endmodule
