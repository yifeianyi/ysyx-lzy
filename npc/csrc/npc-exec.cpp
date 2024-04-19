#include "common.h"
#include <npcState.hpp>
#include <itrace.hpp>
extern void (*ref_difftest_regcpy)(void *dut, bool direction);
extern void (*ref_difftest_exec)(uint64_t n);
extern NPCState npc_status;
extern word_t *GPR;
CPU_module percpu;
CPU_state Ref_state;
bool Inst_finished = false;
extern "C"  void inst_finished(){
        Inst_finished = true;
}

static void checkregs(CPU_state *ref,paddr_t ref_pc);

static void execClock(uint64_t n){
    for(int i=0;i<n;i++){
        // Log("inst:"FMT_PADDR,percpu.getCurInst());
        percpu.stepAndWave();
        if(npc_status.state == NPC_ABORT || npc_status.state == NPC_END){
            npc_status.halt_pc = percpu.getCurPC();
            break;
        }
        // Log("Cur_pc  :"FMT_WORD,percpu.getCurPC());
    }
}

static void execInst(uint64_t n){
    // Log("si n(n=%ld)",n);
    for(int i=0;i<n;i++){
        while(!Inst_finished){
            execClock(1);
        }
        Inst_finished = false;


        if(percpu.itraceTurn){
            Itrace_Record(percpu.getCurPC());
        }
        //difftest
        //执行前先拿到pc，执行后pc值会变.
        ref_difftest_regcpy(&Ref_state, DIFFTEST_TO_DUT);
        paddr_t Ref_pc = Ref_state.pc;

        ref_difftest_exec(1);
        ref_difftest_regcpy(&Ref_state, DIFFTEST_TO_DUT);
        checkregs(&Ref_state,Ref_pc);
        

        if(npc_status.state == NPC_END || npc_status.state == NPC_ABORT)break;
    }
}

void npc_execute(uint64_t n,std::string arg){
    switch (npc_status.state)
    {
    case NPC_END: case NPC_ABORT: 
        // npc_status.halt_pc = cpu.pc;
        printf("Program execution has ended. To restart the program, exit NPC and run again.\n");
        return;
    default:
        npc_status.state = NPC_RUNNING;
        break;
    }

    //-----------------
    if(arg == "sc")
        execClock(n);
    else if(arg == "si")
        execInst(n);
    else Assert(0,"npc-exec error.");


    switch (npc_status.state)
    {
    case NPC_RUNNING: npc_status.state = NPC_STOP;break;
    case NPC_END: case NPC_ABORT:
        npc_status.halt_ret = 0;
        
        Log("npc: %s at pc = " FMT_WORD,
            (npc_status.state == NPC_ABORT ? ASNI_FMT("ABORT", ASNI_FG_RED) :
            (npc_status.halt_ret == 0 ? ASNI_FMT("HIT GOOD TRAP", ASNI_FG_GREEN) :
            ASNI_FMT("HIT BAD TRAP", ASNI_FG_RED))),
            npc_status.halt_pc);
    case NPC_QUIT: break;
        
    }
    
}

//===================================== Difftest ===============================================
static const char *regs[] = {
  "$0", "ra", "sp", "gp", "tp", "t0", "t1", "t2",
  "s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5",
  "a6", "a7", "s2", "s3", "s4", "s5", "s6", "s7",
  "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"
};
void diff_compare_regsdisplay(CPU_state *ref_r,int idx){
  for (int i = 0; i < 32; i++)
  {
    if(i%3==0 && i!=0)printf("\n");
    if(i==idx){
      printf("\033[31m%4s:  dut = "FMT_PADDR"\t  ref = "FMT_PADDR"\033[37m \033[0m\t", regs[i], GPR[i],ref_r->gpr[i]);
    }
    else{
      printf("%4s:  dut = "FMT_PADDR"\t  ref = "FMT_PADDR"\t", regs[i], GPR[i],ref_r->gpr[i]);
    }
  }
  printf("\n");
}
bool isa_difftest_checkregs(CPU_state *ref_r, paddr_t ref_pc) {
    paddr_t dut_pc = percpu.getCurPC();
    if( dut_pc != ref_pc){
        printf("\033[31mPC:\n\tdut = "FMT_PADDR"\n\tref = "FMT_PADDR"\033[37m \033[0m\n", percpu.getCurPC(), ref_pc);
        diff_compare_regsdisplay(ref_r,-1);
        return false;
    }

    for(int i=0;i<32;i++){
        if(ref_r->gpr[i] !=  GPR[i])
        {
            Log("reg is error!!!");
            printf("PC:\n\tdut:"FMT_PADDR" \n\tref:"FMT_PADDR"\n",percpu.getCurPC(),ref_pc);
            diff_compare_regsdisplay(ref_r,i);
            return false;
        }
    }
  return true;
}
static void checkregs(CPU_state *ref,paddr_t ref_pc){

 if(!isa_difftest_checkregs(ref, ref_pc) ){
    npc_status.state    = NPC_ABORT;
    npc_status.halt_pc  = percpu.getCurPC();

    Display_ringbuf();
 }
}