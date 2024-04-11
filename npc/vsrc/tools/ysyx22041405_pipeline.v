module ysyx22041405_pipeline #(parameter WIDTH = 32)
(
    input clk,
    input rst,
    input we,
    input [WIDTH-1:0] data_in,
    output reg [WIDTH-1:0] data_out
);

    always @(posedge clk or posedge rst) begin
        if (rst) 
            data_out <= 0;
        else if(we)
            data_out <= data_in;
        else 
            data_out <= data_out;
    end

endmodule