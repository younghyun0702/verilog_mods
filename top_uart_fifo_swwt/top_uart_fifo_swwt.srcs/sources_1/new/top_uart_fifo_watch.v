`timescale 1ns / 1ps

module top_uart_fifo_watch #(
    parameter CLK_FREQ_HZ        = 100_000_000,
    parameter BD_HZ              = 100_000,
    parameter HOLD_TIME_BTN_R    = 200_000_000,
    parameter HOLD_TIME_BTN_UD   = 150_000_000,
    parameter HOLD_TIME_BTN_L    = 150_000_000,
    parameter REPEAT_TIME_BTN_UD = 20_000_000,
    parameter BASIC_TIME         = 100,
    parameter SCAN_HZ            = 1000,
    parameter MSEC_WIDTH         = 7,
    parameter SEC_WIDTH          = 6,
    parameter MIN_WIDTH          = 6,
    parameter HOUR_WIDTH         = 5,
    parameter MSEC_TIMES         = 100,
    parameter SEC_TIMES          = 60,
    parameter MIN_TIMES          = 60,
    parameter HOUR_TIMES         = 24
) (
    input        clk,
    input        rst,
    input        rx,
    input        btnU,
    input        btnD,
    input        btnL,
    input        btnR,
    input        sw0,
    input        sw1,
    input        sw15,
    input        echo,
    output       trig,
    output       tx,
    output [3:0] fnd_com,
    output [7:0] fnd_data,
    output [1:0] led,
    output       led_valid,
    inout        dht11
);

    wire w_com_btnC;
    wire w_com_btnR;
    wire w_com_btnL;
    wire w_com_btnU;
    wire w_com_btnD;
    wire w_com_btnS;

    wire [23:0] w_time_data;
    wire [11:0] w_sr04_data;
    wire [15:0] w_dht11_data;

    

    timepiecer U_SW_WT (
        .clk(clk),
        .rst(rst),
        .btnR(btnR),
        .btnL(btnL),
        .btnU(btnU),
        .btnD(btnD),
        .com_btnC(w_com_btnC),
        .com_btnR(w_com_btnR),
        .com_btnL(w_com_btnL),
        .com_btnU(w_com_btnU),
        .com_btnD(w_com_btnD),
        .com_btnS(w_com_btnS),
        .sw0(sw0),
        .sw1(sw1),
        .sw15(sw15),
        .i_sr04_bcd_data(w_sr04_data),
        .i_dht_bcd_data(w_dht11_data),
        .o_time_bcd_data(w_time_data),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data),
        .led(led)
    );

    uart_interface U_UART_UNIT (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .sw({sw1, sw0}),
        .send_start(w_com_btnS),
        .time_data(w_time_data),
        .sr04_data(w_sr04_data),
        .dht_data(w_dht11_data),
        .tx(tx),
        .btnC(w_com_btnC),
        .btnR(w_com_btnR),
        .btnL(w_com_btnL),
        .btnU(w_com_btnU),
        .btnD(w_com_btnD),
        .btnS(w_com_btnS)
    );

    wire senser_starter;

    top_sr04_controller U_SR04 (
        .clk(clk),
        .rst(rst),
        .sr04_start(senser_starter),
        .echo(echo),
        .i_sw({sw1, sw0}),

        .trig(trig),
        .distance(),
        .sr04_bcd(w_sr04_data)

    );
    dht11_sensor U_DHT11 (
        .clk(clk),
        .rst(rst),
        .i_sw({sw1, sw0}),
        .dht11_start(senser_starter),
        .humi_bcd(w_dht11_data[7:0]),
        .temp_bcd(w_dht11_data[15:8]),
        .led_valid(led_valid),
        .dht11(dht11)
    );


    tick_gen_1s U_1S_TICK (
        .clk(clk),
        .rst(rst),
        .tick_1s(senser_starter)
    );
    // uart  인터페이스 추가하면서 파임피스로 센서갑 입력 추가해서 디스플레이 셀렉트 조절

endmodule


module tick_gen_1s (
    input clk,
    input rst,
    output reg tick_1s
);


    // parameter F_COUNT = 100_000_000 / 10_000_000;
    parameter F_COUNT = 100_000_000;


    reg [$clog2(F_COUNT)-1:0] conter_reg;


    always @(posedge clk, posedge rst) begin
        if (rst) begin
            conter_reg <= 0;
            tick_1s <= 0;
        end else begin
            conter_reg <= conter_reg + 1;
            if (conter_reg == F_COUNT - 1) begin
                conter_reg <= 0;
                tick_1s <= 1'b1;
            end else begin
                tick_1s <= 1'b0;
            end
        end


    end
endmodule
