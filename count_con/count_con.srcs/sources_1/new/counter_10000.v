`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/04/10 13:46:54
// Design Name: 
// Module Name: counter_10000
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


module counter_10000 #(
    parameter integer CLK_FREQ_HZ = 100_000_000,
    parameter integer TICK_HZ = 10,
    parameter integer FND_SCAN_HZ = 1000
) (
    input clk,
    input rst,
    output [3:0] fnd_com,
    output [7:0] fnd_data
);
    wire [13:0] w_tick_counter;

    fnd_controller #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .SCAN_HZ(FND_SCAN_HZ)
    ) U_FND_CNTL (
        .clk(clk),
        .rst(rst),
        .fnd_in(w_tick_counter),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );


    data_path #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .TICK_HZ(TICK_HZ)
    ) U_DATAPATH (
        .clk(clk),
        .rst(rst),
        .tick_counter(w_tick_counter)
    );

endmodule
