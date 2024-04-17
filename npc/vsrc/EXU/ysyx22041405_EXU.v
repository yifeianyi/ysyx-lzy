import "DPI-C" function void Ebreak();
module ysyx22041405_EXU#(parameter WIDTH = 32)(
    /*       input       */
    input               clk,
    input               rst,
    input [`ID_EX_WIDTH - 1: 0] ID_EX_message,
    
    /*      output       */
    output[`EX_DATA_WIDTH - 1: 0] EX_Data_message,
    // output[WIDTH - 1: 0] pc_add4,
    // output[WIDTH - 1: 0] next_pc,

    /*    Ctrl signal    */
    output[`EX_CTRL_WIDTH - 1: 0] EX_Ctrl_message
    // input [        3: 0] branch_sel,
    // input                branch_compare
);
    
/*===============================================================
        wire spilt
===============================================================*/
    wire [WIDTH - 1: 0] Imm,rf_rdata1,rf_rdata2, pc, inst;
    wire [13:0]alu_Ctrl;
    wire alu_s1_sel,alu_s2_sel,inst_ebreak,inst_lui,inst_valid;
    wire [`FORD_MES_WIDTH- 1:0] EX_forward_mes;
    wire [`ID_Data_WIDTH - 1:0] from_ID_Data;
    wire [`ID_CTRL_WIDTH - 1:0] from_ID_Ctrl;
    assign {from_ID_Ctrl, from_ID_Data} = ID_EX_message;
    assign {Imm, rf_rdata1, rf_rdata2, pc, inst} = from_ID_Data;
    assign {alu_Ctrl, alu_s1_sel, alu_s2_sel, EX_forward_mes, inst_ebreak,inst_lui, inst_valid} = from_ID_Ctrl[`ID_CTRL_WIDTH - 1 :`LSU_CTRL_WIDTH];
    wire [        4: 0] ex_rf_raddr1,ex_rf_raddr2, ex_rf_waddr;
    wire ex_rf_we;
    assign {ex_rf_we, ex_rf_raddr1, ex_rf_raddr2, ex_rf_waddr} = EX_forward_mes;

//===========================================================================
//===========================================================================

    wire [WIDTH - 1: 0] alu_src1;
    wire [WIDTH - 1: 0] alu_src2;
    assign  alu_src1 = alu_s1_sel? (inst_lui?{32{1'b0}}: pc):rf_rdata1; // lui 指令走的x0 寄存器相加
    assign  alu_src2 = alu_s2_sel? Imm : rf_rdata2;

    //======================== ALU module ================================
    wire [WIDTH - 1: 0] alu_result;
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

//--------------------- 数据打包 ------------------------------------------
    wire [`IF_ID_WIDTH - 1: 0] if_mes = {pc, inst};
    wire [`BASE_MES_WIDTH-1:0] base_mse = { inst_ebreak,inst_lui, inst_valid };
    
    assign EX_Data_message = {alu_result, if_mes };
    assign EX_Ctrl_message = {base_mse, EX_forward_mes, from_ID_Ctrl[`LSU_CTRL_WIDTH -1 :0] };

    // assign EX_LS_message = {EX_Data_message, EX_Ctrl_message};
endmodule //ysyx22041405_EXU
