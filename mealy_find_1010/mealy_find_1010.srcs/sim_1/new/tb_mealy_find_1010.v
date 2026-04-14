`timescale 1ns / 1ps

module tb_mealy_find_1010 ();
    reg [11 : 0] data;  //시뮬레이션 데이터
    reg clk, rst;
    reg din_bit;
    wire dout_bit;
    wire [3:0] state;
    ////
    //      01_1010_1011_00 비트를 입력하여  A (재자리) -> B-> B-> C -> D -> A -> B -> C -> D -> B -> C -> A
    //                                                               (출력 = 1)
    ////



    mealy_find_1010 U0 (
        .clk(clk),
        .rst(rst),
        .din_bit(din_bit),
        .dout_bit(dout_bit)
    );
    integer i;
    assign state = U0.state_reg;

    always #5 clk = ~clk;

    initial begin
        clk  = 0;
        rst  = 1;
        data = 12'b01_1010_1011_00;
        #10;
        rst = 0;

        for (i = 0; i < 12; i = i + 1) begin
            @(negedge clk);
            din_bit = data[11-i];
        end


        $stop;
    end


endmodule
