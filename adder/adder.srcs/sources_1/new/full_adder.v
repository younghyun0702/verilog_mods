`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/04/10 12:50:11
// Design Name: 
// Module Name: full_adder
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


module full_adder (
    input  a,
    input  b,
    input  Cin,
    output S,
    output C
);
    wire s1, c1, c2;

    half_adder U1 (
        .a(a),
        .b(b),
        .S(s1),
        .C(c1)
    );
    half_adder U2 (
        .a(s1),
        .b(Cin),
        .S(S),
        .C(c2)
    );

    or U3 (C, c1, c2);

endmodule
