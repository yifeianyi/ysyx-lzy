#include <trace.h>

void mtrace(vaddr_t addr, int len, word_t data,char op){
    if(op=='r'){
        printf(ANSI_FMT("read %lx %d byte data",ANSI_FG_YELLOW)"\n",addr,len);
    }
    else{
        printf(ANSI_FMT("write %d byte data into %lx data: %lx",ANSI_FG_CYAN)"\n",len, addr, data);
    }
}