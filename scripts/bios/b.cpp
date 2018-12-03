#include<stdio.h>
#include<iostream>

int main(){
	FILE *f = fopen("bios.b", "w");
	unsigned int a;
	while(scanf("%x,", &a)!=EOF){
		fwrite(&a, sizeof(unsigned int), 1, f);
	}
}
