`include "./ysyx22041405_IDU.v"
module rv_percpu#(parameter WIDTH = 32)(
    input                   clk,
    input                   rst,  

    //debug
    output  [WIDTH - 1: 0]  pc,
    output  [WIDTH - 1: 0]  inst
);
    // outports wire
wire [WIDTH-1:0] 	inst;
wire [WIDTH-1:0] 	pc;

ysyx22041405_IFU u_ysyx22041405_IFU#(
	.WIDTH 	( 32  )
)
(
	.clk  	( clk   ),
	.rst  	( rst   ),
	.inst 	( inst  ),
	.pc   	( pc    )
);


// outports wire
wire [WIDTH-1:0] 	rf_rs1;
wire [WIDTH-1:0] 	rf_rs2;
wire [WIDTH-1:0] 	Imm;

ysyx22041405_IDU u_ysyx22041405_IDU#(
    .WIDTH 	( 32  )
)
(
    .clk    	( clk     ),
    .rst    	( rst     ),
    .inst   	( inst    ),
    .rf_rd  	( rf_rd   ),
    .rf_rs1 	( rf_rs1  ),
    .rf_rs2 	( rf_rs2  ),
    .Imm    	( Imm     )
);


endmodule //rv_percpu
