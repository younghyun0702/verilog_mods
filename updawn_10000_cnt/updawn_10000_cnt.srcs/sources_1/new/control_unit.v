`timescale 1ns / 1ps



module control_unit (
    input [2:0] sw,
    output run_bnt,
    output rst,
    output mode
);
    

    assign {mode, rst, run_bnt} = sw[2:0];

endmodule
