#include "common.h"
#include <npcState.hpp>
extern NPCState npc_status;
CPU_module percpu;

static void execute(uint64_t n){
    for(int i=0;i<n;i++){
        Log("Cur_pc  :"FMT_WORD,percpu.getCurPC());
        // Log("inst:"FMT_PADDR,percpu.getCurInst());
        percpu.stepAndWave();
        if(npc_status.state == NPC_ABORT || npc_status.state == NPC_END){
            npc_status.halt_pc = percpu.getCurPC();
            break;
        }
            
        // percpu.updateCPUstate();
        // percpu.displayReg();
    }
}
void npc_execute(uint64_t n){
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
    execute(n);
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



