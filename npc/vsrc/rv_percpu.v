module rv_percpu#(parameter WIDTH = 32)(
    input                   clk,
    input                   rst,  

    //debug
    output  [WIDTH - 1: 0]  pc,
    output  [WIDTH - 1: 0]  debug_inst
);
/*----------------------------- IFU -------------------------------------------*/
assign debug_inst = IF_ID_message[31:0];
assign pc = IF_pc;
/* verilator lint_off UNOPTFLAT */
wire [WIDTH-1:0] 	IF_inst;
wire [     31:0]    IF_pc;
wire [     31:0]    ID_pc;
wire [     31:0]    EX_pc;
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

    /*    Ctrl signal    */
    .IF_ID_we   ( IF_ID_we )
    // .nextpc_sel(nextpc_sel)
);


ysyx22041405_LSU u_lsu(
    /*       input       */
    .clk        (   clk     ),
    .pc         (   IF_pc   ),
    // .dm_addr    (   dm_addr ),
    // .rf_wdata   (  rf_wdata ),

    /*      output       */
    .inst       (   IF_inst )
    // .dm_rdata   ( dm_rdata  ),

    /*    Ctrl signal    */
    // .dm_we      (   dm_we   ),
    // .dm_re      (   dm_re   ),
    // .dm_mask    (   dm_mask )
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
wire [13:0]         alu_Ctrl;
wire                alu_s1_sel;
wire                alu_s2_sel;
// wire [3:0]          branch_sel;
// wire                branch_compare;

// // MEM
// wire                dm_src_sel;
// wire                dm_re;
// wire                dm_we;
// wire [        7: 0] dm_mask;

// // WBU
// wire                wb_sel;
// wire [        7: 0] wb_mask;
wire [`ID_Data_WIDTH - 1: 0]ID_Data_message;
wire [`ID_CTRL_WIDTH - 1: 0]ID_Ctrl_message;
ysyx22041405_IDU #(
    .WIDTH 	( 32  )
)u_IDU
(
    /*       input       */
    .clk    	    ( clk     ),
    .rst    	    ( rst     ),
    .IF_ID_message  (IF_ID_message),
    .rf_wdata       ( rf_wdata),
    .rf_waddr       ( ex_rf_waddr),

    /*      output       */
    .ID_Data_message (ID_Data_message),


    /*    Ctrl signal    */
    .rf_we          (ex_rf_we),
    .ID_Ctrl_message( ID_Ctrl_message)

    //EXU
    // .alu_Ctrl       ( alu_Ctrl),
    // .alu_s1_sel (alu_s1_sel)
    // .alu_s2_sel     (alu_s2_sel)
    // .branch_sel (branch_sel),
    // .branch_compare (branch_compare),

    //MEM
    // .dm_src_sel (dm_src_sel ),
    // .dm_mask    (dm_mask    ),
    // .dm_re      (dm_re      ),
    // .dm_we      (dm_we      ),

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
wire [WIDTH-1:0] 	alu_result;
wire [        4: 0] ex_rf_waddr;
wire  ex_rf_we;
// // wire [WIDTH-1:0] 	pc_add4;
// // wire [WIDTH-1:0] 	next_pc;
ysyx22041405_EXU #(
    .WIDTH(32)
)u_EXU
(
    .clk        (   clk     ),
    .rst        (   rst     ),

    /*       input       */
    .pc         (   pc      ),
    .ID_EX_message(ID_EX_message),

    /*      output       */
    
    .ex_rf_waddr(ex_rf_waddr),
    .ex_rf_we   (ex_rf_we   ),
    .alu_result ( alu_result)
    // .pc_add4    ( pc_add4   ),
    // .next_pc    ( next_pc   ),

    /*    Ctrl signal    */
    // .alu_Ctrl   ( alu_Ctrl      ),
    // .alu_s1_sel ( alu_s1_sel    )
    // .alu_s2_sel ( alu_s2_sel    )
    // .branch_sel ( branch_sel    ),
    // .branch_compare(branch_compare)
);
assign rf_wdata = alu_result;


/*----------------------------- MEM -------------------------------------------*/


// wire [WIDTH-1:0] 	dm_rdata;
// wire [WIDTH-1:0] 	dm_addr;
// ysyx22041405_MEM#(
//     .WIDTH(32)
// ) u_MEM
// (
//     .clk        (   clk     ),
//     .rst        (   rst     ),
//     /*       input       */
//     .pc_add4    (   pc_add4 ),
//     .alu_result ( alu_result),
//     .rf_rs2     (   rf_rs2  ),

//     /*      output       */
//     .dm_rdata   ( dm_rdata  ),
//     .rf_wdata   ( rf_wdata  ),
//     .dm_addr    (  dm_addr  ),

//     /*    Ctrl signal    */
//     .dm_src_sel(dm_src_sel),
//     .dm_re     (   dm_re  ),
//     .dm_we     (   dm_we  ),
//     .dm_mask   (  dm_mask )
// );


/*----------------------------- WBU -------------------------------------------*/
// ysyx22041405_WBU#(
//     .WIDTH(32)
// ) u_WBU
// (
//     /*       input       */
//     // .clk        (clk),
//     // .rst        (rst),
//     .dm_addr    (   dm_addr     ),
//     .dm_rdata   (   dm_rdata   ),
//     /*      output       */
//     .rf_wdata   (   rf_wdata    ),

//     /*    Ctrl signal    */
//     .wb_sel     (   wb_sel      ),
//     .wb_mask    (   wb_mask     )
// );

endmodule //rv_percpu
