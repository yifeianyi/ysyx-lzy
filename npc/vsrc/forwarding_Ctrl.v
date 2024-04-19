module forwarding_Ctrl#(parameter WIDTH = 32) (
    /*       input       */
    //EXU
    input [  4: 0]       ex_rf_raddr1,
    input [  4: 0]       ex_rf_raddr2,
    input [WIDTH - 1: 0] ex_rf_rdata1,
    input [WIDTH - 1: 0] ex_rf_rdata2,

    //LSU
    input [  4: 0]       ls_rf_waddr,
    input                ls_rf_we,
    input [WIDTH - 1: 0] ls_rf_wdata_i,   //exu前递的数据

    //WBU
    input [  4: 0]       wb_rf_waddr,
    input                wb_rf_we,
    input [WIDTH - 1: 0] wb_rf_wdata_i,   //lsu前递的数据

    /*       output       */
    output[WIDTH - 1: 0] ex_rf_rdata1_o,
    output[WIDTH - 1: 0] ex_rf_rdata2_o
);
    /********************     前递选通信号      ********************/
    //rs1
    wire ForwardA_exu = ls_rf_we && (ls_rf_waddr != 0 ) && (ls_rf_waddr == ex_rf_raddr1);
    wire ForwardA_lsu = wb_rf_we && (wb_rf_waddr != 0 ) && (wb_rf_waddr == ex_rf_raddr1) && (!ForwardA_exu);

    //rs2
    wire ForwardB_exu = ls_rf_we && (ls_rf_waddr != 0 ) && (ls_rf_waddr == ex_rf_raddr2);
    wire ForwardB_lsu = wb_rf_we && (wb_rf_waddr != 0 ) && (wb_rf_waddr == ex_rf_raddr2) && (!ForwardB_exu);


    /********************     前递数据选择      ********************
    *
    *   10: exu前递
    *   01：lsu前递
    *   00: 无前递
    *   11：除非受到了宇宙射线影响,否则不存在该值
    *
    ***************************************************************/
    wire [1:0] FA_sel   =   {ForwardA_exu, ForwardA_lsu};
    wire [1:0] FB_sel   =   {ForwardB_exu, ForwardB_lsu};
    `define EXU_FD 2'b10
    `define LSU_FD 2'b01
    `define NOT_FD 2'b00
    `define Err_FD 2'b11

    reg[WIDTH - 1: 0] r_data1, r_data2;
    assign ex_rf_rdata1_o = r_data1;
    assign ex_rf_rdata2_o = r_data2;
    always @(*) begin
        case (FA_sel)
            `EXU_FD: r_data1 = ls_rf_wdata_i;
            `LSU_FD: r_data1 = wb_rf_wdata_i;
            `NOT_FD: r_data1 = ex_rf_rdata1;
            default: r_data1 = 32'b0;
        endcase
        
        case (FB_sel)
            `EXU_FD: r_data2 = ls_rf_wdata_i;
            `LSU_FD: r_data2 = wb_rf_wdata_i;
            `NOT_FD: r_data2 = ex_rf_rdata2;
            default: r_data2 = 32'b0;
        endcase
    end

    
endmodule