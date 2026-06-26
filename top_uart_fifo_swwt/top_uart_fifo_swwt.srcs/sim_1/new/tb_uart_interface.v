`timescale 1ns / 1ps

module tb_uart_interface ();

    reg clk;
    reg rst;
    reg rx;
    reg [1:0] sw;
    reg send_start;
    reg [23:0] time_data;
    reg [11:0] sr04_data;
    reg [15:0] dht_data;

    wire tx;
    wire btnC, btnR, btnL, btnU, btnD, btnS;

    // 시뮬레이션 속도 단축용
    parameter CLK_PERIOD = 10;
    parameter F_COUNT_SIM = 4;
    parameter BIT_PERIOD = CLK_PERIOD * F_COUNT_SIM * 16;

    uart_interface dut (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .sw(sw),
        .send_start(send_start),
        .time_data(time_data),
        .sr04_data(sr04_data),
        .dht_data(dht_data),
        .tx(tx),
        .btnC(btnC),
        .btnR(btnR),
        .btnL(btnL),
        .btnU(btnU),
        .btnD(btnD),
        .btnS(btnS)
    );

    // 내부 baud tick 속도 줄이기
    defparam dut.U_UART.U_BAUD_TICK_GEN.F_COUNT = F_COUNT_SIM;
    defparam dut.U_UART.U_BAUD_TICK_GEN.WIDTH   = 2;

    always #(CLK_PERIOD / 2) clk = ~clk;

    // UART RX로 1바이트 전송
    task UART_RX_SEND;
        input [7:0] data;
        integer i;
        begin
            rx = 1'b1;
            #(BIT_PERIOD);

            // start bit
            rx = 1'b0;
            #(BIT_PERIOD);

            // data bit, LSB first
            for (i = 0; i < 8; i = i + 1) begin
                rx = data[i];
                #(BIT_PERIOD);
            end

            // stop bit
            rx = 1'b1;
            #(BIT_PERIOD);
        end
    endtask

    // send_start 1클럭 pulse
    task SEND_START_PULSE;
        begin
            @(posedge clk);
            send_start = 1'b1;
            @(posedge clk);
            send_start = 1'b0;
        end
    endtask

    // 버튼 출력 확인용
    task CHECK_BTN;
        input [5:0] expected;
        input [8*20-1:0] name;
        integer i;
        begin
            for (i = 0; i < 500; i = i + 1) begin
                @(posedge clk);
                if ({btnC, btnR, btnL, btnU, btnD, btnS} == expected) begin
                    $display("[PASS] %s button pulse detected", name);
                    i = 500;
                end
            end
        end
    endtask

    initial begin
        clk = 0;
        rst = 1;
        rx = 1;
        sw = 2'b00;
        send_start = 0;
        time_data = 24'h123456;
        sr04_data = 12'h123;
        dht_data = 16'h2536;

        // =====================================================
        // Scenario 1. Reset 검증
        // =====================================================
        $display("====================================");
        $display("Scenario 1 : Reset Verification");
        $display("====================================");

        #100;
        rst = 0;
        #100;

        if (tx == 1'b1) $display("[PASS] TX idle state is HIGH");
        else $display("[FAIL] TX idle state is not HIGH");

        // =====================================================
        // Scenario 2. RX 단일 명령 검증
        // =====================================================
        $display("====================================");
        $display("Scenario 2 : RX ASCII Command Test");
        $display("====================================");

        UART_RX_SEND("C");
        CHECK_BTN(6'b100000, "C");

        UART_RX_SEND("R");
        CHECK_BTN(6'b010000, "R");

        UART_RX_SEND("L");
        CHECK_BTN(6'b001000, "L");

        UART_RX_SEND("U");
        CHECK_BTN(6'b000100, "U");

        UART_RX_SEND("D");
        CHECK_BTN(6'b000010, "D");

        UART_RX_SEND("S");
        CHECK_BTN(6'b000001, "S");

        // =====================================================
        // Scenario 3. 잘못된 입력 검증
        // =====================================================
        $display("====================================");
        $display("Scenario 3 : Invalid RX Input Test");
        $display("====================================");

        UART_RX_SEND("A");
        #1000;

        if ({btnC, btnR, btnL, btnU, btnD, btnS} == 6'b000000)
            $display("[PASS] Invalid input ignored");
        else $display("[FAIL] Invalid input generated button signal");

        // =====================================================
        // Scenario 4. 연속 RX 입력 검증
        // =====================================================
        $display("====================================");
        $display("Scenario 4 : Continuous RX Test");
        $display("====================================");

        UART_RX_SEND("C");
        UART_RX_SEND("R");
        UART_RX_SEND("L");
        UART_RX_SEND("U");
        UART_RX_SEND("D");
        UART_RX_SEND("S");

        #5000;
        $display("[INFO] Continuous RX input test finished");

        // =====================================================
        // Scenario 5. TX 시계 데이터 검증
        // =====================================================
        $display("====================================");
        $display("Scenario 5 : TX Time Data Test");
        $display("====================================");

        sw = 2'b00;
        time_data = 24'h123456;
        SEND_START_PULSE();

        #(BIT_PERIOD * 200);
        $display("[INFO] WT time data transmission finished");

        // =====================================================
        // Scenario 6. TX 스톱워치 데이터 검증
        // =====================================================
        $display("====================================");
        $display("Scenario 6 : TX Stopwatch Data Test");
        $display("====================================");

        sw = 2'b01;
        time_data = 24'h010203;
        SEND_START_PULSE();

        #(BIT_PERIOD * 20);
        $display("[INFO] SW stopwatch data transmission finished");

        // =====================================================
        // Scenario 7. TX 센서 데이터 검증
        // =====================================================
        $display("====================================");
        $display("Scenario 7 : TX Sensor Data Test");
        $display("====================================");

        sw = 2'b10;
        dht_data = 16'h2536;
        SEND_START_PULSE();

        #(BIT_PERIOD * 13);
        $display("[INFO] DHT data transmission finished");

        sw = 2'b11;
        sr04_data = 12'h123;
        SEND_START_PULSE();

        #(BIT_PERIOD * 12);
        $display("[INFO] SR04 data transmission finished");

        // =====================================================
        // Scenario 8. Loopback 검증용 안내
        // =====================================================
        $display("====================================");
        $display("Scenario 8 : Loopback");
        $display("For loopback test, connect tx to rx externally");
        $display("====================================");

        #1000;
        $display("====================================");
        $display("UART Interface Verification Finished");
        $display("====================================");

        $finish;
    end

endmodule
