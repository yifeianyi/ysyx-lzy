// `include "./ysyx22041405_decoder_n_m.v"
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
    output [2:0]          alu_Ctrl,
    output                alu_s1_sel,
    output                alu_s2_sel,
    output                branch_add4,
    output                branch_and,
    output                branch_src,

    // MEM
    output                mem_addr_sel,

    // WBU
    output                wb_sel,
    output                wb_mask

);  
    localparam R_TYPE = 7'b0100000;
    localparam I_TYPE = 7'b0010000;
    localparam S_TYPE = 7'b0001000;
    localparam B_TYPE = 7'b0000100;
    localparam U_TYPE = 7'b0000010;
    localparam J_TYPE = 7'b0000001;

    //instruction split
    wire [ 6: 0]    opcode;
    wire [14:12]    funct3;
    wire [31:25]    funct7;
    wire [11: 7]    rd;
    wire [19:15]    rs1;
    wire [24:20]    rs2;
    wire [127:0]    opcode_d;
    wire [127:0]    funct7_d;
    wire [ 7: 0]    funct3_d;

    assign opcode = inst [6:0];
    assign funct3 = inst [14:12];
    assign funct7 = inst [31:25];
    assign   rd   = inst [11: 7];
    assign   rs1  = inst [19:15];
    assign   rs2  = inst [24:20];

    ysyx22041405_decoder_n_m #(.n(7),.m(128)) decoder0_7_128 (.in (opcode),.out(opcode_d));
    ysyx22041405_decoder_n_m #(.n(7),.m(128)) decoder1_7_128 (.in (funct7),.out(funct7_d));
    ysyx22041405_decoder_n_m #(.n(3),.m(8)) decoder2_3_8   (.in (funct3),.out(funct3_d));

    wire [ 6: 0]    inst_type;
    wire            R_type;
    wire            I_type;
    wire            S_type;
    wire            B_type;
    wire            U_type;
    wire            J_type;
    wire            Ebreak;

    assign R_type    = opcode_d[7'b0110011];
    assign I_type    = opcode_d[7'b0000011] || opcode_d[7'b0010011] || opcode_d[7'b1100111];
    assign S_type    = opcode_d[7'b0100011];
    assign B_type    = opcode_d[7'b1100011];
    assign U_type    = opcode_d[7'b0010111];
    assign J_type    = opcode_d[7'b1101111];
    assign Ebreak    = opcode_d[7'b1110011];
    assign inst_type = {Ebreak, R_type, I_type, S_type, B_type, U_type, J_type};
    //======================= Imm generated ==================================
    //inst split
    wire            inst_31;
    wire [30:25]    inst_30_25;
    wire [24:21]    inst_24_21;
    wire            inst_20;
    wire [19:12]    inst_19_12;
    wire [11: 8]    inst_11_8;
    wire            inst_7;
    wire [30:20]    inst_30_20;

    assign inst_31    = inst[31];
    assign inst_30_25 = inst[30:25];
    assign inst_24_21 = inst[24:21];
    assign inst_20    = inst[20];
    assign inst_19_12 = inst[19:12];
    assign inst_11_8  = inst[11: 8];
    assign inst_7     = inst[7];
    assign inst_30_20 = {inst_30_25, inst_24_21, inst_20};


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

    

endmodule //rv_IDU
