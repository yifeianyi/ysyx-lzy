module ysyx22041405_IDU #(parameter WIDTH = 32)(
    /*       input       */
    input   clk,
    input   rst,
    input [`IF_ID_WIDTH - 1: 0] IF_ID_message,
    input [WIDTH - 1: 0] rf_wdata,
    input [        4: 0] rf_waddr,

    /*      output       */
    output[`ID_Data_WIDTH-1: 0] ID_Data_message,
    // output[        4: 0] id_rf_raddr1,
    // output[        4: 0] id_rf_raddr2,
    // output[WIDTH - 1: 0] id_rf_rdata1,
    // output[WIDTH - 1: 0] id_rf_rdata2,
    
    // /*    Ctrl signal    */
    input                       rf_we,
    output[`ID_CTRL_WIDTH-1: 0] ID_Ctrl_message
    // EXU 
    // output [3:0]          branch_sel,
    // output                branch_compare,
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

        // .id_rf_raddr1   (id_rf_raddr1),
        // .id_rf_raddr2   (id_rf_raddr2),
        // .id_rf_rdata1   (id_rf_rdata1),
        // .id_rf_rdata2   (id_rf_rdata2),

        /*    Ctrl signal    */
        .rf_we          (rf_we),
        .ID_Ctrl_message( ID_Ctrl_message)
        //EXU
        // .branch_sel (branch_sel),
        // .branch_compare (branch_compare),
    );
    
    
endmodule //ysyx22041405_IDU

