#include "common.h"
#include <readline/readline.h>
#include <readline/history.h>
#include <string>

#define NR_CMD ARRLEN(cmd_table)
static int is_batch_mode = false;
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
static int cmd_info(char *args);
static int cmd_x(char *args);

static struct {
  const char *name;
  const char *description;
  int (*handler) (char *);
} cmd_table [] = {
  { "help", "Display information about all supported commands", cmd_help },
  { "c", "Continue the execution of the program", cmd_c },
  { "q", "Exit NEMU", cmd_q },
  { "si", " step one instruction", cmd_si},
  { "info", "print regfiles ", cmd_info},
  { "x", "print segment memory", cmd_x}
  // { "sc", " step one clock." NULL}
};



static int cmd_info(char *args){
    char *cmd = strtok(args, " ");
    if(strcmp(cmd,"r")==0){
        // Log("============================================");
        // isa_reg_display();
        // Log("============================================");
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
        // cpu_exec(1); //改为npc_exec
        return 0;
    }
    else if(sscanf(args,"%lu",&cnt) == 1){ 
      // cpu_exec(cnt);
    }
    else {
        printf("'%s' must be an integer.\n", args); 
        cmd_help("si");
    }

    return 0;
}
static int cmd_c(char *args) {
  // cpu_exec(-1); //改为npc_exec
  return 0;
}
static int cmd_q(char *args){
  return 0;
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
        if (cmd_table[i].handler(args) < 0) { return; }
        break;
      }
    }

    if (i == NR_CMD) { printf("Unknown command '%s'\n", cmd); }
  }
}