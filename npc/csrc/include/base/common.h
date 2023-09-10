#ifndef __COMMON_H__
#define __COMMON_H__
//  std library
#include <stdint.h>
#include <stdio.h>
#include <inttypes.h>
#include <stdbool.h>
#include <string.h>
#include <assert.h>

// common 
#include "macro.h"

// about verilator
#include "verilated.h"
#include "verilated_vcd_c.h" //导出vcd文件需要
#include "Vtop.h"

static VerilatedContext* contextp = new VerilatedContext;
static VerilatedVcdC* tfp = new VerilatedVcdC;
static Vtop *top = new Vtop;

#define PG_ALIGN __attribute((aligned(4096)))


typedef MUXDEF(CONFIG_ISA64, uint64_t, uint32_t) word_t;
typedef MUXDEF(CONFIG_ISA64, int64_t, int32_t)  sword_t;
#define FMT_WORD MUXDEF(CONFIG_ISA64, "0x%016" PRIx64, "0x%08" PRIx32)

typedef word_t vaddr_t;
typedef MUXDEF(PMEM64, uint64_t, uint32_t) paddr_t;
#define FMT_PADDR MUXDEF(PMEM64, "0x%016" PRIx64, "0x%08" PRIx32)
typedef uint16_t ioaddr_t;

#include <debug.h>
// #ifdef CONFIG_TRACE
// #include <trace.h>
// #endif


#endif