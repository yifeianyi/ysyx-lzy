module top #(parameter WIDTH = 32)(
    input                   clk,
    input                   rst,  

    //debug
    output  [WIDTH - 1: 0]  pc,
    output  [WIDTH - 1: 0]  debug_inst
);
    rv_percpu cpu(
        .clk        (clk),
        .rst        (rst),
        .pc         (pc),
        .debug_inst (debug_inst)
    );
endmodule