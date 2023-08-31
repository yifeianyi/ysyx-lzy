module ysyx_22041405_decoder#(parameter WIDTH = 32, ADDR_WIDTH = 5)(
    input [WIDTH - 1 : 0]   instr,
    output[WIDTH - 1 : 0]   instr_type,

    output rf_we,
    output[ADDR_WIDTH-1 :0] rf_raddr1,
    output[ADDR_WIDTH-1 :0] rf_raddr2,
    output[ADDR_WIDTH-1 :0] rf_waddr,
    output                  rf_rd_sel,

    output                  alu_src1_sel,
    output                  alu_src2_sel,
    output                  alu_opcode
);
    wire [6:0]  opcode;
    wire [2:0]  func3;
    wire [6:0]  func7;

    assign opcode       = instr[ 6: 0];
    assign rf_waddr     = instr[11: 7];
    assign func3        = instr[14:12];
    assign rf_raddr1    = instr[19:15];
    assign rf_raddr2    = instr[24:20];
    assign func7        = instr[31:25];

    //========================= instruction   wire ==========================
    wire addi;

    //========================= instruction define ==========================
    assign addi = ;
    
    
    

endmodule