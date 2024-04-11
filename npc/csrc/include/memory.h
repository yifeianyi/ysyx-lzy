#ifndef __MEMORY_HPP__
#define __MEMORY_HPP__
    #include <common.h>
    #define CONFIG_MSIZE 0x8000000
    #define CONFIG_MBASE 0x80000000
    #define CONFIG_PC_RESET_OFFSET 0x0
    #define PMEM_LEFT  ((paddr_t)CONFIG_MBASE)
    #define PMEM_RIGHT ((paddr_t)CONFIG_MBASE + CONFIG_MSIZE - 1)
    #define RESET_VECTOR (PMEM_LEFT + CONFIG_PC_RESET_OFFSET)
    #define PG_ALIGN __attribute((aligned(4096)))
    uint8_t* guest_to_host(paddr_t paddr);
    paddr_t host_to_guest(uint8_t *haddr);

    void init_memory();
#endif