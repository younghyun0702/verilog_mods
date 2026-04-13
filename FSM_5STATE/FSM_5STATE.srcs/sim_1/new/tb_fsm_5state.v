`timescale 1ns / 1ps


module tb_fsm_5state ();

    reg clk, rst;
    reg  [2:0] sw;
    wire [2:0] led;

    fsm_5state U0 (
        .clk(clk),
        .rst(rst),
        .sw (sw),
        .led(led)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        #20;
        rst = 0;
        #20;
        sw = 3'b000;  // A
        #20;
        //?��계방?�� ?��바�??
        sw = 3'b001;  // A -> B
        #20;
        sw = 3'b010;  // B -> C
        #20;
        sw = 3'b100;  // C -> D 
        #20;
        sw = 3'b111;  // D -> E
        #20;
        sw = 3'b000;  // E -> A
        #60;

        //A -> C -> D -> A ?��?��
        sw = 3'b010;  // A -> C
        #20;
        sw = 3'b100;  // C -> D
        #20;
        sw = 3'b000;  // D -> A
        #60;

        //A -> C -> D -> B ?��?��
        sw = 3'b010;  // A -> C
        #20;
        sw = 3'b100;  // C -> D
        #20;
        sw = 3'b001;  // D -> B
        #60;



        $stop;



    end




endmodule
