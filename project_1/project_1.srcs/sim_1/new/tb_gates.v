`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/04/10 10:48:55
// Design Name: 
// Module Name: tb_gates
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_gates ();
    integer intA, intB, intC, intD, d, f, c;




    initial begin
        intA = -12 / 4;
        intB = -'d12 / 4;
        intC = -'sd12 / 4;
        intD = -(4'sd12) / 4;

        $display("%d, %d, %d, %d", intA, intB, intC, intD);

        d = 4'b1000;
        f = 4'b1000;

        if (d == f) c = 1;
        else c = 0;

        $display("%d", c);




        $stop;


    end


endmodule
