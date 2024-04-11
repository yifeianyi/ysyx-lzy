#include<npcState.hpp>
extern NPCState npc_status;
extern CPU_module percpu;
word_t *gpr = NULL;
static const char *regs[] = {
  "$0", "ra", "sp", "gp", "tp", "t0", "t1", "t2",
  "s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5",
  "a6", "a7", "s2", "s3", "s4", "s5", "s6", "s7",
  "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"
};
CPU_module::CPU_module(/*gs */)
{   
    tfp      = new VerilatedVcdC;
    top      = new Vtop;
    contextp = top->contextp();
    Log("The CPU model is created successfully.");
}

CPU_module::~CPU_module()
{
    tfp->close();
    delete top;

}
void CPU_module::Reset(){
    top->rst = 1;
    top->clk = 1;
    top->eval();
    contextp->timeInc(1);
    tfp->dump(contextp->time());

    top->clk = !top->clk;
    top->rst = 0;
    top->eval();
    contextp->timeInc(1);
    tfp->dump(contextp->time());
}
void CPU_module::TraceOpen(){
    traceTurn = true;
    contextp->traceEverOn(true);
    top->trace(tfp, 99);
    tfp->open("dump.vcd");
    Log("Wave trace open.");
}
void CPU_module::TraceOff(){
    traceTurn = false;
    tfp->close();
    Log("Wave trace close.");
}
void CPU_module::stepAndWave(){
    top->clk = !top->clk;
    top->eval();
        contextp->timeInc(1);
        tfp->dump(contextp->time());
    top->clk = !top->clk;
    top->eval();
        contextp->timeInc(1);
        tfp->dump(contextp->time());
    return;
}

word_t CPU_module::getCurInst(){
    return top->debug_inst;
}
paddr_t CPU_module::getCurPC(){
    return top->pc;
}

//-------------------- cpu_state --------------------
void CPU_module::updateCPUstate(){
    for(int i = 0;i<32;i++){
        cpu.gpr[i] = gpr[i];
    }
}
void CPU_module::displayReg(){
    printf("pc:"FMT_PADDR"\n",getCurPC());
    for(int i=0;i<32;i++){
        if(i%4==0 && i!=0)printf("\n");
          printf("%3s:" FMT_PADDR " \t\t",regs[i], cpu.gpr[i]);
    }
    printf("\n");
}

/*================================== DPI-C ==================================================*/
extern "C"{
    void Ebreak(){
        // Log("In Ebreak.");
        npc_status.state = NPC_END;
    }
    void test_addi(int imm){
        Log("In addi test.");
        printf("Imm: "FMT_WORD"\n",imm);
    }
    void inst_nsupport(){
        Log("This instruction is not support");
        // printf("",percpu.getCurInst());
        npc_status.state = NPC_ABORT;
    }
}
extern "C"{
    void fetch_regfile_data(const svOpenArrayHandle reg){
        gpr = (uint32_t *)(((VerilatedDpiOpenVar*)reg)->datap());
    }
}