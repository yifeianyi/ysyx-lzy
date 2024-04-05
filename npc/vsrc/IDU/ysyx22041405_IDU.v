module ysyx22041405_IDU #(parameter WIDTH = 32)(
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
    output                dm_re,
    output                dm_we,
    output [WIDTH - 1: 0] dm_mask,

    // WBU
    output                wb_sel,
    output [WIDTH - 1: 0] wb_mask
);

    
    rv_IDU IDU 
    (
        /*       input       */
        .clk    	( clk     ),
        .rst    	( rst     ),
        .inst   	( inst    ),
        .rf_wdata   ( rf_wdata),

        /*      output       */
        .rf_rs1 	( rf_rs1  ),
        .rf_rs2 	( rf_rs2  ),
        .Imm    	( Imm     ),

        /*    Ctrl signal    */
        //EXU
        .alu_Ctrl   ( alu_Ctrl),
        .alu_s1_sel (alu_s1_sel),
        .alu_s2_sel (alu_s2_sel),
        .branch_sel (branch_sel),
        .branch_compare (branch_compare),

        //MEM
        .dm_src_sel (dm_src_sel),
        .dm_mask    (dm_mask),
        .dm_re      (dm_re),
        .dm_we      (dm_we),

        //WBU
        .wb_sel     (   wb_sel  ),
        .wb_mask    (   wb_mask )
    );
    
    
endmodule //ysyx22041405_IDU

