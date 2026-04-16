`timescale 1ns / 100ps

module tb_updown_10000_cnt ();
    reg clk;
    reg rst;
    reg btnD, btnL, btnR;
    wire [3:0] fnd_com;
    wire [7:0] fnd_data;

    //디바운스 회로 주기 100kHz에서 1MHz로 수정
    //버튼 입력 후 디바운신된 신호 1번 입력 밭으려면 클럭의 800주기 동안 기다리기 
    //따라서 버튼 1회 입력을 800nS로 정의
    //
    //입력 후 카운팅 동작 을 보기 위해서 0.1초에 1 카운팅 인점을 고려하여 100_000_000당 1카운트 
    //하지만 이것또한 가시성을 위해 카운팅 주파수 10Hz에서 1000Hz로 모듈 수정
    //따라서 한 카운팅 1_000_000

    parameter PUSH = 100;  //버튼 입력 시간
    parameter CNT1 = 1_000_000;  // 1카운트 정의
    parameter TIME = 10;  // 100MHz 한주기 정의

    updown_10000_cnt UUT (
        .clk (clk),
        .rst (rst),
        .btnD(btnD),
        .btnL(btnL),
        .btnR(btnR)
    );

    wire [ 1:0] state;
    wire [13:0] count;
    wire db_btnD, db_btnL, db_btnR;

    assign state   = UUT.U_control.current_state;
    assign count   = UUT.U_DATAPATH.tick_counter;
    assign db_btnD = UUT.U_BD_MODE.o_btn;
    assign db_btnL = UUT.U_BD_CLEAR.o_btn;
    assign db_btnR = UUT.U_BD_RUNSTOP.o_btn;

    always #5 clk = ~clk;  // 100MHz clock


    initial begin

        //1.초기화
        clk  = 0;  // 클럭 0으로 초기화
        rst  = 1;
        btnD = 0;
        btnL = 0;
        btnR = 0;
        @(negedge clk);
        @(negedge clk);
        rst  = 0;

        //2.UP COUNT 시작
        btnR = 1;
        repeat (100) @(negedge clk);
        btnR = 0;
        #(CNT1 * 20);

        //3. STOP기능 RUN에서 STOP으로 복귀
        btnR = 1;
        repeat (100) @(negedge clk);
        btnR = 0;
        #(CNT1 * 10);

        //4. 카운트 모드 줜환 MODE -> ~MODE 로 변화
        btnD = 1;
        repeat (100) @(negedge clk);
        btnD = 0;
        #(CNT1 * 5);

        //5.DOWN COUNT 시작
        btnR = 1;
        repeat (100) @(negedge clk);
        btnR = 0;
        #(CNT1 * 30);
        ////////
        //STOP기능 RUN에서 STOP으로 복귀
        btnR = 1;
        repeat (100) @(negedge clk);
        btnR = 0;
        ////////

        //6. CLEAR 동작
        btnL = 1;
        repeat (100) @(negedge clk);
        btnL = 0;

        repeat (1200) @(negedge clk);
        //7. 우선순위 확인
        btnL = 1;
        btnD = 1;
        repeat (100) @(negedge clk);
        btnL = 0;
        btnD = 0;

        @(negedge clk);
        @(negedge clk);

        //7. 우선순위 확인
        btnL = 1;
        btnD = 1;
        btnR = 1;
        repeat (100) @(negedge clk);
        btnL = 0;
        btnD = 0;
        btnR = 0;

        @(negedge clk);
        @(negedge clk);

        //7. 우선순위 확인
        btnL = 1;
        btnD = 1;
        btnR = 1;
        repeat (100) @(negedge clk);
        btnL = 0;
        btnD = 0;
        btnR = 0;


        repeat (800) @(negedge clk);
        //7. 우선순위 확인
        btnL = 1;
        btnD = 1;
        btnR = 1;
        repeat (100) @(negedge clk);
        btnL = 0;
        btnD = 0;
        btnR = 0;

        repeat (800) @(negedge clk) $stop;
    end

    /*
    initial begin
        clk = 0;  // 클럭 0으로 초기화
        // 시나리오 순서로 검증 
        #20;
        // 초기화
        rst   = 1;
        sw[2] = 0;
        sw[1] = 0;
        sw[0] = 1;
        // 업카운팅 동작
        #25;
        rst   = 0;
        sw[2] = 0;
        sw[1] = 0;
        sw[0] = 1;  // run모드
        #(SEC * 2);  //2초카운팅 기다림

        //stop 동작 확인
        sw[0] = 0;
        #(5 * SEC_0_1);  // stop모드

        //업카운트 
        sw[0] = 1;
        #(3 * SEC_0_1);  //다시 RUN

        // 다운카운팅 동작
        rst   = 0;
        sw[2] = 1;  // 다운 카운팅 모드
        sw[1] = 0;
        sw[0] = 1;  // run모드
        #(SEC * 3);  // 3초간 카운팅

        //다운 카운트 stop
        sw[0] = 0;
        #(5 * SEC_0_1);  // stop모드
        sw[0] = 1;
        #(3 * SEC_0_1);  //다시 RUN

        // 다운 동작 중 클리어 동작 확인
        sw[1] = 1;
        #(3 * SEC_0_1);  // 0.3초간 클리어 유지
        //클리어 후 카운팅
        sw[1] = 0;
        #(3 * SEC_0_1);

        //업 카운팅 5초간
        sw[2] = 0;
        sw[1] = 0;
        sw[0] = 1;  // run모드
        #(SEC);  //5초카운팅 기다림

        // 업 동작 중 클리어 동작 확인
        sw[1] = 1;
        #(3 * SEC_0_1);  // 0.3초간 클리어 유지
        //클리어 후 카운팅
        sw[1] = 0;
        #(3 * SEC_0_1);

        $stop;
    end
    */

    /*
    //1,2,3기능확인
    initial begin
        clk = 0;  // 클럭 0으로 초기화
        // 시나리오 순서로 검증 
        #20;
        // 1. 보드의 rst 버튼에 의한 리셋
        rst   = 1;
        sw[2] = 0;
        sw[1] = 0;
        sw[0] = 1;
        #25;
        rst = 0;
        #20;
        rst = 1;
        #20;

        // 2.TICK 10Hz 생성 확인 및 카운팅 동작 확인
        rst   = 0;
        sw[2] = 0;
        sw[1] = 0;
        sw[0] = 1;  // run모드
        #(SEC / 5);  //0.2초카운팅 기다림
        #20;
        rst = 1;
        #20;
        rst   = 0;
        sw[2] = 0;
        sw[1] = 0;
        sw[0] = 1;  // run모드
        #(SEC / 5);  //0.2초 카운팅 기다림


        $stop;
    end
*/



    /*
    initial begin
        // 초기상태 정의
        clk   = 0;
        rst   = 1;  // 0으로 리셋
        sw[2] = 1;  // 
        sw[1] = 1;  // sw리셋 하지 않은 상태
        sw[0] = 1;  // 카운트 stop 상태

        // 카운트 시작
        #20;  // 20ns 대기하여 리셋 해제
        rst   = 0;
        sw[2] = 0;  // 카운트 모드 (업모드)  
        sw[1] = 0;  // sw리셋 하지 않은 상태
        sw[0] = 1;  // 카운트 start 상태

        #100_000_000;  // 

        rst   = 0;
        sw[2] = 0;  // 카운트 모드 (업모드)
        sw[1] = 0;  // sw리셋 하지 않은 상태
        sw[0] = 0;  // 카운트 stop 상태

        #10_000;// 1ms 대기하여 멈춘 상태에서의 FND 출력 확인           

        rst   = 0;
        sw[2] = 1;  // 카운트 모드 (다운모드)
        sw[1] = 0;  // sw리셋 하지 않은 상태
        sw[0] = 1;  // 카운트 start 상태

        #1000; // 400ms 대기 (10000 카운트가 10Hz에서 1초에 10번 증가하므로 400ms는 충분히 카운트가 진행될 시간)           

        rst   = 0;
        sw[2] = 1;  // 카운트 모드 (다운모드)
        sw[1] = 0;  // sw리셋 하지 않은 상태
        sw[0] = 0;  // 카운트 stop 상태

        #1_000; //1ms 대기하여 멈춘 상태에서의 FND 출력 확인           

        rst   = 0;
        sw[2] = 1;  //카운트 모드 (다운모드)
        sw[1] = 0;  //sw리셋 하지 않은 상태
        sw[0] = 1;  //start 상태

        #1_000_000;  //1ms 대기

        rst   = 0;
        sw[2] = 1;  //카운트 모드 (다운모드)
        sw[1] = 1;  //sw리셋 상태로 변경하여 카운트 리셋
        sw[0] = 1;  //start 상태

        #1_000_000;  //1ms 대기
        sw[2] = 0;  //카운트 모드 (업모드)
        sw[1] = 0;  //sw리셋 하지 않은 상태
        sw[0] = 1;  //start 상태

        #400_000_000; //400ms 대기 (10000 카운트가 10Hz에서 1초에 10번 증가하므로 400ms는 충분히 카운트가 진행될 시간)           

        sw[2] = 0;  //카운트 모드 (업모드)
        sw[1] = 1;  //sw리셋 상태로 변경하여 카운트 리셋
        sw[0] = 1;  //start 상태
        $stop;
        $finish;
    end
*/

endmodule
