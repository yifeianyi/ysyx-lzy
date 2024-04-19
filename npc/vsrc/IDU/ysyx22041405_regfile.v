module ysyx22041405_regfile#(parameter WIDTH = 32)(
    input  wire        clk,
    input  wire        rst,
    // READ PORT 1
    input  wire [ 4:0] raddr1,
    output wire [WIDTH -1: 0] rdata1,
    // READ PORT 2
    input  wire [ 4:0] raddr2,
    output wire [WIDTH -1: 0] rdata2,
    // WRITE PORT
    input  wire        we,       //write enable, HIGH valid
    input  wire [ 4:0] waddr,
    input  wire [WIDTH -1: 0] wdata
);
`define REGNUM 32
reg [WIDTH -1: 0] rf[`REGNUM -1: 0];
//WRITE

always @(negedge  clk) begin
    if(rst)begin
        integer i;
        for (i = 0; i < 32; i = i + 1) begin
            rf[i] <= 0;
        end
    end
    else if(we && waddr != 0)rf[waddr] <= wdata;
end

import "DPI-C" function void fetch_regfile_data(input logic [WIDTH-1:0] regfile_data[]);
initial fetch_regfile_data(rf); 
//READ OUT 
// assign rdata1 = (raddr1==5'b0) ? {WIDTH{1'b0}} : rf[raddr1];
// assign rdata2 = (raddr2==5'b0) ? {WIDTH{1'b0}} : rf[raddr2];

// 如果读地址等于写地址，并且正在写操作，则直接返回写数据
assign rdata1 = (raddr1 == 5'b0) ? {(WIDTH){1'b0}}:                
                (raddr1 == waddr && we) ? wdata:
                            rf[raddr1] ;
assign rdata2 = (raddr2 == 5'b0) ? {(WIDTH){1'b0}}:
                (raddr2 == waddr && we) ? wdata:
                            rf[raddr2] ;

endmodule
