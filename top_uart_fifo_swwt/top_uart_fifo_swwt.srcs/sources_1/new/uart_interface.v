`timescale 1ns / 1ps

module uart_interface (
    input         clk,
    input         rst,
    input         rx,
    input  [ 1:0] sw,
    input         send_start,
    input  [23:0] time_data,
    input  [11:0] sr04_data,
    input  [15:0] dht_data,
    output        tx,
    output        btnC,
    output        btnR,
    output        btnL,
    output        btnU,
    output        btnD,
    output        btnS
);

    wire [7:0] w_rx_data, w_btn_ascii_data;
    wire [7:0] w_tx_data, w_push_data;
    wire w_rx_done, w_rx_fifo_empty, w_rx_pop;
    wire w_tx_start, w_tx_push, w_tx_fifo_full, w_tx_busy;


    uart U_UART (
        .clk(clk),
        .rst(rst),
        .tx_start(~w_tx_start),
        .tx_data(w_tx_data),
        .rx(rx),
        .rx_data(w_rx_data),
        .rx_done(w_rx_done),
        .tx_busy(w_tx_busy),
        .tx(tx)
    );

    fifo U_FUFO_RX (
        .clk(clk),
        .rst(rst),
        .push_data(w_rx_data),
        .push(w_rx_done),
        .pop(w_rx_pop),
        .pop_data(w_btn_ascii_data),
        .full(),
        .empty(w_rx_fifo_empty)
    );

    fifo #(
        .DEPTH(25)
    ) U_FUFO_TX (
        .clk(clk),
        .rst(rst),
        .push_data(w_push_data),
        .push(w_tx_push),
        .pop(~w_tx_busy),
        .pop_data(w_tx_data),
        .full(w_tx_fifo_full),
        .empty(w_tx_start)
    );

    ascii_decoder U_AS_DECODER (
        .clk(clk),
        .rst(rst),
        .rx_fifo_empty(w_rx_fifo_empty),
        .btn_ascii_data(w_btn_ascii_data),
        .pop(w_rx_pop),
        .btnC(btnC),
        .btnR(btnR),
        .btnL(btnL),
        .btnU(btnU),
        .btnD(btnD),
        .btnS(btnS)
    );

    ascii_sender U_AS_SENDER (
        .clk(clk),
        .rst(rst),
        .tx_fifo_full(w_tx_fifo_full),
        .send_start(send_start),
        .sw(sw),
        .i_time_data(time_data),
        .i_sensor_sr04(sr04_data),
        .i_sensor_dht11(dht_data),
        .push_data(w_push_data),
        .push(w_tx_push)
    );





endmodule
