`timescale 1ns / 1ps

module tb_ragister_8bit ();

    reg clk, rst;
    reg  [7:0] d;
    wire [7:0] q;

    ragister_8bit UREG (
        .clk(clk),
        .rst(rst),
        .d  (d),
        .q  (q)
    );

    always #5 clk = ~clk;

    integer i;

    initial begin
        clk = 0;
        rst = 0;

        d   = 8'h00;
        #10;
        rst = 0;
        @(posedge clk);

        for (i = 0; i < 256; i = i + 1) begin
            #1;
            d = i;
            @(posedge clk);
        end

        @(negedge clk);

        $stop;



    end

endmodule
