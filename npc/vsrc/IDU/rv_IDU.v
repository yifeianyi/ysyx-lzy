////////////////////////////////////////////////////////////////////////////////
// Module: yrv_IDU.v
// Description: [Description_of_Module]
//
// Author: Yifeianyi
// Date: 2024-2-26 07:19:33
//
// Revision History:
// - [2024-2-26]: 初版,单周期版本 - Yifeianyi
//
// [Additional_Notes_and_Information]
//
////////////////////////////////////////////////////////////////////////////////
module rv_IDU#(parameter WIDTH = 32)(
    /*       input       */
    input   clk,
    input   rst,
    input [WIDTH - 1: 0] inst,
    input [WIDTH - 1: 0] rf_wdata,

    /*      output       */
    output[WIDTH - 1: 0] Imm,
    output[WIDTH - 1: 0] rf_rs1,
    output[WIDTH - 1: 0] rf_rs2,
    
    /*    Ctrl signal    */
    // EXU 
    output [8:0]          alu_Ctrl,
    output                alu_s1_sel,
    output                alu_s2_sel,
    output [3:0]          branch_sel,
    output                branch_compare,

    // MEM
    output                dm_src_sel,
    output [WIDTH - 1: 0] dm_mask,
    output                dm_re,
    output                dm_we,

    // WBU
    output                wb_sel,
    output [WIDTH - 1: 0] wb_mask

);  
    localparam R_TYPE = 6'b100000;
    localparam I_TYPE = 6'b010000;
    localparam S_TYPE = 6'b001000;
    localparam B_TYPE = 6'b000100;
    localparam U_TYPE = 6'b000010;
    localparam J_TYPE = 6'b000001;

    //instruction split
    wire [ 6: 0]    opcode = inst [6:0];
    wire [14:12]    funct3 = inst [14:12];
    wire [31:25]    funct7 = inst [31:25];
    wire [11: 7]    rd     = inst [11: 7];
    wire [19:15]    rs1    = inst [19:15];
    wire [24:20]    rs2    = inst [24:20];
    wire [127:0]    opcode_d;
    wire [127:0]    funct7_d;
    wire [ 7: 0]    funct3_d;

    ysyx22041405_decoder_n_m #(.n(7),.m(128)) decoder0_7_128 (.in (opcode),.out(opcode_d));
    ysyx22041405_decoder_n_m #(.n(7),.m(128)) decoder1_7_128 (.in (funct7),.out(funct7_d));
    ysyx22041405_decoder_n_m #(.n(3),.m(8)) decoder2_3_8   (.in (funct3),.out(funct3_d));

    wire [ 5: 0]    inst_type;
    wire            R_type = opcode_d[7'b0110011];
    wire            I_type = opcode_d[7'b0000011] || opcode_d[7'b0010011] || opcode_d[7'b1100111];;
    wire            S_type = opcode_d[7'b0100011];
    wire            B_type = opcode_d[7'b1100011];
    wire            U_type = opcode_d[7'b0010111] || opcode_d[7'b0110111];
    wire            J_type = opcode_d[7'b1101111];
    assign inst_type = {R_type, I_type, S_type, B_type, U_type, J_type};

    //======================= Imm generated ==================================
    //inst split
    wire            inst_31     = inst[31];
    wire [30:25]    inst_30_25  = inst[30:25];
    wire [24:21]    inst_24_21  = inst[24:21];
    wire            inst_20     = inst[20];
    wire [19:12]    inst_19_12  = inst[19:12];
    wire [11: 8]    inst_11_8   = inst[11: 8];
    wire            inst_7      = inst[7];
    wire [30:20]    inst_30_20  = {inst_30_25, inst_24_21, inst_20};

    //imm_type
    wire [WIDTH-1:0]imm_I;
    wire [WIDTH-1:0]imm_S;
    wire [WIDTH-1:0]imm_B;
    wire [WIDTH-1:0]imm_U;
    wire [WIDTH-1:0]imm_J;
    reg  [WIDTH-1:0]Imm_d;
    assign imm_I = {{21{inst_31}}, inst_30_25, inst_24_21, inst_20};
    assign imm_S = {{21{inst_31}}, inst_30_25, inst_11_8 , inst_7};
    assign imm_B = {{20{inst_31}}, inst_7, inst_30_25, inst_11_8, 1'b0};
    assign imm_U = {  inst_31    , inst_30_20, inst_19_12, 12'b0};
    assign imm_J = {{12{inst_31}}, inst_19_12, inst_20, inst_30_25, inst_24_21, 1'b0};

    always @(*)begin
        case (inst_type)
            I_TYPE: Imm_d = imm_I;
            S_TYPE: Imm_d = imm_S;
            B_TYPE: Imm_d = imm_B;
            U_TYPE: Imm_d = imm_U;
            J_TYPE: Imm_d = imm_J;
            default: Imm_d = {WIDTH{1'b0}};
        endcase
    end
    assign Imm = Imm_d;
    //=======================     regfile    ==================================
    // outports wire
    wire            we;
    wire [31:0]     rf_rdata1;
    wire [31:0]     rf_rdata2;
    assign we = 1'b1;
    ysyx22041405_regfile #(.WIDTH( 32  ))   u_regfile
    (
        .clk        ( clk       ),
        .raddr1     ( rs1       ),
        .rdata1     (rf_rdata1  ),
        .raddr2     ( rs2       ),
        .rdata2     ( rf_rdata2 ),
        .we         ( we        ),
        .waddr      ( rd        ),
        .wdata      ( rf_wdata  )
    );

    //=======================  Decoder  ==================================
    /*    R-Type    */
    wire inst_add , inst_sub  , inst_and  , inst_or  , inst_xor , 
         inst_mul , inst_div  , inst_divu , inst_sltu, inst_remu,
         inst_mulh, inst_mulhu, inst_rem  , inst_sll , inst_sra ,
         inst_srl , inst_slt;

    assign inst_add = opcode_d[7'b0110011] & funct3_d[3'b000] & funct7_d[7'b0000000];//
    assign inst_sub = opcode_d[7'b0110011] & funct3_d[3'b000] & funct7_d[7'b0100000];//
    assign inst_and = opcode_d[7'b0110011] & funct3_d[3'b111] & funct7_d[7'b0000000];//
    assign inst_or  = opcode_d[7'b0110011] & funct3_d[3'b110] & funct7_d[7'b0000000];//
    assign inst_xor = opcode_d[7'b0110011] & funct3_d[3'b100] & funct7_d[7'b0000000];//

    assign inst_mul = opcode_d[7'b0110011] & funct3_d[3'b000] & funct7_d[7'b0000001];//
    assign inst_div = opcode_d[7'b0110011] & funct3_d[3'b100] & funct7_d[7'b0000001];//
    assign inst_divu= opcode_d[7'b0110011] & funct3_d[3'b101] & funct7_d[7'b0000001];//
    assign inst_sltu= opcode_d[7'b0110011] & funct3_d[3'b011] & funct7_d[7'b0000000];//
    assign inst_remu= opcode_d[7'b0110011] & funct3_d[3'b111] & funct7_d[7'b0000001];//
    
    assign inst_mulh =opcode_d[7'b0110011] & funct3_d[3'b001] & funct7_d[7'b0000001];//
    assign inst_mulhu=opcode_d[7'b0110011] & funct3_d[3'b011] & funct7_d[7'b0000001];//
    assign inst_rem  =opcode_d[7'b0110011] & funct3_d[3'b110] & funct7_d[7'b0000001];//
    assign inst_sll  =opcode_d[7'b0110011] & funct3_d[3'b001] & funct7_d[7'b0000000];//
    assign inst_sra  =opcode_d[7'b0110011] & funct3_d[3'b101] & funct7_d[7'b0100000];//

    assign inst_srl  =opcode_d[7'b0110011] & funct3_d[3'b101] & funct7_d[7'b0000000];//
    assign inst_slt  =opcode_d[7'b0110011] & funct3_d[3'b010] & funct7_d[7'b0000000];//



    /*    I-Type    */
    wire inst_lbu , inst_lhu  , inst_lb   , inst_lw  , inst_lh  ,
         inst_addi, inst_xori , inst_andi , inst_slli, inst_srli,
         inst_srai, inst_ori  , inst_sltiu, inst_jalr;

    assign inst_lbu     = opcode_d[7'b0000011] & funct3_d[3'b100];//
    assign inst_lhu     = opcode_d[7'b0000011] & funct3_d[3'b101];//
    assign inst_lb      = opcode_d[7'b0000011] & funct3_d[3'b000];//
    assign inst_lw      = opcode_d[7'b0000011] & funct3_d[3'b001];//
    assign inst_lh      = opcode_d[7'b0000011] & funct3_d[3'b010];//

    assign inst_addi    = opcode_d[7'b0010011] & funct3_d[3'b000];//
    assign inst_xori    = opcode_d[7'b0010011] & funct3_d[3'b100];//
    assign inst_andi    = opcode_d[7'b0010011] & funct3_d[3'b111];//
    assign inst_slli    = opcode_d[7'b0010011] & funct3_d[3'b001] & ( funct7_d[7'b0000000] | funct7_d[7'b0000001]);//
    assign inst_srli    = opcode_d[7'b0010011] & funct3_d[3'b101] & ( funct7_d[7'b0000000] | funct7_d[7'b0000001]);//
    
    assign inst_srai    = opcode_d[7'b0010011] & funct3_d[3'b101] & ( funct7_d[7'b0100000] | funct7_d[7'b0100001]);//
    assign inst_ori     = opcode_d[7'b0010011] & funct3_d[3'b110];//
    assign inst_sltiu   = opcode_d[7'b0010011] & funct3_d[3'b011];//
    assign inst_jalr    = opcode_d[7'b1100111] & funct3_d[3'b000];//


    /*    S-Type    */
    wire inst_sb, inst_sh, inst_sw;
    assign inst_sb      = opcode_d[7'b0100011] & funct3_d[3'b000];//
    assign inst_sh      = opcode_d[7'b0100011] & funct3_d[3'b001];//
    assign inst_sw      = opcode_d[7'b0100011] & funct3_d[3'b010];//

    /*    B-Type    */
    wire inst_beq, inst_bne, inst_bge, inst_bgeu, inst_blt, inst_bltu;
    assign inst_beq     = opcode_d[7'b1100011] & funct3_d[3'b000];//
    assign inst_bne     = opcode_d[7'b1100011] & funct3_d[3'b001];//
    assign inst_bge     = opcode_d[7'b1100011] & funct3_d[3'b101];//
    assign inst_bgeu    = opcode_d[7'b1100011] & funct3_d[3'b111];//
    assign inst_blt     = opcode_d[7'b1100011] & funct3_d[3'b100];//
    assign inst_bltu    = opcode_d[7'b1100011] & funct3_d[3'b110];//

    /*    U-Type    */
    wire inst_lui;    
    wire inst_auipc;
    assign inst_auipc   = opcode_d[7'b0010111];//
    assign inst_lui     = opcode_d[7'b0110111];//

    /*    J-Type    */
    wire inst_jal;
    assign inst_jal     = opcode_d[7'b1101111];//

    /*      Others       */
    wire inst_ebreak;
    wire load_inst = inst_lbu | inst_lhu | inst_lb | inst_lw |inst_lh;
    assign inst_ebreak  = inst == 32'b00000000000100000000000001110011;

    /***************      Ctrl wire       ***************/
    /*==========  IDU  =========*/
    wire rf_nwe;
    assign rf_nwe       = S_type | B_type;
    /*==========  EXU  =========*/
    /*-----  alu  -----*/
    wire alu_UorS,alu_RorL,alu_AorS,alu_LorA;
    wire [4: 0] alu_op;

    assign alu_Ctrl     = {alu_UorS , alu_RorL , alu_AorS , alu_LorA , alu_op};
    assign alu_s1_sel   = R_type | I_type | S_type | B_type | inst_lui;
    assign alu_s2_sel   = I_type | S_type | U_type;
    assign alu_UorS     = inst_div | inst_rem | inst_sra | inst_slt | inst_srai | inst_bge | inst_blt;
    assign alu_RorL     = inst_sll | inst_slli;
    assign alu_AorS     = inst_sub | inst_beq | inst_bne;
    assign alu_LorA     = inst_sra | inst_srai;
    /*-------------*/
    wire [7:0] alu_opcode = {alu_shift, alu_add, alu_slt, alu_bge, alu_and, alu_or, alu_xor, alu_mod};
    wire alu_shift  =   inst_sll | inst_sra | inst_srl |
                        inst_slli| inst_srai| inst_srli;

    wire alu_add    = (((~alu_shift) & (~alu_slt)) & ((~alu_bge) & (~alu_and))) & 
                      ((  (~alu_or)  & (~alu_xor)) & ((~alu_mod) & (~alu_mul)) ) & (~alu_div);
    wire alu_slt    =   inst_slt | inst_sltu | inst_sltiu | inst_blt | inst_bltu;
    wire alu_bge    =   inst_bge | inst_bgeu;
    wire alu_and    =   inst_and | inst_andi;
    wire alu_or     =   inst_or  | inst_ori ;
    wire alu_xor    =   inst_xor | inst_xori;
    wire alu_mod    =   inst_rem | inst_remu;
    wire alu_mul    =   inst_mul | inst_mulh | inst_mulhu;
    wire alu_div    =   inst_div | inst_divu;

    assign alu_op[4:3] = {alu_div,alu_mul};
    ysyx22041405_encoder_n_m #(.n(8),.m(3)) encoder8_3(
        .in(alu_opcode),
        .out(alu_op[2:0])
    );



    /*---  branch  ---*/
    wire nextpc_src_sel, branch_src_sel, branch_condit, branch_nseq;
    assign branch_sel     = {nextpc_src_sel, branch_src_sel, branch_condit, branch_nseq};
    assign nextpc_src_sel = inst_jalr;
    assign branch_src_sel = inst_jalr;
    assign branch_condit  = B_type;
    assign branch_nseq    = inst_jalr | inst_jal;
    assign branch_compare = inst_bne;

    /*==========  MEM  =========*/
    assign dm_src_sel     = inst_jalr | inst_jal;;
    assign dm_mask        = dm_mask_r; 
    assign dm_re          = load_inst;
    assign dm_we          = S_type;

    /*==========  WBU  =========*/
    assign wb_sel         = load_inst;
    assign wb_mask        = wb_mask_r; 

    reg [WIDTH - 1:0] dm_mask_r;
    reg [WIDTH - 1:0] wb_mask_r;
    
    always @(*) begin
        case (funct3[1:0])
            2'b00:begin
                wb_mask_r = `MASK_BYTE;
                dm_mask_r = `MASK_BYTE;
            end
            2'b01:begin
                wb_mask_r = `MASK_HALF;
                dm_mask_r = `MASK_HALF;
            end
            2'b10:begin
                wb_mask_r = `MASK_WORD;
                dm_mask_r = `MASK_WORD;
            end
            default: wb_mask_r= 32'b0;
        endcase
    end



    /*================================== IDU_state =========================================*/
    /*
        valid-ready state: TODO
    */


endmodule //rv_IDU