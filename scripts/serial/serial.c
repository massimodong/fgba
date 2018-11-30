#include<stdio.h>
#include<fcntl.h>
#include<assert.h>

int main(int argc, char *argv[]){
	assert(argc >= 2);
	int fd = open(argv[1], O_RDWR | O_NOCTTY | O_NDELAY);
}
