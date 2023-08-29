#include <klib.h>
#include <klib-macros.h>
#include <stdint.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)
#define NEGATIVE -1
#define POSITIVE 1

size_t strlen(const char *s) {
  size_t len = 0;
  for (size_t i = 0; s[i] !='\0'; i++)len++;
  return len;
}

char *strcpy(char *dst, const char *src) {
  int len = strlen(src);
  for(int i=0;i<len;i++){
    dst[i] = src[i];
  }
  dst[len]='\0';
  return dst;
}

char *strncpy(char *dst, const char *src, size_t n) {
  for(int i=0;i<n;i++){
    if(src[i]!='\0'){ dst[i] = src[i]; }
    else{ dst[i] ='\0'; }
  }
  return dst;
}

char *strcat(char *dst, const char *src) {
  size_t len = strlen(dst);
  size_t i;
  for( i = 0 ; src[i]!='\0';i++){
    dst[len + i] = src[i]; 
  }
  dst[len+i] = '\0';
  return dst;
}

int strcmp(const char *s1, const char *s2) {
  while (*s1)
  {
      if (*s1 != *s2)break;// 如果字符不同，或者到达第二个字符串的结尾
      s1++,s2++;
  }

  // 将 `char*` 转换为 `unsigned char*` 后返回 ASCII 差异
  return *(uint8_t*)s1 - *(uint8_t*)s2;
}

int strncmp(const char *s1, const char *s2, size_t n) {
  int flag = 0;
  int len1 = strlen(s1);
  int len2 = strlen(s2);
  for(int i=0;i<n;i++){
    if(s1[i]!='\0' && s2[i]!='\0'){
      if(s1[i]<s2[i]){      flag = NEGATIVE;break;}
      else if(s1[i]>s2[i]){ flag = POSITIVE;break;}
    }
    else if(len1<len2){flag = NEGATIVE;break;}
    else if(len1>len2){flag = POSITIVE;break;}
  }
  return flag;
  return 0;
}

void *memset(void *s, int c, size_t n) {
  void*ret = s;
  for(int i=0;i<n;i++){
    *(char*)s = (char)c;
    s = (char*)s+1;
  }
  // *(char*)s = (char)'\0';//末尾结束符很重要
  return ret;
}

void *memmove(void *dst, const void *src, size_t n) {
  panic("Not implemented");
}

void *memcpy(void *out, const void *in, size_t n) {
  // 容错处理
    if(out == NULL || in == NULL){
        return NULL;
    }
    unsigned char *pdst = (unsigned char *)out;
    const unsigned char *psrc = (const unsigned char *)in;
    //判断内存是否重叠
    bool flag1 = (pdst >= psrc && pdst < psrc + n);
    bool flag2 = (psrc >= pdst && psrc < pdst + n);
    if(flag1 || flag2){
        // cout<<"内存重叠"<<endl;
        printf(" 内存重叠\n");
        return NULL;
    }
    // 拷贝
    while(n--){
        *pdst = *psrc;
        pdst++;
        psrc++;
    }
    return out;
}

int memcmp(const void *s1, const void *s2, size_t n) {
  uint8_t ret;
  for(int i=0;i<n;i++){
      ret = ((uint8_t*)s1)[i] - ((uint8_t*)s2)[i];
    if( ret!=0 )return ret;
  }
  return ret;
}

#endif
