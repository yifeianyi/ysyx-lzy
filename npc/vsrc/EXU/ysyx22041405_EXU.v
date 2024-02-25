module ysyx22041405_EXU#(parameter WIDTH = 32)(
    input               clk,
    input               rst,
    input [WIDTH - 1: 0] pc,
    input [WIDTH - 1: 0] Imm,
    input [WIDTH - 1: 0] rf_rs1,
    input [WIDTH - 1: 0] rf_rs2,
    
    // ALU port
    output[WIDTH - 1: 0] alu_result,
    output[WIDTH - 1: 0] pc_add4,
    output[WIDTH - 1: 0] next_pc,

    output[        2: 0] alu_Ctrl,
    output               alu_s1_sel,
    output               alu_s2_sel,
    output               branch_and,
    output               branch_add4,
    output               branch_src

);
    //======================== ALU module ================================

    
endmodule //ysyx22041405_EXU
