module ysyx_22041405_core#(parameter WIDTH = 32)(
    input                   clk,
    input                   rst,

    output                  iram_re,
    output [WIDTH-1 : 0]    iram_addr,
    input  [WIDTH-1 : 0]    iram_rdata,
    
    output                  dram_re,
    output                  dram_we,
    output [WIDTH-1 : 0]    dram_addr,
    output [WIDTH-1 : 0]    dram_wdata,
    input  [WIDTH-1 : 0]    dram_rdata   
);

    wire [WIDTH-1 : 0]  instr;
    wire [WIDTH-1 : 0]  cur_pc;
  
    ysyx_22041405_IFU(
        .clk        (clk),
        .rst        (rst),
        
        .iram_rdata (iram_rdata),
        .iram_addr  (iram_addr),
        .pc         (cur_pc),
        .instr      (instr)
    );

    wire rf_we;
    assign rf_we = 1'b1;
    ysyx_22041405_IDU(
        .clk        (clk),
        .rst        (rst),

        .instr      (instr),
        .pc         (cur_pc),

        .rf_we      (rf_we),
        .rf_waddr   (rf_waddr),
        .rf_wdata   (rf_rd),
        .rf_rs1     (rf_rs1),
        .rf_rs2     (rf_rs2),

        //contrl signal
        .alu_src1_sel   (alu_src1_sel),
        .alu_src2_sel   (alu_src2_sel),
        .alu_opcode     (alu_opcode),
        .instr_type     (instr_type)
        // .mem_we         (),
        // .mem_re         (),
        // .rf_rd_sel      (),
    );

    ysyx_22041405_EXU(
        .clk        (clk),
        .rst        (rst),

        //data
        .rf_rs1     (rf_rs1),
        .rf_rs2     (rf_rs2),

        //contrl signal
        .alu_src1_sel   (alu_src1_sel),
        .alu_src2_sel   (alu_src2_sel),
        .alu_opcode     (alu_opcode),
        .instr_type     (instr_type)
    );

    // ysyx_22041405_MEM(
    //     .clk        (clk),
    //     .rst        (rst),
    // );

    // ysyx_22041405_WB(
    //     .clk        (clk),
    //     .rst        (rst),
    // );



endmodule