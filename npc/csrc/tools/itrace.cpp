#include<itrace.hpp>
#include<ctype.h>
// Itrace itrace;
extern CPU_module percpu;

struct Buffer{
    char logbuf[LOG_LEN];
    vaddr_t pc;
    uint32_t idx;
}ringbuf[BUFFER_SIZE];

paddr_t Cur_pc = 0;
uint32_t tail = 0; //同一pc下的指令可能有多条在ringbuf中

void push_to_iringbuf(const char *logbuf,vaddr_t pc){
    Cur_pc = pc;
    ringbuf[tail].pc = pc;
    ringbuf[tail].idx= tail;
    memcpy(ringbuf[tail].logbuf , logbuf, sizeof(ringbuf[tail].logbuf));
    tail = (tail + 1) % BUFFER_SIZE;
}

void Itrace_Record(paddr_t pc){
    if( PMEM_LEFT > pc ||  pc> PMEM_RIGHT  ) return ;
    
    // fetch instruction
    uint8_t *inst = guest_to_host(pc);

    // get a log
    char buffer[LOG_LEN];
    char *log = buffer;
    char *p = log;
    for(int i = 0; i < 4;i++){
        p += sprintf(p, " %02x", inst[i]);
    }
    p += sprintf(p, "\t");
    
    // disasm
    disassemble(p, pc, inst, 4);
    // Log("log: %s.",log);
    
    // push_to_ringbuf
    push_to_iringbuf(log,pc);
}

void Display_ringbuf(){
    Log("=============== iringbuf ==================");
    for(uint32_t i = 0; i < BUFFER_SIZE; i++){
        if(Cur_pc == ringbuf[i].pc && ringbuf[i].idx == (LOG_LEN + tail-1) % LOG_LEN ) {
            printf(ASNI_FMT("--> %s", ASNI_BG_GREEN)"\n",ringbuf[i].logbuf);
        }
        else if(ringbuf[i].logbuf!=NULL &&  strlen(ringbuf[i].logbuf)!=0){
            // Log("logbuf len: %ld",strlen(ringbuf[i].logbuf));
            printf("    %s\n",ringbuf[i].logbuf); 
        }
        else break;
    }
}