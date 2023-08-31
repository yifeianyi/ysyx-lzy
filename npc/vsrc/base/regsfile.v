module regsfile #(ADDR_WIDTH = 1, DATA_WIDTH = 1) (
    input clk,
    input rst,

    input [ADDR_WIDTH-1:0] rf_raddr1,
    input [ADDR_WIDTH-1:0] rf_raddr2,
    input [DATA_WIDTH-1:0] rf_src1,
    input [DATA_WIDTH-1:0] rf_src2,

    input rf_we,
    input [ADDR_WIDTH-1:0] rf_waddr,
    input [DATA_WIDTH-1:0] rf_wdata
);
  reg [DATA_WIDTH-1:0] rf [ADDR_WIDTH-1:0];
  
  always @(posedge clk) begin
    if (rst)begin 
        for (integer i = 0; i < 32; i = i + 1) begin
            rf[i] = 32'h00000000; // 初始化所有寄存器为 0
        end
    end
    else if(rf_we)begin 
        rf[rf_waddr] <= wdata;
    end
  end

  assign rf_src1 = rf[rf_raddr1];
  assign rf_src2 = rf[rf_raddr2];

endmodule