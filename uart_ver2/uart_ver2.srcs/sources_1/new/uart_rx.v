`timescale 1ns / 1ps

module uart_rx (
    input clk,
    input rst,
    input rx,
    input i_b_tick,
    output [7:0] rx_data,
    output rx_done

);

    parameter IDLE = 0, START = 1, DATA_RX = 2, STOP = 3;

    reg [1:0] current_state, next_state;
    reg [4:0] b_tick_reg, b_tick_next;
    reg [2:0] bit_cnt_reg, bit_cnt_next;
    reg [7:0] data_reg, data_next;
    reg rx_done_reg, rx_done_next;

    assign rx_done = rx_done_reg;
    assign rx_data = data_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
            data_reg      <= 0;
            bit_cnt_reg   <= 0;
            b_tick_reg    <= 0;
            rx_done_reg   <= 0;
        end else begin
            current_state <= next_state;
            data_reg      <= data_next;
            bit_cnt_reg   <= bit_cnt_next;
            b_tick_reg    <= b_tick_next;
            rx_done_reg   <= rx_done_next;
        end
    end


    always @(*) begin
        next_state   = current_state;
        bit_cnt_next = bit_cnt_reg;
        b_tick_next  = b_tick_reg;
        case (current_state)
            IDLE:
            if (i_b_tick) begin
                if (rx == 0) next_state = START;
            end
            START: begin
                if (b_tick_reg == 7) begin
                    next_state   = DATA_RX;
                    b_tick_next  = 0;
                    bit_cnt_next = 0;
                end else begin
                    b_tick_next = b_tick_reg + 1;
                end
            end
            DATA_RX:
            if (i_b_tick) begin
                if (b_tick_reg == 15) begin
                    b_tick_next = 0;
                    if (bit_cnt_reg == 7) begin
                        next_state = STOP;
                    end else begin
                        bit_cnt_next = bit_cnt_reg + 1;
                    end
                end else begin
                    b_tick_next = b_tick_reg + 1;
                end
            end
            STOP:
            if (i_b_tick) begin
                if (b_tick_reg == 23) begin
                    next_state  = IDLE;
                    b_tick_next = 0;
                end else begin
                    b_tick_next = b_tick_reg + 1;
                end

            end
        endcase

    end

    always @(*) begin
        data_next = data_reg;
        rx_done_next = rx_done_reg;

        case (current_state)
            IDLE: rx_done_next = 0;
            START: begin
                data_next = 8'h00;
            end
            DATA_RX:
            if (i_b_tick) begin
                if (b_tick_reg == 15) begin
                    data_next = {rx, data_reg[7:1]};
                end
            end

            STOP:
            if (i_b_tick) begin

                if (b_tick_reg == 23) rx_done_next = 1;
            end
        endcase

    end


endmodule
