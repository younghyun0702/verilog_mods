`timescale 1ns / 1ps

module tb_top_uart_fifo_watch;

    reg clk;
    reg rst;
    reg rx;

    reg btnU, btnD, btnL, btnR;
    reg sw0, sw1, sw15;
    reg echo;

    wire trig;
    wire tx;
    wire [3:0] fnd_com;
    wire [7:0] fnd_data;
    wire [1:0] led;
    wire led_valid;
    wire dht11;

    assign dht11 = 1'bz;

    // 파라미터 오버라이드 없이 DUT 인스턴스
    top_uart_fifo_watch dut (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .btnU(btnU),
        .btnD(btnD),
        .btnL(btnL),
        .btnR(btnR),
        .sw0(sw0),
        .sw1(sw1),
        .sw15(sw15),
        .echo(echo),
        .trig(trig),
        .tx(tx),
        .fnd_com(fnd_com),
        .fnd_data(fnd_data),
        .led(led),
        .led_valid(led_valid),
        .dht11(dht11)
    );

    always #5 clk = ~clk;  // 100MHz

    localparam BAUD_PERIOD = 104_167;  // 9600bps, ns 기준

    task uart_send_byte;
        input [7:0] data;
        integer i;
        begin
            rx = 1'b0;  // start bit
            #(BAUD_PERIOD);

            for (i = 0; i < 8; i = i + 1) begin
                rx = data[i];  // LSB first
                #(BAUD_PERIOD);
            end

            rx = 1'b1;  // stop bit
            #(BAUD_PERIOD);
        end
    endtask

    task uart_read_byte;
        output [7:0] data;
        integer i;
        begin
            wait (tx == 1'b0);  // start bit
            #(BAUD_PERIOD + BAUD_PERIOD / 2);

            for (i = 0; i < 8; i = i + 1) begin
                data[i] = tx;
                #(BAUD_PERIOD);
            end

            #(BAUD_PERIOD);  // stop bit
        end
    endtask

    reg [7:0] tx_data_from_dut;

    initial begin
        clk  = 0;
        rst  = 1;
        rx   = 1;

        btnU = 0;
        btnD = 0;
        btnL = 0;
        btnR = 0;

        sw0  = 0;
        sw1  = 0;
        sw15 = 0;

        echo = 0;

        #1000;
        rst = 0;
        #1000;

        $display("====================================");
        $display("UART command test start");
        $display("====================================");

        uart_send_byte("U");
        #20000;
        $display("Sent U command");

        uart_send_byte("D");
        #20000;
        $display("Sent D command");

        uart_send_byte("L");
        #20000;
        $display("Sent L command");

        uart_send_byte("R");
        #20000;
        $display("Sent R command");

        uart_send_byte("C");
        #20000;
        $display("Sent C command");

        $display("====================================");
        $display("UART TX response test");
        $display("====================================");

        sw1 = 0;
        sw0 = 0;

        uart_send_byte("S");
        $display("Sent S command");

        repeat (8) begin
            uart_read_byte(tx_data_from_dut);
            $display("TX DATA = %h, ASCII = %c", tx_data_from_dut,
                     tx_data_from_dut);
        end

        $display("====================================");
        $display("SR04 trig connection test");
        $display("====================================");

        sw1 = 1;
        sw0 = 0;

        // 내부 sensor starter를 기다리면 오래 걸리므로 강제 펄스 발생
        force dut.senser_starter = 1'b1;
        #100;
        release dut.senser_starter;

        #200000;

        if (trig) $display("PASS: trig signal observed");
        else
            $display(
                "CHECK: trig not observed. Check SR04 i_sw connection or trig pulse timing."
            );

        $display("====================================");
        $display("Simulation finished");
        $display("====================================");

        #100000;
        $finish;
    end

endmodule
