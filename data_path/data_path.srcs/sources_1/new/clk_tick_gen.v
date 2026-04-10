`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/04/10 13:21:54
// Design Name: 
// Module Name: clk_tick_gen
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


module clk_tick_gen (
    input clk,
    input rst,
    output reg o_tick
);
    reg [$clog2(100_000_000/10) - 1 : 0] counter_reg;

    a


endmodule
