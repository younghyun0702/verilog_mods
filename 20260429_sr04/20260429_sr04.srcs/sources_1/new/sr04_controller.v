`timescale 1ns / 1ps

module top_sr04_controller (
    input        clk,
    input        rst,
    input        btnR,
    input        echo,
    output       trig,
    output [3:0] fnd_com,
    output [7:0] fnd_data

);

    wire w_tick_58us, w_btnR;
    wire [8:0] w_distance;

    ila_0 ILA (
        .clk(clk),
        .probe0(w_btnR),
        .probe1(w_distance)
    );

    debouncer U_BD (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnR),
        .o_btn(w_btnR)
    );

    fnd_controller U_FND (
        .clk(clk),
        .rst(rst),
        .fnd_in({5'b0, w_distance}),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data)
    );

    sr04_controller U_SR_CONTROL (
        .clk(clk),
        .rst(rst),
        .sr04_start(w_btnR),
        .tick_58us(w_tick_58us),
        .echo(echo),
        .trig(trig),
        .distance(w_distance)
    );

    tick_gen_us U_TICK (
        .clk(clk),
        .rst(rst),
        .tick_58us(w_tick_58us)
    );

endmodule

// 시나리오 
// 1. sr04_start에 1을입력하면 strat 상태로 넘어감
// 2. trig에 출력이 1을 11us유지하고 0으로 돌악ㅁ
// 3. echo 에 입력을 유지하는 시간에 따라 distanc출력의 값을 확인
// 입력 예시 echo = 1 #58000; 58us 이기 때문에 1cm
// #58000*2

module sr04_controller (
    input            clk,
    input            rst,
    input            sr04_start,
    input            tick_58us,
    input            echo,
    output reg       trig,
    output     [8:0] distance

);

    parameter IDLE = 0, START = 1, WAIT = 2, RESPONSE = 3;

    reg [15:0] cm_cnt_reg, ms_cnt_next;
    reg [2:0] sr_state_reg, sr_state_next;
    reg [8:0] distance_reg, distance_next;

    assign distance = distance_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            sr_state_reg <= IDLE;
            cm_cnt_reg   <= 0;
            distance_reg <= 0;
        end else begin
            sr_state_reg <= sr_state_next;
            cm_cnt_reg   <= ms_cnt_next;
            distance_reg <= distance_next;
        end
    end

    always @(*) begin
        sr_state_next = sr_state_reg;
        ms_cnt_next = cm_cnt_reg;
        distance_next = distance_reg;
        trig = 0;
        case (sr_state_reg)
            IDLE: begin
                trig = 0;
                if (sr04_start) begin
                    sr_state_next = START;
                    distance_next = 0;
                end
            end
            START: begin
                trig = 1;
                if (tick_58us) begin
                    ms_cnt_next = 0;
                    trig = 0;
                    sr_state_next = WAIT;
                end
            end
            WAIT: begin
                trig = 0;
                if (echo == 1 && tick_58us) begin
                    sr_state_next = RESPONSE;
                end
            end
            RESPONSE: begin
                trig = 0;
                if (tick_58us) begin
                    ms_cnt_next = cm_cnt_reg + 1;
                    if (echo == 0) begin
                        distance_next = cm_cnt_reg + 1;
                        ms_cnt_next   = 0;
                        sr_state_next = IDLE;
                    end else if (cm_cnt_reg == 400) begin
                        distance_next = cm_cnt_reg + 1;
                        ms_cnt_next   = 0;
                        sr_state_next = IDLE;
                    end
                end
            end
        endcase
    end

endmodule


module tick_gen_us (
    input clk,
    input rst,
    output reg tick_58us
);

    // parameter F_COUNT = 100_000_000 / 10_000_000;
    parameter F_COUNT = 100_000_000 / 17_241;

    reg [$clog2(F_COUNT)-1:0] conter_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            conter_reg <= 0;
            tick_58us  <= 0;
        end else begin
            conter_reg <= conter_reg + 1;
            if (conter_reg == F_COUNT) begin
                conter_reg <= 0;
                tick_58us = 1'b1;
            end else begin
                tick_58us <= 1'b0;
            end
        end

    end

endmodule
