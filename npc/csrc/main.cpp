#include <common.h>
#include <npcState.hpp>

NPCState npc_status = { .state = NPC_STOP };

void init_monitor(int argc, char** argv);
void engine_start();
int is_exit_status_bad();
extern CPU_module percpu;
int main(int argc, char** argv) {
  // Log("pc:"FMT_PADDR,percpu.getCurPC());
  init_monitor(argc, argv);
  engine_start();
  percpu.TraceOff();
  // return is_exit_status_bad();
  return 0;
}

int is_exit_status_bad(){
  int good = (npc_status.state == NPC_QUIT);
  Log("good:%d",good);
  return !good;
}
