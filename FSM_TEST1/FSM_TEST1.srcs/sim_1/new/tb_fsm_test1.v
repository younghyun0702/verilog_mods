`timescale 1ns / 1ps


module tb_fsm_test1 ();

    reg clk, rst;
    reg  [1:0] sw;
    wire [2:0] led;

    fsm_test1 U0 (
        .clk(clk),
        .rst(rst),
        .sw (sw),
        .led(led)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        #50;
        rst = 0;
        sw  = 2'b01;
        #20;
        sw = 2'b00;
        #20;
        sw = 2'b11;
        #20;

        //state chang
        sw = 2'b10;
        #20;
        sw = 2'b00;
        #10;

        // state chang
        sw = 2'b11;
        #30;

        //STATE CHANG MORE
        sw = 2'b01;
        #20;
        $stop;



    end




endmodule
