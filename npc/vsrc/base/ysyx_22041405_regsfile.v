module ysyx_22041405_regsfile #(parameter ADDR_WIDTH = 5, DATA_WIDTH = 32) (
    input clk,
    input rst,

    input [4:0] rf_raddr1,
    input [4:0] rf_raddr2,
    input [4:0] rf_waddr,

    output[DATA_WIDTH-1:0] rf_rs1,
    output[DATA_WIDTH-1:0] rf_rs2,
    input [DATA_WIDTH-1:0] rf_wdata
);
  reg [DATA_WIDTH-1:0] rf [2**ADDR_WIDTH - 1:0];
  
  always @(posedge clk) begin
    if (rst)begin 
        for (integer i = 0; i < 32; i = i + 1) begin
            rf[i] <= 32'h00000000; // 初始化所有寄存器为 0
        end
    end
    else begin 
        rf[rf_waddr] <= rf_wdata;
    end
  end

  assign rf_rs1 = (rf_raddr1==5'b00000)? 32'h00000000 : rf[rf_raddr1];
  assign rf_rs2 = (rf_raddr2==5'b00000)? 32'h00000000 : rf[rf_raddr2];

endmodule