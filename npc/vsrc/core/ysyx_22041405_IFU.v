import "DPI-C" function void pmem_read(
  input int addr, output int data);
module ysyx_22041405_IFU#(parameter WIDTH = 32)(
    input clk,
    input rst,
    
    output [WIDTH - 1: 0]inst,
    output [WIDTH - 1: 0]pc
);
  reg  [WIDTH - 1: 0] pc_t;
  
  always @(posedge clk) begin
    if(rst)begin 
      pc_t <= 32'h80000000;
      pmem_read(32'h80000000, inst);
    end
    else begin
      pc_t <= pc + 4;
      pmem_read(pc_t, inst);
    end
  end

  assign pc = pc_t;

endmodule
