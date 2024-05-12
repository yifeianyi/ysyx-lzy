#include <common.h>

static Context* do_event(Event e, Context* c) {
  switch (e.event) {
    case EVENT_YIELD: Log("In event yield.");break;
    case EVENT_SYSCALL: Log("In event yield.");break;
    default: panic("Unhandled event ID = %d", e.event);break;
  }
  c->mepc +=4;
  return c;
}

void init_irq(void) {
  Log("Initializing interrupt/exception handler...");
  cte_init(do_event);
}
