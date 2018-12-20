#include <stdarg.h>
#include <stddef.h>

volatile unsigned char * const ioram = (unsigned char *)0x04000000;
volatile unsigned short * const vram = (unsigned short *)0x06000000;

void _putc(char c){
	while(1){ // wait for serial port to be ready
		unsigned char cnt = ioram[0x401];
		if((cnt &1) == (cnt>>1)) break;
	}

	//load data
	ioram[0x400] = c;

	//send!
	ioram[0x401] ^= 1;
}

void _puthex(int v){
	if(v < 10) _putc(v + '0');
	else _putc(v - 10 + 'a');
}

void _puts(const char *str){
	for(int i=0;str[i]!='\0';++i){
		_putc(str[i]);
	}
}

void setcolor(int x,int y,int r,int g,int b){
	short color = r + (g<<5) + (b<<10);

	vram[(y<<8) - (y<<4) + x] = color;
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

int _printf(const char *fmt, ...) {
  __print_format__(__print_format__putc_oc, __print_format__nop);
}

int _vsprintf(char *out, const char *fmt, va_list ap) {
  return 0;
}

int _sprintf(char *out, const char *fmt, ...) {
  __print_format__(__print_format__s_oc, __print_format__s_end);
}

int _snprintf(char *out, size_t n, const char *fmt, ...) {
  return 0;
}

size_t _strlen(const char *s) {
  size_t ret=0;
  while(s[ret] != '\0') ++ret;
  return ret;
}

char *_strcpy(char* dst,const char* src) {
  size_t i;
  for(i=0;src[i]!='\0';++i) dst[i]=src[i];
  dst[i]='\0';
  return dst;
}

char* _strncpy(char* dst, const char* src, size_t n) {
  size_t i;
  for(i=0;i<n && src[i]!='\0';++i) dst[i]=src[i];
  if(i<n) dst[i]='\0';
  return dst;
}

char* _strcat(char* dst, const char* src) {
  size_t s=0,i;
  while(dst[s]!='\0') ++s;
  for(i=0;src[i]!='\0';++i) dst[s+i]=src[i];
  dst[s+i]='\0';
  return dst;
}

int _strcmp(const char* s1, const char* s2) {
  for(size_t i=0;;++i){
    if(s1[i]!=s2[i]){
      return s1[i]<s2[i] ? -1 : 1;
    }

    if(s1[i]=='\0'){
      return 0;
    }
  }
  return 0;
}

int _strncmp(const char* s1, const char* s2, size_t n) {
  for(size_t i=0;i<n;++i){
    if(s1[i]!=s2[i]){
      return s1[i]<s2[i] ? -1 : 1;
    }

    if(s1[i]=='\0'){
      return 0;
    }
  }
  return 0;
}

void* _memset(void* v,int c,size_t n) {
  for(size_t i=0;i<n;++i) ((char *) v)[i]=c;
  return v;
}

void* _memcpy(void* out, const void* in, size_t n) {
  for(size_t i=0;i<n;++i) ((char *) out)[i]=((char *) in)[i];
  return out;
}

int _memcmp(const void* s1, const void* s2, size_t n){
  for(size_t i=0;i<n;++i){
    if(((char *)s1)[i]!=((char *)s2)[i]){
      return (((char *)s1)[i])<(((char *)s2)[i]) ? -1 : 1;
    }

    if(((char *)s1)[i]=='\0'){
      return 0;
    }
  }
  return 0;
}

void _halt(int cond){
	ioram[0] = 0x03;
	ioram[1] = 0x04;

	if(cond){
		_printf("Hit Bad Trap\n");
		vram[0] = 0x001F; //C = 000000000011111 = R
	}else{
		_printf("Hit Good Trap\n");
		vram[0] = 0x03E0; //C = 000001111100000 = G
	}

	while(1);
}

