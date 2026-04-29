`timescale 1ns / 1ps

module top_sr04_controller (
    input        clk,
    input        rst,
    input        btn_R,
    input        echo,
    output       trig,
    output [3:0] fnd_com,
    output [7:0] fnd_data
);


endmodule

module sr04_controller (
    input        clk,
    input        rst,
    input        sr40_start,
    input        tick_us,
    input        echo,
    output       trig,
    output [8:0] distance
);




endmodule


module tick_gen_us (
    input clk,
    input rst,
    output reg tick_us
);

    parameter F_COUNT = 100_000_000 / 1_000_000;

    reg [$clog2(F_COUNT)-1:0] conter_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            conter_reg <= 0;
            tick_us <= 0;
        end else begin
            conter_reg <= conter_reg + 1;
            if (conter_reg == F_COUNT) begin
                conter_reg <= 0;
                tick_us = 1'b1;
            end else begin
                tick_us <= 1'b0;
            end
        end

    end

endmodule
