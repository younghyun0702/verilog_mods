`timescale 1ns / 1ps

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
