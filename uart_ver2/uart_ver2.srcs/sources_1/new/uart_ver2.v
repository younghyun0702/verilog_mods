`timescale 1ns / 1ps


module uart_ver2 #(
    parameter CLK_100MHZ = 100_000_000,
    parameter BAUD_HZ = 9600 * 16,
    parameter DB_HZ = 100_000
) (
    input        clk,
    input        rst,
    input        tx_start,
    input  [7:0] tx_data,
    input        rx,
    output [7:0] rx_data,
    output       rx_done,
    output       tx_busy,
    output       tx
);

    wire w_b_tick;

    uart_rx U_URAT_RX (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .i_b_tick(w_b_tick),
        .rx_data(rx_data),
        .rx_done(rx_done)

    );

    uart_tx U_UART_TX (
        .clk     (clk),
        .rst     (rst),
        .tx_start(tx_start),
        .tx_data (tx_data),
        .i_b_tick(w_b_tick),
        .tx_busy (tx_busy),
        .tx      (tx)
    );

    baud_tick_gen #(
        .CLK_100MHZ(CLK_100MHZ),
        .TICK_HZ(BAUD_HZ)
    ) U_BAUD_TICK_GEN (
        .clk(clk),
        .rst(rst),
        .o_b_tick(w_b_tick)
    );


endmodule


module uart_tx #(
    parameter CLK_100MHZ = 100_000_000

) (
    input        clk,
    input        rst,
    input        tx_start,
    input  [7:0] tx_data,
    input        i_b_tick,
    input        tx_busy,
    output       tx
);

    parameter IDLE = 0, START = 1, DATA_TX = 2, STOP = 3;

    reg [2:0] current_state, next_state;
    reg tx_reg, tx_next;

    reg [7:0] data_reg, data_next;
    reg [2:0] bit_count_reg, bit_count_next;
    reg tx_busy_reg, tx_busy_next;
    reg [3:0] b_tick_cnt_reg, b_tick_cnt_next;

    assign tx = tx_reg;
    assign tx_busy = tx_busy_reg;

    // 상태 업데이트 블럭
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
            tx_reg <= 1'b1;
            data_reg <= 8'h00;
            bit_count_reg <= 3'b000;
            b_tick_cnt_reg <= 4'h0;
            tx_busy_reg <= 1'b0;

        end else begin
            current_state <= next_state;
            tx_reg <= tx_next;
            data_reg <= data_next;
            bit_count_reg <= bit_count_next;
            b_tick_cnt_reg <= b_tick_cnt_next;
            tx_busy_reg <= tx_busy_next;
        end
    end



    //상태 전이 블럭
    always @(*) begin
        next_state = current_state;
        b_tick_cnt_next = b_tick_cnt_reg;
        bit_count_next = bit_count_reg;
        case (current_state)
            IDLE: if (tx_start) next_state = START;

            START:
            if (i_b_tick) begin
                if (b_tick_cnt_reg == 15) begin
                    b_tick_cnt_next = 0;
                    next_state = DATA_TX;
                end else b_tick_cnt_next = b_tick_cnt_reg + 1;
            end
            DATA_TX: begin
                if (i_b_tick) begin
                    if (b_tick_cnt_reg == 15) begin
                        b_tick_cnt_next = 0;
                        bit_count_next  = bit_count_reg + 1;
                        if (bit_count_reg == 7) begin
                            next_state = STOP;
                            bit_count_next = 0;

                        end
                    end else begin
                        b_tick_cnt_next = b_tick_cnt_reg + 1;
                    end

                end
            end
            STOP: begin
                if (i_b_tick) begin
                    if (b_tick_cnt_reg == 15) begin
                        next_state = IDLE;
                        b_tick_cnt_next = 0;
                    end else b_tick_cnt_next = b_tick_cnt_reg + 1;
                end
            end
        endcase
    end

    // 출력 블럭
    always @(*) begin
        tx_next = tx_reg;
        data_next = data_reg;
        tx_busy_next = tx_busy_reg;
        case (current_state)
            IDLE: begin
                tx_busy_next = 0;
                tx_next = 1'b1;
            end
            START: begin
                tx_next = 1'b0;
                data_next = tx_data;
                tx_busy_next = 1;
            end
            DATA_TX: tx_next = data_reg[bit_count_reg];
            STOP: tx_next = 1'b1;
        endcase
    end

endmodule

module debouncer #(
    parameter CLK_100MHZ = 100_000_000,
    parameter DB_HZ = 100_000
) (
    input  clk,
    input  rst,
    input  i_btn,
    output o_btn
);

    localparam F_COUNT = CLK_100MHZ / DB_HZ;
    reg [$clog2(F_COUNT)-1:0] r_counter;
    reg clk_100khz;
    wire w_debouncer;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_counter  <= 0;
            clk_100khz <= 0;
        end else begin
            r_counter <= r_counter + 1;
            if (r_counter == F_COUNT - 1) begin
                r_counter  <= 0;
                clk_100khz <= 1;
            end else begin
                clk_100khz <= 0;
            end
        end

    end


    reg [7 : 0] sync_reg, sync_next;

    always @(posedge clk_100khz, posedge rst) begin
        if (rst) begin
            sync_reg <= 0;
        end else begin
            sync_reg <= sync_next;
        end

    end

    always @(*) begin
        sync_next = {sync_reg[6:0], i_btn};
    end

    assign w_debouncer = &sync_reg;

    reg edge_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            edge_reg <= 0;
        end else begin
            edge_reg <= w_debouncer;
        end
    end

    assign o_btn = w_debouncer & (~edge_reg);

endmodule

module baud_tick_gen #(
    parameter CLK_100MHZ = 100_000_000,
    parameter TICK_HZ = 9600 * 16
) (
    input clk,
    input rst,
    output reg o_b_tick
);

    localparam F_COUNT = CLK_100MHZ / TICK_HZ;
    localparam WIDTH = $clog2(F_COUNT) - 1;

    reg [WIDTH : 0] count_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count_reg = 0;
            o_b_tick  = 1'b0;
        end else if (count_reg == F_COUNT - 1) begin
            count_reg = 0;
            o_b_tick  = 1;
        end else begin
            count_reg = count_reg + 1;
            o_b_tick  = 0;
        end

    end

endmodule
