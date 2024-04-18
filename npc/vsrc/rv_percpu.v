module rv_percpu#(parameter WIDTH = 32)(
    input                   clk,
    input                   rst,  

    //debug
    output  [WIDTH - 1: 0]  debug_pc,
    output  [WIDTH - 1: 0]  debug_inst
);
/*----------------------------- IFU -------------------------------------------*/
/* verilator lint_off UNOPTFLAT */
wire [WIDTH-1:0] 	IF_inst;
wire [     31:0]    IF_pc;
wire                IF_ID_we;
// wire nextpc_sel;

ysyx22041405_IFU#(
	.WIDTH 	( 32  )
) u_IFU
(
    /*       input       */
    .clk  	( clk   ), 
	.rst  	( rst   ),
    // .next_pc(next_pc),
	
    /*      output       */
    .pc   	    ( IF_pc    ),
    .inst       (IF_inst   ),

    /*    Ctrl signal    */
    .IF_ID_we   ( IF_ID_we )
    // .nextpc_sel(nextpc_sel)
);

wire [`IF_ID_WIDTH - 1:0] IF_message;
wire [`IF_ID_WIDTH - 1:0] IF_ID_message;
assign IF_message = {IF_pc ,IF_inst};
ysyx22041405_pipeline #(.WIDTH(`IF_ID_WIDTH)) IF_ID(
    .clk        (   clk          ),
    .rst        (   rst          ),
    .we         (   IF_ID_we     ),
    .data_in    (   IF_message   ),
    .data_out   (   IF_ID_message)
);

/*----------------------------- IDU -------------------------------------------*/
// outports wire
wire [WIDTH-1:0] 	ID_rf_rs1;
wire [WIDTH-1:0] 	ID_rf_rs2;
wire [WIDTH-1:0]    rf_wdata;
wire [WIDTH-1:0] 	Imm;
/*----------Ctrl wire---------------*/
// EXU 
// wire [3:0]          branch_sel;
// wire                branch_compare;

wire [`ID_Data_WIDTH - 1: 0]ID_Data_message;
wire [`ID_CTRL_WIDTH - 1: 0]ID_Ctrl_message;
wire [WIDTH - 1: 0] wb_rf_wdata;
wire [        4: 0] wb_rf_waddr;
wire ls_rf_we;
ysyx22041405_IDU #(
    .WIDTH 	( 32  )
)u_IDU
(
    /*       input       */
    .clk    	    ( clk     ),
    .rst    	    ( rst     ),
    .IF_ID_message  (IF_ID_message),
    .rf_wdata       ( wb_rf_wdata),
    .rf_waddr       ( wb_rf_waddr),  

    /*      output       */
    .ID_Data_message (ID_Data_message),


    /*    Ctrl signal    */
    .rf_we          (wb_rf_we),
    .ID_Ctrl_message( ID_Ctrl_message)

    //EXU
    // .branch_sel (branch_sel),
    // .branch_compare (branch_compare),

    // //WBU
    // .wb_sel     (   wb_sel  ),
    // .wb_mask    (   wb_mask )
);


wire [`ID_EX_WIDTH - 1: 0] ID_message = {ID_Ctrl_message, ID_Data_message};
wire [`ID_EX_WIDTH - 1: 0] ID_EX_message;
ysyx22041405_pipeline #(.WIDTH(`ID_EX_WIDTH)) ID_EX(
    .clk    (clk),
    .rst    (rst),
    .we     (1'b1),
    .data_in(ID_message),
    .data_out(ID_EX_message)
);


// /*----------------------------- EXU -------------------------------------------*/
wire [`EX_DATA_WIDTH - 1: 0] EX_Data_message;
wire [`EX_CTRL_WIDTH - 1: 0] EX_Ctrl_message;
ysyx22041405_EXU #(
    .WIDTH(32)
)u_EXU
(
    .clk        (   clk     ),
    .rst        (   rst     ),

    /*       input       */
    .ID_EX_message(ID_EX_message),

    /*      output       */
    .EX_Data_message(EX_Data_message),
    .ex_rf_raddr1   (ex_rf_raddr1),
    .ex_rf_raddr2   (ex_rf_raddr2),
    // .pc_add4    ( pc_add4   ),
    // .next_pc    ( next_pc   ),

    /*    Ctrl signal    */
    .EX_Ctrl_message(EX_Ctrl_message)
    // .branch_sel ( branch_sel    ),
    // .branch_compare(branch_compare)

);

wire [`EX_LS_WIDTH - 1: 0] EX_message = { EX_Data_message, EX_Ctrl_message };
wire [`EX_LS_WIDTH - 1: 0] EX_LS_message;
ysyx22041405_pipeline #(.WIDTH(`EX_LS_WIDTH)) EX_LS(
    .clk    (   clk ),
    .rst    (   rst ),
    .we     (   1'b1),
    .data_in(   EX_message  ),
    .data_out(  EX_LS_message)
);



/*----------------------------- MEM -------------------------------------------*/
wire [`LS_DATA_WIDTH - 1: 0] LS_Data_message; 
wire [`LS_CTRL_WIDTH - 1: 0] LS_Ctrl_message;
ysyx22041405_LSU#(
    .WIDTH(32)
) u_LSU
(
    .clk        (   clk     ),
    .rst        (   rst     ),

    /*       input       */
    .EX_LS_message  (EX_LS_message),

    /*      output       */
    .LS_Data_message(LS_Data_message),
    .ls_rf_raddr1   (ls_rf_raddr1),
    .ls_rf_raddr2   (ls_rf_raddr2),

    /*    Ctrl signal    */
    .LS_Ctrl_message(LS_Ctrl_message)
);


wire [`LS_WB_WIDTH - 1: 0] LS_message = {LS_Data_message, LS_Ctrl_message};
wire [`LS_WB_WIDTH - 1: 0] LS_WB_message;
ysyx22041405_pipeline #(.WIDTH(`LS_WB_WIDTH)) LS_WB(
    .clk        (   clk         ),
    .rst        (   rst         ),
    .we         (   1'b1        ),
    .data_in    (   LS_message  ),
    .data_out   (  LS_WB_message)
);

/*----------------------------- WBU -------------------------------------------*/
wire wb_rf_we;
wire [WIDTH - 1: 0]wb_rf_wdata;
ysyx22041405_WBU#(
    .WIDTH(32)
) u_WBU
(
    /*       input       */
    .LS_WB_message  (LS_WB_message),

    /*      output       */
    .wb_rf_raddr1   (wb_rf_raddr1),
    .wb_rf_raddr2   (wb_rf_raddr2),
    .wb_rf_waddr    (wb_rf_waddr),
    .wb_rf_wdata    (wb_rf_wdata),

    /*    Ctrl signal    */
    .wb_rf_we       (wb_rf_we   ),

    /*    Debug     */
    .debug_inst ( debug_inst  ),
    .debug_pc   ( debug_pc    )
);

/*--------------------------------- forwarding ------------------------------------------*/
wire [4:0] ex_rf_raddr1,ex_rf_raddr2;
wire [4:0] ls_rf_raddr1,ls_rf_raddr2;
wire [4:0] wb_rf_raddr1,wb_rf_raddr2;



endmodule //rv_percpu
