module ysyx22041405_WBU#(parameter WIDTH = 32)(
    /*       input       */
    input [WIDTH - 1: 0]     dm_addr,
    input [WIDTH - 1: 0]     dm_rdata,

    /*      output       */
    output[WIDTH - 1: 0]     rf_wdata,

    /*    Ctrl signal    */
    input                    wb_sel,
    input [WIDTH - 1: 0]     wb_mask
);
    assign rf_wdata = wb_sel? (dm_rdata & wb_mask) : dm_addr;
endmodule