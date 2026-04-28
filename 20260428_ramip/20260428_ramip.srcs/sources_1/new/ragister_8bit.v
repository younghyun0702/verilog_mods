`timescale 1ns / 1ps


module ragister_8bit (
    input clk,
    input rst,
    input [7:0] d,
    output reg [7:0] q
);

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            q <= 8'h00;
        end else begin
            q <= d;
        end
    end



endmodule
