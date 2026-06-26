`timescale 1ns / 1ps

module tb_test_counter;

    reg        clk;
    reg        rstn;
    reg        load;
    reg  [7:0] data_in;
    reg        en;
    wire [7:0] count;
    wire       done;

    test_counter dut (
        .clk    (clk),
        .rstn   (rstn),
        .load   (load),
        .data_in(data_in),
        .en     (en),
        .count  (count),
        .done   (done)
    );

    // clock period = 20ns
    always #10 clk = ~clk;

    initial begin
        clk     = 0;
        rstn    = 0;
        load    = 0;
        data_in = 8'h00;
        en      = 0;

        // 초기 reset 구간
        #15;
        en = 1;  // 그림처럼 en 먼저 올라감

        #25;
        rstn = 1;  // reset_n 해제

        // data 준비
        #25;
        data_in = 8'h03;

        // load pulse: active-low
        // load가 0으로 내려가면서 03h 로드
        #15;
        load = 1;
        #15;

        load = 0;

        #35;


        // 이후 클럭마다 감소
        // 03h -> 02h -> 01h -> 00h -> done

        #140;
        $finish;
    end

endmodule
