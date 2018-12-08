#include "klib.h"
#include <stdarg.h>

#ifndef __ISA_NATIVE__

static void uint2str(char *s, unsigned int d){
  size_t p=0;

  if(d==0){
    s[p++]='0';
  }else{
    while(d){
      s[p++]=(int)(d%10) + '0';
      d/=10;
    }

    for(size_t i=0,j=p-1;i<j;++i,--j){
      char t=s[i];
      s[i]=s[j];
      s[j]=t;
    }
  }
  s[p]='\0';
}


static void int2str(char *s, int d){
  int neg = 0;
  size_t p=0;
  if(d<0){
    neg = 1;
    s[p++]='-';
    d=-d;
  }

  if(d==0){
    s[p++]='0';
  }else{
    while(d){
      s[p++]=(d%10) + '0';
      d/=10;
    }

    for(size_t i=neg,j=p-1;i<j;++i,--j){
      char t=s[i];
      s[i]=s[j];
      s[j]=t;
    }
  }
  s[p]='\0';
}

#define __print_format__putc_oc(c) _putc(c)
#define __print_format__nop 

#define __print_format__s_oc(c) out[p++]=(c)
#define __print_format__s_end out[p]='\0'

#define __print_format__(oc, end) do{                                  \
  size_t p=0;                                                          \
  va_list ap;                                                          \
  static char buff[100];                                               \
                                                                       \
  int d;                                                               \
  unsigned int u;                                                      \
  char *s;                                                             \
                                                                       \
  va_start(ap, fmt);                                                   \
  while(*fmt){                                                         \
    if(*fmt == '%'){                                                   \
      ++fmt;                                                           \
      switch(*(fmt++)){                                                \
        case 's':                                                      \
          s = va_arg(ap, char *);                                      \
          for(size_t i=0;s[i]!='\0';++i) oc(s[i]);                     \
          break;                                                       \
        case 'd':                                                      \
          d = va_arg(ap, int);                                         \
          int2str(buff, d);                                            \
          for(size_t i=0;buff[i]!='\0';++i) oc(buff[i]);               \
          break;                                                       \
        case 'u':                                                      \
          u = va_arg(ap, unsigned int);                                \
          uint2str(buff, u);                                           \
          for(size_t i=0;buff[i]!='\0';++i) oc(buff[i]);               \
          break;                                                       \
        case '%':                                                      \
          oc('%');                                                     \
          break;                                                       \
      }                                                                \
    }else{                                                             \
      oc(*fmt);                                                        \
      fmt++;                                                           \
    }                                                                  \
  }                                                                    \
  va_end(ap);                                                          \
                                                                       \
  end;                                                                 \
  return p;                                                            \
}while(0)

int printf(const char *fmt, ...) {
  __print_format__(__print_format__putc_oc, __print_format__nop);
}

int vsprintf(char *out, const char *fmt, va_list ap) {
  return 0;
}

int sprintf(char *out, const char *fmt, ...) {
  __print_format__(__print_format__s_oc, __print_format__s_end);
}

int snprintf(char *out, size_t n, const char *fmt, ...) {
  return 0;
}

#endif
