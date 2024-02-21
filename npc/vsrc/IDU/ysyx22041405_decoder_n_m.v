module ysyx22041405_decoder_n_m#(parameter n = 3, m = 8)(
    input [n - 1: 0] in,
    output[m - 1: 0] co
);
genvar i;
generate for (i=0; i<m; i=i+1) begin : gen_for_dec_n_m
    assign co[i] = (in == i);
end endgenerate
    
endmodule //ysyx22041405_decoder_n_m
