#ifndef AM_INCLUDED
#define AM_INCLUDED 1

#include <stdio.h>
#include <stdarg.h>
#include <stddef.h>

typedef struct _Area {
  void *start, *end;
} _Area;
static _Area _heap = {(void*)0x02000000, (void*)0x02040000};

volatile unsigned static char * const ioram = (unsigned char *)0x04000000;
volatile unsigned static short * const vram = (unsigned short *)0x06000000;

//typedef unsigned uint32_t;
//typedef int int32_t;

static inline void _putc(char c){
	while(1){ // wait for serial port to be ready
		unsigned char cnt = ioram[0x401];
		if((cnt &1) == (cnt>>1)) break;
	}

	//load data
	ioram[0x400] = c;

	//send!
	ioram[0x401] ^= 1;
}

static inline void _puthex(int v){
	if(v < 10) _putc(v + '0');
	else _putc(v - 10 + 'a');
}

static inline void _puts(const char *str){
	for(int i=0;str[i]!='\0';++i){
		_putc(str[i]);
	}
}

static inline void setcolor(int x,int y,int r,int g,int b){
	short color = r + (g<<5) + (b<<10);

	vram[(y<<8) - (y<<4) + x] = color;
}

static inline void _halt(int cond){
	ioram[0] = 0x03;
	ioram[1] = 0x04;

	if(cond){
		vram[0] = 0x001F; //C = 000000000011111 = R
	}else{
		vram[0] = 0x03E0; //C = 000001111100000 = G
	}

	while(1);
}

__attribute__((noinline))
static void nemu_assert(int cond) {
  if (!cond) _halt(1);
}

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

static inline int _printf(const char *fmt, ...) {
  __print_format__(__print_format__putc_oc, __print_format__nop);
}

static inline int _vsprintf(char *out, const char *fmt, va_list ap) {
  return 0;
}

static inline int _sprintf(char *out, const char *fmt, ...) {
  __print_format__(__print_format__s_oc, __print_format__s_end);
}

static inline int _snprintf(char *out, size_t n, const char *fmt, ...) {
  return 0;
}

static inline int uptime(){
	unsigned long long v = ioram[0x105];
	v<<=8;
	v|=ioram[0x104];
	v<<=8;
	v|=ioram[0x101];
	v<<=8;
	v|=ioram[0x100];

	v = v * 3072 / 50000;
	return v;
}

static inline void _ioe_init(){
	char *p = _heap.start;
	while(p!=_heap.end){
		*p = 0;
		++p;
	}
	ioram[0x100] = 0;
	ioram[0x101] = 0;
	ioram[0x102] = 0x83;

	ioram[0x104] = 0;
	ioram[0x105] = 0;
	ioram[0x106] = 0x84;

	ioram[0x108] = 0;
	ioram[0x109] = 0;
	ioram[0x10a] = 0x84;

	ioram[0x10c] = 0;
	ioram[0x10d] = 0;
	ioram[0x10e] = 0x84;
}

#endif

