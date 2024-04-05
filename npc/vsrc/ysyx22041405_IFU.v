module ysyx22041405_IFU#(parameter WIDTH = 32)(
    input clk,
    input rst,
    input  [      31 : 0] next_pc,
    output [      31 : 0] pc
);
    reg [WIDTH - 1: 0] pc_r;
    always @(posedge clk) begin
        if(rst) begin
            pc_r <= 32'b0;
        end
        else begin
            pc_r <= next_pc;
        end
    end
    assign pc   = pc_r;
    
endmodule //ysyx22041405_IFU
