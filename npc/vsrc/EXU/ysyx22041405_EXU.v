import "DPI-C" function void Ebreak();
module ysyx22041405_EXU#(parameter WIDTH = 32)(
    /*       input       */
    input               clk,
    input               rst,
    input [WIDTH - 1: 0] pc,
    input [`ID_EX_WIDTH - 1: 0] ID_EX_message,
    // input [WIDTH - 1: 0] Imm,
    // input [WIDTH - 1: 0] rf_rdata1,
    // input [WIDTH - 1: 0] rf_rdata2,
    
    /*      output       */
    output[        4: 0] ex_rf_waddr,
    output ex_rf_we,
    output[WIDTH - 1: 0] alu_result
    // output[WIDTH - 1: 0] pc_add4,
    // output[WIDTH - 1: 0] next_pc,

    /*    Ctrl signal    */
    // input [       13: 0] alu_Ctrl,
    // input                alu_s1_sel
    // input                alu_s2_sel
    // input [        3: 0] branch_sel,
    // input                branch_compare
);
    //========================== Fetch ID_message ===================================
    wire [WIDTH - 1: 0] Imm,rf_rdata1,rf_rdata2 ;
    wire [4:0] rf_waddr;
    wire [13:0]alu_Ctrl;
    wire alu_s2_sel,rf_we,inst_ebreak;
    wire [`ID_Data_WIDTH - 1:0] from_ID_Data;
    wire [`ID_CTRL_WIDTH - 1:0] from_ID_Ctrl;
    assign {from_ID_Ctrl, from_ID_Data} = ID_EX_message;
    assign {Imm, rf_rdata1, rf_rdata2, rf_waddr} = from_ID_Data;
    assign {alu_Ctrl, alu_s2_sel, rf_we, inst_ebreak} = from_ID_Ctrl;

    always @(*) begin
        if(inst_ebreak)Ebreak();
        
    end

    //---------过渡方案---------
    assign ex_rf_waddr = rf_waddr;
    assign ex_rf_we    = rf_we;


    wire [WIDTH - 1: 0] alu_src1;
    wire [WIDTH - 1: 0] alu_src2;
    // assign  alu_src1 = alu_s1_sel? rf_rdata1 : pc;
    assign  alu_src1 = rf_rdata1;//过渡方案
    assign  alu_src2 = alu_s2_sel? Imm : rf_rdata2;

    //======================== ALU module ================================
    ysyx22041405_ALU #(.WIDTH(32)) u_alu(
        .src1       (   alu_src1    ),
        .src2       (   alu_src2    ),
        .result     (   alu_result  ),
        .alu_Ctrl   (   alu_Ctrl    )
    );

    // assign pc_add4 = pc + 4;
    // ysyx22041405_branch #(.WIDTH(32)) u_branch(
    //     /*       input       */
    //     .pc             (   pc              ),
    //     .Imm            (   Imm             ),
    //     .rf_rdata1         (   rf_rdata1          ),
    //     .pc_add4        (   pc_add4         ),

    //     /*    Ctrl signal    */
    //     .branch_sel     (   branch_sel      ),
    //     .alu_result     (   alu_result      ),

    //     /*      output       */
    //     .next_pc        (   next_pc         )
    // );

    
endmodule //ysyx22041405_EXU
