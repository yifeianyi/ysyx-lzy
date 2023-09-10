#ifndef __PADDR_H__
#define __PADDR_H__
    #include "common.h"

    #define CONFIG_MBASE 0x80000000
    #define CONFIG_MSIZE 0x8000000
    #define CONFIG_PC_RESET_OFFSET 0x0

    #define PMEM_LEFT  ((paddr_t)CONFIG_MBASE)
    #define PMEM_RIGHT ((paddr_t)CONFIG_MBASE + CONFIG_MSIZE - 1)
    #define RESET_VECTOR (PMEM_LEFT + CONFIG_PC_RESET_OFFSET)

    void init_mem();
#endif