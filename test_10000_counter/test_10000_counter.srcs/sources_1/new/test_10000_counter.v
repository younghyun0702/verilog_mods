`timescale 1ns / 1ps

module test_10000_counter #(

    parameter FCOUNT = 10000,
    parameter WIDTH  = $clog2(FCOUNT) - 1

) (
    input clk,
    input rst,
    input mode,
    output [WIDTH:0] count
);


    reg [WIDTH:0] cnt_reg;

    assign count = cnt_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            cnt_reg <= 0;
        end else begin
            if (!mode) begin
                if (cnt_reg == FCOUNT - 1) begin
                    cnt_reg <= 0;
                end else begin
                    cnt_reg <= cnt_reg + 1;
                end
            end else begin
                if (cnt_reg == 0) begin
                    cnt_reg <= FCOUNT - 1;
                end else begin
                    cnt_reg <= cnt_reg - 1;
                end
            end
        end
    end
endmodule
