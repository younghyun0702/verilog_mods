`timescale 1ns / 1ps

module tb_uart_interface ();

    parameter CLK_PERIOD = 10;
    parameter BAUD_RATE = 9600;
    parameter BAUD_PERIOD = 1_000_000_000 / BAUD_RATE;

    reg clk;
    reg rst;
    reg rx;
    reg send_start;
    reg [1:0] sw;
    reg [23:0] time_data;
    reg [11:0] sr04_data;
    reg [15:0] dht_data;

    wire tx;
    wire btnC, btnR, btnL, btnU, btnD, btnS;

    integer pass_count;
    integer fail_count;

    uart_interface DUT (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .send_start(send_start),
        .sw(sw),
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

    always #(CLK_PERIOD / 2) clk = ~clk;

    // ===============================
    // PC -> FPGA UART 송신 task
    // ===============================
    task send_uart_byte;
        input [7:0] data;
        integer i;
        begin
            rx = 1'b1;
            #(BAUD_PERIOD);

            rx = 1'b0;  // start bit
            #(BAUD_PERIOD);

            for (i = 0; i < 8; i = i + 1) begin
                rx = data[i];
                #(BAUD_PERIOD);
            end

            rx = 1'b1;  // stop bit
            #(BAUD_PERIOD);
        end
    endtask

    // ===============================
    // FPGA -> PC UART 수신 task
    // tx 라인을 TB가 읽음
    // ===============================
    task read_uart_byte;
        output [7:0] data;
        integer i;
        begin
            data = 8'h00;

            // start bit 기다림
            wait (tx == 1'b0);
            $display($time);
            // start bit 중앙으로 이동
            #(BAUD_PERIOD / 2);
            // data bit 중앙으로 이동
            #(BAUD_PERIOD);
            for (i = 0; i < 8; i = i + 1) begin
                data[i] = tx;
                #(BAUD_PERIOD);
            end

            // stop bit 시간
            #(BAUD_PERIOD);
        end
    endtask

    // ===============================
    // 결과 출력용 task
    // ===============================
    task check_result;
        input condition;
        input [200*8:1] msg;
        begin
            if (condition) begin
                pass_count = pass_count + 1;
                $display("[PASS] %s", msg);
            end else begin
                fail_count = fail_count + 1;
                $display("[FAIL] %s", msg);
            end
        end
    endtask

    // ===============================
    // 버튼 pulse 확인
    // ===============================
    task check_rx_command;
        input [7:0] cmd;
        input [5:0] expected_btn;
        reg [5:0] btn_value;
        integer k;
        begin
            send_uart_byte(cmd);

            btn_value = 6'b000000;

            // decoder 출력 pulse를 기다리기 위해 일정 시간 감시
            for (k = 0; k < 200000; k = k + 1) begin
                @(posedge clk);
                if ({btnC, btnR, btnL, btnU, btnD, btnS} != 6'b000000) begin
                    btn_value = {btnC, btnR, btnL, btnU, btnD, btnS};
                end
            end

            if (btn_value == expected_btn) begin
                pass_count = pass_count + 1;
                $display("[PASS] RX cmd %c -> btn = %b", cmd, btn_value);
            end else begin
                fail_count = fail_count + 1;
                $display("[FAIL] RX cmd %c -> btn = %b, expected = %b", cmd,
                         btn_value, expected_btn);
            end

        end
        // 다음 테스트 시작 전 안정화
    endtask

    // ===============================
    // TX 문자열 확인
    // ===============================
    task check_tx_string_time;
        input [1:0] mode_sw;
        input [23:0] data;
        reg [7:0] rx_byte;
        reg [7:0] expected[0:12];
        integer i;
        begin
            if (mode_sw == 2'b00) begin
                expected[0] = "W";
                expected[1] = "T";
            end else begin
                expected[0] = "S";
                expected[1] = "W";
            end

            expected[2] = "=";
            expected[3] = data[23:20] + 8'h30;
            expected[4] = data[19:16] + 8'h30;
            expected[5] = ":";
            expected[6] = data[15:12] + 8'h30;
            expected[7] = data[11:8] + 8'h30;
            expected[8] = ":";
            expected[9] = data[7:4] + 8'h30;
            expected[10] = data[3:0] + 8'h30;
            expected[11] = "s";
            expected[12] = 8'h0D;

            sw = mode_sw;
            time_data = data;

            @(posedge clk);
            send_start = 1;
            @(posedge clk);
            send_start = 0;

            for (i = 0; i < 13; i = i + 1) begin
                read_uart_byte(rx_byte);

                if (rx_byte == expected[i]) begin
                    pass_count = pass_count + 1;
                    $display("[PASS] TX byte[%0d] = %h (%c)", i, rx_byte,
                             rx_byte);
                end else begin
                    fail_count = fail_count + 1;
                    $display("[FAIL] TX byte[%0d] = %h, expected = %h", i,
                             rx_byte, expected[i]);
                end
            end
            wait (tx == 1'b1);
            #(BAUD_PERIOD * 3);
        end
    endtask

    task check_tx_string_sr04;
        input [11:0] data;
        reg [7:0] rx_byte;
        reg [7:0] expected[0:10];
        integer i;
        begin
            expected[0] = "S";
            expected[1] = "R";
            expected[2] = "0";
            expected[3] = "4";
            expected[4] = "=";
            expected[5] = data[11:8] + 8'h30;
            expected[6] = data[7:4] + 8'h30;
            expected[7] = data[3:0] + 8'h30;
            expected[8] = "c";
            expected[9] = "m";
            expected[10] = 8'h0D;

            sw = 2'b10;
            sr04_data = data;

            @(posedge clk);
            send_start = 1;
            @(posedge clk);
            send_start = 0;

            for (i = 0; i < 11; i = i + 1) begin
                read_uart_byte(rx_byte);

                if (rx_byte == expected[i]) begin
                    pass_count = pass_count + 1;
                    $display("[PASS] SR04 TX byte[%0d] = %h (%c)", i, rx_byte,
                             rx_byte);
                end else begin
                    fail_count = fail_count + 1;
                    $display("[FAIL] SR04 TX byte[%0d] = %h, expected = %h", i,
                             rx_byte, expected[i]);
                end
            end
            $display("1", $time);

        end
    endtask

    initial begin
        clk = 0;
        rst = 1;
        rx = 1;
        send_start = 0;
        sw = 0;
        time_data = 0;
        sr04_data = 0;
        dht_data = 0;

        pass_count = 0;
        fail_count = 0;

        #100;
        rst = 0;
        #100;

        $display("====================================");
        $display("TEST 1 : RX command check");
        $display("====================================");

        check_rx_command("C", 6'b100000);
        check_rx_command("R", 6'b010000);
        check_rx_command("L", 6'b001000);
        check_rx_command("U", 6'b000100);
        check_rx_command("D", 6'b000010);
        check_rx_command("S", 6'b000001);
        check_rx_command("X", 6'b000000);

        $display("====================================");
        $display("TEST 2 : TX time data check");
        $display("====================================");

        check_tx_string_time(2'b00, 24'h123456);

        $display("====================================");
        $display("TEST 3 : TX stopwatch data check");
        $display("====================================");
        $display("2", $time);


        check_tx_string_time(2'b01, 24'h001530);
        $display("3", $time);


        $display("====================================");
        $display("TEST 4 : TX SR04 data check");
        $display("====================================");

        check_tx_string_sr04(12'h123);

        $display("====================================");
        $display("SIMULATION RESULT");
        $display("PASS = %0d", pass_count);
        $display("FAIL = %0d", fail_count);
        $display("====================================");

        #1000;

        $finish;
        $stop;
    end

endmodule


// `timescale 1ns / 1ps

// module tb_uart_interface ();

//     parameter CLK_FREQ = 100_000_000;
//     parameter BAUD_RATE = 9600;
//     parameter CLK_PERIOD = 10;
//     parameter BAUD_PERIOD = 1_000_000_000 / BAUD_RATE;

//     reg clk;
//     reg rst;
//     reg rx;
//     reg [1:0] sw;
//     reg send_start;
//     reg [23:0] time_data;
//     reg [11:0] sr04_data;
//     reg [15:0] dht_data;

//     wire tx;
//     wire btnC, btnR, btnL, btnU, btnD, btnS;
// uart_interface
//     uart_interface DUT (
//         .clk(clk),
//         .rst(rst),
//         .rx(rx),
//         .sw(sw),
//         .send_start(send_start),
//         .time_data(time_data),
//         .sr04_data(sr04_data),
//         .dht_data(dht_data),
//         .tx(tx),
//         .btnC(btnC),
//         .btnR(btnR),
//         .btnL(btnL),
//         .btnU(btnU),
//         .btnD(btnD),
//         .btnS(btnS)
//     );

//     always #5 clk = ~clk;

//     // PC가 FPGA로 UART 1바이트 보내는 task
//     task send_uart_byte;
//         input [7:0] data;
//         integer i;
//         begin
//             // idle
//             rx = 1'b1;
//             #(BAUD_PERIOD);

//             // start bit
//             rx = 1'b0;
//             #(BAUD_PERIOD);

//             // data bit, LSB first
//             for (i = 0; i < 8; i = i + 1) begin
//                 rx = data[i];
//                 #(BAUD_PERIOD);
//             end

//             // stop bit
//             rx = 1'b1;
//             #(BAUD_PERIOD);
//         end
//     endtask

//     // 버튼 pulse 확인용
//     task check_btn;
//         input [7:0] char;
//         begin
//             send_uart_byte(char);
//             #(BAUD_PERIOD * 2);

//             $display("[%0t] RX char = %c | C=%b R=%b L=%b U=%b D=%b S=%b",
//                      $time, char, btnC, btnR, btnL, btnU, btnD, btnS);
//         end
//     endtask

//     // send_start 1클럭 pulse
//     task send_start_pulse;
//         begin
//             @(posedge clk);
//             send_start = 1'b1;
//             @(posedge clk);
//             send_start = 1'b0;
//         end
//     endtask

//     initial begin
//         clk = 0;
//         rst = 1;
//         rx = 1;
//         sw = 0;
//         send_start = 0;
//         time_data = 24'h123456;
//         sr04_data = 12'h123;
//         dht_data = 16'h2537;

//         #(CLK_PERIOD * 10);
//         rst = 0;
//         #(CLK_PERIOD * 10);

//         $display("====================================");
//         $display("TEST 1 : RX single command");
//         $display("====================================");

//         check_btn("C");
//         check_btn("R");
//         check_btn("L");
//         check_btn("U");
//         check_btn("D");
//         check_btn("S");

//         $display("====================================");
//         $display("TEST 2 : RX lowercase command");
//         $display("====================================");

//         check_btn("c");
//         check_btn("r");
//         check_btn("l");
//         check_btn("u");
//         check_btn("d");
//         check_btn("s");

//         $display("====================================");
//         $display("TEST 3 : RX undefined command");
//         $display("====================================");

//         check_btn("X");

//         $display("====================================");
//         $display("TEST 4 : RX continuous command");
//         $display("====================================");

//         send_uart_byte("C");
//         send_uart_byte("R");
//         send_uart_byte("L");
//         send_uart_byte("U");
//         send_uart_byte("D");
//         send_uart_byte("S");

//         #(BAUD_PERIOD * 5);

//         $display("====================================");
//         $display("TEST 5 : TX time data, sw = 00");
//         $display("====================================");

//         sw = 2'b00;
//         time_data = 24'h123456;
//         send_start_pulse();

//         #(BAUD_PERIOD * 20);

//         $display("====================================");
//         $display("TEST 6 : TX stopwatch data, sw = 01");
//         $display("====================================");

//         sw = 2'b01;
//         time_data = 24'h001530;
//         send_start_pulse();

//         #(BAUD_PERIOD * 20);

//         $display("====================================");
//         $display("TEST 7 : TX SR04 data, sw = 10");
//         $display("====================================");

//         sw = 2'b10;
//         sr04_data = 12'h123;
//         send_start_pulse();

//         #(BAUD_PERIOD * 20);

//         $display("====================================");
//         $display("TEST 8 : TX DHT11 data, sw = 11");
//         $display("====================================");

//         sw = 2'b11;
//         dht_data = 16'h2537;
//         send_start_pulse();

//         #(BAUD_PERIOD * 35);

//         $display("====================================");
//         $display("TEST 9 : TX while RX command");
//         $display("====================================");

//         sw = 2'b00;
//         time_data = 24'h235959;
//         send_start_pulse();

//         #(BAUD_PERIOD * 3);
//         send_uart_byte("C");
//         send_uart_byte("R");

//         #(BAUD_PERIOD * 30);

//         $display("====================================");
//         $display("TEST DONE");
//         $display("====================================");

//         $stop;
//     end

// endmodule
