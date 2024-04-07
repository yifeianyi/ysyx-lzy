#include "common.h"

extern NPCState npc_status;
uint64_t g_nr_guest_inst = 0;
static uint64_t g_timer = 0; // unit: us

static void statistic() {
#define NUMBERIC_FMT MUXDEF(CONFIG_TARGET_AM, "%", "%'") PRIu64
  Log("host time spent = " NUMBERIC_FMT " us", g_timer);
  Log("total guest instructions = " NUMBERIC_FMT, g_nr_guest_inst);
  if (g_timer > 0) Log("simulation frequency = " NUMBERIC_FMT " inst/s", g_nr_guest_inst * 1000000 / g_timer);
  else Log("Finish running in less than 1 us and can not calculate the simulation frequency");
}



static void execute(uint64_t n){
    //过渡方案.
    npc_status.state = NPC_END;
}

void npc_execute(uint64_t n){
    switch (npc_status.state)
    {
    case NPC_END: case NPC_ABORT: 
        npc_status.halt_pc = 
        printf("Program execution has ended. To restart the program, exit NPC and run again.\n");
        return;
    default:
        npc_status.state = NPC_RUNNING;
        break;
    }

    uint64_t timer_start = get_time();
    execute(n);
    uint64_t timer_end = get_time();
    g_timer += timer_end - timer_start;

    switch (npc_status.state)
    {
    case NPC_RUNNING: npc_status.state = NPC_STOP;break;
    case NPC_END: case NPC_ABORT:
        Log("npc: %s at pc = " FMT_WORD,
          (npc_status.state == NPC_ABORT ? ASNI_FMT("ABORT", ASNI_FG_RED) :
           (npc_status.halt_ret == 0 ? ASNI_FMT("HIT GOOD TRAP", ASNI_FG_GREEN) :
            ASNI_FMT("HIT BAD TRAP", ASNI_FG_RED))),
          npc_status.halt_pc);
    case NPC_QUIT: statistic();
        
    }
    
}

// void reg_display();
// void assert_fail_msg();


