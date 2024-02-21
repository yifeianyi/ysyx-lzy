`include "./rv_IDU.v"
module ysyx22041405_IDU#(parameter WIDTH = 32)(
    input   clk,
    input   rst,

    //regfiles 相关
    input [WIDTH - 1: 0] inst,
    input [WIDTH - 1: 0] rf_rd,
    output[WIDTH - 1: 0] rf_rs1,
    output[WIDTH - 1: 0] rf_rs2,
    output[WIDTH - 1: 0] Imm
);

    
    rv_IDU IDU#(
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
    
    
endmodule //ysyx22041405_IDU

