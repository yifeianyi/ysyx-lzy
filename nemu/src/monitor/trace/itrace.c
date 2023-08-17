#include <trace.h>
struct Buffer{
    char logbuf[128];
    vaddr_t pc;
}buffer[CONFIG_ITRACE_IRINGBUF_SIZE];

static uint32_t tail = 0;
static vaddr_t CurPC;

void push_to_iringbuf(const char *logbuf,vaddr_t pc){
    CurPC = pc;
    buffer[tail].pc = pc;
    memcpy(buffer[tail].logbuf , logbuf, sizeof(buffer[tail].logbuf));
    tail = (tail + 1) % CONFIG_ITRACE_IRINGBUF_SIZE;
}

void print_iringbuf(){
    Log("=============== iringbuf ==================");
    for(uint32_t i = 0; i < CONFIG_ITRACE_IRINGBUF_SIZE; i++){
        if(CurPC == buffer[i].pc) printf(ANSI_FMT("--> %s", ANSI_BG_GREEN)"\n",buffer[i].logbuf);
        else if(buffer[i].logbuf!=NULL)printf("    %s\n",buffer[i].logbuf); 
        else break;
    }
}