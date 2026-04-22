`timescale 1ns / 1ps

module uart #(
    parameter CLK_100MHZ = 100_000_000,
    parameter BAUD_HZ = 9600,
    parameter DB_HZ = 100_000
) (
    input        clk,
    input        rst,
    input        btnR,
    input  [7:0] tx_data,
    output       tx
);

    wire w_b_tick, w_start;

    debouncer #(
        .CLK_100MHZ(CLK_100MHZ),
        .DB_HZ(DB_HZ)
    ) U_BD (
        .clk  (clk),
        .rst  (rst),
        .i_btn(btnR),
        .o_btn(w_start)
    );

    uart_tx U_UART_TX (
        .clk     (clk),
        .rst     (rst),
        .tx_start(w_start),
        .tx_data (tx_data),
        .i_b_tick(w_b_tick),
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



module uart_tx #(
    parameter CLK_100MHZ = 100_000_000

) (
    input        clk,
    input        rst,
    input        tx_start,
    input  [7:0] tx_data,
    input        i_b_tick,
    output       tx
);

    parameter IDLE = 8, WAIT = 9, START = 10;
    parameter BIT0 = 0, BIT1 = 1, BIT2 = 2;
    parameter BIT3 = 3, BIT4 = 4, BIT5 = 5;
    parameter BIT6 = 6, BIT7 = 7, STOP = 11;

    reg [3:0] current_state, next_state;
    reg tx_reg, tx_next;

    reg [7:0] data_reg, data_next;


    assign tx = tx_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
            tx_reg <= 1'b1;
            data_reg <= 8'h00;

        end else begin
            current_state <= next_state;
            tx_reg <= tx_next;
            data_reg <= data_next;
        end
    end

    always @(*) begin
        next_state = current_state;
        case (current_state)
            IDLE:  if (tx_start) next_state = WAIT;
            WAIT:  if (i_b_tick) next_state = START;
            START: if (i_b_tick) next_state = BIT0;
            BIT0:  if (i_b_tick) next_state = BIT1;
            BIT1:  if (i_b_tick) next_state = BIT2;
            BIT2:  if (i_b_tick) next_state = BIT3;
            BIT3:  if (i_b_tick) next_state = BIT4;
            BIT4:  if (i_b_tick) next_state = BIT5;
            BIT5:  if (i_b_tick) next_state = BIT6;
            BIT6:  if (i_b_tick) next_state = BIT7;
            BIT7:  if (i_b_tick) next_state = STOP;
            STOP:  if (i_b_tick) next_state = IDLE;
        endcase
    end

    always @(*) begin
        tx_next   = tx_reg;
        data_next = data_reg;
        case (current_state)
            IDLE: tx_next = 1'b1;
            WAIT: tx_next = tx_reg;
            START: begin
                tx_next   = 1'b0;
                data_next = tx_data;
            end
            BIT0: tx_next = data_reg[0];
            BIT1: tx_next = data_reg[1];
            BIT2: tx_next = data_reg[2];
            BIT3: tx_next = data_reg[3];
            BIT4: tx_next = data_reg[4];
            BIT5: tx_next = data_reg[5];
            BIT6: tx_next = data_reg[6];
            BIT7: tx_next = data_reg[7];
            STOP: tx_next = 1'b1;
        endcase
    end

endmodule

module baud_tick_gen #(
    parameter CLK_100MHZ = 100_000_000,
    parameter TICK_HZ = 9600
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
        end else begin
            count_reg = count_reg + 1;
            o_b_tick  = 0;
            if (count_reg == F_COUNT - 1) begin
                count_reg = 0;
                o_b_tick  = 1;
            end
        end
    end

endmodule
