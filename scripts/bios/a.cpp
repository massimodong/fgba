#include<stdio.h>
#include<iostream>

int main(){
	unsigned int a;
	int cc=0;
	while(scanf("%x,", &a)!=EOF){
		printf("%x: %x;\n", cc++, a);
	}
}
