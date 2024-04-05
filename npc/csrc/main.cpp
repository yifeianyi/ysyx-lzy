#include "common.h"
void init_monitor(int argc, char** argv);
void engine_start();
int is_exit_status_bad();
int main(int argc, char** argv) {

  printf("argc:%d \nargv[0]:%s\n",argc,argv[0]);
  
  init_monitor(argc, argv);
  engine_start();

  return is_exit_status_bad();
}


int is_exit_status_bad(){
  return 0;
}
