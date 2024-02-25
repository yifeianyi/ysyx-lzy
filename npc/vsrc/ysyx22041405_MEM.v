module ysyx22041405_MEM#(parameter WIDTH = 32)(
    input                   clk,
    input                   rst,
    input [WIDTH - 1: 0]    alu_result,
    input [WIDTH - 1: 0]    pc_add4,
    input [WIDTH - 1: 0]    rf_rs2,

    output[WIDTH - 1: 0]    mem_rdata,
    output[WIDTH - 1: 0]    mem_src,
    output[WIDTH - 1: 0]    rf_wdata,
    input                   mem_addr_sel
);

assign mem_src = mem_addr_sel? alu_result : pc_add4;


/*
    Data memory 写

    alway@(possedge clk)begin

    end

*/


endmodule