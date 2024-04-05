module ysyx22041405_MEM#(parameter WIDTH = 32)(
    input                   clk,
    input                   rst,

    /*       input       */
    input [WIDTH - 1: 0]    alu_result,
    input [WIDTH - 1: 0]    pc_add4,
    input [WIDTH - 1: 0]    rf_rs2,

    /*      output       */
    output[WIDTH - 1: 0]    dm_rdata,
    output[WIDTH - 1: 0]    dm_addr,
    output[WIDTH - 1: 0]    rf_wdata,

    /*    Ctrl signal    */
    input                   dm_src_sel,
    input                   dm_re,
    input                   dm_we,
    input [WIDTH - 1: 0]    dm_mask
);

assign dm_addr = dm_src_sel? alu_result : pc_add4;


/*
    Data memory 写

    alway@(possedge clk)begin

    end

*/


endmodule