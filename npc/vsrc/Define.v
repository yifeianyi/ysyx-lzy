`timescale 1ps/1ps
// `include "ysyx22041405_IFU.v"
// `include "ysyx22041405_IDU.v"
// `include "ysyx22041405_EXU.v"
// `include "ysyx22041405_MEM.v"
//inst_type
`define R_TYPE 7'b0100000
`define I_TYPE 7'b0010000
`define S_TYPE 7'b0001000
`define B_TYPE 7'b0000100
`define U_TYPE 7'b0000010
`define J_TYPE 7'b0000001
`define EBREAK 7'b1000000

`define MASK_BYTE 32'h000000ff
`define MASK_HALF 32'h0000ffff
`define MASK_WORD 32'hffffffff
