`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/04/21 17:40:53
// Design Name: 
// Module Name: TB_debouncer
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


module TB_debouncer ();

    reg clk, rst, i_btn;
    wire o_btn;

    debouncer #(
        .CLK_FREQ_HZ(100_000_000),  // 100MHz
        .DB_HZ      (100_000_00)    // 100k
    ) U0 (
        .clk  (clk),
        .rst  (rst),
        .i_btn(i_btn),
        .o_btn(o_btn)
    );

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        rst   = 1;
        i_btn = 0;

        repeat (3) @(negedge clk);
        rst = 0;
        #10;

        i_btn = 1;
        #(5 * 1000);

        i_btn = 0;

        #20;
        $stop;
    end



endmodule
