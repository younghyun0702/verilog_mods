`timescale 1ns / 1ps


module tb_uart_ver2 ();
    reg          clk;
    reg          rst;
    reg          btn;
    reg  [7 : 0] tx_data;
    wire         tx;

    uart_ver2 #(
        .CLK_100MHZ(100_000_000),
        .BAUD_HZ(9600),
        .DB_HZ(100_000_0)
    ) U_UART (
        .clk(clk),
        .rst(rst),
        .btnR(btn),
        .tx_data(tx_data),
        .tx(tx)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;

        repeat (10) @(negedge clk);
        rst = 0;
        #100;

        tx_data = 8'b10101111;
        repeat (5) @(negedge clk);

        btn = 1;
        repeat (1000) @(negedge clk);
        btn = 0;

        repeat (150000) @(negedge clk);

        btn = 1;
        tx_data = 8'b10101100;
        repeat (1000) @(negedge clk);
        btn = 0;

        repeat (150000) @(negedge clk);

        $finish;
        $stop;

    end

endmodule
