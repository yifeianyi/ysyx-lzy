module top #(parameter WIDTH = 32)(
    input                   clk,
    input                   rst,  

    //debug
    output  [WIDTH - 1: 0]  pc,
    output  [WIDTH - 1: 0]  debug_inst
);  
    // reg [WIDTH - 1: 0] pc_r;
    // always @(posedge clk ) begin
    //     if(rst) pc_r <= 32'h80000000;
    //     else pc_r <= pc_r + 4;
    // end
    // assign pc = pc_r;

    rv_percpu cpu(
        .clk        (clk),
        .rst        (rst),
        .pc         (pc),
        .debug_inst (debug_inst)
    );
endmodule