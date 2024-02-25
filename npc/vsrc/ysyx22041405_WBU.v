module ysyx22041405_WBU#(parameter WIDTH = 32)(
    input [WIDTH - 1: 0]     mem_src,
    input [WIDTH - 1: 0]     mem_rdata,
    input                    wb_sel,

    output[WIDTH - 1: 0]     rf_wdata
);
    assign rf_wdata = wb_sel? mem_rdata : mem_src;
endmodule