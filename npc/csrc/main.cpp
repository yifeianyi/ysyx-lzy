#include <common.h>


NPCState npc_status = { .state = NPC_STOP };

void init_monitor(int argc, char** argv);
void engine_start();
int is_exit_status_bad();

int main(int argc, char** argv) {

  init_monitor(argc, argv);
  engine_start();

  return is_exit_status_bad();
}










int is_exit_status_bad(){
  int good = (npc_status.state == NPC_END && npc_status.halt_ret == 0) ||
    (npc_status.state == NPC_QUIT);
  return !good;
}
