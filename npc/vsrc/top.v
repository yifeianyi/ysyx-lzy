module top#( parameter WIDTH = 32) (
    input                   clk,
    input                   rst,

    //debug
    output [WIDTH - 1: 0]   debug_inst,
    output [WIDTH - 1: 0]   debug_pc
);

    ysyx_22041405_core cpu(
        .clk        (clk),
        .rst        (rst),
        .inst       (debug_inst),
        .pc         (debug_pc)
    );
endmodule