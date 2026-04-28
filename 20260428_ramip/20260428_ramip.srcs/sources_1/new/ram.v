`timescale 1ns / 1ps

//수차출력
// module ram (
//     input            clk,
//     input      [3:0] addr,
//     input      [7:0] wdata,
//     input            we,
//     output reg [7:0] rdata
// );

//     reg [7:0] ram[0:15];

//     always @(posedge clk) begin
//         if (we) begin
//             ram[addr] <= wdata;
//         end else if (!we) begin
//             rdata <= ram[addr];
//         end else rdata <= 8'hxx;
//     end
// endmodule


//조합출력
module ram (
    input        clk,
    input  [3:0] addr,
    input  [7:0] wdata,
    input        we,
    output [7:0] rdata
);

    reg [7:0] ram[0:15];

    always @(posedge clk) begin
        if (we) begin
            ram[addr] <= wdata;
        end
    end

    assign rdata = ram[addr];




endmodule
