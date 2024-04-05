module ysyx22041405_encoder_n_m #(parameter n = 8,m = 3)( //m = log2(n)
    input [n-1:0] in,
    output[m-1:0] out 
);
reg [m-1:0] out_r;
integer i;
always @ (in)
begin
    out_r = {m{1'b0}}; 
    for (i = 0; i < n; i = i + 1) begin
        if (in[i] == 1'b1) begin
            out_r = i[m-1:0];
            break;
        end
    end
end

endmodule
