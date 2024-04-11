module ysyx22041405_WBU#(parameter WIDTH = 32)(
    /*       input       */
    input [WIDTH - 1: 0]     dm_addr,
    input [WIDTH - 1: 0]     dm_rdata,

    /*      output       */
    output[WIDTH - 1: 0]     rf_wdata,

    /*    Ctrl signal    */
    input                    wb_sel,
    input [        7: 0]     wb_mask
);
    assign rf_wdata = rf_wdata_r;
    reg [WIDTH - 1: 0]rf_wdata_r;
    always @(*) begin
        case (wb_mask)
            `MASK_BYTE: rf_wdata_r = dm_rdata & 32'h000000ff;
            `MASK_HALF: rf_wdata_r = dm_rdata & 32'h0000ffff;
            `MASK_WORD: rf_wdata_r = dm_rdata & 32'hffffffff;
            default:    rf_wdata_r = dm_rdata & {WIDTH{1'b1}};

        endcase
    end
endmodule