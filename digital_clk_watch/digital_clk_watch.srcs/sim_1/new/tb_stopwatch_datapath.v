`timescale 1ns / 1ps

module tb_stopwatch_datapath ();
    reg clk;
    reg rst;
    reg i_clear, i_mode, i_runstop;
    wire [6:0] msec;
    wire [5:0] sec;
    wire [5:0] min;
    wire [4:0] hour;


    parameter SEC_DELAY = 1000000;
    parameter MIN_DELAY = SEC_DELAY * 60;

    stopwatch_datapath U0 (
        .clk(clk),
        .rst(rst),
        .i_clear(i_clear),
        .i_mode(i_mode),
        .i_runstop(i_runstop),
        .msec(msec),
        .sec(sec),
        .min(min),
        .hour(hour)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        i_clear = 0;
        i_mode = 0;
        i_runstop = 0;
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);

        rst = 0;
        i_runstop = 1;
        repeat (1) @(SEC_DELAY);




        i_clear = 1;
        @(negedge clk);
        @(negedge clk);
        i_clear = 0;



        i_mode  = 1;
        #(MIN_DELAY);

        $finish;
        $stop;
    end


endmodule
