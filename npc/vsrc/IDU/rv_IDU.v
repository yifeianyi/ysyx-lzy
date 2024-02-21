`include "./ysyx22041405_decoder_n_m.v"
`include "./ysyx22041405_regfile.v"
module rv_IDU#(parameter WIDTH = 32)(
    input   clk,
    input   rst,

    //regfiles port
    input [WIDTH - 1: 0] inst,
    // input [WIDTH - 1: 0] rf_rd,
    output[WIDTH - 1: 0] Imm,
    output[WIDTH - 1: 0] rf_rdata1,
    output[WIDTH - 1: 0] rf_rdata2,
    output[WIDTH - 1: 0] rf_wdata,
    
    //============ ALU ==============
    output [2:0] 
);
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

    ysyx22041405_decoder_n_m decoder0_7_128#(.n(7),.m(128))(.in (opcode),.out(opcode_d));
    ysyx22041405_decoder_n_m decoder1_7_128#(.n(7),.m(128))(.in (funct7),.out(funct7_d));
    ysyx22041405_decoder_n_m decoder2_3_8  #(.n(7),.m(128))(.in (funct3),.out(funct3_d));

    wire [ 6: 0]    inst_type;
    wire            R_type;
    wire            I_type;
    wire            S_type;
    wire            B_type;
    wire            U_type;
    wire            J_type;
    wire            Ebreak;

    assign R_type    = opcode_d[6'b0110011];
    assign I_type    = opcode_d[6'b0000011] || opcode_d[6'b0010011] || opcode_d[6'b1100111];
    assign S_type    = opcode_d[6'b0100011];
    assign B_type    = opcode_d[6'b1100011];
    assign U_type    = opcode_d[6'b0010111];
    assign J_type    = opcode_d[6'b1101111];
    assign Ebreak    = opcode_d[6'b1110011];
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
    wire [WIDTH-1:0]Imm;
    wire [WIDTH-1:0]imm_I;
    wire [WIDTH-1:0]imm_S;
    wire [WIDTH-1:0]imm_B;
    wire [WIDTH-1:0]imm_U;
    wire [WIDTH-1:0]imm_J;
    assign imm_I = {{21{inst_31}}, inst_30_25, inst_24_21, inst_20};
    assign imm_S = {{21{inst_31}}, inst_30_25, inst_11_8 , inst_7};
    assign imm_B = {{20{inst_31}}, inst_7, inst_30_25, inst_11_8, 1'b0};
    assign imm_U = {  inst_31    , inst_30_20, inst_19_12, 12'b0};
    assign imm_J = {{12{inst_31}}, inst_19_12, inst_20, inst_30_25, inst_24_21, 1'b0};

    always @(*)begin
        case (inst_type)
            I_TYPE: Imm = imm_I;
            S_TYPE: Imm = imm_S;
            B_TYPE: Imm = imm_B;
            U_TYPE: Imm = imm_U;
            J_TYPE: Imm = imm_J;
            default: Imm = {WIDTH{0}};
        endcase
    end
    //=======================     regfile    ==================================
    // outports wire
    wire            we;
    wire [31:0]     rf_rdata1;
    wire [31:0]     rf_rdata2;
    wire [31:0]     rf_wdata;
    assign we = 1'b1;
    ysyx22041405_regfile u_regfile#(
        .WIDTH( 32  )
    )
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
