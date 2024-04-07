#ifndef __COMMON_H__
#define __COMMON_H__

// Base standard library
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <assert.h>
#include <macro.h>

// 
typedef long long ll;
typedef uint32_t word_t;
typedef int32_t  sword_t;
#define FMT_WORD "0x%08x"

typedef word_t   vaddr_t;
typedef uint32_t paddr_t;
#define FMT_PADDR "0x%08x"
typedef uint16_t ioaddr_t;

//Verilator
#include "Vtop.h"
#include <verilated.h>
#include <verilated_vcd_c.h>    

// DPI-C
#include <svdpi.h>
#include <Vtop__Dpi.h>
#include <verilated_dpi.h>


// save cpu RTL state
/*
    用于获取RTL的相关信息，用于 difftest 和 维护整个npc的状态机。
*/
typedef struct {
  word_t gpr[32];
  vaddr_t pc;
  word_t csr[32];  //csr[0] == mtvec csr[1] == mepc csr[2] == mstatus csr[3] == mcause
} CPU_state;

enum { NPC_RUNNING, NPC_STOP, NPC_END, NPC_ABORT, NPC_QUIT };
typedef struct {
  vaddr_t halt_pc;
  uint32_t halt_ret;
  uint64_t halt_clk;
  int state;
} NPCState;


// ------------------- log -------------------

#define ASNI_FG_BLACK   "\33[1;30m"
#define ASNI_FG_RED     "\33[1;31m"
#define ASNI_FG_GREEN   "\33[1;32m"
#define ASNI_FG_YELLOW  "\33[1;33m"
#define ASNI_FG_BLUE    "\33[1;34m"
#define ASNI_FG_MAGENTA "\33[1;35m"
#define ASNI_FG_CYAN    "\33[1;36m"
#define ASNI_FG_WHITE   "\33[1;37m"
#define ASNI_BG_BLACK   "\33[1;40m"
#define ASNI_BG_RED     "\33[1;41m"
#define ASNI_BG_GREEN   "\33[1;42m"
#define ASNI_BG_YELLOW  "\33[1;43m"
#define ASNI_BG_BLUE    "\33[1;44m"
#define ASNI_BG_MAGENTA "\33[1;35m"
#define ASNI_BG_CYAN    "\33[1;46m"
#define ASNI_BG_WHITE   "\33[1;47m"
#define ASNI_NONE       "\33[0m"

#define ASNI_FMT(str, fmt) fmt str ASNI_NONE


#define _Log(...) \
do { \
    printf(__VA_ARGS__); \
} while (0)

#define Log(format, ...) \
    _Log(ASNI_FMT("[%s:%d %s] " format, ASNI_FG_BLUE) "\n", \
        __FILE__, __LINE__, __func__, ## __VA_ARGS__)


// -------------- assert plus ------------------
#define Assert(cond, format, ...) \
  do { \
    if (!(cond)) { \
      (fflush(stdout), fprintf(stderr, ASNI_FMT(format, ASNI_FG_RED) "\n", ##  __VA_ARGS__)); \
      assert(cond); \
    } \
  } while (0)

#define panic(format, ...) Assert(0, format, ## __VA_ARGS__)

#define TODO() panic("please implement me")

void npc_execute(uint64_t n);
uint64_t get_time();
#endif