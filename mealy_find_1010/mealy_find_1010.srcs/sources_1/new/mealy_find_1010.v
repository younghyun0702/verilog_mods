`timescale 1ns / 1ps

module mealy_find_1010 (
    input  clk,
    input  rst,
    input  din_bit,
    output dout_bit
);
    reg [3:0] state_reg, next_state;

    parameter A = 4'hA;
    parameter B = 4'hB;
    parameter C = 4'hC;
    parameter D = 4'hD;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state_reg <= A;
        end else begin
            state_reg <= next_state;
        end
    end

    always @(*) begin
        next_state = state_reg;
        case (state_reg)
            A: begin
                if (din_bit == 1) next_state = B;
            end
            B: begin
                if (din_bit == 0) next_state = C;
            end
            C: begin
                if (din_bit == 1) next_state = D;
                else next_state = A;
            end
            D: begin
                if (din_bit == 0) next_state = A;
                else next_state = B;
            end
        endcase
    end

    assign dout_bit = (din_bit == 0) && (state_reg == D);


endmodule
