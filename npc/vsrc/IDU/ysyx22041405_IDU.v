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

    
    rv_IDU IDU 
    (
        .clk    	( clk     ),
        .rst    	( rst     ),
        .inst   	( inst    ),
        .rf_wdata   ( rf_wdata),
        .rf_rs1 	( rf_rs1  ),
        .rf_rs2 	( rf_rs2  ),
        .Imm    	( Imm     ),

        .alu_Ctrl   ( alu_Ctrl),
        .alu_s1_sel (alu_s1_sel),
        .alu_s2_sel (alu_s2_sel),
        .branch_add4(branch_add4),
        .branch_and (branch_and),
        .branch_src (branch_src),
        .mem_addr_sel(mem_addr_sel),
        .wb_sel     (   wb_sel  ),
        .wb_mask    (   wb_mask )
    );
    
    
endmodule //ysyx22041405_IDU

