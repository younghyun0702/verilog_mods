`timescale 1ns / 1ps

module tb_top_sr04_controller ();
    reg        clk;
    reg        rst;
    reg        btnR;
    reg        echo;
    wire       trig;
    wire [8:0] distance;

    parameter US_DELAY = 1_000;
    parameter CM_DELAY = 60_000;

    top_sr04_controller U_SR (
        .clk(clk),
        .rst(rst),
        .btnR(btnR),
        .echo(echo),
        .trig(trig),
        .distance(distance)
    );

    always #5 clk = ~clk;

    initial begin
        // reset
        clk = 0;
        rst = 1;
        #10;

        rst = 0;
        @(negedge clk);

        btnR = 1;
        @(negedge clk);
        btnR = 0;
        @(negedge clk);


        #(CM_DELAY);
        #(CM_DELAY);
        #(CM_DELAY);

        //ehco 입력
        echo = 1;
        #CM_DELAY;
        #CM_DELAY;
        #CM_DELAY;
        #CM_DELAY;
        echo = 0;

        #CM_DELAY;
        $stop;
    end


endmodule
