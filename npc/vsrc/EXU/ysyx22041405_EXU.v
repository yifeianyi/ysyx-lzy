module ysyx22041405_EXU#(parameter WIDTH = 32)(
    /*       input       */
    input               clk,
    input               rst,
    input [WIDTH - 1: 0] pc,
    input [WIDTH - 1: 0] Imm,
    input [WIDTH - 1: 0] rf_rs1,
    input [WIDTH - 1: 0] rf_rs2,
    
    /*      output       */
    output[WIDTH - 1: 0] alu_result,
    output[WIDTH - 1: 0] pc_add4,
    output[WIDTH - 1: 0] next_pc,

    /*    Ctrl signal    */
    input [        8: 0] alu_Ctrl,
    input                alu_s1_sel,
    input                alu_s2_sel,
    input [        3: 0] branch_sel,
    input                branch_compare
);

    wire [WIDTH - 1: 0] alu_src1;
    wire [WIDTH - 1: 0] alu_src2;
    assign  alu_src1 = alu_s1_sel? rf_rs1 : pc;
    assign  alu_src2 = alu_s2_sel? Imm : rf_rs2;

    //======================== ALU module ================================
    ysyx22041405_ALU #(.WIDTH(32)) u_alu(
        .src1       (   alu_src1    ),
        .src2       (   alu_src2    ),
        .result     (   alu_result  ),
        .alu_Ctrl   (   alu_Ctrl    )
    );


    assign pc_add4 = pc + 4;
    ysyx22041405_branch #(.WIDTH(32)) u_branch(
        /*       input       */
        .pc             (   pc              ),
        .Imm            (   Imm             ),
        .rf_rs1         (   rf_rs1          ),
        .pc_add4        (   pc_add4         ),

        /*    Ctrl signal    */
        .branch_sel     (   branch_sel      ),
        .alu_result     (   alu_result      ),

        /*      output       */
        .next_pc        (   next_pc         )
    );

    
endmodule //ysyx22041405_EXU
