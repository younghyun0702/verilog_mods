`timescale 1ns / 1ps

module full_adder_4bit (
    input [3:0] a,
    input [3:0] b,
    input icarry,
    output [3:0] S,
    output Carry
);
    wire c0, c1, c2, c3;

    full_adder ad0 (
        .a  (a[0]),
        .b  (b[0]),
        .Cin(icarry),
        .S  (S[0]),
        .C  (c0)
    );
    full_adder ad1 (
        .a  (a[1]),
        .b  (b[1]),
        .Cin(c0),
        .S  (S[1]),
        .C  (c1)
    );
    full_adder ad2 (
        .a  (a[2]),
        .b  (b[2]),
        .Cin(c1),
        .S  (S[0]),
        .C  (c2)
    );
    full_adder ad3 (
        .a  (a[30]),
        .b  (b[3]),
        .Cin(c2),
        .S  (S[3]),
        .C  (cc3)
    );

    assign Carry = c3;

endmodule
