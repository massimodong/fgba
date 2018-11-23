#include<stdio.h>
#include<unistd.h>
#include<assert.h>
#include<iostream>

int main(int argc, char *argv[]){
	int width;
	FILE *f;
	unsigned int t;
	assert(argc == 3);

	sscanf(argv[1], "%d", &width);
	f = fopen(argv[2], "r");

	printf("WIDTH=%d;\n", width);

	unsigned int size;
	fseek(f, 0l, SEEK_END);
	size = ftell(f);
	size = (size + width - 1) / width;
	fseek(f, 0l, SEEK_SET);

	printf("DEPTH=%d;\n", size);

	printf("ADDRESS_RADIX=HEX;\nDATA_RADIX=HEX;\nCONTENT\nBEGIN\n");

	unsigned int x;
	for(x=0;x<size;++x){
		t=0;
		fread(&t, width, 1, f);
		printf("%X: %X;\n", x, t);
	}

	printf("END;\n");
}
