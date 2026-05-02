`timescale 1ns / 1ps

module dht11_sensor (
    input clk,
    input rst,
    input dht11_start,
    output [7:0] humi_bcd,
    output [7:0] temp_bcd,
    output led_valid,
    inout dht11
);

    wire w_tick_us;
    wire [7:0] w_humi_dec, w_temp_dec;
    wire [3:0] w_hum_digit_1, w_hum_digit_10;
    wire [3:0] w_temp_digit_1, w_temp_digit_10;


    assign humi_bcd = {w_hum_digit_10, w_hum_digit_1};
    assign temp_bcd = {w_temp_digit_10, w_temp_digit_1};

    digit_splitter U_HUM_DIGIT_SPLIT (
        .digit_in(w_humi_dec),
        .digit_1 (w_hum_digit_1),
        .digit_10(w_hum_digit_10)
    );

    digit_splitter U_TEMP_DIGIT_SPLIT (
        .digit_in(w_temp_dec),
        .digit_1 (w_temp_digit_1),
        .digit_10(w_temp_digit_10)
    );

    tick_gen_us U_DHT11_TICK_GEN_US (
        .clk(clk),
        .rst(rst),
        .tick_us(w_tick_us)
    );


    dht11_controller U_DHT11_CNTL (
        .clk        (clk),
        .rst        (rst),
        .dht11_start(dht11_start),
        .tick_us    (w_tick_us),
        .humidity   (w_humi_dec),
        .temperature(w_temp_dec),
        .valid      (led_valid),    // for check sum
        .dht11      (dht11)
    );



endmodule

module digit_splitter (
    input  [7:0] digit_in,  //관련된 입력 14bit로
    output [3:0] digit_1,
    output [3:0] digit_10
);
    assign digit_1  = digit_in % 10;  // digit 1
    assign digit_10 = (digit_in / 10) % 10;  // digit 10

endmodule

module dht11_controller (
    input        clk,
    input        rst,
    input        dht11_start,
    input        tick_us,
    output [7:0] humidity,
    output [7:0] temperature,
    output       valid,        // for check sum
    inout        dht11
);


    parameter IDLE = 0, START = 1, WAIT = 2, SYNCL = 3, SYNCH = 4;
    parameter DATA_SYNC = 5, DATA_COUNT = 6, DATA_DECISION = 7;
    parameter STOP = 8;

    reg [3:0] c_state, n_state;
    reg [5:0] bit_cnt_reg, bit_cnt_next;  // receive bit counter
    reg [$clog2(19_000)-1:0]
        tick_cnt_reg, tick_cnt_next;  // general tick counter
    reg out_sel_reg, out_sel_next;  // dht11 io 3state control
    reg dht11_reg, dht11_next;  // dht11 output drive

    reg [39:0] data_reg, data_next;

    // dht11 output 3state control
    assign dht11 = (out_sel_reg) ? dht11_reg : 1'bz;

    assign valid = (data_reg[7:0] == (data_reg[39:32] + data_reg[31:24] + data_reg [23:16] + data_reg[15:8])) ? 1:0;

    assign humidity = data_reg[39:32];
    assign temperature = data_reg[23:16];


    always @(posedge clk, posedge rst) begin
        if (rst) begin
            c_state <= IDLE;
            bit_cnt_reg <= 0;
            tick_cnt_reg <= 0;
            out_sel_reg <= 1'b1;  // default output mode 
            dht11_reg <= 1'b1;  // default high state
            data_reg <= 0;
        end else begin
            c_state <= n_state;
            bit_cnt_reg <= bit_cnt_next;
            tick_cnt_reg <= tick_cnt_next;
            out_sel_reg <= out_sel_next;
            dht11_reg <= dht11_next;
            data_reg <= data_next;
        end
    end

    always @(*) begin
        n_state = c_state;
        bit_cnt_next = bit_cnt_reg;
        tick_cnt_next = tick_cnt_reg;
        out_sel_next = out_sel_reg;
        dht11_next = dht11_reg;
        data_next = data_reg;

        case (c_state)
            IDLE: begin
                dht11_next   = 1'b1;
                out_sel_next = 1'b1;
                if (dht11_start) begin
                    tick_cnt_next = 0;
                    bit_cnt_next = 0;
                    n_state = START;
                end
            end
            START: begin
                dht11_next = 1'b0;
                if (tick_us) begin
                    if (tick_cnt_reg > 19_000) begin
                        tick_cnt_next = 0;
                        n_state = WAIT;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            WAIT: begin
                dht11_next = 1'b1;
                if (tick_us) begin
                    if (tick_cnt_reg > 30) begin
                        tick_cnt_next = 0;
                        n_state = SYNCL;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            SYNCL: begin
                // output is high impedence "z"
                out_sel_next = 1'b0;
                if (tick_us) begin
                    if ((tick_cnt_reg > 40) && (dht11)) begin
                        tick_cnt_next = 0;
                        n_state = SYNCH;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            SYNCH: begin
                if (tick_us) begin
                    if ((tick_cnt_reg > 40) && (!dht11)) begin
                        tick_cnt_next = 0;
                        n_state = DATA_SYNC;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            DATA_SYNC: begin
                if (tick_us) begin
                    if (dht11) begin
                        tick_cnt_next = 0;
                        n_state = DATA_COUNT;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            DATA_COUNT: begin
                if (tick_us) begin
                    if (!dht11) begin
                        n_state = DATA_DECISION;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end
            end
            DATA_DECISION: begin
                if (tick_cnt_reg > 45) begin
                    data_next = {
                        data_reg[38:0], 1'b1
                    };  // 45us보다 길면 '1'로 판단
                end else begin
                    data_next = {
                        data_reg[38:0], 1'b0
                    };  // 45us보다 짧으면 '0'으로 판단
                end

                bit_cnt_next  = bit_cnt_reg + 1;
                tick_cnt_next = 0;

                if (bit_cnt_reg == 39) begin
                    n_state = STOP;
                end else begin
                    n_state = DATA_SYNC;
                end
            end
            STOP: begin
                if (tick_us) begin
                    if (tick_cnt_reg > 50) begin
                        tick_cnt_next = 0;
                        n_state = IDLE;
                    end else begin
                        tick_cnt_next = tick_cnt_reg + 1;
                    end
                end

            end
        endcase
    end

endmodule

module tick_gen_us (
    input      clk,
    input      rst,
    output reg tick_us
);
    parameter F_COUNT = 100_000_000 / 1_000_000;
    reg [$clog2(F_COUNT)-1:0] counter_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            counter_reg <= 0;
            tick_us <= 0;
        end else begin
            counter_reg <= counter_reg + 1;
            if (counter_reg == F_COUNT - 1) begin
                counter_reg <= 0;
                tick_us <= 1'b1;
            end else begin
                tick_us <= 1'b0;
            end
        end

    end
endmodule



