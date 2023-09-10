#include "common.h"
#include "execute.h"
#include "paddr.h"


void step_and_dump_wave();
void exec_once();
void sim_exit();
void init_sim();
void init_cpu();
void execute(size_t n);

static bool ebreak_flag = false;
extern "C" void Ebreak(){
  ebreak_flag = true;
  Log("======== Ebreak test ==========");
  // Log("======== addi test ==========");
}

int main(int argc ,char** argv){
  init_sim();
  init_mem();
  init_cpu();

  execute(10);

  sim_exit();
  return 0;
}



//======================== execute =========================
void step_and_dump_wave(){
  top->eval();
  contextp->timeInc(1);
  tfp->dump(contextp->time());
}

void exec_once(){
  top->clk = 0;
  top->rst = 0;
  step_and_dump_wave();

  top->clk = 1;
  top->rst = 0;
  step_and_dump_wave();
}
void sim_exit(){
  step_and_dump_wave();
  tfp->close();
}
void init_sim(){
  contextp->traceEverOn(true);
  top->trace(tfp, 90);
  tfp->open("dump.vcd");
  printf(" simulator init finished.\n");
}
void init_cpu(){
  top->clk = 0;
  top->rst = 1;
  step_and_dump_wave();
  // Log("part1: pc = %x inst = %x",top->debug_pc ,top->debug_inst);
  top->clk = 1;
  top->rst = 1;
  step_and_dump_wave();
  // Log("part2: pc = %x inst = %x",top->debug_pc ,top->debug_inst);
}
void execute(size_t n){
  
  Log("==== in execute ===");
  if(contextp == NULL){
    Log(" contextp is NULL ");
    assert(0);
  } 

  for (size_t i = n; i > 0; i--)
  {
    exec_once();
    Log(" pc = %x ,inst = %x ",top->debug_pc ,top->debug_inst);
    if(ebreak_flag){
      // Log("---- ebreak_flag: %d ----",ebreak_flag);
      break;
    }
  }
}