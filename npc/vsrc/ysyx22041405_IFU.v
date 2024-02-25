module ysyx22041405_IFU#(parameter WIDTH = 32)(
    input clk,
    input rst,
    output [WIDTH - 1: 0] inst,
    output [WIDTH - 1: 0] pc,
    input pc_en
);
    reg [WIDTH - 1: 0] pc_t;

    always @(posedge clk) begin
        if(rst) begin
            pc_t <= {WIDTH{1'b0}};
        end
        else begin
            pc_t <= pc_t + 4;
        end
    end
    assign pc   = pc_t;
    assign inst = {WIDTH{1'b0}};// ToDo
    
endmodule //ysyx22041405_IFU
