#include "execute.h"


// void step_and_dump_wave(){
//   top->eval();
//   Verilated::timeInc(1);
//   tfp->dump(Verilated::time());
// }
// void init_sim(){
//   Verilated::traceEverOn(true);
//   top->trace(tfp, 90);
//   tfp->open("dump.vcd");
//   printf(" simulator init finished.\n");
// }


// void execute(size_t n){
  
//   Log("==== in execute ===");
//   // if(contextp == NULL){
//   //   Log(" contextp is NULL ");
//   //   assert(0);
//   // } 

//   for (size_t i = n; i > 0; i--)
//   {
//     exec_once();
//   }
// }
// void exec_once(){
//   top->clk = 0;
//   top->rst = 0;
//   step_and_dump_wave();
//   Log("part1: pc = %x  inst = %x",top->debug_pc, top->debug_pc);

//   top->clk = 1;
//   top->rst = 0;
//   step_and_dump_wave();
//   Log("part2: pc = %x  inst = %x",top->debug_pc, top->debug_pc);
// }

// void sim_exit(){
//   step_and_dump_wave();
//   tfp->close();
// }