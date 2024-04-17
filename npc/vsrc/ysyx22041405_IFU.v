module ysyx22041405_IFU#(parameter WIDTH = 32)(
    input clk,
    input rst,
    // input  [      31 : 0] next_pc,

    /*      output       */
    output [      31 : 0] pc,
    output [WIDTH - 1: 0] inst,
    /*    Ctrl signal    */
    output  IF_ID_we
    // input nextpc_sel
);
    reg [WIDTH - 1: 0] pc_r;
    initial begin
        pc_r = 32'h80000000;
    end

    always @(posedge clk) begin
        if(rst) begin
            pc_r <= 32'h80000000;
        end
        else begin
            // pc_r <= nextpc_sel?next_pc:(pc_r + 4);
            pc_r <= pc_r + 4;
        end

        pmem_read(pc , inst);
    end
    assign pc   = pc_r;
    
    /*-------------------------------------*/
    assign IF_ID_we = 1'b1;
    // reg  [1: 0] IF_state;
    // reg IF_ID_we_r;
    
    // initial begin
    //     IF_state = `IDLE;
    // end

    // always @(posedge clk)begin
    //     if(rst) begin
    //         IF_state <= `IDLE;
    //     end
    //     else begin
    //         case (IF_state)
    //             `IDLE:begin
    //                 IF_state   <= `WAIT;
    //             end
    //             `WAIT: begin
    //                 IF_state   <= `WAIT;
    //             end
    //             default: IF_state <= `STATE_ERROR;
    //         endcase
    //     end
    // end
    // always@(*)begin
    //     case (IF_state)
    //         `IDLE:begin
    //             IF_ID_we_r = 1'b0;
    //         end
    //         `WAIT: begin
    //             IF_ID_we_r = 1'b1;
    //         end
    //     endcase
    // end
endmodule //ysyx22041405_IFU
