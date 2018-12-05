void setcolor(int x,int y,int r,int g,int b){
	volatile unsigned short * const vram = (unsigned short *)0x06000000;

	short color = r + (g<<5) + (b<<10);

	vram[(y<<8) - (y<<4) + x] = color;
}

int main(){
	volatile unsigned char *ioram = (unsigned char *)0x04000000;
	ioram[0] = 3;
	ioram[1] = 4;
	//setio(0, 0x403);

	for(int i=0;i<160;++i) for(int j=0;j<240;++j) setcolor(j, i, 31,31,31);

	int x=0,y=0,dx=1,dy=1;
	for(int i=0;i<10;++i) for(int j=0;j<10;++j) setcolor(j, i, 13, 13, 31);

	ioram[0x102] = 0x83;
	//setio(0x100, 0x830000);

	int last=0;
	while(1){
		if(last == (ioram[0x101] & 0xfc)){
			continue;
		}
		last = (ioram[0x101] & 0xfc);

		x+=dx;
		y+=dy;

		if(x==0 || x==230) dx=-dx;
		if(y==0 || y==150) dy=-dy;

		for(int i=0;i<10;++i) for(int j=0;j<10;++j) setcolor(x+j, y+i, 13, 13, 31);
	}

	return 0;
}
