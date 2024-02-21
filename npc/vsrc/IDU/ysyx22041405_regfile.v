module ysyx22041405_regfile#(parameter WIDTH = 32)(
    input  wire        clk,
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
reg [WIDTH -1: 0] rf[REGNUM -1: 0];

//WRITE
always @(posedge clk) begin
    if (we) rf[waddr]<= wdata;
end

//READ OUT 1
assign rdata1 = (raddr1==5'b0) ? {WIDTH{0}} : rf[raddr1];

//READ OUT 2
assign rdata2 = (raddr2==5'b0) ? {WIDTH{0}} : rf[raddr2];

endmodule
