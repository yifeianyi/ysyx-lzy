`timescale 1ps/1ps

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
`define BASE_MES_WIDTH 3    // inst_ebreak + inst_lui + inst_valid
`define EX_BASE_MES_WIDTH 2 // inst_ebreak + inst_valid
`define FORD_MES_WIDTH 16   // id_rf_we, rs1, rs2, rd

//IFU
`define IF_ID_WIDTH 64      // pc,inst

//IDU
`define EXU_CTRL_WIDHT 16   // alu_Ctrl + alu_s1_sel + alu_s2_sel
`define LSU_CTRL_WIDTH 10   // dm_mask + dm_we + dm_re
`define WBU_CTRL_WIDTH 8    // wb_rmask

`define ID_Data_WIDTH 32*4 + `IF_ID_WIDTH //Imm + rf_rs1 + rf_rs2 + pc_add4
`define ID_CTRL_WIDTH `BASE_MES_WIDTH + `FORD_MES_WIDTH + `EXU_CTRL_WIDHT + `LSU_CTRL_WIDTH + `WBU_CTRL_WIDTH
`define ID_EX_WIDTH  `ID_Data_WIDTH +`ID_CTRL_WIDTH


//EXU
`define EX_DATA_WIDTH 64 + `IF_ID_WIDTH // alu_result + rf_rdata2
`define EX_CTRL_WIDTH `EX_BASE_MES_WIDTH + `FORD_MES_WIDTH + `LSU_CTRL_WIDTH + `WBU_CTRL_WIDTH
`define EX_LS_WIDTH `EX_DATA_WIDTH + `EX_CTRL_WIDTH 

//LSU
`define LS_DATA_WIDTH `IF_ID_WIDTH  + 32*2 + 5 //ls_rf_wdata + dm_rdata + ls_rf_waddr
`define LS_CTRL_WIDTH `EX_BASE_MES_WIDTH + 9 // wb_rmask + wb_rf_we
`define LS_WB_WIDTH `LS_DATA_WIDTH + `LS_CTRL_WIDTH



import "DPI-C" function void pmem_read(input  int raddr, output  int rdata);
import "DPI-C" function void pmem_write(input  int waddr, input  int wdata, input byte mask);

import "DPI-C" function void inst_finished();
import "DPI-C" function void inst_nsupport();



