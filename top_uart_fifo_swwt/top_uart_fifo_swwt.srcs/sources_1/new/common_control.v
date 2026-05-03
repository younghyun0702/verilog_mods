`timescale 1ns / 1ps

module common_control (
    input clk,
    input rst,
    input [1:0] i_sw,
    input i_btnR,
    output reg o_display_mode
);

    always @(posedge clk or posedge rst) begin
        if (rst) begin  // reset이면 timepiece=HH:MM, timer=SS:MS 기본값으로 초기화
            o_display_mode <= ~i_sw[0];
        end else if (i_btnR) begin  // btnR short가 들어오면 HH:MM <-> SS:MS 토글
            if (i_sw == 2'b11) o_display_mode <= 0;
            else o_display_mode <= ~o_display_mode;
        end
    end

endmodule
