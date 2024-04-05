module ysyx22041405_ALU#(parameter WIDTH = 32)(
    input [WIDTH - 1: 0] src1,
    input [WIDTH - 1: 0] src2,
    output[WIDTH - 1: 0] result,

    //====== ALU Ctrl ======
    input [        8: 0] alu_Ctrl
);
    // select alu_op
    localparam ALUSHIFT = 3'd7;// 111
    localparam ALUADDER = 3'd6;// 110
    localparam ALUSLT   = 3'd5;// 101
    localparam ALUBGE   = 3'd4;// 100
    localparam ALUAND   = 3'd3;// 011
    localparam ALUOR    = 3'd2;// 010
    localparam ALUXOR   = 3'd1;// 001
    localparam ALUMOD   = 3'd0;// 000

    /*

        1、电路运算上没有有无符号的区别。
        2、verilog的位移运算符会根据运算数是否为有符号数，自适应进行算术or逻辑位移。

    */
    /****       Crtl spilt       ****/
                                    //  0                 1
    wire                alu_UorS;   // Unsigned     or  signed
    wire                alu_LorR;   // left         or  right
    wire                alu_AorS;   // Adder        or  Suber
    wire                alu_AorL;   // arithmetic   or  logic
    wire [        4: 0] alu_op;     // [4]div  [3]mul   [2:0]others
    assign {alu_UorS , alu_LorR , alu_AorS , alu_AorL , alu_op} = alu_Ctrl;
    

    /***        Calc        ***/
    wire [WIDTH - 1: 0] alu_shift;  // 7
    wire [WIDTH - 1: 0] alu_add;    // 6    
    wire [WIDTH - 1: 0] alu_slt;    // 5
    wire [WIDTH - 1: 0] alu_bge;    // 4
    wire [WIDTH - 1: 0] alu_and;    // 3
    wire [WIDTH - 1: 0] alu_or;     // 2
    wire [WIDTH - 1: 0] alu_xor;    // 1
    wire [WIDTH - 1: 0] alu_mod;    // 0
    wire [WIDTH - 1: 0] alu_mul;    // 8
    wire [WIDTH - 1: 0] alu_div;    // 9


    // 7: Shifter
    wire [WIDTH - 1: 0] Llshift;
    wire [WIDTH - 1: 0] Lashift;
    wire [WIDTH - 1: 0] Rlshift;
    wire [WIDTH - 1: 0] Rashift;

    assign Llshift = src1 << src2;
    assign Lashift = $signed(src1) << $signed(src2);
    assign Rlshift = src1 >> src2;
    assign Rashift = $signed(src1) >> $signed(src2);
    assign alu_shift = alu_LorR?
    ( alu_AorL? Rlshift : Rashift ):
    ( alu_AorL? Llshift : Lashift );


    // 6: Adder
    wire [WIDTH - 1: 0] adder_u;
    wire [WIDTH - 1: 0] adder_s;
    wire [WIDTH - 1: 0] adder_ssub;
    wire [WIDTH - 1: 0] adder_usub;

    assign adder_u       = src1 + src2;
    assign adder_usub    = src1 - src2;
    assign adder_s       = $signed(src1) + $signed(src2);
    assign adder_ssub    = $signed(src1) - $signed(src2);
    assign alu_add       = alu_UorS?
    ( alu_AorS? adder_ssub : adder_s ):
    ( alu_AorS? adder_usub : adder_u );

    // 5:slt   4:bge
    /*
        branch_compare控制:
            0:  src1==src2 等价于 alu_result == 0 ,即: alu_op == sub
            1:  src1!=src2 等价于 alu_result != 0 ,即: alu_op == sub
    */
    wire slt_u;
    wire slt_s;
    wire bge_u;
    wire bge_s;

    assign slt_u = src1 < src2;
    assign slt_s = $signed(src1) < $signed(src2);
    assign alu_slt = alu_UorS? {{(WIDTH-1){1'b0}},slt_s} : {{(WIDTH-1){1'b0}},slt_u};
    assign bge_u = src1 >= src2;
    assign bge_s = $signed(src1) >= $signed(src2);
    assign alu_bge = alu_UorS? {{(WIDTH-1){1'b0}},bge_s} : {{(WIDTH-1){1'b0}},bge_u};

    // 3: and  2:or  1:xor  0:mod
    wire [WIDTH - 1: 0] and_u;
    wire [WIDTH - 1: 0] and_s;
    wire [WIDTH - 1: 0] or_u;
    wire [WIDTH - 1: 0] or_s;
    wire [WIDTH - 1: 0] xor_u;
    wire [WIDTH - 1: 0] xor_s;
    wire [WIDTH - 1: 0] mod_u;
    wire [WIDTH - 1: 0] mod_s;

    assign and_u = src1 & src2;
    assign and_s = $signed(src1) & $signed(src2);
    assign or_u = src1 | src2;
    assign or_s = $signed(src1) | $signed(src2);
    assign xor_u = src1 ^ src2;
    assign xor_s = $signed(src1) ^ $signed(src2);
    assign mod_u = src1 % src2;
    assign mod_s = $signed(src1) % $signed(src2);

    assign alu_and = alu_UorS? and_s : and_u;
    assign alu_or  = alu_UorS?  or_s : or_u;
    assign alu_xor = alu_UorS? xor_s : xor_u;
    assign alu_mod = alu_UorS? mod_s : mod_u;

    // 8: mul 9: div ####### 有待优化，先直接用符号代替了
    wire [WIDTH - 1: 0] mul_u;
    wire [WIDTH - 1: 0] mul_s;
    wire [WIDTH - 1: 0] div_u;
    wire [WIDTH - 1: 0] div_s;
    // wire [WIDTH*2 - 1: 0] mul_h; 有待处理
    // wire [WIDTH*2 - 1: 0] mul_hu;
    assign mul_u = src1 * src2;
    assign mul_s = $signed(src1) * $signed(src2);
    assign div_u = src1 / src2;
    assign div_s = $signed(src1) / $signed(src2);

    
    

    reg  [WIDTH - 1: 0] ret_base_d;
    wire [WIDTH - 1: 0] ret_base;
    wire [WIDTH - 1: 0] ret_mul;
    assign ret_base     = ret_base_d;
    assign ret_mul      = alu_op[3]? alu_mul: ret_base;
    assign result       = alu_op[4]? alu_div: alu_mul;

    always @(alu_op[2:0])begin
        case (alu_op[2:0])
        /* 111 */ ALUSHIFT:     ret_base_d = alu_shift;
        /* 110 */ ALUADDER:     ret_base_d = alu_add;
        /* 101 */ ALUSLT:       ret_base_d = alu_slt;
        /* 100 */ ALUBGE:       ret_base_d = alu_bge;
        /* 011 */ ALUAND:       ret_base_d = alu_and;
        /* 010 */ ALUOR:        ret_base_d = alu_or;
        /* 001 */ ALUXOR:       ret_base_d = alu_xor;
        /* 000 */ ALUMOD:       ret_base_d = alu_mod;
        endcase
    end


endmodule //ysyx22041405_alu
