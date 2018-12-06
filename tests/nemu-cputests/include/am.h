void setcolor(int x,int y,int r,int g,int b){
	volatile unsigned short * const vram = (unsigned short *)0x06000000;

	short color = r + (g<<5) + (b<<10);

	vram[(y<<8) - (y<<4) + x] = color;
}

void _halt(int cond){
	volatile unsigned char *ioram = (unsigned char *)0x04000000;
	ioram[0] = 0x03;
	ioram[1] = 0x04;

	volatile unsigned short *vram = (unsigned short *)0x06000000;

	if(cond){
		vram[0] = 0x001F; //C = 000000000011111 = R
	}else{
		vram[0] = 0x03E0; //C = 000001111100000 = G
	}

	while(1);
}
