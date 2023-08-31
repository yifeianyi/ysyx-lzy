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
    wire [ 6: 0]    opcode;
    wire [ 2: 0]    func3;
    wire [ 6: 0]    func7;
    wire            inst_7;
    wire            inst_20;
    wire            inst_31;
    wire [ 3: 0]    inst_11_8;
    wire [ 3: 0]    inst_24_21;
    wire [ 5: 0]    inst_30_25;
    wire [ 7: 0]    inst_19_12;
    wire [10: 0]    inst_30_20;

    assign opcode       = instr[ 6: 0];
    assign rf_waddr     = instr[11: 7];
    assign func3        = instr[14:12];
    assign rf_raddr1    = instr[19:15];
    assign rf_raddr2    = instr[24:20];
    assign func7        = instr[31:25];

    assign inst_7       = instr[7];
    assign inst_20      = instr[20];
    assign inst_31      = instr[31];
    assign inst_11_8    = instr[11:8];
    assign inst_24_21   = instr[24:21];
    assign inst_30_25   = instr[30:25];
    assign inst_19_12   = instr[18:12];
    assign inst_30_20   = instr[30:20];

//------------ instr decode ----------------
    wire [ 127: 0]  opcode_d;
    wire [ 127: 0]  func7_d;
    wire [   7: 0]  func3_d;
    
    ysyx_22041405_decoder_n_m #(n=7, m = 128) inst_dec0( .in(opcode), .out(opcode_d));
    ysyx_22041405_decoder_n_m #(n=7, m = 128) inst_dec1( .in(func7 ), .out(func7_d));
    ysyx_22041405_decoder_n_m #(n=3, m = 8  ) inst_dec2( .in(func3 ), .out(func3_d));
    
    wire R_type;
    wire I_type;
    wire S_type;
    wire B_type;
    wire U_type;
    wire J_type;
    wire [5:0]Inst_type;

    wire [WIDTH - 1: 0] I_Imm;
    wire [WIDTH - 1: 0] S_Imm;
    wire [WIDTH - 1: 0] B_Imm;
    wire [WIDTH - 1: 0] U_Imm;
    wire [WIDTH - 1: 0] J_Imm;
    wire [WIDTH - 1: 0] Imm;
    reg  [WIDTH - 1: 0] Imm_d;
    assign Imm = Imm_d;

    assign I_Imm = {{inst_31}*21                                 ,inst_30_25 ,inst_24_21 ,inst_20};
    assign S_Imm = {{inst_31}*21                                 ,inst_30_25 ,inst_11_8  ,inst_7 };
    assign B_Imm = {{inst_31}*20                        ,inst_7  ,inst_30_25 ,inst_11_8  ,1'b0   };
    assign U_Imm = { inst_31     ,inst_30_20,inst_19_12 ,{1'b0}*12};
    assign J_Imm = {{inst_31}*12            ,inst_19_12 ,inst_20 ,inst_30_25 ,inst_24_21 ,1'b0};


    assign R_type = opcode_d[7'b0110011] | opcode_d[7'b0111011];
    assign I_type = opcode_d[7'b0000011] | opcode_d[7'b0010011] | opcode[7'b0011011] | opcode_d[7'b1100111];
    assign S_type = opcode_d[7'b0100011];
    assign B_type = opcode_d[7'b1100011];
    assign U_type = opcode_d[7'b0010111];
    assign J_type = opcode_d[7'b1101111];
    assign Inst_type = { R_type, I_type, S_type, B_type, U_type, J_type};

    localparam RTYPE = 6'b100000;
    localparam ITYPE = 6'b100000;
    localparam STYPE = 6'b100000;
    localparam BTYPE = 6'b100000;
    localparam UTYPE = 6'b100000;
    localparam JTYPE = 6'b100000;

    always @(*) begin
        case (Inst_type)
            ITYPE: Imm_d = I_Imm;
            STYPE: Imm_d = S_Imm;
            BTYPE: Imm_d = B_Imm;
            UTYPE: Imm_d = U_Imm;
            JTYPE: Imm_d = J_Imm;
            default: 
        endcase
    end


    //========================= instruction   wire ==========================
    wire addi;
    // wire lui;
    // wire jal;
    // wire jalr;
    // wire auipc;
    // wire ebreak;


    //========================= instruction define ==========================
    assign addi = opcode_d[7'b0010011] & func3_d[3'b000];

    
    //======================== Ctrl Signal ==================================
    
    
    

endmodule