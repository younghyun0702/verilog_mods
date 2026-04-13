`timescale 1ns / 1ps


module tick_gen_10Hz #(
    parameter integer CLK_FREQ_HZ = 100_000_000,
    parameter integer TICK_HZ = 10
) (
    input clk,
    input rst,
    output reg o_tick
);

    localparam integer TICK_COUNT = CLK_FREQ_HZ / TICK_HZ;
    localparam integer COUNTER_WIDTH = (TICK_COUNT <= 1) ? 1 : $clog2(
        TICK_COUNT
    );

    reg [COUNTER_WIDTH-1:0] counter_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg <= {COUNTER_WIDTH{1'b0}};
            o_tick      <= 1'b0;
        end else begin
            o_tick <= 1'b0;
            if (counter_reg == TICK_COUNT - 1) begin
                counter_reg <= {COUNTER_WIDTH{1'b0}};
                o_tick      <= 1'b1;  // 논블로킹이라 동시 구현
            end else begin
                counter_reg <= counter_reg + 1'b1;
            end
        end
    end
endmodule
