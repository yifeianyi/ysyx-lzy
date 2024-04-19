
#include<common.h>
#include<getopt.h>
#include"memory.h"
#include<npcState.hpp>
extern CPU_module percpu;
void sdb_set_batch_mode();
static int parse_args(int argc, char *argv[]);
static long load_img();
size_t init_mem();

static char *diff_so_file = NULL;
static char *img_file = NULL;
static int difftest_port = 1234;
void init_difftest(size_t img_size);
void init_monitor(int argc, char *argv[]){
    parse_args(argc, argv);
    init_disasm("riscv64-pc-linux-gnu");
    percpu.TraceOpen();
    percpu.Reset();
    size_t img_size =  init_mem();
    init_difftest(img_size);
}

static int parse_args(int argc, char *argv[]){
    const struct option table[] = {
        {"batch"    , no_argument      , NULL, 'b'},
        {"diff"     , required_argument, NULL, 'd'},
        {"port"     , required_argument, NULL, 'p'},
        // {"help"     , no_argument      , NULL, 'h'},
        {0          , 0                , NULL,  0 },
  };
  int o;
    while ( (o = getopt_long(argc, argv, "-bd:p:", table, NULL)) != -1) {
    switch (o) {
      case 'b': sdb_set_batch_mode(); break;
      case 'p': sscanf(optarg, "%d", &difftest_port); break;
      case 'd': diff_so_file = optarg; break;
      case 1: img_file = optarg; return 0;
      default:
        printf("Usage: %s [OPTION...] IMAGE [args]\n\n", argv[0]);
        printf("\t-b,--batch              run with batch mode\n");
        printf("\t-d,--diff=REF_SO        run DiffTest with reference REF_SO\n");
        printf("\t-p,--port=PORT          run DiffTest with port PORT\n");
        printf("\n");
        exit(0);
    }
  }
  return 0;
}
size_t init_mem(){
  Log("physical memory area [" FMT_PADDR ", " FMT_PADDR "]", PMEM_LEFT, PMEM_RIGHT);
  size_t img_size = load_img();
  if(img_file!=NULL){
    Log("Load image size is %ld byte.",img_size);
    return img_size;
  }
  else{
    Log("No image.");
    return 0;
  } 
  
}
static long load_img(){
  if (img_file == NULL) {
    Log("No image is given. Use the default build-in image.");
    return 4096; // built-in image size
  }
  FILE *fp = fopen(img_file, "rb");
  Assert(fp, "Can not open '%s'", img_file);
  Log("Image path: %s",img_file);

  fseek(fp, 0, SEEK_END);
  long size = ftell(fp);

  fseek(fp, 0, SEEK_SET);
  int ret = fread(guest_to_host(RESET_VECTOR), size, 1, fp);
  assert(ret == 1);

  fclose(fp);
  return size;

}



