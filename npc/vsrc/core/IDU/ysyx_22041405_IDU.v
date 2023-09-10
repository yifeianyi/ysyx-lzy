module ysyx_22041405_IDU#(parameter WIDTH = 32, ADDR_WIDTH = 5) (
    input   clk,
    input   rst,

    input [WIDTH - 1: 0] inst,
    output[WIDTH - 1: 0] rf_rs1,
    output[WIDTH - 1: 0] rf_rs2,
    output[WIDTH - 1: 0] Imm,
    input [WIDTH - 1: 0] alu_result,

    output        [7: 0] alu_opcode,
    output               alu_src2_sel,
    output               alu_add_or_sub,
    output               alu_U_or_S
);
    ysyx_22041405_Ctrl ctrl(
        .inst       (inst),
        .rf_raddr1  (rf_raddr1),
        .rf_raddr2  (rf_raddr2),
        .rf_waddr   (rf_waddr),
        .Imm        (Imm),

        // Ctrl
        .alu_opcode     (alu_opcode),
        .alu_src2_sel   (alu_src2_sel),
        .alu_add_or_sub (alu_add_or_sub),
        .alu_U_or_S     (alu_U_or_S)
    );

    wire [ADDR_WIDTH - 1: 0] rf_raddr1;
    wire [ADDR_WIDTH - 1: 0] rf_raddr2;
    wire [ADDR_WIDTH - 1: 0] rf_waddr;
    wire [     WIDTH - 1: 0] rf_wdata;

    assign rf_wdata = alu_result;   //过渡方案
    ysyx_22041405_regsfile regsfile(
        .clk        (clk),
        .rst        (rst),

        .rf_raddr1  (rf_raddr1),
        .rf_raddr2  (rf_raddr2),
        .rf_waddr   (rf_waddr),

        .rf_rs1     (rf_rs1),
        .rf_rs2     (rf_rs2),
        .rf_wdata   (rf_wdata)
    );
    
endmodule