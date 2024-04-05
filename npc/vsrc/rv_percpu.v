module rv_percpu#(parameter WIDTH = 32)(
    input                   clk,
    input                   rst,  

    //debug
    output  [WIDTH - 1: 0]  pc,
    output  [WIDTH - 1: 0]  debug_inst
);

assign debug_inst = inst;


wire [WIDTH-1:0] 	inst;
ysyx22041405_IFU#(
	.WIDTH 	( 32  )
) u_IFU
(
    /*       input       */
    .clk  	( clk   ),
	.rst  	( rst   ),
    .next_pc(next_pc),
	
    /*      output       */
    .pc   	( pc    )

    /*    Ctrl signal    */
);

ysyx22041405_LSU u_lsu(
    .clk        (   clk     ),
    .pc         (   pc      ),
    .dm_addr    (   dm_addr ),
    .rf_wdata   (  rf_wdata ),

    .inst       (   inst    ),
    .dm_rdata   ( dm_rdata  ),

    .dm_we      (   dm_we   ),
    .dm_re      (   dm_re   ),
    .dm_mask    (   dm_mask )
);

// outports wire
wire [WIDTH-1:0] 	rf_rs1;
wire [WIDTH-1:0] 	rf_rs2;
wire [WIDTH-1:0]    rf_wdata;
wire [WIDTH-1:0] 	Imm;
/*----------Ctrl wire---------------*/
// EXU 
wire [8:0]          alu_Ctrl;
wire                alu_s1_sel;
wire                alu_s2_sel;
wire [3:0]          branch_sel;
wire                branch_compare;


// MEM
wire                dm_src_sel;
wire                dm_re;
wire                dm_we;
wire [WIDTH - 1: 0] dm_mask;

// WBU
wire                wb_sel;
wire [WIDTH - 1: 0] wb_mask;

ysyx22041405_IDU #(
    .WIDTH 	( 32  )
)u_IDU
(
    /*       input       */
    .clk    	( clk     ),
    .rst    	( rst     ),
    .inst   	( inst    ),
    .rf_wdata   ( rf_wdata),

    /*      output       */
    .rf_rs1 	( rf_rs1  ),
    .rf_rs2 	( rf_rs2  ),
    .Imm    	( Imm     ),

    /*    Ctrl signal    */
    //EXU
    .alu_Ctrl   ( alu_Ctrl),
    .alu_s1_sel (alu_s1_sel),
    .alu_s2_sel (alu_s2_sel),
    .branch_sel (branch_sel),
    .branch_compare (branch_compare),

    //MEM
    .dm_src_sel (dm_src_sel ),
    .dm_mask    (dm_mask    ),
    .dm_re      (dm_re      ),
    .dm_we      (dm_we      ),

    //WBU
    .wb_sel     (   wb_sel  ),
    .wb_mask    (   wb_mask )
);

wire [WIDTH-1:0] 	alu_result;
wire [WIDTH-1:0] 	pc_add4;
wire [WIDTH-1:0] 	next_pc;
ysyx22041405_EXU #(
    .WIDTH(32)
)u_EXU
(
    .clk        (   clk     ),
    .rst        (   rst     ),

    /*       input       */
    .pc         (   pc      ),
    .Imm        (   Imm     ), 
    .rf_rs1     (   rf_rs1  ),
    .rf_rs2     (   rf_rs2  ),

    /*      output       */
    .alu_result ( alu_result),
    .pc_add4    ( pc_add4   ),
    .next_pc    ( next_pc   ),

    /*    Ctrl signal    */
    .alu_Ctrl   ( alu_Ctrl      ),
    .alu_s1_sel ( alu_s1_sel    ),
    .alu_s2_sel ( alu_s2_sel    ),
    .branch_sel ( branch_sel    ),
    .branch_compare(branch_compare)
);

wire [WIDTH-1:0] 	dm_rdata;
wire [WIDTH-1:0] 	dm_addr;
ysyx22041405_MEM#(
    .WIDTH(32)
) u_MEM
(
    .clk        (   clk     ),
    .rst        (   rst     ),
    /*       input       */
    .pc_add4    (   pc_add4 ),
    .alu_result ( alu_result),
    .rf_rs2     (   rf_rs2  ),

    /*      output       */
    .dm_rdata   ( dm_rdata  ),
    .rf_wdata   ( rf_wdata  ),
    .dm_addr    (  dm_addr  ),

    /*    Ctrl signal    */
    .dm_src_sel(dm_src_sel),
    .dm_re     (   dm_re  ),
    .dm_we     (   dm_we  ),
    .dm_mask   (  dm_mask )
);

ysyx22041405_WBU#(
    .WIDTH(32)
) u_WBU
(
    /*       input       */
    // .clk        (clk),
    // .rst        (rst),
    .dm_addr    (   dm_addr     ),
    .dm_rdata   (   dm_rdata   ),
    /*      output       */
    .rf_wdata   (   rf_wdata    ),

    /*    Ctrl signal    */
    .wb_sel     (   wb_sel      ),
    .wb_mask    (   wb_mask     )
);

endmodule //rv_percpu
