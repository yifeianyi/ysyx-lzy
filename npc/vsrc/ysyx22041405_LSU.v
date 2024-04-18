module ysyx22041405_LSU#(parameter WIDTH = 32)(
    input                   clk,
    input                   rst,

    /*       input       */
    input  [`EX_LS_WIDTH - 1: 0] EX_LS_message,

    /*      output       */
    output [               4: 0] ls_rf_raddr1, 
    output [               4: 0] ls_rf_raddr2,
    output [`LS_DATA_WIDTH-1: 0] LS_Data_message,

    // /*    Ctrl signal    */
    output [`LS_CTRL_WIDTH-1: 0] LS_Ctrl_message
);

/**************************************************************************
    wire split
***************************************************************************/
wire [`EX_DATA_WIDTH - 1: 0] from_EX_Data;
wire [`EX_CTRL_WIDTH - 1: 0] from_EX_Ctrl;
assign { from_EX_Data, from_EX_Ctrl } = EX_LS_message;

//EX_Data
wire [WIDTH - 1: 0] alu_result,ls_rf_rdata2;
wire [ 4: 0] ls_rf_waddr;
wire [`IF_ID_WIDTH - 1: 0] if_mse;
wire [WIDTH - 1: 0] pc,inst;

assign{alu_result,ls_rf_rdata2, if_mse} = from_EX_Data;
assign{pc, inst} = if_mse;
wire [WIDTH - 1: 0] ls_rf_wdata = alu_result;

//EX_Ctrl
wire [`FORD_MES_WIDTH - 1: 0]LS_forward_mes;
wire [`LSU_CTRL_WIDTH - 1: 0]LS_Ctrl_mes;
wire [ 7: 0]ls_wmask;
wire ls_dm_we, ls_dm_re;

wire [`EX_BASE_MES_WIDTH-1:0] base_mse;
wire inst_ebreak,inst_valid;
assign {base_mse, LS_forward_mes, LS_Ctrl_mes} = from_EX_Ctrl[`EX_CTRL_WIDTH - 1: `WBU_CTRL_WIDTH];
assign {ls_wmask, ls_dm_we , ls_dm_re} = LS_Ctrl_mes;
assign {inst_ebreak, inst_valid} = base_mse;

wire [ 4:0] ls_rf_waddr;
wire ls_rf_we;
assign {ls_rf_we, ls_rf_raddr1, ls_rf_raddr2, ls_rf_waddr} = LS_forward_mes;


//================================================================================
wire [WIDTH - 1: 0] dm_addr = alu_result ;


/*======================================================================================
    Data memory
======================================================================================*/
    wire [WIDTH - 1: 0] ls_dm_rdata = ls_rf_rdata2;
    always @(posedge clk) begin
        if(ls_dm_we)pmem_write(dm_addr,ls_dm_rdata,ls_wmask);
    end

/**************************************************************************
    To WBU
***************************************************************************/

    
    assign LS_Data_message = {ls_rf_waddr, ls_rf_wdata, ls_dm_rdata, pc,inst};
    assign LS_Ctrl_message = {base_mse, ls_rf_we, LS_Ctrl_mes[`WBU_CTRL_WIDTH - 1: 0] };
endmodule