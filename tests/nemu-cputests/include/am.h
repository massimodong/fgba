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

void _halt(int cond){
	ioram[0] = 0x03;
	ioram[1] = 0x04;

	if(cond){
		vram[0] = 0x001F; //C = 000000000011111 = R
	}else{
		vram[0] = 0x03E0; //C = 000001111100000 = G
	}

	while(1);
}
