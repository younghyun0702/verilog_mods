`timescale 1ns / 1ps

module test_counter (
    input            clk,
    input            rstn,
    input            load,
    input      [7:0] data_in,
    input            en,
    output     [7:0] count,
    output reg       done
);

    parameter IDLE = 0, LOAD = 1, CNT = 2;

    reg [1:0] state_reg, state_next;
    reg [7:0] cnt_reg, cnt_next;

    assign count = cnt_reg;

    always @(posedge clk, posedge en, negedge rstn) begin
        if (en) begin
            if (!rstn) begin
                state_reg <= IDLE;
                cnt_reg   <= 0;
            end else begin
                state_reg <= state_next;
                cnt_reg   <= cnt_next;
            end
        end
    end


    always @(*) begin
        cnt_next = cnt_reg;
        state_next = state_reg;
        done = 0;
        if (en) begin
            case (state_reg)
                IDLE: begin
                    if (load) begin
                        state_next = LOAD;
                    end
                end

                LOAD: begin
                    state_next = CNT;
                    cnt_next   = data_in;
                end

                CNT: begin
                    if (cnt_reg == 0) begin
                        state_next = IDLE;
                        done = 1;
                    end else begin
                        cnt_next = cnt_reg - 1;
                    end

                end

            endcase
        end
    end

endmodule
