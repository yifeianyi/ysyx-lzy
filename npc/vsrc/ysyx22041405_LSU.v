module ysyx22041405_LSU#(parameter WIDTH = 32)(
    input                   clk,
    input                   rst,

    /*       input       */
    input  [`EX_LS_WIDTH - 1: 0] EX_LS_message,

    /*      output       */
    // output [`LS_DATA_WIDTH-1: 0] LS_Data_message,

    // /*    Ctrl signal    */
    // output [`LS_CTRL_WIDTH-1: 0] LS_Ctrl_message,


    /*      Debug        */
    output [WIDTH - 1: 0] debug_inst,
    output [       31: 0] debug_pc
);

/**************************************************************************
    wire split
***************************************************************************/
wire [`EX_DATA_WIDTH - 1: 0] from_EX_Data;
wire [`EX_CTRL_WIDTH - 1: 0] from_EX_Ctrl;
assign { from_EX_Data, from_EX_Ctrl } = EX_LS_message;

//EX_Data
wire [WIDTH - 1: 0] alu_result,ls_rf_wdata;
wire [ 4: 0] ls_rf_waddr;
// wire ls_rf_we;
wire [`IF_ID_WIDTH - 1: 0] if_mse;
wire [WIDTH - 1: 0] pc,inst;

assign{alu_result, if_mse} = from_EX_Data;
assign{pc, inst} = if_mse;
assign ls_rf_wdata = alu_result;

//EX_Ctrl
wire inst_ebreak,inst_valid;
wire [`FORD_MES_WIDTH - 1: 0]LS_forward_mes;
wire [`LSU_CTRL_WIDTH - 1: 0]LS_Ctrl_mes;
wire [ 7: 0]ls_wmask;
wire ls_dm_we;

assign {inst_ebreak, inst_valid, LS_forward_mes, LS_Ctrl_mes} = from_EX_Ctrl;
assign {ls_wmask, ls_dm_we } = LS_Ctrl_mes;

wire [ 4:0] ls_rf_raddr1,ls_rf_raddr2 ,ls_rf_waddr;
wire ls_rf_we;
assign {ls_rf_we, ls_rf_raddr1, ls_rf_raddr2, ls_rf_waddr} = LS_forward_mes;


//----------------------------------------
    assign debug_inst = inst;
    assign debug_pc   = pc;


//================================================================================
wire [WIDTH - 1: 0] dm_addr = alu_result ;


/*======================================================================================
    Data memory
======================================================================================*/
    wire [WIDTH - 1: 0] ls_dm_rdata;
    always @(posedge clk) begin
        if(ls_dm_we)pmem_write(dm_addr,ls_dm_rdata,ls_wmask);
    end

    always @(*) begin
        if(inst_ebreak)Ebreak();
        if(inst_valid && inst!=0) inst_finished();
        else if(!inst_valid && inst !=0)inst_nsupport();
    end

/**************************************************************************
    To WBU
***************************************************************************/
    // wire [:] ;
    // assign LS_Data_message = { ls_dm_rdata,}

endmodule