module ysyx_22041405_decoder_n_m #(parameter n = 1, m = 1)(
    input [n - 1: 0] in,
    output[m - 1: 0] out
);
genvar i;
generate for (i=0; i<m; i=i+1) begin : gen_for_decoder_n_m
    assign out[i] = (in == i);
end endgenerate
endmodule