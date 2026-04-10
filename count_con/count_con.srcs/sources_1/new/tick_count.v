`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/04/10 13:39:15
// Design Name: 
// Module Name: tick_count
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


module tick_count (
    input clk,
    input rst,
    input i_tick,
    output [13:0] o_tick_counter
);

    reg [13:0] tick_counter_reg;

    assign o_tick_counter = tick_counter_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            tick_counter_reg <= 14'd0;
        end else if (i_tick == 1'b1) begin
            if (tick_counter_reg == 14'd9999) begin
                tick_counter_reg <= 14'd0;
            end else begin
                tick_counter_reg <= tick_counter_reg + 1'b1;
            end
        end
    end
endmodule
