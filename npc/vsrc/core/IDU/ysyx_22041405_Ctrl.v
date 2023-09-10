import "DPI-C" function void Ebreak();
module ysyx_22041405_Ctrl#(parameter WIDTH = 32, ADDR_WIDTH = 5)(
    input [     WIDTH - 1: 0]    inst,
    output[ADDR_WIDTH - 1: 0]    rf_raddr1,
    output[ADDR_WIDTH - 1: 0]    rf_raddr2,
    output[ADDR_WIDTH - 1: 0]    rf_waddr,
    output[     WIDTH - 1: 0]    Imm,

    //Ctrl
    output[             7: 0]   alu_opcode,
    output                      alu_add_or_sub,
    output                      alu_U_or_S,
    output                      alu_src2_sel
);

    wire [6:0]  inst_opcode;
    wire [6:0]  inst_func7;
    wire [2:0]  inst_func3;
    wire [4:0]  inst_rd;
    wire [4:0]  inst_rs1;
    wire [4:0]  inst_rs2;

    assign inst_opcode = inst[ 6: 0];
    assign inst_rd     = inst[11: 7];
    assign inst_func3  = inst[14:12];
    assign inst_rs1    = inst[19:15];
    assign inst_rs2    = inst[24:20];
    assign inst_func7  = inst[31:25];

    //---------------- Imm wire ---------------------------
    wire inst_31 ;
    wire inst_20;
    wire inst_7;
    wire [10:0] inst_30_20;
    wire [5: 0] inst_30_25;
    wire [3: 0] inst_24_21;
    wire [7: 0] inst_19_12;
    wire [3: 0] inst_11_8;
    
    assign inst_31 = inst[31];
    assign inst_20 = inst[20];
    assign inst_7  = inst[7];
    assign inst_30_20 = inst[30:20];
    assign inst_30_25 = inst[30:25];
    assign inst_24_21 = inst[24:21];
    assign inst_19_12 = inst[19:12];
    assign inst_11_8  = inst[11: 8];

    assign rf_raddr1 = inst_rs1;
    assign rf_raddr2 = inst_rs2;
    assign rf_waddr  = inst_rd;
    
    //---------------------------------------------------------------------
    wire [127:0]inst_opcode_d;
    wire [127:0]inst_func7_d;
    wire [7:0]  inst_func3_d;
    wire [31: 0]inst_rd_d;
    wire [31: 0]inst_rs1_d;
    wire [31: 0]inst_rs2_d;

    ysyx_22041405_decoder_n_m #(.n(7), .m(128))    decOp( .in(inst_opcode), .out(inst_opcode_d));
    ysyx_22041405_decoder_n_m #(.n(7), .m(128)) decfunc7( .in( inst_func7), .out( inst_func7_d));
    ysyx_22041405_decoder_n_m #(.n(3), .m(8))   decfunc3( .in( inst_func3), .out( inst_func3_d));

    //--------------------wire-----------debug-ebreak--------------------
    ysyx_22041405_decoder_n_m #(.n(5), .m(32)) decrd ( .in( inst_rd ), .out( inst_rd_d));
    ysyx_22041405_decoder_n_m #(.n(5), .m(32)) decrs1( .in( inst_rs1), .out(inst_rs1_d));
    ysyx_22041405_decoder_n_m #(.n(5), .m(32)) decrs2( .in( inst_rs2), .out(inst_rs2_d));
    
    wire ebreak;
    assign ebreak   = inst_opcode_d[7'b1110011] & inst_rd_d[5'b00000] & inst_func3_d[3'b000]
                         & inst_rs1_d[5'b00000] & inst_rs2_d[5'b00001] & inst_func7_d[7'b0000000];

    always @(ebreak) begin
        if(ebreak)Ebreak();
    end
    //--------------------wire-----------debug-ebreak--------------------
    
    //============================== inst wire =================================================

    //----------R-type-------------------


    //----------I-type-------------------
    wire addi;
    wire jalr;

    //----------S-type-------------------
    wire sw;

    //----------B-type-------------------

    //----------U-type-------------------
    wire auipc;
    wire lui;

    //----------J-type-------------------
    wire jal;

    //============================== inst define =================================================
    assign addi     = inst_opcode_d[7'b0010011] & inst_func3_d[3'b000];
    assign jalr     = inst_opcode_d[7'b1100111] & inst_func3_d[3'b000];

    assign sw       = inst_opcode_d[7'b0100011] & inst_func3_d[3'b010];

    assign auipc    = inst_opcode_d[7'b0010111];
    assign lui      = inst_opcode_d[7'b0110111];

    assign jal      = inst_opcode_d[7'b1101111];
    

    //================================  Imm ====================================================

    wire [WIDTH - 1: 0] Imm_I;
    wire [WIDTH - 1: 0] Imm_S;
    wire [WIDTH - 1: 0] Imm_B;
    wire [WIDTH - 1: 0] Imm_U;
    wire [WIDTH - 1: 0] Imm_J;
    reg  [WIDTH - 1: 0] Imm_d;

    assign Imm_I = { {21{inst_31}}          ,inst_30_25 ,inst_24_21 ,inst_20  };
    assign Imm_S = { {21{inst_31}}          ,inst_30_25 ,inst_11_8  ,inst_7 };
    assign Imm_B = { {20{inst_31}} ,inst_7  ,inst_30_25 ,inst_11_8  ,1'b0};
    assign Imm_U = { inst_31 , inst_30_20 ,inst_19_12 ,{12{1'b0}} };
    assign Imm_J = { {12{inst_31}}        ,inst_19_12 ,inst_20 ,inst_30_25 ,inst_24_21 ,1'b0 };
    assign Imm   = Imm_d;

    localparam RTYPE = 6'b000001;
    localparam ITYPE = 6'b000010;
    localparam STYPE = 6'b000100;
    localparam BTYPE = 6'b001000;
    localparam UTYPE = 6'b010000;
    localparam JTYPE = 6'b100000;

    wire r_type;
    wire i_type;
    wire s_type;
    wire b_type;
    wire u_type;
    wire j_type;
    wire [ 5: 0] Inst_type;

    assign r_type = inst_opcode_d[7'b0110011] | inst_opcode_d[7'b0111011];
    assign i_type = inst_opcode_d[7'b0000011] | inst_opcode_d[7'b0010011] 
                  | inst_opcode_d[7'b0011011] | inst_opcode_d[7'b1100111];
    assign s_type = inst_opcode_d[7'b0100011];
    assign b_type = inst_opcode_d[7'b1100011];
    assign u_type = inst_opcode_d[7'b0010111] | inst_opcode_d[7'b0110111];
    assign j_type = inst_opcode_d[7'b1101111];
    assign Inst_type = { j_type ,u_type ,b_type ,s_type ,i_type ,r_type };

    always @(Inst_type) begin
        case (Inst_type)
            RTYPE: Imm_d = 32'b0;   // R-type 无imm，直接保持原值
            ITYPE: Imm_d = Imm_I;
            STYPE: Imm_d = Imm_S;
            BTYPE: Imm_d = Imm_B;
            UTYPE: Imm_d = Imm_U;
            JTYPE: Imm_d = Imm_J;
            default: Imm_d=32'b0;
        endcase
    end

    //================================ Ctrl ====================================================

    wire alu_add;
    wire alu_Lshift;
    wire alu_slt;
    wire alu_Rshift;
    wire alu_direct;
    wire alu_and;
    wire alu_or;
    wire alu_xor;

    assign alu_add = addi;
    assign alu_Lshift = 1'b0;
    assign alu_slt    = 1'b0;
    assign alu_Rshift = 1'b0;
    assign alu_direct = 1'b0;
    assign alu_and    = 1'b0;
    assign alu_or     = 1'b0;
    assign alu_xor    = 1'b0;

    assign alu_opcode     = { alu_add   ,alu_Lshift ,alu_slt ,alu_Rshift, 
                              alu_direct,alu_and    ,alu_or  ,alu_xor };
    assign alu_add_or_sub = 1'b0;//过渡方案
    assign alu_U_or_S     = 1'b0;
    assign alu_src2_sel   = addi;
    
endmodule