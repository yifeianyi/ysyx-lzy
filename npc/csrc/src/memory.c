#include "paddr.h"

static uint32_t img[]{
    0x00100513, // li a0, 1
    0x00200593, // li a1, 2
    0x00558593, // addi a1, a1, 5
    0x005a8613, // addi a2, a1, 10
    0x00100073  // ebreak;
};
static uint8_t pmem[CONFIG_MSIZE] PG_ALIGN = {};


uint8_t* guest_to_host(paddr_t paddr) { return pmem + paddr - CONFIG_MBASE; }
void init_mem(){
    memcpy(guest_to_host(RESET_VECTOR), img, sizeof(img));
}
static inline bool in_pmem(paddr_t addr) {
  return addr - CONFIG_MBASE < CONFIG_MSIZE;
}

extern "C" void pmem_read( paddr_t addr, word_t *data){
    
    if (likely(in_pmem(addr))){
        uint8_t *pt = guest_to_host(addr) + 7;
        word_t ret = 0;
        for (int i = 0; i < 8; ++i) {
            ret = (ret << 8) | (*pt--);
        }
        
        *data = ret;
    #ifdef MTRACE
        printf("In memory, addr: %x , data: %x\n",addr, *data);
    #endif 
    } 
}