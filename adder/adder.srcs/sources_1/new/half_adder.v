`timescale 1ns / 1ps

module half_adder (
    input  a,
    input  b,
    output S,
    output C
);

    assign {C, S} = a + b;

endmodule
