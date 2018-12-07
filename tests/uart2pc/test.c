volatile unsigned char * const ioram = (unsigned char *)0x04000000;

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

int main(){
	_putc('H');
	_putc('e');
	_putc('l');
	_putc('l');
	_putc('o');
	_putc(',');
	_putc(' ');
	_putc('W');
	_putc('o');
	_putc('r');
	_putc('l');
	_putc('d');
	_putc('\n');
	return 0;
}
