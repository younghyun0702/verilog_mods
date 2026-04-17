`timescale 1ns / 1ps

module control_unit_timer (
    input            clk,
    input            rst,
    input            BTN_D,
    input            BTN_L,
    input            BTN_R,
    input            BTN_U,
    input      [3:0] sw,
    output reg       o_run_stop,
    output reg       o_clear,
    output           o_mode,
    output           o_led
);

    parameter STOP = 2'b00;
    parameter RUN = 2'b01;
    parameter MODE = 2'b10;
    parameter CLEAR = 2'b11;

    reg mode_state = 0;
    reg [1:0] current_state, next_state;

    assign o_mode = mode_state;
    assign o_led  = sw;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= STOP;
            mode_state <= 0;
        end else begin
            current_state <= next_state;
            if (current_state == MODE) mode_state <= ~mode_state;
            else mode_state <= mode_state;
        end
    end
    //CL
    always @(*) begin
        next_state = current_state;
        case (current_state)
            STOP: begin
                if (BTN_R) next_state = RUN;
                else if (BTN_L) next_state = CLEAR;
                else if (BTN_D) next_state = MODE;
            end
            RUN: if (BTN_R) next_state = STOP;

            MODE: next_state = STOP;

            CLEAR: next_state = STOP;

        endcase
    end

    always @(*) begin
        o_run_stop = 0;
        o_clear    = 0;
        case (current_state)
            STOP: begin
                o_run_stop = 0;
                o_clear    = 0;
            end
            RUN: begin
                o_run_stop = 1;
            end
            CLEAR: begin
                o_clear = 1;
            end

        endcase
    end
endmodule

