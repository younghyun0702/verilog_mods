`timescale 1ns / 1ps

module test_edgede (
    input  clk,
    input  rst,
    input  async_in,
    output pulse
);

    reg sync0, sync1, sync2;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            sync0 <= 0;
            sync1 <= 0;
            sync2 <= 0;
        end else begin
            sync0 <= async_in;
            sync1 <= sync0;
            sync2 <= sync1;

        end
    end

    assign pulse = sync1 & ~sync2;

endmodule
