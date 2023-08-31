module ysyx_22041405_IFU#(parameter WIDTH = 32)(
    input clk,
    input rst,

    input [WIDTH - 1: 0]    iram_rdata;
    output[WIDTH - 1: 0]    iram_addr;
    output[WIDTH - 1: 0]    pc;
    output[WIDTH - 1: 0]    instr;
);
    
    reg [WIDTH - 1: 0]  pc_t;
    always @(posedge clk) begin
      pc_t <= ret? 0x80000000: pc_t + 4;
    end

    assign pc = pc_t;
    assign iram_addr = pc;
    assign instr = iram_rdata;

endmodule
