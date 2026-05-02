`timescale 1ns / 1ps

module top_uart_fifo_watch ( 


);
   timepiecer U_SW_WT(
    .clk(clk),
    .rst(rst),
    .btnR(),
    .btnL(),
    .btnU(),
    .btnD(),
    .sw0(),
    .sw1(),
    .sw15(),
    .fnd_com(),
    .fnd_data(),
    .led
);

// uart  인터페이스 추가하면서 파임피스로 센서갑 입력 추가해서 디스플레이 셀렉트 조절

endmodule
