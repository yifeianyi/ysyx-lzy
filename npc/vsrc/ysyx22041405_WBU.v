module ysyx22041405_WBU#(parameter WIDTH = 32)(
    /*       input       */
    input [`LS_WB_WIDTH - 1: 0] LS_WB_message,

    /*      output       */
    output[WIDTH - 1: 0]     wb_rf_wdata,
    output[        4: 0]     wb_rf_waddr,
    // output[        4: 0]     wb_rf_raddr1,
    // output[        4: 0]     wb_rf_raddr2,

    /*    Ctrl signal    */
    output                   wb_rf_we,

    /*      Debug        */
    output [WIDTH - 1: 0] debug_inst,
    output [       31: 0] debug_pc
);
    /*===============================================================
        wire spilt
    ===============================================================*/
    wire [`LS_DATA_WIDTH - 1: 0] from_LS_Data;
    wire [`LS_CTRL_WIDTH - 1: 0] from_LS_Ctrl;
    assign {from_LS_Data , from_LS_Ctrl} = LS_WB_message;

    wire [`FORD_MES_WIDTH- 1: 0] WB_forward_mes;


    //--- Data ---
    wire [WIDTH - 1: 0] dm_rdata, ls_rf_wdata, inst;
    wire [ 4: 0]ls_rf_waddr;
    wire [31: 0] pc;
    wire [`IF_ID_WIDTH - 1: 0] if_mes;
    assign {ls_rf_waddr, ls_rf_wdata, dm_rdata ,if_mes} = from_LS_Data;
    assign {pc, inst} = if_mes;

    //--- Ctrl ---
    wire [`EX_BASE_MES_WIDTH-1:0] base_mse;
    wire inst_ebreak, inst_valid;
    wire [  7: 0] wb_rmask;

    assign {base_mse, wb_rf_we, wb_rmask} = from_LS_Ctrl;
    assign { inst_ebreak, inst_valid } = base_mse;

    //================================================================
    //================================================================

    assign wb_rf_wdata = ls_rf_wdata;   // 过渡方案
    assign wb_rf_waddr = ls_rf_waddr;

    // reg [WIDTH - 1: 0]rf_wdata_r;
    // always @(*) begin
    //     case (wb_mask)
    //         `MASK_BYTE: rf_wdata_r = dm_rdata & 32'h000000ff;
    //         `MASK_HALF: rf_wdata_r = dm_rdata & 32'h0000ffff;
    //         `MASK_WORD: rf_wdata_r = dm_rdata & 32'hffffffff;
    //         default:    rf_wdata_r = dm_rdata & {WIDTH{1'b1}};
    //     endcase
    // end


    always @(*) begin
        if(inst_ebreak)Ebreak();
        if(inst_valid && inst!=0) inst_finished();
        else if(!inst_valid && inst !=0)inst_nsupport();
    end

    //-----------Debug--------------------
    assign debug_inst = inst;
    assign debug_pc   = pc;
endmodule