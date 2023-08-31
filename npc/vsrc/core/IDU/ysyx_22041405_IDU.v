module ysyx_22041405_IDU(
    input clk,
    input rst,

    input [WIDTH - 1: 0] instr,
    input [WIDTH - 1: 0] pc,

    input                rf_we,
    input [WIDTH - 1: 0] rf_waddr,
    input [WIDTH - 1: 0] rf_wdata,
    output[WIDTH - 1: 0] rf_rs1,
    output[WIDTH - 1: 0] rf_rs2,

    //contrl signal
    output              alu_src1_sel,
    output              alu_src2_sel,
    output [3:0]        alu_opcode,
    output              instr_type
);
    ysyx_22041405_decoder(
        .instr          (instr),
        .instr_type     (instr_type),

        .rf_we          (rf_we),
        .rf_raddr1      (rf_raddr1),
        .rf_raddr2      (rf_raddr2),
        .rf_waddr       (rf_waddr),
        .rf_rd_sel      (rf_rd_sel),

        .alu_src1_sel   (alu_src1_sel),
        .alu_src2_sel   (alu_src2_sel),
        .alu_opcode     (alu_opcode)
    )

    #(ADDR_WIDTH = 5,DATA_WIDTH = 32) regsfile(
        .clk            (clk),
        .rst            (rst),

        .rf_raddr1      (rf_raddr1),
        .rf_raddr2      (rf_raddr2),
        .rf_src1        (rf_raddr1),
        .rf_src2        (rf_raddr2),

        .rf_we          (rf_we),
        .rf_wdata       (rf_wdata),
        .rf_waddr       (rf_waddr)
    )

endmodule