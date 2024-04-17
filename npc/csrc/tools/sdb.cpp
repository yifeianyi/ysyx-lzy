#include "common.h"
#include <readline/readline.h>
#include <readline/history.h>
#include <string>
#include <npcState.hpp>
#define NR_CMD ARRLEN(cmd_table)
static int is_batch_mode = false;
void npc_execute(uint64_t n,std::string arg);

extern NPCState npc_status;
extern CPU_module percpu;
void init_regex();
void init_wp_pool();

static char* rl_gets() {
  static char *line_read = NULL;

  if (line_read) {
    free(line_read);
    line_read = NULL;
  }

  line_read = readline("(npc-rv32) ");

  if (line_read && *line_read) {
    add_history(line_read);
  }

  return line_read;
}

void sdb_set_batch_mode() {
  is_batch_mode = true;
}

static int cmd_help(char *args);
static int cmd_c(char *args);
static int cmd_q(char *args);
static int cmd_si(char *args);
static int cmd_sc(char *args);
static int cmd_info(char *args);
static int cmd_x(char *args);
static int cmd_itrace(char *args);
static int cmd_mtrace(char *args);

static struct {
  const char *name;
  const char *description;
  int (*handler) (char *);
} cmd_table [] = {
  { "help", "Display information about all supported commands", cmd_help },
  { "c", "Continue the execution of the program", cmd_c },
  { "q", "Exit NEMU", cmd_q },
  { "si", " step one instruction", cmd_si},
  { "sc", " step one Clock", cmd_sc},
  { "info", "print regfiles ", cmd_info},
  { "x", "print segment memory", cmd_x},
  {"itrace", "Turn ON or turn off the instruction trace.",cmd_itrace},
  {"mtrace", "Turn ON or turn off the memory trace.",cmd_mtrace},
  // { "sc", " step one clock." NULL}
};


static int cmd_itrace(char *args){
  if(args == NULL || strcmp(args, "o") == 0){
    percpu.itraceTurn = true;
    printf(ASNI_FMT("itrace: ON",ASNI_FG_GREEN));
    return 0;
  }
  if(strcmp(args, "c")){
    printf(ASNI_FMT("itrace: OFF",ASNI_FG_RED));
    percpu.itraceTurn = false;
    return 0;
  }
}
static int cmd_mtrace(char *args){
  if(args == NULL || strcmp(args, "o") == 0){
    percpu.mtraceTurn = true;
    printf(ASNI_FMT("mtrace: ON",ASNI_FG_GREEN));
    return 0;
  }
  if(strcmp(args, "c")){
    percpu.mtraceTurn = false;
    printf(ASNI_FMT("mtrace: OFF",ASNI_FG_RED));
    return 0;
  }
}

static int cmd_info(char *args){
    char *cmd = strtok(args, " ");
    if(strcmp(cmd,"r")==0){
        percpu.displayReg();
    }
    else{
        printf("Unknown command '%s'\n", cmd);
        cmd_help("info");
    }
    return 0;
}
static int cmd_si(char *args){
    uint64_t cnt;
    if (args == NULL) { 
      npc_execute(1,"si"); //改为npc_exec
      return 0;
    }
    else if(sscanf(args,"%lu",&cnt) == 1){ 
      npc_execute(cnt,"si");
    }
    else {
        printf("'%s' must be an integer.\n", args); 
        cmd_help("si");
    }
    return 0;
}
static int cmd_sc(char *args){
    uint64_t cnt;
    if (args == NULL) { 
      npc_execute(1,"sc"); //改为npc_exec
      return 0;
    }
    else if(sscanf(args,"%lu",&cnt) == 1){ 
      npc_execute(cnt,"sc");
    }
    else {
        printf("'%s' must be an integer.\n", args); 
        cmd_help("sc");
    }
    return 0;
}
static int cmd_c(char *args) {
  npc_execute(-1,"si");
  return 0;
}
static int cmd_q(char *args){
  npc_status.state = NPC_QUIT;
  
  return -1;
}
static int cmd_x(char *args){
  return 0;
}
static int cmd_help(char *args) {
  /* extract the first argument */
  char *arg = strtok(args, " ");
  int i;

  if (arg == NULL) {
    /* no argument given */
    for (i = 0; i < NR_CMD; i ++) {
      printf("%s - %s\n", cmd_table[i].name, cmd_table[i].description);
    }
  }
  else {
    for (i = 0; i < NR_CMD; i ++) {
      if (strcmp(arg, cmd_table[i].name) == 0) {
        printf("%s - %s\n", cmd_table[i].name, cmd_table[i].description);
        return 0;
      }
    }
    printf("Unknown command '%s'\n", arg);
  }
  return 0;
}



//-------------------------------------------------
void init_sdb(){
    // init_regex();
    // init_wp_pool();
}
void engine_start(){
  if (is_batch_mode) {
    cmd_c("");
    return;
  }
  for (char *str; (str = rl_gets()) != NULL; ) {
    char *str_end = str + strlen(str);
    char *cmd = strtok(str, " ");
    if (cmd == NULL) { continue; }
    char *args = cmd + strlen(cmd) + 1;
    if (args >= str_end) {
      args = NULL;
    }

    int i;
    for (i = 0; i < NR_CMD; i ++) {
      if (strcmp(cmd, cmd_table[i].name) == 0) {
        if (cmd_table[i].handler(args) < 0) { 
          Log("NPC quit");
          return; 
        }
        break;
      }
    }

    if (i == NR_CMD) { printf("Unknown command '%s'\n", cmd); }
  }
}