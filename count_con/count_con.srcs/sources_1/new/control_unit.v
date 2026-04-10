`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/04/10 13:58:01
// Design Name: 
// Module Name: control_unit
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


module control_unit (
    input [2:0] sw,
    output reg rs_bnt,
    output reg clear,
    output reg mode
);

    always @(*) begin
        case (sw[2:0])
            3'b1xx:  {rs_bnt, clear, mode} = 3'b100;
            3'b01x:  {rs_bnt, clear, mode} = 3'b010;
            3'b001:  {rs_bnt, clear, mode} = 3'b001;
            default: {rs_bnt, clear, mode} = 3'bxxx;
        endcase
    end


endmodule
