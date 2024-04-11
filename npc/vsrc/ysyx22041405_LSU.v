import "DPI-C" function void pmem_read(
  input int raddr, output int rdata);
import "DPI-C" function void pmem_write(
  input int waddr, input int wdata, input byte mask);
module ysyx22041405_LSU#(parameter WIDTH = 32)(
    input                   clk,

    /*      input        */
    input [WIDTH - 1: 0]    pc,
    // input [WIDTH - 1: 0]    dm_addr,
    // input [WIDTH - 1: 0]    rf_wdata,

    /*      output       */
    output[WIDTH - 1: 0]    inst
    // output[WIDTH - 1: 0]    dm_rdata,

    
    // /*    Ctrl signal    */
    // input                   dm_we,
    // input                   dm_re,
    // input [7:0]             dm_mask
);
    
    /*          Data-Memory Controller          */
    // reg [WIDTH - 1: 0] dm_rdata_r;
    // always @(posedge clk) begin
    //     if(dm_we) pmem_write(dm_addr, rf_wdata, dm_mask);
    // end
    // assign dm_rdata = dm_rdata_r;
    // wire dm_re = 1;
    always @(posedge clk) begin
        pmem_read( pc, inst);
        // if(dm_re)pmem_read(pc, dm_rdata_r);
        // else dm_rdata_r = 0;
        
    end

endmodule