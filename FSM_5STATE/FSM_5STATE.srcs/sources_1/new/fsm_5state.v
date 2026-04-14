`timescale 1ns / 1ps

module fsm_5state (
    input        clk,
    input        rst,
    input  [2:0] sw,
    output [2:0] led
);

    parameter [2:0] STATE_A = 3'b001, 
                    STATE_B = 3'b010, 
                    STATE_C = 3'b011, 
                    STATE_D = 3'b100,    
                    STATE_E = 3'b101;


    reg [2:0] current_state, next_state;
    reg [2:0] led_reg, led_next;

    assign led = led_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            current_state <= STATE_A;
            led_reg <= 3'b000;
        end else begin
            current_state <= next_state;
            led_reg <= led_next;
        end
    end

    // next state Combinational Logic
    always @(*) begin
        next_state = current_state;
        led_next   = led_reg;
        case (current_state)
            STATE_A: begin
                //led_next = 3'b000;
                if (sw == 3'b001) begin
                    led_next = 3'b000;
                    next_state = STATE_B;
                end else if (sw == 3'b010) begin
                    next_state = STATE_C;
                end
            end
            STATE_B: begin
                //led_next = 3'b001;
                if (sw == 3'b010) begin
                    led_next = 3'b001;
                    next_state = STATE_C;
                end
            end
            STATE_C: begin
                //led_next = 3'b010;
                if (sw == 3'b100) begin
                    led_next = 3'b010;
                    next_state = STATE_D;
                end
            end
            STATE_D: begin
                //led_next = 3'b111;
                if (sw == 3'b000) begin
                    led = 
                    next_state = STATE_A;
                end else if (sw == 3'b001) begin
                    next_state = STATE_B;
                end else if (sw == 3'b111) begin
                    next_state = STATE_E;
                end
            end
            STATE_E: begin
                if (sw == 3'b000) begin
                    next_state = STATE_A;
                end
            end
        endcase
    end

endmodule
