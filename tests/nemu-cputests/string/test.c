#include "trap.h"

char *s[] = {
	"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", 
	"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaab",
	"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
	", World!\n",
	"Hello, World!\n",
	"#####"
};

char str1[] = "Hello";
char str[20];

int main() {
	nemu_assert(_strcmp(s[0], s[2]) == 0);
	//_printf("step 1\n");
	nemu_assert(_strcmp(s[0], s[1]) == -1);
	//_printf("%d\n", _strcmp(s[0], s[1]));
	//_printf("step 2\n");
	//_printf("%d\n", _strcmp(s[0] + 1, s[1] + 1));
	nemu_assert(_strcmp(s[0] + 1, s[1] + 1) == -1);
	//_printf("step 3\n");
	nemu_assert(_strcmp(s[0] + 2, s[1] + 2) == -1);
	//_printf("step 4\n");
	nemu_assert(_strcmp(s[0] + 3, s[1] + 3) == -1);
	//_printf("step 5\n");

	nemu_assert(_strcmp( _strcat(_strcpy(str, str1), s[3]), s[4]) == 0);
	//_printf("step 6\n");

	nemu_assert(_memcmp(_memset(str, '#', 5), s[5], 5) == 0);
	//_printf("step 7\n");

	_halt(0);
	return 0;
}
