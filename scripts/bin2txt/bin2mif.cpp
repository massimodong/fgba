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

	unsigned int size;
	fseek(f, 0l, SEEK_END);
	size = ftell(f);
	size = (size + width - 1) / width;
	fseek(f, 0l, SEEK_SET);

	unsigned int x;
	for(x=0;x<size;++x){
		t=0;
		fread(&t, width, 1, f);
		printf("@%x %x\n", x, t);
	}
}
