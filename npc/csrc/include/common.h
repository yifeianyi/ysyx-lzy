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
#define FMT_WORD "0x%04lx"

typedef word_t   vaddr_t;
typedef uint32_t paddr_t;
#define FMT_PADDR "0x%04lx"
typedef uint16_t ioaddr_t;

//Verilator
#include "Vrv_percpu.h"
#include <verilated.h>
#include <verilated_vcd_c.h>    

// DPI-C
#include <svdpi.h>
#include <Vrv_percpu__Dpi.h>
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

#endif