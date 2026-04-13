`timescale 1ns / 1ps

module fsm_test1 (
    input            clk,
    input            rst,
    input      [1:0] sw,
    output reg [2:0] led
);

    parameter STATE_A = 2'b00, STATE_B = 2'b01, STATE_C = 2'b10;



    reg [1:0] current_state, next_state;
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
                if (sw == 2'b01) begin
                    next_state = STATE_B;
                end else begin
                    next_state = current_state;
                end
            end
            STATE_B: begin
                if (sw == 2'b10) begin
                    next_state = STATE_C;
                end else begin
                    next_state = current_state;
                end
            end
            STATE_C: begin
                if (sw == 2'b11) begin
                    next_state = STATE_A;
                end else begin
                    next_state = current_state;
                end
            end
            default: next_state = next_state;
        endcase
    end

    always @(*) begin
        case (current_state)
            STATE_A: led = 3'b001;
            STATE_B: led = 3'b010;
            STATE_C: led = 3'b100;
            default: led = 3'b000;
        endcase
    end





endmodule
