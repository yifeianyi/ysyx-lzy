
#include <memory.hpp>
static uint8_t pmem[CONFIG_MSIZE] PG_ALIGN = {};
static const uint32_t img[] = {
    
};
uint8_t* guest_to_host(paddr_t paddr) { return pmem + paddr - CONFIG_MBASE; }
paddr_t host_to_guest(uint8_t *haddr) { return haddr - pmem + CONFIG_MBASE; }

void init_memory(){
    memcpy(guest_to_host(RESET_VECTOR), img, sizeof(img));
}

static inline bool in_pmem(paddr_t addr) {
  return addr - CONFIG_MBASE < CONFIG_MSIZE;
}

static inline void Rshift_Data(word_t &wdata, uint8_t &mask, uint8_t *&p){
    wdata >>= 8;
    mask >>= 1;
    p++;
}
extern "C"{
    void paddr_read(paddr_t raddr, word_t *rdata){
        if(likely(in_pmem(raddr))){
            uint8_t *p =  guest_to_host(raddr) + sizeof(word_t) - 1;//小端读取
            word_t rst = 0;
            for(int i=0; i<sizeof(word_t); i++){
                rst = (rst << 8) | (*p--);
            }
            *rdata = rst;
            return;
        }
    } 

    void paddr_write(paddr_t waddr, word_t wdata, uint8_t mask){
        if (likely(in_pmem(waddr))){
            uint8_t *p = guest_to_host(waddr);
            for(int i=0;i<sizeof(word_t);i++){
                if(mask & 1) *p = wdata & 0xff;
                Rshift_Data(wdata,mask,p);
            }
        }
    } 
}

