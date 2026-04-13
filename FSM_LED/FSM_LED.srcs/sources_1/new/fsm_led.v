`timescale 1ns / 1ps

module fsm_led (
    input clk,
    input rst,
    input sw,
    output [1:0] led
);

    parameter STATE_A = 1'b0, STATE_B = 1'b1;

    // state register
    reg current_state, next_state;
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            current_state <= STATE_A;
        end else begin
            current_state <= next_state;
        end
    end

    // next state Combinational Logic
    always @(*) begin
        case (current_state)
            STATE_A: begin
                if (sw == 1) begin
                    next_state = STATE_B;
                end else begin
                    next_state = current_state;
                end
            end
            STATE_B: begin
                if (sw == 0) begin
                    next_state = STATE_A;
                end else begin
                    next_state = current_state;
                end
            end
            default: next_state = next_state;
        endcase
    end

    assign led = (current_state == STATE_B) ? 2'b01 : 2'b10;





endmodule
