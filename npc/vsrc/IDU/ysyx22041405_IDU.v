module ysyx22041405_IDU #(parameter WIDTH = 32)(
    /*       input       */
    input   clk,
    input   rst,
    input [`IF_ID_WIDTH - 1: 0] IF_ID_message,
    input [WIDTH - 1: 0] rf_wdata,
    input [        4: 0] rf_waddr,

    /*      output       */
    output[`ID_Data_WIDTH-1: 0] ID_Data_message,
    
    // /*    Ctrl signal    */
    input                       rf_we,
    output[`ID_CTRL_WIDTH-1: 0] ID_Ctrl_message
    // EXU 
    // output [3:0]          branch_sel,
    // output                branch_compare,

    // MEM
    // output                dm_src_sel,
    // output                dm_re,
    // output                dm_we,
    // output [        7: 0] dm_mask,

    // WBU
    // output                wb_sel,
    // output [        7: 0] wb_mask
);

    
    rv_IDU RV_IDU 
    (
        /*       input       */
        .clk    	( clk     ),
        .rst    	( rst     ),
        .IF_ID_message  (IF_ID_message),
        .rf_wdata   ( rf_wdata),
        .rf_waddr   ( rf_waddr),

        /*      output       */
        .ID_Data_message (ID_Data_message),

        /*    Ctrl signal    */
        .rf_we          (rf_we),
        .ID_Ctrl_message( ID_Ctrl_message)
        //EXU
        // .alu_Ctrl   ( alu_Ctrl),
        // .alu_s1_sel (alu_s1_sel)
        // .alu_s2_sel (alu_s2_sel)
        // .branch_sel (branch_sel),
        // .branch_compare (branch_compare),

        //MEM
        // .dm_src_sel (dm_src_sel),
        // .dm_mask    (dm_mask),
        // .dm_re      (dm_re),
        // .dm_we      (dm_we),

        //WBU
        // .wb_sel     (   wb_sel  ),
        // .wb_mask    (   wb_mask )
    );
    
    
endmodule //ysyx22041405_IDU

