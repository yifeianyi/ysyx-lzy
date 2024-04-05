.section entry, "ax"
.globl _start
.type _start, @function

_start:
  mv s0, zero  #zero寄存器是一个特殊的寄存器，它的值总是0。 这条指令通常用于初始化寄存器。
  la sp, _stack_pointer
  jal _trm_init
