#include <am.h>
#include <nemu.h>
#include <string.h>

#define SYNC_ADDR (VGACTL_ADDR + 4)

static uint32_t gpu_w = 400;
static uint32_t gpu_h = 300;
void __am_gpu_init() {
  // gpu_w = inw(VGACTL_ADDR+2);
  // gpu_h = inw(VGACTL_ADDR);

  int i;
  int w = gpu_w;  // TODO: get the correct width
  int h = gpu_h;  // TODO: get the correct height
  uint32_t *fb = (uint32_t *)(uintptr_t)FB_ADDR;
  for (i = 0; i < w * h; i ++) fb[i] = i;
  outl(SYNC_ADDR, 1);
}

void __am_gpu_config(AM_GPU_CONFIG_T *cfg) {
  *cfg = (AM_GPU_CONFIG_T) {
    .present = true, .has_accel = false,
    .width = gpu_w, .height = gpu_w,
    .vmemsz = 0
  };
}

void __am_gpu_fbdraw(AM_GPU_FBDRAW_T *ctl) {
  int x = ctl->x,y = ctl->y;
  uint32_t *pixels = ctl->pixels;
  int w = ctl->w,h =ctl->h;

  uint32_t *fb = (uint32_t *)(uintptr_t)FB_ADDR;
  for(int i = 0;i<h && y+i<gpu_h;i++,pixels+=w){
    // outl(FB_ADDR+((y+i)*gpu_w + x),*pixels);
    uint32_t cpsz = sizeof(uint32_t)*(x + w > gpu_w? gpu_w-x : w);
    memcpy(&fb[(y+i)*gpu_w + x],pixels,cpsz);//换大行，不是小行
  }
  if (ctl->sync) {
    outl(SYNC_ADDR, 1);
  }
}

void __am_gpu_status(AM_GPU_STATUS_T *status) {
  status->ready = true;
}
