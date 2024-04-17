
#include <memory.h>
#include <npcState.hpp>
extern CPU_module Percpu;
static uint8_t pmem[CONFIG_MSIZE] PG_ALIGN = {};

uint8_t* guest_to_host(paddr_t paddr) { return pmem + paddr - CONFIG_MBASE; }
paddr_t host_to_guest(uint8_t *haddr) { return haddr - pmem + CONFIG_MBASE; }
static void mtrace(paddr_t addr, int len, word_t data,char op){
    if(op=='r'){
        printf(ANSI_FMT("read "FMT_PADDR" %d byte. Data: "FMT_WORD"\n",ANSI_FG_YELLOW),addr,len,data);
    }
    else{
        printf(ANSI_FMT("write %d byte data into "FMT_PADDR". data:" FMT_WORD,ANSI_FG_CYAN)"\n",len, addr, data);
    }
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
    void pmem_read(paddr_t raddr, word_t *rdata){

        if(Percpu.mtraceTurn){
            mtrace(raddr, sizeof(word_t), rdata, 'r');
        }

        if(likely(in_pmem(raddr))){    
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
        if(Percpu.mtraceTurn){
            #define BYTE 0x01
            #define HALF 0x03 
            #define WORD 0x0f

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

            mtrace(raddr, sizeof(word_t), rdata, 'w');
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
