`timescale 1ns / 1ps

module fifo (
    input        clk,
    input        rst,
    input  [7:0] push_data,
    input        push,
    input        pop,
    output [7:0] pop_data,
    output       full,
    output       empty
);

endmodule

module register_file (
    input        clk,
    input  [7:0] wdata,
    input  [2:0] waddr,
    input  [1:0] raddr,
    input        we,
    output [7:0] rdata
);

    reg [7:0] register_file[0:3];

    always @(posedge clk) begin
        if (we) begin
            register_file[waddr] <= wdata;
        end
    end

    assign rdata = register_file[raddr];



endmodule


module control_unit (
    input        clk,
    input        rst,
    input        push,
    input        pop,
    output [1:0] wptr,
    output [1:0] rptr,
    output       full,
    output       empty
);

    reg [1:0] wptr_reg, wptr_next;
    reg [1:0] rptr_reg, rptr_next;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            wptr_reg <= 0;
            rptr_reg <= 0;
        end else begin
            wptr_reg <= wptr_next;
            rptr_reg <= rptr_next;
        end
    end


endmodule
