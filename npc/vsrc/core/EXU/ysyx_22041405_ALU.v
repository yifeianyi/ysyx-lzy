module ysyx_22041405_ALU #(parameter WIDTH = 32) (
    input [WIDTH - 1: 0] src1,
    input [WIDTH - 1: 0] src2,
    output[WIDTH - 1: 0] result,

    input [        7: 0] alu_opcode,
    input                alu_add_or_sub,
    input                alu_U_or_S
);

    wire [WIDTH - 1: 0] alu_add;
    wire [WIDTH - 1: 0] alu_Lshift;
    wire [WIDTH - 1: 0] alu_slt;
    wire [WIDTH - 1: 0] alu_Rshift;
    wire [WIDTH - 1: 0] alu_direct;
    wire [WIDTH - 1: 0] alu_and;
    wire [WIDTH - 1: 0] alu_or;
    wire [WIDTH - 1: 0] alu_xor;

    assign alu_add      = src1 + src2;
    assign alu_Lshift   = 1'0;
    assign alu_slt      = 1'0;
    assign alu_Rshift   = 1'0;
    assign alu_direct   = 1'0;
    assign alu_and      = 1'0;
    assign alu_or       = 1'0;
    assign alu_xor      = 1'0;



    //  assign alu_opcode:
    // { alu_add   ,alu_Lshift ,alu_slt ,alu_Rshift, alu_direct,alu_and    ,alu_or  ,alu_xor };
    localparam ALUADD       = 8'b10000000;
    localparam ALULSHIFT    = 8'b01000000;
    localparam ALUSLT       = 8'b00100000;
    localparam ALURSHIFT    = 8'b00010000;
    localparam ALUDIRECT    = 8'b00001000;
    localparam ALUAND       = 8'b00000100;
    localparam ALUOR        = 8'b00000010;
    localparam ALUXOR       = 8'b00000001;

    reg [WIDTH - 1: 0] alu_result_d;
    always @(alu_opcode) begin
        case (alu_opcode)
            ALUADD:     alu_result_d = alu_add;
            ALULSHIFT:  alu_result_d = alu_Lshift;
            ALUSLT:     alu_result_d = alu_slt;
            ALURSHIFT:  alu_result_d = alu_Rshift;
            ALUDIRECT:  alu_result_d = alu_direct;
            ALUAND:     alu_result_d = alu_and;
            ALUOR:      alu_result_d = alu_or;
            ALUXOR:     alu_result_d = alu_xor;
            default:    alu_result_d = 0;
        endcase
    end

    assign alu_result = alu_result_d;

   
endmodule