#include<stdio.h>
#include<unistd.h>
#include<fcntl.h>
#include<assert.h>
#include<termios.h>

int main(int argc, char *argv[]){
	assert(argc >= 2);
	int fd = open(argv[1], O_RDWR | O_NOCTTY | O_NDELAY);
	assert(fd != -1);

	fcntl(fd, F_SETFL, 0);

	struct termios options;
	tcgetattr(fd, &options);

	cfsetispeed(&options, B115200);
	cfsetospeed(&options, B115200);
	options.c_cflag |= (CLOCAL | CREAD);


	options.c_cflag &= ~PARENB;
	options.c_cflag &= ~CSTOPB;
	options.c_cflag &= ~CSIZE;
	options.c_cflag |= CS8;

	options.c_cflag &= ~CRTSCTS;

	options.c_lflag &= ~(ICANON | ECHO | ECHOE | ISIG);

	tcsetattr(fd, TCSANOW, &options);

	unsigned char checksum = 0, checkxor = 0;


	if(argc >= 3){
		FILE *f = fopen(argv[2], "r");
		while(!feof(f)){
			unsigned char v;
			fread(&v, sizeof(unsigned char), 1, f);
			write(fd, &v, 1);
			checksum += v;
			checkxor ^= v;
		}
	}else{
		printf("listening...\n");
		char c;
		while(1){
			read(fd, &c, 1);
			putchar(c);
		}
	}

	int cs = checksum,
	    cx = checkxor;
	printf("checksum: %x\ncheckxor: %x\n", cs, cx);

	close(fd);
}
