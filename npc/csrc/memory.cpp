
#include <memory.h>
static uint8_t pmem[CONFIG_MSIZE] PG_ALIGN = {};

uint8_t* guest_to_host(paddr_t paddr) { return pmem + paddr - CONFIG_MBASE; }
paddr_t host_to_guest(uint8_t *haddr) { return haddr - pmem + CONFIG_MBASE; }

// void init_memory(){
//     memcpy(guest_to_host(RESET_VECTOR), img, sizeof(img));
// }

static inline bool in_pmem(paddr_t addr) {
  return addr - CONFIG_MBASE < CONFIG_MSIZE;
}

static inline void Rshift_Data(word_t &wdata, uint8_t &mask, uint8_t *&p){
    wdata >>= 8;
    mask >>= 1;
    p++;
}
extern "C"{
    void pmem_read(paddr_t raddr, word_t *rdata){
        if(likely(in_pmem(raddr))){
    // #define __PMEM_DEBUG__ 
    #ifdef __PMEM_DEBUG__
            printf("pmem:0x %02x %02x %02x %02x\n",pmem[0],pmem[1],pmem[2],pmem[3]);
    #endif
            uint8_t *p =  guest_to_host(raddr) + sizeof(word_t) - 1;//小端读取

    #ifdef __PMEM_DEBUG__
            printf("pmem:0x %02x %02x %02x %02x\n",pmem[0],pmem[1],pmem[2],pmem[3]);
            
            printf("pmem+3:%p\np     :%p\n",pmem+3,p);
            // Assert(p==(pmem+3),"p!=pmem+3");
            printf("p   :0x %02x %02x %02x %02x\n",*p,*(p-1),*(p-2),*(p-3));
    #endif            
            word_t rst = 0;
            for(int i=0; i<sizeof(word_t); i++){
                rst = (rst << 8) | (*p--);
            }
            // Log("rdata:"FMT_WORD" rst:"FMT_WORD,*rdata,rst);
            *rdata = rst;
            // Log("rdata:"FMT_WORD" rst:"FMT_WORD,*rdata,rst);
            return;
        }
    } 

    void pmem_write(paddr_t waddr, word_t wdata, uint8_t mask){
        if (likely(in_pmem(waddr))){
            uint8_t *p = guest_to_host(waddr);
            for(int i=0;i<sizeof(word_t);i++){
                if(mask & 1) *p = wdata & 0xff;
                Rshift_Data(wdata,mask,p);
            }
        }
    } 
}
