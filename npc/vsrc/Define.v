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

`define MASK_BYTE 8'h01
`define MASK_HALF 8'h03
`define MASK_WORD 8'h0f
`define MASK_ZERO 8'h00

`define IDLE  2'b00 
`define WAIT  2'b01
`define STALL 2'b10
`define STATE_ERROR 2'b11




//pipline width
`define IF_ID_WIDTH 64
`define ID_Data_WIDTH 101 //Imm + rf_rs1 + rf_rs2
`define ID_CTRL_WIDTH 17 // aluCtrl + alu_s2_sel
`define ID_EX_WIDTH  `ID_Data_WIDTH+`ID_CTRL_WIDTH



