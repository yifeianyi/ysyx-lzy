#include<npcState.hpp>

CPU_module::CPU_module(/*gs */)
{
    this->contextp = new VerilatedContext;
    this->tfp      = new VerilatedVcdC;
    this->top      = new Vtop;
}

CPU_module::~CPU_module()
{
    if(this->traceTurn)
        this->TraceOff();
    delete this->contextp;
    delete this->tfp;
    delete this->top;

}

void CPU_module::TraceOpen(){
    this->traceTurn = true;
    this->contextp->traceEverOn(true);
    this->top->trace(tfp, 0);
}
void CPU_module::TraceOff(){
    this->traceTurn = false;
    tfp->close();
}
void CPU_module::stepAndWave(){

}