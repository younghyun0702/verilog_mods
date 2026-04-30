`timescale 1ns / 1ps


module debouncer #(
    parameter CLK_100MHZ = 100_000_000,
    parameter DB_HZ = 100_000
) (
    input  clk,
    input  rst,
    input  i_btn,
    output o_btn
);

    localparam F_COUNT = CLK_100MHZ / DB_HZ;
    reg [$clog2(F_COUNT)-1:0] r_counter;
    reg clk_100khz;
    wire w_debouncer;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            r_counter  <= 0;
            clk_100khz <= 0;
        end else begin
            r_counter <= r_counter + 1;
            if (r_counter == F_COUNT - 1) begin
                r_counter  <= 0;
                clk_100khz <= 1;
            end else begin
                clk_100khz <= 0;
            end
        end

    end


    reg [7 : 0] sync_reg, sync_next;

    always @(posedge clk_100khz, posedge rst) begin
        if (rst) begin
            sync_reg <= 0;
        end else begin
            sync_reg <= sync_next;
        end

    end

    always @(*) begin
        sync_next = {sync_reg[6:0], i_btn};
    end

    assign w_debouncer = &sync_reg;

    reg edge_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            edge_reg <= 0;
        end else begin
            edge_reg <= w_debouncer;
        end
    end

    assign o_btn = w_debouncer & (~edge_reg);

endmodule
