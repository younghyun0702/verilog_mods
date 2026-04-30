`timescale 1ns / 1ps

module ascii_sender (
    input        clk,
    input        rst,
    input        i_tx_full,
    input        i_btnS,
    input [ 1:0] sw,
    input [23:0] i_time_data,
    // input [10:0] i_sensor_sr04,
    // input [10:0] i_sensor_sr04,

    output [7:0] push_data,
    output       push
);

    parameter ZERO = 8'h30;
    parameter ONE = 8'h31;
    parameter TWO = 8'h32;
    parameter THREE = 8'h33;
    parameter FOUR = 8'h34;
    parameter FIVE = 8'h35;
    parameter SIX = 8'h36;
    parameter SEVEN = 8'h37;
    parameter EIGHT = 8'h38;
    parameter NINE = 8'h39;
    parameter COLON = 8'h3A;
    parameter EQUALS = 8'h3D;

    parameter IDLE = 0, FULL = 1, DATA_PUSH = 2;

    reg [7:0] setup_data_reg [0:15];
    reg [7:0] setup_data_next[0:15];
    reg [1:0] state_reg, state_next;
    reg [3:0] byte_count_reg, byte_count_next;
    reg [7:0] data_reg, data_next;
    reg push_reg, push_next;
    reg [3:0] count_data;

    assign push_data = data_reg;
    assign push = push_reg;
    integer i, j;

    task data2ascii;
        input [23:0] data;
        integer n;
        // sw = 00 : 00 : 00 : 00
        for (n = 0; n < 16; n = n + 1) begin
            if ((n == 2) || (n == 5) || (n == 8) || (n == 11)) begin
                if ((n == 2)) setup_data_next[n] = EQUALS;
                else setup_data_next[n] = COLON;
            end else begin
                //bcd 값 이용하는것이 좋아보임
                //센서값 또한 bcd로
                // case()




                // endcase
            end
        end
    endtask



    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state_reg <= IDLE;
            byte_count_reg <= 0;
            data_reg <= 0;
            push_reg <= 0;
            for (i = 0; i < 16; i = i + 1) begin
                setup_data_reg[i] <= 8'b0;
            end
        end else begin
            state_reg <= state_next;
            byte_count_reg <= byte_count_next;
            data_reg <= data_next;
            push_reg <= push_next;
            for (i = 0; i < 16; i = i + 1) begin
                setup_data_reg[i] <= setup_data_next[i];
            end
        end
    end


    always @(*) begin

        state_next = state_reg;
        push_next = push_reg;
        byte_count_next = byte_count_reg;
        data_next = data_reg;
        for (j = 0; j < 16; j = j + 1) begin
            setup_data_next[j] = setup_data_reg[j];
        end

        case (sw)
            2'b00: begin
                count_data = 4'd15;
            end
            2'b01: begin
                count_data = 4'd15;
            end
            2'b10: begin
                count_data = 4'd10;  /*초음파*/
            end
            2'b11: begin
                count_data = 4'd10;  /*온습도*/
            end

        endcase

        case (state_reg)
            IDLE: begin
                data_next = 0;
                push_next = 0;
                if (i_btnS && !i_tx_full) begin
                    state_next = DATA_PUSH;
                    byte_count_next = 0;
                    push_next = 1;

                end
            end
            DATA_PUSH: begin
                if (!i_tx_full) begin
                    byte_count_next = byte_count_reg + 1;
                    data_next = setup_data_reg[byte_count_reg];
                    if (byte_count_reg == count_data) begin
                        state_next = IDLE;
                        push_next  = 0;
                    end
                end else begin
                    push_next = 0;
                end

            end
            FULL: begin
                state_next = state_reg;
                push_next  = 0;
                if (i_tx_full) begin
                    state_next = DATA_PUSH;
                    push_next  = 1;
                end
            end
        endcase
    end





endmodule
