`timescale 1ns / 1ps

module tb_fifo_ascii_sender ();

    reg clk, rst;
    reg btnS;
    reg [1:0] sw;
    reg [23:0]  time_data;
    reg [11:0]  sr04_data;
    reg [15:0]  dht_data;

    wire [7:0] w_push_data;
    wire [7:0] pop_data;
    wire    empty;

    parameter DEPTH = 4;



    ascii_sender U_SEMD (
        .clk(clk),
        .rst(rst),
        .i_tx_full(w_full),
        .i_btnS(btnS),
        .sw(sw),
        .i_time_data(time_data),
        .i_sensor_sr04(sr04_data),
        .i_sensor_dht11(dht_data),
        .push_data(w_push_data),
        .push(w_push)
    );


    fifo #(
        .DEPTH(DEPTH),
        .BIT_WIDTH(($clog2(DEPTH) - 1))
    ) U_FIFO (
        .clk(clk),
        .rst(rst),
        .push_data(w_push_data),
        .push(w_push),
        .pop(empty),
        .pop_data(pop_data),
        .full(w_full),
        .empty(empty)
    );

    always #5 clk = ~clk;


    /*
입력 
시계 21:30:58s

초음파 123 cm

dht 
온도 27 도씨
슴도 40 %

*/
    initial begin
        clk = 0;
        rst = 1;
        btnS = 0;
        sw = 0;
        time_data = 0;
        sr04_data = 0;
        dht_data = 0;
        #10;
        rst = 0;
        @(posedge clk);

        // 값 입력 현재 시계모드
        time_data = 24'h213058;
        sr04_data = 12'h123;
        dht_data  = 16'h2740;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);

        // 스타트 디바운싱 입력
        btnS = 1;
        #10;
        btnS = 0;





        #100;
        $stop;

    end


endmodule
