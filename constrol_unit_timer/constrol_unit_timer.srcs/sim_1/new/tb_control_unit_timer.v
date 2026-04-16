`timescale 1ns / 1ps
module tb_control_unit_timer ();

    reg clk, rst, BTN_D, BTN_L, BTN_R;
    wire run_stop, clear, mode;

    control_unit_timer U0 (
        .clk(clk),
        .rst(rst),
        .BTN_D(BTN_D),
        .BTN_L(BTN_L),
        .BTN_R(BTN_R),
        .o_run_stop(run_stop),
        .o_clear(clear),
        .o_mode(mode)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        #20;
        rst = 0;
        #20;

        BTN_D = 1;
        #1_000_000;
        BTN_D = 0;
        BTN_R = 1;
        #100;
        BTN_R = 0;
        BTN_L = 1;
        #100;


        $stop;
    end



endmodule
