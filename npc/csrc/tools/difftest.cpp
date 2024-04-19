#include<common.h>
#include<dlfcn.h>
#include<memory.h>
#include<npcState.hpp>
extern CPU_module percpu;
extern uint8_t pmem[CONFIG_MSIZE];
void (*ref_difftest_memcpy)(uint32_t addr, void *buf, size_t n, bool direction) = NULL;
void (*ref_difftest_regcpy)(void *dut, bool direction) = NULL;
void (*ref_difftest_exec)(uint64_t n) = NULL;
void (*ref_difftest_raise_intr)(uint64_t NO) = NULL;

void init_difftest(size_t img_size){
    const char* nemu_home = getenv("NEMU_HOME");
    if (nemu_home == NULL) {
        printf("Error: Environment variable NEMU_HOME not set\n");
        return;
    }

    char ref_so_file[256]; // 定义一个足够大的字符数组来存储路径
    strcpy(ref_so_file, nemu_home);
    strcat(ref_so_file, "/build/riscv32-nemu-interpreter-so");
    Assert(ref_so_file,"Ref_so_file is error.");
    Log("Differential testing:"ASNI_FMT("ON",ASNI_FG_GREEN));
    Log("Ref: %s",ref_so_file);

    //读取 Ref 动态库
    void *handle;
    handle = dlopen(ref_so_file, RTLD_LAZY);
    Assert(handle ,"Ref_so_file is error.");

    ref_difftest_memcpy = (void (*)(uint32_t addr, void *buf, size_t n, bool direction))(dlsym(handle, "difftest_memcpy"));
    Assert(ref_difftest_memcpy,"ref_difftest_memcpy init error.");

    ref_difftest_regcpy = (void (*)(void *dut, bool direction))(dlsym(handle, "difftest_regcpy"));
    Assert(ref_difftest_regcpy,"ref_difftest_regcpy init error.");

    ref_difftest_exec = (void (*)(uint64_t n))(dlsym(handle, "difftest_exec"));
    Assert(ref_difftest_exec,"ref_difftest_exec init error.");

    ref_difftest_raise_intr = (void (*)(uint64_t NO))(dlsym(handle, "difftest_raise_intr"));
    Assert(ref_difftest_raise_intr,"ref_difftest_raise_intr init error.");

    void (*ref_difftest_init)() = (void (*)())(dlsym(handle, "difftest_init"));
    Assert(ref_difftest_init,"ref_difftest_init init error.");

    //初始化 ref 的状态
    ref_difftest_init();
    ref_difftest_memcpy(CONFIG_MBASE, pmem, img_size, DIFFTEST_TO_REF);
    ref_difftest_regcpy(&(percpu.cpu), DIFFTEST_TO_REF);
}