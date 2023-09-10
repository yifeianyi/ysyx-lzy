module ysyx_22041405_core#(parameter WIDTH = 32)(
    input                   clk,
    input                   rst,  

    //debug
    output  [WIDTH - 1: 0]  pc,
    output  [WIDTH - 1: 0]  inst
);
    ysyx_22041405_IFU ifu(
        .clk        (clk),
        .rst        (rst),
        .inst       (inst),
        .pc         (pc)
    );

    wire [WIDTH - 1: 0] Imm;
    wire [WIDTH - 1: 0] rf_rs1;
    wire [WIDTH - 1: 0] rf_rs2;

    wire [WIDTH - 1: 0] alu_result;
    wire [        7: 0] alu_opcode;
    wire                alu_add_or_sub;
    wire                alu_U_or_S;
    wire                alu_src2_sel;
    ysyx_22041405_IDU idu(
        .clk        (clk),
        .rst        (rst),
        
        // Data
        .inst       (inst),
        .rf_rs1     (rf_rs1),
        .rf_rs2     (rf_rs2),
        .Imm        (Imm),
        .alu_result (alu_result),

        //Ctrl
        .alu_src2_sel   (alu_src2_sel),
        .alu_opcode     (alu_opcode),
        .alu_add_or_sub (alu_add_or_sub),
        .alu_U_or_S     (alu_U_or_S)
    );

    ysyx_22041405_EXU exu(
        .rf_rs1     (rf_rs1),
        .rf_rs2     (rf_rs2),
        .Imm        (Imm),
        .alu_result (alu_result),

        // Ctrl
        .alu_src2_sel(alu_src2_sel),
        .alu_opcode (alu_opcode),
        .alu_add_or_sub (alu_add_or_sub),
        .alu_U_or_S     (alu_U_or_S)

    );
   
endmodule