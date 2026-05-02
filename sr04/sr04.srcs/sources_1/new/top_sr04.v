`timescale 1ns / 1ps


module top_sr04_controller (
    input        clk,
    input        rst,
    input        btnR,
    input        echo,
    output       trig,
    output [8:0] distance,
    output [3:0] sr04_bcd_1,
    output [3:0] sr04_bcd_10,
    output [3:0] sr04_bcd_100,
    output [3:0] sr04_bcd_1000


    //output [3:0] fnd_com,
    //output [7:0] fnd_data


);


    wire w_tick_58us, w_btnR;
    wire [8:0] w_distance;
    assign distance = w_distance;

    //ila_0 ILA (
    //    .clk(clk),
    //    .probe0(w_btnR),
    //    .probe1(w_distance)
    //);


    button_debounce U_BD (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnR),
        .o_btn(w_btnR)
    );


    //fnd_controller U_FND (
    //    .clk(clk),
    //    .rst(rst),
    //    .fnd_in({5'b0, w_distance}),
    //    .fnd_com(fnd_com),
    //    .fnd_data(fnd_data)
    //);
    sr04_bcd U_SR04_BCD (
        .distance_in(w_distance),
        .distance_1(sr04_bcd_1),
        .distance_10(sr04_bcd_10),
        .distance_100(sr04_bcd_100),
        .distance_1000(sr04_bcd_1000)


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


module sr04_bcd (
    input [8:0] distance_in,
    output [3:0] distance_1,
    output [3:0] distance_10,
    output [3:0] distance_100,
    output [3:0] distance_1000


);


    assign distance_1 = distance_in % 10;  // digit 1
    assign distance_10 = (distance_in / 10) % 10;  // digit 10
    assign distance_100 = (distance_in / 100) % 10;  // digit 100
    assign distance_1000 = (distance_in / 1000) % 10;  // digit 1000
endmodule


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


    reg [15:0] cm_cnt_reg, cm_cnt_next;
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
            cm_cnt_reg   <= cm_cnt_next;
            distance_reg <= distance_next;
        end
    end


    always @(*) begin
        sr_state_next = sr_state_reg;
        cm_cnt_next = cm_cnt_reg;
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
                    cm_cnt_next = 0;
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
                    cm_cnt_next   = cm_cnt_reg + 1;
                    distance_next = cm_cnt_reg + 1;
                    if (echo == 0) begin
                        cm_cnt_next   = 0;
                        sr_state_next = IDLE;
                    end else if (cm_cnt_reg >= 400) begin
                        distance_next = cm_cnt_reg;
                        cm_cnt_next   = 0;
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