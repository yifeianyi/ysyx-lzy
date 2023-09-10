module ysyx_22041405_EXU #(parameter WIDTH = 32 )(
    input [WIDTH - 1: 0] rf_rs1,
    input [WIDTH - 1: 0] rf_rs2,
    input [WIDTH - 1: 0] Imm,
    output[WIDTH - 1: 0] alu_result,

    input [        7: 0] alu_opcode,
    input                alu_src2_sel,
    input                alu_add_or_sub,
    input                alu_U_or_S
);
    wire [WIDTH - 1: 0] alu_src1;
    wire [WIDTH - 1: 0] alu_src2;

    assign alu_src1 = rf_rs1;
    assign alu_src2 = alu_src2_sel? Imm : rf_rs2;

    ysyx_22041405_ALU alu(
        .src1       (alu_src1),
        .src2       (alu_src2),
        .result     (alu_result),

        .alu_opcode (alu_opcode),
        .alu_add_or_sub (alu_add_or_sub),
        .alu_U_or_S     (alu_U_or_S)
    );
    
endmodule