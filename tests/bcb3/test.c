#include<stdint.h>
typedef uint16_t u16;
volatile unsigned char *ioram = (unsigned char *)0x04000000;
volatile u16* ScanlineCounter = (volatile u16*)0x4000006;
static u16* const paletteMem = (u16*)0x5000000;//PalMemory is 256 16 bit BGR values starting at 0x5000000
static u16* const FrontBuffer = (u16*)0x6000000;
static u16* const BackBuffer = (u16*)0x600A000;

u16* videoBuffer = BackBuffer;

volatile uint32_t * const intr_func = (uint32_t *)0x03007FFC;

void Flip(){
	if(videoBuffer == FrontBuffer){
		videoBuffer = BackBuffer;
		ioram[0] = 0x04;
	}else{
		videoBuffer = FrontBuffer;
		ioram[0] = 0x14;
	}
}

void WaitForVblank(void){
	while(1){
		u16 a = *ScanlineCounter;
		if(a >= 160) break;
	}
}

void setcolor(int x,int y,int p){
	int pos = ((y<<8) - (y<<4) + x),
	    addr = pos >> 1;

	if(pos & 1){
		videoBuffer[addr] = (videoBuffer[addr] & 0x00ff) | (p << 8);
	}else{
		videoBuffer[addr] = (videoBuffer[addr] & 0xff00) | p;
	}
}


int x=0,y=0,dx=1,dy=1;

void intr(){
	ioram[0x208] = 0; //IME
	int st = ~ioram[0x130];

	if(st & (1<<4)){ //Right
		dx=1;
	}else if(st & (1<<5)){ //Left
		dx=-1;
	}else if(st & (1<<6)){ //Up
		dy=-1;
	}else if(st & (1<<7)){ //Down
		dy=1;
	}

	((uint16_t *)ioram)[0x202>>1] = 1<<12;
	ioram[0x208] = 1; //IME
}

int main(){
	ioram[0] = 4;
	ioram[1] = 4;
	ioram[0x208] = 1; //IME
	((uint16_t *)ioram)[0x200>>1] = 1<<12; //IE
	ioram[0x132] = 0xff;
	ioram[0x133] = 0x43;
	//setio(0, 0x403);
	paletteMem[0]=0x7fff;
	paletteMem[1]=0x7dad;
	*intr_func = (uint32_t)intr;

	for(int i=0;i<160;++i) for(int j=0;j<240;++j) setcolor(j, i, 0);
	Flip();
	for(int i=0;i<160;++i) for(int j=0;j<240;++j) setcolor(j, i, 0);

	for(int i=0;i<10;++i) for(int j=0;j<10;++j) setcolor(j, i, 1);

	ioram[0x102] = 0x83;
	//setio(0x100, 0x830000);

	int last=0;
	while(1){
		if(last == (ioram[0x101] & 0xff)){
			continue;
		}
		last = (ioram[0x101] & 0xff);

		x+=dx;
		y+=dy;

		if(x==0 || x==230) dx=-dx;
		if(y==0 || y==150) dy=-dy;

		for(int i=-2;i<12;++i) for(int j=-2;j<12;++j){
			if((0 <= x+j) && (x+j < 240) && (0 <= y+i) && (y+i < 160)) setcolor(x+j, y+i, 0);
		}

		for(int i=0;i<10;++i) for(int j=0;j<10;++j) setcolor(x+j, y+i, 1);
		WaitForVblank();
		Flip();
	}

	return 0;
}
