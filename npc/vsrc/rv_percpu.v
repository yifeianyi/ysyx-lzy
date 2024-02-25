module rv_percpu#(parameter WIDTH = 32)(
    input                   clk,
    input                   rst,  

    //debug
    output  [WIDTH - 1: 0]  pc,
    output  [WIDTH - 1: 0]  debug_inst
);
    // outports wire
wire [WIDTH-1:0] 	inst;
wire                pc_en;  

ysyx22041405_IFU#(
	.WIDTH 	( 32  )
) u_ysyx22041405_IFU
(
    /*       input       */
    .clk  	( clk   ),
	.rst  	( rst   ),
	
    /*      output       */
    .pc   	( pc    ),
    .inst 	( inst  ),

    /*    Ctrl signal    */
    .pc_en  ( pc_en )
);


// outports wire
wire [WIDTH-1:0] 	rf_rs1;
wire [WIDTH-1:0] 	rf_rs2;
wire [WIDTH-1:0]    rf_wdata;
wire [WIDTH-1:0] 	Imm;
// Ctrl wire
wire [  2:  0  ]    alu_Ctrl;
wire                alu_s1_sel;
wire                alu_s2_sel;
wire                branch_and;
wire                branch_add4;
wire                branch_src;
wire                mem_addr_sel;
wire                wb_sel;
wire                wb_mask;

ysyx22041405_IDU #(
    .WIDTH 	( 32  )
)u_ysyx22041405_IDU
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
    // EXU 
    .alu_Ctrl   ( alu_Ctrl      ),
    .alu_s1_sel ( alu_s1_sel    ),
    .alu_s2_sel ( alu_s2_sel    ),
    .branch_and ( branch_and    ),
    .branch_add4( branch_add4   ),
    .branch_src ( branch_src    ),

    // MEM
    .mem_addr_sel( mem_addr_sel ),

    // WBU
    .wb_sel     ( wb_sel        ),
    .wb_mask    ( wb_mask       )

);

wire [WIDTH-1:0] 	alu_result;
wire [WIDTH-1:0] 	pc_add4;
wire [WIDTH-1:0] 	next_pc;
ysyx22041405_EXU #(
    .WIDTH(32)
)u_ysyx22041405_EXU
(
    /*       input       */
    .clk        (   clk     ),
    .rst        (   rst     ),
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
    .branch_and ( branch_and    ),
    .branch_add4( branch_add4   ),
    .branch_src ( branch_src    )
);

wire [WIDTH-1:0] 	mem_rdata;
wire [WIDTH-1:0] 	mem_src;
ysyx22041405_MEM#(
    .WIDTH(32)
) u_ysyx22041405_MEM
(
    /*       input       */
    .clk        (   clk     ),
    .rst        (   rst     ),
    .pc_add4    (   pc_add4 ),
    .alu_result ( alu_result),
    .rf_rs2     (   rf_rs2  ),

    /*      output       */
    .mem_rdata  ( mem_rdata ),
    .rf_wdata   ( rf_wdata  ),
    .mem_src    (  mem_src  ),

    /*    Ctrl signal    */
    .mem_addr_sel(mem_addr_sel)
);

ysyx22041405_WBU#(
    .WIDTH(32)
) u_ysyx22041405_WBU
(
    /*       input       */
    // .clk        (clk),
    // .rst        (rst),
    
    .mem_src    (   mem_src     ),
    .mem_rdata  (   mem_rdata   ),

    /*      output       */
    .rf_wdata   (   rf_wdata    ),

    /*    Ctrl signal    */
    .wb_sel     ( wb_sel        )
);

endmodule //rv_percpu
