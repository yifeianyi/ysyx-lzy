
#include <memory.h>
#include <npcState.hpp>
extern CPU_module percpu;
static uint8_t pmem[CONFIG_MSIZE] PG_ALIGN = {};

uint8_t* guest_to_host(paddr_t paddr) { return pmem + paddr - CONFIG_MBASE; }
paddr_t host_to_guest(uint8_t *haddr) { return haddr - pmem + CONFIG_MBASE; }
static void mtrace(paddr_t addr, int len, word_t data,char op){
    if(op=='r'){
        printf(ASNI_FMT("read "FMT_PADDR" %d byte. Data: "FMT_WORD"\n",ASNI_FG_YELLOW),addr,len,data);
    }
    else{
        printf(ASNI_FMT("write %d byte data into "FMT_PADDR". data:" FMT_WORD,ASNI_FG_CYAN)"\n",len, addr, data);
    }
}



static inline bool in_pmem(paddr_t addr) {
  return addr - CONFIG_MBASE < CONFIG_MSIZE;
}

static inline void Rshift_Data(int &wdata, char &mask, uint8_t *&p){
    wdata >>= 8;
    mask >>= 1;
    p++;
}

#define BYTE 0x01
#define HALF 0x03 
#define WORD 0x0f
extern "C"{
    void pmem_read(int raddr, int *rdata){
        if(likely(in_pmem(raddr))){
            uint8_t *p = guest_to_host(raddr) + sizeof(word_t) - 1;
            word_t rst = 0;
            for(int i=0; i<sizeof(word_t); i++){
                rst = (rst << 8) | (*p--);
            }
            *rdata = rst;

            if(percpu.mtraceTurn){
                mtrace(raddr, sizeof(word_t), *rdata, 'r');
            }
            return;
        }
    } 
}
extern "C"{
    void pmem_write(int waddr, int wdata, char mask){
        if(percpu.mtraceTurn){


            int len;
            switch (mask)
            {
            case BYTE:  len = 1; break;
            case HALF:  len = 2; break;
            case WORD:  len = 4; break;
            default:
                Assert(0,"wmask is error. wmask: %02x",mask);
                break;
            }

            mtrace(waddr, sizeof(word_t), wdata, 'w');
        }
        
        if (likely(in_pmem(waddr))){
            uint8_t *p = guest_to_host(waddr);
            for(int i=0;i<sizeof(word_t);i++){
                if(mask & 1) *p = wdata & 0xff;
                Rshift_Data(wdata,mask,p);
            }
        }
    } 
}
