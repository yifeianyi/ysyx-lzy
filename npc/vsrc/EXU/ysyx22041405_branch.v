////////////////////////////////////////////////////////////////////////////////
// Module: ysyx22041405_branch.v
// Description: [Description_of_Module]
//
// Author: Yifeianyi
// Date: 2024-2-26 07:19:33
//
// Revision History:
// - [2024-2-26]: 初版,单周期版本 - Yifeianyi
//
// [Additional_Notes_and_Information]
// branch_sel:
// - [3]: branch_sel[3]  : 0:imm_add_and    1: imm_add  
// - [2]: branch_src     : 0:src1           1: pc       ; branch 数据预处理
// - [1]: branch_seq     : 0:pc_add4        1: others   ; 是否顺序执行
// - [0]: sel_nextpc_ctrl: 0:branch_sel[1]  1: alu_rst  ; 有无条件跳转
//
// -- sel_nextpc_ctrl 和 branch_sel[1]、branch_sel[0] 是配套使用的控制源. 
// -- branch_sel[1]: branch_add4,是否顺序执行，0:顺序 1:跳转
// -- branch_sel[2]: 
//
////////////////////////////////////////////////////////////////////////////////
module ysyx22041405_branch #(parameter WIDTH = 32)(
    /*       input       */
    input [WIDTH - 1: 0] Imm,
    input [WIDTH - 1: 0] rf_rs1,
    input [WIDTH - 1: 0] pc,
    input [WIDTH - 1: 0] pc_add4,
    
    /*    Ctrl signal    */
    input [WIDTH - 1: 0] alu_result,
    input [        3: 0] branch_sel,

    /*      output       */
    output[WIDTH - 1: 0] next_pc
);
    // spilt
    wire branch_src,branch_seq,sel_nextpc_ctrl;
    assign {branch_src, branch_seq, sel_nextpc_ctrl} = branch_sel[2:0];

    //pre
    wire [WIDTH - 1: 0] add_src2;
    wire [WIDTH - 1: 0] add_imm;
    wire [WIDTH - 1: 0] add_imm_and;
    wire [WIDTH - 1: 0] nextpc_src2;
    
    assign add_src2     = branch_src? pc: rf_rs1;
    assign add_imm      = Imm + add_src2;
    assign add_imm_and  = add_imm & ~({{(WIDTH-1){1'b0}},{1'b1}});
    assign nextpc_src2 = branch_sel[3]? add_imm : add_imm_and;

    //select signal
    assign next_pc = sel_nextpc_ctrl?
    (alu_result[0]?  nextpc_src2 : pc_add4):
    (branch_seq   ?  pc_add4 : nextpc_src2);

endmodule